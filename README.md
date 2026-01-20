# KENSIS

KENSIS is a Soil Information System of the Kenya Soil Survey, which is part of [KALRO](https://kalro.org). The SIS
is under active development. An initial release is expected in Q3 2026.

This repository maintains the sourcecode, configuration and documentation of the Soil Information System. 
View the SIS online at [KALRO-ICT.github.io/kensis](https://KALRO-ICT.github.io/KENSIS).

The following components can be distinguished:

- Content Management of the SIS website
- A PostGres Database
- An ETL workflow to harmonize soil observation data from various campaigns
- Various modelling efforts to predict the distribution of soil properties (Digital Soil Mapping)
- A Mapserver instance which provides convenience API's to the database and Tiff files
- A Terria-JS instance which provides interactive viewing of the datasets
