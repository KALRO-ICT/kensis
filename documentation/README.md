# Server setup

## Overview of the SIS

```mermaid
flowchart TD
    RE[/Repo of Soildata\] -->|ETL| DB[(SIS database)]
    DB -->|R-Bridge| MM{{Modelling and mapping}}
    MM -->|Soil maps| WW([SIS frontend])
    DB -->|Sampling data| WW
```

## Getting started

Besided various scripts to manage the SIS backend, this repository also contains the content of the SIS frontend website. 
So you can [clone this repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository) to your github organisation, update the [configuration](../website/_quarto.yml) and your SIS will be online instantly (on the github infrastructure).

## Contents of this documentation

The SIS has various components:
- Repository of [Soil Observation data](./observation-data/) 
- [ETL](./ETL) scripts
- a [postgres](./postgres/) database server 
- Modelling of [Soil maps](./soil-maps/)
- The frontend [website](./cms/)

Optional:
- a [mapserver](./mapserver/) instance providing access to various data files 
- a [pycsw](./pycsw) catalogue tocategorise reports, maps and datasets
- a [terria-js](./terriajs/) instance for advanced map viewing options
