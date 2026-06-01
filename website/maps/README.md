
convert to cog in epsg:3857
```
gdalwarp -t_srs EPSG:3857 -r bilinear -co COMPRESS=LZW -co BIGTIFF=IF_SAFER SOC_Kenya.tif SOC_Kenya_cog.tif -of cog
gdalwarp -t_srs EPSG:3857 -r bilinear -co COMPRESS=LZW -co BIGTIFF=IF_SAFER soilPH_Kenya.tif soilPH_Kenya_cog.tif -of cog
gdalwarp -t_srs EPSG:3857 -r bilinear -co COMPRESS=LZW -co BIGTIFF=IF_SAFER soilPhosphorus_Kenya.tif soilPhosphorus_Kenya_cog.tif -of cog
gdalwarp -t_srs EPSG:3857 -r bilinear -co COMPRESS=LZW -co BIGTIFF=IF_SAFER soilPotassium_Kenya.tif soilPotassium_Kenya_cog.tif -of cog
gdalwarp -t_srs EPSG:3857 -r bilinear -co COMPRESS=LZW -co BIGTIFF=IF_SAFER soilZinc_Kenya.tif soilZinc_Kenya_cog.tif -of cog
```

get bounds and min/max
```
gdalinfo -mm SOC_Kenya_cog.tif
```
