
convert to cog in epsg:3857
```
gdalwarp -t_srs EPSG:3857 -r bilinear -co TILED=YES -co COMPRESS=LZW -co BIGTIFF=IF_SAFER \
  -co COPY_SRC_OVERVIEWS=YES -co COG=YES soilPH_Kenya_Kenya.tif soilPH_Kenya_cog.tif
```

get bounds and min/max
```
gdalinfo -mm SOC_Kenya_cog.tif
```
