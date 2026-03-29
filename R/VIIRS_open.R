## =============================================================================
## viirs_open.R
## Objetivo: Abrir producto VIIRS VNP46A1 (Black Marble) y exportar como GeoTIFF
## Autora: Sol Represa
## Fecha original: 23/10/2020 - La Plata, Argentina
## =============================================================================

library(gdalUtils)
library(raster)
library(rgdal)

# --- Configuración -----------------------------------------------------------
# Colocar el archivo .h5 en data/raw/ y editar el nombre aquí
filename  <- "data/raw/VNP46A1.A2020285.h12v12.001.2020286073702.h5"

# Archivo intermedio (se sobreescribe)
file_tmp  <- "data/processed/intermedio.tif"

# Archivo de salida final
file_out  <- "data/processed/DNB_Sensor_Radiance.tif"

# CRS de salida
crs_project <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

# Valor de relleno (NA) del producto VNP46A1
na_fill <- 65535

# Índice de la subdataset a extraer (5 = DNB_At_Sensor_Radiance_500m)
sds_index <- 5

# --- Verificación de GDAL ----------------------------------------------------
# Descomentar para verificar que GDAL tenga soporte HDF5:
# gdal_setInstallation(verbose = TRUE)
# gdal_chooseInstallation(hasDrivers = "HDF5")

# --- Procesamiento ------------------------------------------------------------

# 1) Inspeccionar metadatos del HDF5
info <- gdalinfo(filename)

# 2) Extraer subdataset de interés
sds <- get_subdatasets(filename)
message("Subdatasets disponibles:")
print(sds)
message("Extrayendo subdataset ", sds_index, ": ", sds[sds_index])

gdal_translate(sds[sds_index], dst_dataset = file_tmp)

# 3) Leer como raster y asignar CRS
VIIRS_raster <- raster(file_tmp, crs = crs_project)

# 4) Marcar valores de relleno como NA
NAvalue(VIIRS_raster) <- na_fill

# 5) Asignar extensión geográfica desde los metadatos del HDF5
#    Los metadatos contienen EastBoundingCoord, NorthBoundingCoord, etc.
#    Se extraen parseando las líneas relevantes de gdalinfo
extract_coord <- function(info, pattern) {
  line <- grep(pattern, info, value = TRUE)[1]
  as.numeric(regmatches(line, regexpr("-?[0-9]+\\.?[0-9]*", line)))
}

xmax <- extract_coord(info, "EastBoundingCoord")
xmin <- extract_coord(info, "WestBoundingCoord")
ymax <- extract_coord(info, "NorthBoundingCoord")
ymin <- extract_coord(info, "SouthBoundingCoord")

message("Extensión: xmin=", xmin, " xmax=", xmax, " ymin=", ymin, " ymax=", ymax)
extent(VIIRS_raster) <- extent(xmin, xmax, ymin, ymax)

# 6) Exportar como GeoTIFF
writeRaster(VIIRS_raster, file_out, format = "GTiff", overwrite = TRUE)
message("GeoTIFF exportado: ", file_out)

# Limpiar archivo intermedio
if (file.exists(file_tmp)) file.remove(file_tmp)
