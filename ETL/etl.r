#!/usr/bin/env Rscript
#
# import_soil_csvs_to_postgres.R
#
# Usage (example):
# Rscript import_soil_csvs_to_postgres.R \
#   --data_dir /path/to/csvs \
#   --pg_host db.example.org --pg_port 5432 --pg_db mydb --pg_user me --pg_password secret \
#   --schema public
#
# Requires: DBI, RPostgres, readr, dplyr, tidyr, stringr, glue, optparse, jsonlite
#

suppressPackageStartupMessages({
  library(DBI)
  library(RPostgres)
  library(readr)
  library(dplyr)
  library(tidyr)
  library(stringr)
  library(glue)
  library(optparse)
  library(jsonlite)
})

option_list <- list(
  make_option(c("-d", "--data_dir"), type="character", default=".",
              help="Directory containing data .csv files and metadata files", metavar="dir"),
  make_option(c("--pg_host"), type="character", default="localhost", help="Postgres host"),
  make_option(c("--pg_port"), type="integer", default=5432, help="Postgres port"),
  make_option(c("--pg_db"), type="character", default="soil_db", help="Postgres database name"),
  make_option(c("--pg_user"), type="character", default=NULL, help="Postgres user"),
  make_option(c("--pg_password"), type="character", default=NULL, help="Postgres password"),
  make_option(c("--schema"), type="character", default="public", help="Postgres schema to use"),
  make_option(c("-v", "--verbose"), action="store_true", default=FALSE, help="Verbose output")
)
opt <- parse_args(OptionParser(option_list = option_list))

data_dir <- opt$data_dir
pg_host <- opt$pg_host
pg_port <- opt$pg_port
pg_db <- opt$pg_db
pg_user <- opt$pg_user
pg_password <- opt$pg_password
pg_schema <- opt$schema
verbose <- opt$verbose

vcat <- function(...) if (verbose) cat(..., "\n")

# ---- Create / ensure schema-qualified identifier ----
q <- function(x) DBI::dbQuoteIdentifier(conn, Id(schema = pg_schema, table = x))

# ----- DB schema creation (Postgres) -----
create_tables <- function(conn) {
  # create schema if not exists
  dbExecute(conn, glue("CREATE SCHEMA IF NOT EXISTS {DBI::dbQuoteIdentifier(conn, pg_schema)};"))

  # locations
  dbExecute(conn, glue("
    CREATE TABLE IF NOT EXISTS {q('locations')} (
      location_id TEXT PRIMARY KEY,
      label TEXT,
      latitude DOUBLE PRECISION,
      longitude DOUBLE PRECISION,
      extra JSONB,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
    );"))

  # samples
  dbExecute(conn, glue("
    CREATE TABLE IF NOT EXISTS {q('samples')} (
      sample_id TEXT PRIMARY KEY,
      location_id TEXT REFERENCES {q('locations')}(location_id) ON DELETE SET NULL,
      sample_label TEXT,
      sample_date TIMESTAMP WITH TIME ZONE,
      depth DOUBLE PRECISION,
      extra JSONB,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
    );"))

  # observations: store method & unit here
  dbExecute(conn, glue("
    CREATE TABLE IF NOT EXISTS {q('observations')} (
      observation_id BIGSERIAL PRIMARY KEY,
      sample_id TEXT REFERENCES {q('samples')}(sample_id) ON DELETE CASCADE,
      location_id TEXT REFERENCES {q('locations')}(location_id) ON DELETE CASCADE,
      parameter TEXT NOT NULL,
      value DOUBLE PRECISION,
      unit TEXT,
      method TEXT,            -- method/procedure used to produce/measure the value
      recorded_as TEXT,       -- original column name or raw recorded value
      extra JSONB,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
    );"))

  dbExecute(conn, glue("CREATE INDEX IF NOT EXISTS {pg_schema}_obs_sample_idx ON {q('observations')}(sample_id);"))
  dbExecute(conn, glue("CREATE INDEX IF NOT EXISTS {pg_schema}_obs_param_idx ON {q('observations')}(parameter);"))
  dbExecute(conn, glue("CREATE INDEX IF NOT EXISTS {pg_schema}_samples_loc_idx ON {q('samples')}(location_id);"))
}

# ----- helper: read metadata -----
read_metadata_file <- function(data_csv_path) {
  meta_path <- file.path(dirname(data_csv_path),
                         paste0(tools::file_path_sans_ext(basename(data_csv_path)), "-metadata.csv"))
  if (!file.exists(meta_path)) {
    vcat("No metadata file found for", basename(data_csv_path), "- will attempt to infer roles.")
    return(NULL)
  }
  vcat("Reading metadata:", meta_path)
  md <- read_csv(meta_path, show_col_types = FALSE)
  if (!"colname" %in% names(md) || !"role" %in% names(md)) {
    stop(glue("Metadata file {meta_path} must contain at least 'colname' and 'role' columns"))
  }
  # Accept optional 'unit' and 'method' and 'type'
  md <- md %>%
    mutate(colname = as.character(colname),
           role = tolower(as.character(role)),
           unit = if ("unit" %in% names(md)) as.character(unit) else NA_character_,
           method = if ("method" %in% names(md)) as.character(method) else NA_character_,
           type = if ("type" %in% names(md)) as.character(type) else NA_character_) %>%
    select(colname, role, unit, method, type, everything())
  return(md)
}

# ----- heuristics to infer roles if metadata is missing -----
infer_roles <- function(df) {
  cols <- names(df)
  role_df <- data.frame(colname = cols, role = NA_character_, stringsAsFactors = FALSE)

  loc_patterns <- c("^location", "^loc_", "longitude", "longitude$", "^lon$", "^lat", "latitude", "gps", "easting", "northing")
  sample_patterns <- c("sample", "^id$", "sample_id", "id$", "label", "date", "depth", "plot")
  for (i in seq_along(cols)) {
    cn <- tolower(cols[i])
    if (any(sapply(loc_patterns, function(p) grepl(p, cn)))) {
      role_df$role[i] <- "location"
    } else if (any(sapply(sample_patterns, function(p) grepl(p, cn)))) {
      role_df$role[i] <- "sample"
    } else {
      # numeric-like columns are parameters
      # try to coerce a few values
      vals <- na.omit(as.character(df[[cols[i]]]))
      numeric_like <- FALSE
      if (length(vals) > 0) {
        numeric_like <- all(!is.na(suppressWarnings(as.numeric(vals[1:min(length(vals), 20)]))))
      }
      if (numeric_like) {
        role_df$role[i] <- "parameter"
      } else {
        role_df$role[i] <- "sample"
      }
    }
  }
  return(role_df)
}

# ----- upsert location using INSERT ... ON CONFLICT -----
upsert_location <- function(conn, loc_id, label = NA_character_, lat = NA_real_, lon = NA_real_, extras = list()) {
  extra_json <- if (length(extras) == 0) NA else toJSON(extras, auto_unbox = TRUE)
  sql <- glue("
    INSERT INTO {q('locations')}(location_id, label, latitude, longitude, extra)
    VALUES (?, ?, ?, ?, ?)
    ON CONFLICT (location_id)
    DO UPDATE SET
      label = COALESCE(EXCLUDED.label, {q('locations')}.label),
      latitude = COALESCE(EXCLUDED.latitude, {q('locations')}.latitude),
      longitude = COALESCE(EXCLUDED.longitude, {q('locations')}.longitude),
      extra = COALESCE({q('locations')}.extra, EXCLUDED.extra)
  ;")
  dbExecute(conn, sql, params = list(loc_id, label, lat, lon, extra_json))
  vcat("Upserted location:", loc_id)
}

# ----- upsert sample -----
upsert_sample <- function(conn, sample_id, location_id = NA_character_, sample_label = NA, sample_date = NA_character_, depth = NA_real_, extras = list()) {
  extra_json <- if (length(extras) == 0) NA else toJSON(extras, auto_unbox = TRUE)
  # try to parse sample_date to ISO if provided
  sample_date_parsed <- if (!is.na(sample_date) && nzchar(sample_date)) { sample_date } else NA
  sql <- glue("
    INSERT INTO {q('samples')}(sample_id, location_id, sample_label, sample_date, depth, extra)
    VALUES (?, ?, ?, ?, ?, ?)
    ON CONFLICT (sample_id)
    DO UPDATE SET
      location_id = COALESCE(EXCLUDED.location_id, {q('samples')}.location_id),
      sample_label = COALESCE(EXCLUDED.sample_label, {q('samples')}.sample_label),
      sample_date = COALESCE(EXCLUDED.sample_date, {q('samples')}.sample_date),
      depth = COALESCE(EXCLUDED.depth, {q('samples')}.depth),
      extra = COALESCE({q('samples')}.extra, EXCLUDED.extra)
  ;")
  dbExecute(conn, sql, params = list(sample_id, location_id, sample_label, sample_date_parsed, depth, extra_json))
  vcat("Upserted sample:", sample_id)
}

# ----- insert observations in batch -----
insert_observations <- function(conn, obs_df) {
  if (nrow(obs_df) == 0) return()
  # For performance use dbWriteTable to a temp table, then INSERT ... SELECT to target (safer than looping)
  temp_tbl <- paste0("tmp_obs_", as.integer(runif(1, 1e6, 9e6)))
  dbWriteTable(conn, Id(schema = pg_schema, table = temp_tbl), obs_df, temporary = TRUE, overwrite = TRUE)
  sql <- glue("
    INSERT INTO {q('observations')}(sample_id, location_id, parameter, value, unit, method, recorded_as, extra)
    SELECT sample_id, location_id, parameter, value, unit, method, recorded_as, extra
    FROM {DBI::dbQuoteIdentifier(conn, Id(schema = pg_schema, table = temp_tbl))}
  ;")
  dbExecute(conn, sql)
  # temp table will be dropped at end of session automatically
  vcat("Inserted", nrow(obs_df), "observations (via temp table).")
}

# ----- process single CSV -----
process_csv <- function(conn, csv_path) {
  vcat("Processing:", csv_path)
  df <- read_csv(csv_path, show_col_types = FALSE)
  md <- read_metadata_file(csv_path)

  if (is.null(md)) {
    role_df <- infer_roles(df)
    md <- data.frame(colname = role_df$colname,
                     role = role_df$role,
                     unit = NA_character_,
                     method = NA_character_,
                     type = NA_character_,
                     stringsAsFactors = FALSE)
  } else {
    # Ensure metadata contains an entry for each df col
    missing_cols <- setdiff(names(df), md$colname)
    if (length(missing_cols) > 0) {
      vcat("Metadata missing entries for columns:", paste(missing_cols, collapse = ", "))
      inferred <- infer_roles(df %>% select(all_of(missing_cols)))
      md <- bind_rows(md, data.frame(colname = inferred$colname, role = inferred$role,
                                     unit = NA_character_, method = NA_character_, type = NA_character_, stringsAsFactors = FALSE))
    }
  }

  # Normalize
  md <- md %>% mutate(colname = as.character(colname), role = tolower(role), unit = ifelse(is.na(unit), NA, unit),
                      method = ifelse(is.na(method), NA, method))

  # Identify key columns
  sample_id_col <- md %>% filter(role == "sample" & str_detect(tolower(colname), "id")) %>% pull(colname) %>% .[1]
  location_id_col <- md %>% filter(role == "location" & str_detect(tolower(colname), "id")) %>% pull(colname) %>% .[1]
  param_cols <- md %>% filter(role == "parameter") %>% pull(colname)

  # Create synthetic sample id if missing
  if (is.na(sample_id_col) || length(sample_id_col) == 0) {
    vcat("No sample id column found - creating synthetic sample_id using filename + row number")
    df <- df %>% mutate(.sample_id = paste0(tools::file_path_sans_ext(basename(csv_path)), "_r", row_number()))
    sample_id_col <- ".sample_id"
  }
  if (is.na(location_id_col) || length(location_id_col) == 0) {
    loc_label_col <- md %>% filter(role == "location" & str_detect(tolower(colname), "label|name")) %>% pull(colname) %>% .[1]
    if (!is.na(loc_label_col) && loc_label_col %in% names(df)) {
      df <- df %>% mutate(.location_id = as.character(.data[[loc_label_col]]))
      location_id_col <- ".location_id"
    } else {
      vcat("No location id/label found - creating synthetic location id per sample")
      df <- df %>% mutate(.location_id = paste0(tools::file_path_sans_ext(basename(csv_path)), "_loc_r", row_number()))
      location_id_col <- ".location_id"
    }
  }

  # lat/lon optional
  lat_col <- md %>% filter(role == "location" & str_detect(tolower(colname), "lat")) %>% pull(colname) %>% .[1]
  lon_col <- md %>% filter(role == "location" & str_detect(tolower(colname), "lon|long")) %>% pull(colname) %>% .[1]

  # sample-level extras
  sample_label_col <- md %>% filter(role == "sample" & str_detect(tolower(colname), "label|name")) %>% pull(colname) %>% .[1]
  sample_date_col <- md %>% filter(role == "sample" & str_detect(tolower(colname), "date")) %>% pull(colname) %>% .[1]
  depth_col <- md %>% filter(role == "sample" & str_detect(tolower(colname), "depth")) %>% pull(colname) %>% .[1]

  # Build unique locations and upsert
  loc_cols_all <- md %>% filter(role == "location") %>% pull(colname)
  if (!location_id_col %in% names(df)) stop("Computed location_id column not found in df")
  loc_df <- df %>%
    transmute(location_id = as.character(.data[[location_id_col]])) %>%
    distinct()

  for (i in seq_len(nrow(loc_df))) {
    lid <- loc_df$location_id[i]
    row_sample <- df %>% filter(.data[[location_id_col]] == lid) %>% slice(1)
    lat_val <- if (!is.na(lat_col) && lat_col %in% names(row_sample)) as.numeric(row_sample[[lat_col]]) else NA_real_
    lon_val <- if (!is.na(lon_col) && lon_col %in% names(row_sample)) as.numeric(row_sample[[lon_col]]) else NA_real_
    label_val <- if (!is.na(sample_label_col) && sample_label_col %in% names(row_sample)) as.character(row_sample[[sample_label_col]]) else as.character(lid)

    extras <- list()
    for (ec in setdiff(loc_cols_all, c(location_id_col, lat_col, lon_col))) {
      if (ec %in% names(row_sample)) extras[[ec]] <- row_sample[[ec]]
    }
    upsert_location(conn, lid, label_val, lat_val, lon_val, extras)
  }

  # Samples upsert
  samples_to_insert <- df %>%
    transmute(
      sample_id = as.character(.data[[sample_id_col]]),
      location_id = as.character(.data[[location_id_col]]),
      sample_label = if (!is.na(sample_label_col) && sample_label_col %in% names(df)) as.character(.data[[sample_label_col]]) else NA_character_,
      sample_date = if (!is.na(sample_date_col) && sample_date_col %in% names(df)) as.character(.data[[sample_date_col]]) else NA_character_,
      depth = if (!is.na(depth_col) && depth_col %in% names(df)) as.numeric(.data[[depth_col]])
    ) %>% distinct(sample_id, .keep_all = TRUE)

  for (i in seq_len(nrow(samples_to_insert))) {
    r <- samples_to_insert[i,]
    upsert_sample(conn, r$sample_id, r$location_id, r$sample_label, r$sample_date, r$depth, extras = list())
  }

  # Observations: pivot parameter columns
  if (length(param_cols) == 0) {
    vcat("No parameter columns found for", basename(csv_path))
    return(invisible(NULL))
  }

  obs_long <- df %>%
    select(all_of(c(sample_id_col, location_id_col, param_cols))) %>%
    pivot_longer(cols = all_of(param_cols), names_to = "parameter", values_to = "value") %>%
    mutate(
      sample_id = as.character(.data[[sample_id_col]]),
      location_id = as.character(.data[[location_id_col]]),
      value = as.numeric(value),
      unit = NA_character_,
      method = NA_character_,
      recorded_as = parameter,
      extra = NA
    ) %>%
    select(sample_id, location_id, parameter, value, unit, method, recorded_as, extra) %>%
    filter(!is.na(value))

  # attach units & methods from metadata if available
  param_meta <- md %>% filter(role == "parameter") %>% select(colname, unit, method)
  if (nrow(param_meta) > 0) {
    obs_long <- obs_long %>% left_join(param_meta, by = c("parameter" = "colname")) %>%
      mutate(unit = coalesce(unit.y, unit.x),
             method = coalesce(method.y, method.x)) %>%
      select(sample_id, location_id, parameter, value, unit, method, recorded_as, extra)
  }

  # bulk insert
  insert_observations(conn, obs_long)
}

# ----- MAIN -----
csv_files <- list.files(path = data_dir, pattern = "\\.csv$", full.names = TRUE)
csv_files <- csv_files[!grepl("-metadata\\.csv$", csv_files, ignore.case = TRUE)]

if (length(csv_files) == 0) {
  stop("No CSV files found in directory: ", data_dir)
}

vcat("Found CSV files:", paste(basename(csv_files), collapse = ", "))

# Open Postgres connection
conn <- dbConnect(RPostgres::Postgres(),
                  host = pg_host, port = pg_port, dbname = pg_db,
                  user = pg_user, password = pg_password)
on.exit(dbDisconnect(conn), add = TRUE)

create_tables(conn)

for (f in csv_files) {
  tryCatch({
    process_csv(conn, f)
  }, error = function(e) {
    message("Error processing ", f, ": ", e$message)
  })
}

vcat("Done. Data imported into Postgres database '", pg_db, "' schema '", pg_schema, "'.", sep = "")
