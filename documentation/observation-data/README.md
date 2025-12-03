# Soil observation data 

This topic describes a data modelling options to store or exchange soil observation data, which is suggested for KenSIS

## Why is it important?

Adopting one of the models/conventions below for your (research) data has three benefits.

- The models assist in identifying what aspects are typically captured on an observation: which `property` is observed, how can you reference the `feature of interest`, which `unit of measure` is used, which `procedure` is used, when and by who has the observation been made. (For some soil properties the selected procedure effects the result or uncertainty substantially).
- When encoded following the above information in standardised ways, other users (humans and machines) can easily locate and understand the information
- Various software tools are available which support workflows on standardised observation data, such as conversion tools, validation tools, visualisation tools. So you don't need to write custom software or data models.

## Approach

A common factor in these approaches is that metadata (which property, which unit of measure, which procedure) is captured in a seperate metadata file which is connected to the data file. Notice that this approach requires that the procedure and unit are constant in the column. Data from different campaigns with different procedures can not be combined in a single file.

Notice that all these initiatives benefit from established vocabularies for soil properties and observation procedures, such as the vocabularies provided by [Australian National SIS](https://vocabs.ardc.edu.au/viewById/634)

## Background

The approach assumes soil observation data in 1 or 2 related tables

Location

ID | Label | X | Y
--- | --- | --- | ---
uae438 | 10m from street | 2.35 | 50.35 
fte218 | 30m bhind barn | 2.45 | 51.15

Horizon / Sample

Profile | Label | Upper | Lower | Date | N | P | K 
--- | --- | --- | --- | --- | --- | --- | --- 
uae438 | O | 0 | 10 | 2025-10-04 | 0.3 | 0.01 | 0.01
uae438 | A | 10 | 30 | 2025-10-04 | 0.1 | 0.01 | 0.01

## Approach

This approach suggests for each considered Soil data file, to create a second CSV file, {name}-metadata.csv, which contains machine readible column metadata. It is a tailored CSV format, every row on the table describes a column of a dataset. Notice that typical dataset metadata (title, abstract, ...) is stored in a separate file (for example using the [MCF appraoch]()). The soil files with their sidecar metadata files are stored together in a file repository, where it can be picked up by selected tooling.

table | column | title | type | property | unit | procedure
--- | --- | --- | --- | --- | --- | ---
obs.csv | N | Nitrogen | numeric | Nitrogen | mole/kg | TotalN_dc
obs.csv | Profile | Profile | loc.csv#ID | | |
loc.csv | ID | Identifier | string | | |
loc.csv | Label | Label | String | | |

Notice that this approach requires CSV files to originate from a single campaign, where a single set of observations is done using a single procedure. To combine multiple CSV's from multiple campaigns in a database, is described in the next section.

## Data standardisation

The approach above captures enough information to facilitate a number of standardisation wokflows. In this step each observed value in a column is typically converted to a single row, referencing the relavant observed property, the unit of measure and the procedure. The following standardisation options are available

- Convert the metadata files to [datapackage+tableschema](https://datapackage.org/standard/table-schema/) or [iso19110](https://www.iso.org/standard/57303.html) which are recognised conventions for feature catalogue metadata 
- [CSVW](https://csvw.org) is an approach to convert CSV data to RDF. RDF data can be encoded as schema.org or [SSN/SOSA](https://www.w3.org/TR/vocab-ssn/).
- GSP and ISRIC are endorsing a [soil datamodel in PostGres](https://github.com/FAO-SID/GloSIS/tree/main/glosis-db) which is able to store soil observation data according to the [iso28258](https://www.iso.org/standard/44595.html) standard. Tooling is available which can convert the annotated CSV to this database model.
