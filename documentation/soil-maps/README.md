# Soil maps

A [Soil maps](https://en.wikipedia.org/wiki/Soil_map) is a geographical representation showing diversity of soil types or soil properties (soil pH, textures, organic matter, depths of horizons etc.) in the area of interest. It is typically the result of a soil survey as well as predictions of distribution of soil properties between sampling locations. Soil maps are typically the main product of a SIS. As soil surveyers we are often focussed on sampling and laboratory analysis, but we should keep in mind that our main audience consumes our data via soil maps.

Two approaches are common to poduce soil maps:
- Soil surveyers draw a boundary between two areas where they expect soil properties to be similar. The sampling locations are selected to identify these boundaries. The resulting map is typically a vector polygon dataset.
- Spatial statistics and other spatial and machine learning algorythms are increasingly used to predit the disctirbution of soil properties from point observation data in combination with co-variates, such as Digital Elevation Model, Earth Imagery, Geology. The resulting map is typically a grid (GeoTiff) dataset, and is typically combined with an uncertainty band.

Soil maps are typically made available through repositories, with relevant metadata. When referencing the map from the SIS, aim to reference the relevant source location and metadata. In some cases the data file needs to be optimised for consumption, prior to being added.

When producing a map, keep the metadata in a sidecar file. Also reference any source data which is used for map production.


