## Sol Represa
# Objective: Open VIIRS - VNP46A1 product
# 23/10/2020 - La Plata, Argentina



library(gdalUtils)
library(raster)
library(rgdal)
#library(R.utils)
#library(maptools)


setwd("C:\\Users\\solre\\Desktop\\S5P")
filename = "C:\\Users\\solre\\Desktop\\S5P\\VNP46A1.A2020253.h12v12.001.2020254080958.h5"


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# CORROBORAR:
# gdal_setInstallation(verbose=TRUE) # ver version gdal
# getOption("gdalUtils_gdalPath")  #verificar que podamos abrir HDF5
# gdal_chooseInstallation(hasDrivers="HDF5")

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 


## Inspect hdf5

info <-  gdalinfo(filename)
# info[4]  # [4] "Coordinate System is `'"  

#info[207]  #Long Name
info[43]
crs_viirs = '+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +R=6371007.181 +units=latlon +no_defs'





## Open hdf5
sds <- get_subdatasets(filename)

gdal_translate(sds[5], dst_dataset = filename)


VIIRS_raster <- raster(filename, crs = crs_viirs)


# NA 
NAvalue(VIIRS_raster) <- 65535

# Extention
xmax =  as.numeric(substr(info[183], nchar(info[183])-3,nchar(info[183])-1)) #EastBoundingCoord
ymax = as.numeric(substr(info[191], nchar(info[191])-3,nchar(info[191])-1)) #NorthBoundingCoord
ymin = as.numeric(substr(info[204], nchar(info[204])-3,nchar(info[204])-1)) #SouthBoundingCoord
xmin = as.numeric(substr(info[209], nchar(info[209])-3,nchar(info[209])-1))  #WestBoundingCoord


extent(VIIRS_raster) <- extent(xmin, xmax, ymin, ymax)

crs_project = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

VIIRS_raster_reproject_b <- projectRaster(VIIRS_raster,
                                          crs = crs_project,
                                          method = "bilinear")


file_save <- "DNB_Sensor_Radiance.tif"

writeRaster(VIIRS_raster_reproject_b, file_save, format = "GTiff")

