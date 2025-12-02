
# Mapserver component

[mapsever](mapserver.org) is a component which can give access to spatial formats (geotiff, database) in various OGC standard API's such as WMS, WFS, WCS, OGCAPI-features


## Install mapserver in ubuntu

```
sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable
sudo apt-get update
sudo apt-get install cgi-mapserver
``
##  Configuration

Configuration is stored in [mapserver.config](mapserver.config). Access to various data files is configured in [mapfiles](./mapfiles/)
