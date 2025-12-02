
# Mapserver component

[mapsever](https://mapserver.org) is a component which can give access to spatial formats (geotiff, database) in various OGC standard API's such as WMS, WFS, WCS, OGCAPI-features

Mapserver version 8.6 is used

## Install mapserver in ubuntu

```
sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable
sudo apt-get update
sudo apt-get install cgi-mapserver
```

##  Configuration

Configuration (including aliases to map files) is stored in [mapserver.config](mapserver.config). 
Access to various data files is configured in [map files](./mapfiles/)
Map services are available via <example.com/ows/{alias}?service=WMS&request=GetCapabilities>

In order for mapserver to access the tiff files, the tiff files should be uploaded to the server, a webdav service could provide this functionality.