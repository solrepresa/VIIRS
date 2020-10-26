## Sol Represa
# Objective: Open VIIRS - VNP46A1 product
# 23/10/2020 - La Plata, Argentina



library(gdalUtils)
library(raster)
library(rgdal)
#library(R.utils)
#library(maptools)


setwd("C:\\Users\\solre\\Desktop\\S5P")
filename = "C:\\Users\\solre\\Desktop\\S5P\\VNP46A1.A2020285.h12v12.001.2020286073702.h5"
file_save <- "intermedio.tif"
file_export <- "DNB_Sensor_Radiance.tif"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# CORROBORAR:
# gdal_setInstallation(verbose=TRUE) # ver version gdal
# getOption("gdalUtils_gdalPath")  #verificar que podamos abrir HDF5
# gdal_chooseInstallation(hasDrivers="HDF5")

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 


## Inspect hdf5

info <-  gdalinfo(filename) #Abrir hdf5

info[207]  #Long Name
#crs_modis = '+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +R=6371007.181 +units=m +no_defs'
crs_project = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"



## Open hdf5
sds <- get_subdatasets(filename)

gdal_translate(sds[5], dst_dataset = file_save)

VIIRS_raster <- raster(file_save, crs = crs_project)


# NA 
NAvalue(VIIRS_raster) <- 65535

# Extention
xmax =  as.numeric(substr(info[183], nchar(info[183])-3,nchar(info[183])-1)) #EastBoundingCoord
ymax = as.numeric(substr(info[191], nchar(info[191])-3,nchar(info[191])-1)) #NorthBoundingCoord
ymin = as.numeric(substr(info[204], nchar(info[204])-3,nchar(info[204])-1)) #SouthBoundingCoord
xmin = as.numeric(substr(info[209], nchar(info[209])-3,nchar(info[209])-1))  #WestBoundingCoord


extent(VIIRS_raster) <- extent(xmin, xmax, ymin, ymax)


writeRaster(VIIRS_raster, file_export, format = "GTiff", overwrite=TRUE)

