---
title: "Data Section Kenya Soil Survey"
format: html
page-layout: full
---

The Kenya Soil Survey (KSS) provides soil data collected through rigorous field work, laboratory analysis, and spatial modelling.  
This page explains how soil data are typically acquired, how soil properties are predicted and converted into maps, and how you can best explore the datasets available on this site.

---

## 1. How Soil Data Are Collected

### Field Surveys
Soil data collection starts with **structured field campaigns** conducted across diverse landscapes in Kenya.

Typical activities include:
- **Site selection** using stratified sampling, transects, or grid-based designs  
- **Soil profile description**, including horizons, structure, colour, texture, and root distribution  
- **Auger observations** collected at dense sampling intervals  
- **Geolocation** using GPS/GNSS equipment  
- **Land use and vegetation notes**  
- **Field photographs** and sketches  

Field teams follow standardized KSS procedures to ensure consistency and reproducibility.

### Laboratory Analysis
Samples collected in the field are analysed in accredited laboratories to determine:

- Soil pH  
- Organic carbon and organic matter  
- Nitrogen, phosphorus, potassium  
- Cation exchange capacity (CEC)  
- Texture (sand, silt, clay)  
- Micronutrients (Fe, Mn, Cu, Zn)  
- Bulk density  
- Mineralogical characteristics (where applicable)

Analytical methods align with national and international standards (FAO, USDA, ISO).

---

## 2. From Points to Maps: Predicting Soil Properties in Space

Raw field and laboratory data represent point observations—specific measurements taken at specific locations.  
To create **continuous soil maps**, KSS uses **predictive soil mapping** (also known as digital soil mapping).

###  Environmental Covariates
Spatial predictors are assembled from multiple sources, including:

- Satellite imagery (e.g., vegetation indices, surface reflectance)  
- Climate surfaces (rainfall, temperature)  
- Terrain attributes (slope, curvature, elevation, topographic index)  
- Geological and parent material maps  
- Land cover and land use layers  

These covariates help explain how soils vary across the landscape.

###  Predictive Modelling
Common modelling approaches include:

- Random forest and gradient boosting models  
- Generalized additive models  
- Machine learning ensemble approaches  
- Geostatistical methods (e.g., regression-kriging)  
- Hybrid models combining machine learning and spatial interpolation  

Models generate **predictions** and **uncertainty layers**, enabling users to understand confidence levels in each mapped product.

###  Map Production
The output maps include:

- Soil property rasters at standard resolutions  
- Soil class maps based on classification systems (e.g., WRB, USDA)  
- Soil health indicator maps  
- Derived suitability layers (e.g., crop suitability, erosion risk)  

Each map includes metadata detailing:

- Data sources  
- Methods  
- Units  
- Accuracy statistics  
- Date of production  


## 3. How to Explore the Data

### Browsing the Dataset Library
You can explore datasets by visiting the **Data** or **Downloads** sections of this website.  
Each dataset includes:
- A description of its purpose  
- Links to download raw or processed formats  
- Metadata summaries  
- Recommended software and tools for use  

### Exploring Maps Interactively
Many soil maps can be viewed using interactive map tools integrated into this site or external GIS tools such as:

- QGIS  
- ArcGIS  
- Google Earth Engine  
- Web map viewers (Leaflet / Mapbox-based)

Interactive functions allow you to:
- Zoom to your region of interest  
- Click to view predicted values  
- Overlay multiple soil layers  
- Download map tiles or full-resolution rasters 
 
### Using Data for Decision-Making
The soil datasets support many applications, including:

- Agricultural planning and crop suitability  
- Land restoration and conservation design  
- National and county-level environmental reporting  
- Academic research and modelling  
- Soil health monitoring  

KSS encourages users to consult the accompanying documentation to correctly interpret data and understand limitations.

## Learn More

To understand sampling guidelines, laboratory standards, or modelling workflows, visit the **Documentation** section.  
For recent field campaign summaries, see [Publications](./publications.md).


