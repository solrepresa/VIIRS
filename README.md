# VIIRS Black Marble — Lectura de productos VNP46A1

Script en R para abrir archivos HDF5 del producto **VIIRS VNP46A1** (Black Marble), extraer la banda de radiancia nocturna (DNB At-Sensor Radiance) y exportarla como GeoTIFF georreferenciado.

## Contexto

El producto [VNP46A1](https://ladsweb.modaps.eosdis.nasa.gov/missions-and-measurements/products/VNP46A1/) es un dato diario de radiancias nocturnas del sensor VIIRS (Visible Infrared Imaging Radiometer Suite) a bordo del satélite Suomi NPP. Forma parte de la suite **Black Marble** de NASA, útil para estudios de iluminación artificial, actividad económica, consumo energético y urbanización.

Los archivos se distribuyen en formato HDF5 con proyección sinusoidal y tiles del sistema de grilla MODIS (ej. h12v12).

## Qué hace el script

1. Inspecciona el archivo HDF5 con `gdalinfo` para obtener metadatos (extensión geográfica, subdatasets disponibles).
2. Extrae la subdataset de interés (`DNB_At_Sensor_Radiance_500m`, posición 5) usando `gdal_translate`.
3. Asigna el CRS (WGS84) y la extensión geográfica leída de los metadatos del HDF5.
4. Marca los valores de relleno (65535) como NA.
5. Exporta el resultado como GeoTIFF.

## Estructura del repositorio

```
VIIRS/
├── data/
│   ├── raw/             # Colocar aquí los archivos .h5 descargados
│   └── processed/       # GeoTIFFs de salida
├── R/
│   └── viirs_open.R     # Script principal
├── output/              # Figuras (opcional)
├── .gitignore
└── README.md
```

## Requisitos

- R ≥ 4.0
- GDAL instalado en el sistema con soporte para HDF5
- Paquetes R: `gdalUtils`, `raster`, `rgdal`

```r
install.packages(c("gdalUtils", "raster", "rgdal"))
```

> **Nota sobre paquetes deprecados:** `rgdal` y `raster` fueron retirados de CRAN en 2023. Las alternativas modernas son `terra` y `sf`. Ver la sección [Migración a terra](#migración-a-terra) más abajo.

### Verificar que GDAL soporte HDF5

```r
library(gdalUtils)
gdal_setInstallation(verbose = TRUE)
gdal_chooseInstallation(hasDrivers = "HDF5")
```

## Uso

1. Descargar un archivo VNP46A1 desde [LAADS DAAC](https://ladsweb.modaps.eosdis.nasa.gov/) (requiere cuenta Earthdata).
2. Colocarlo en `data/raw/`.
3. Editar las rutas en `R/viirs_open.R` o — mejor — usar los paths relativos que ya apuntan a `data/raw/` y `data/processed/`.

```r
source("R/viirs_open.R")
```

El script genera un GeoTIFF en `data/processed/`.

## Cómo adaptar a otros productos VIIRS

El script funciona con cualquier producto HDF5 de la familia VIIRS/MODIS. Para adaptarlo:

- Cambiar el **índice de subdataset** en `get_subdatasets()` (ej. posición 5 → la banda que necesites). Podés inspeccionar las bandas disponibles con `gdalinfo(filename)`.
- Ajustar el **valor NA** si es distinto a 65535 (consultar la guía de usuario del producto).
- Para productos con otra proyección nativa, verificar los metadatos de extensión y CRS.

## Migración a terra

El paquete `terra` reemplaza a `raster` + `rgdal` y simplifica mucho la lectura de HDF5:

```r
library(terra)

r <- rast("data/raw/VNP46A1.A2020285.h12v12.001.2020286073702.h5",
          subds = 5)
NAflag(r) <- 65535
writeRaster(r, "data/processed/DNB_Sensor_Radiance.tif", overwrite = TRUE)
```

Con `terra` ya no es necesario extraer manualmente la extensión de los metadatos. Los jóvenes la tienen más sencillo.

## Datos de ejemplo

Los archivos HDF5 de VIIRS pesan entre 10–50 MB por tile, por lo que no se incluyen en el repositorio. Para descargar un archivo de prueba:

1. Ir a [LAADS DAAC](https://ladsweb.modaps.eosdis.nasa.gov/).
2. Buscar el producto **VNP46A1**.
3. Seleccionar una fecha y tile (ej. h12v12 para Buenos Aires).
4. Guardar en `data/raw/`.


## Referencias

- [Black Marble User Guide v1.0](https://viirsland.gsfc.nasa.gov/PDF/VIIRS_BlackMarble_UserGuide.pdf)
- [Tutorial: Working with Daily NASA VIIRS Surface Reflectance Data](https://lpdaac.usgs.gov/resources/e-learning/working-daily-nasa-viirs-surface-reflectance-data/)
- [VNP13 Vegetation Index User Guide & ATBD](https://lpdaac.usgs.gov/documents/184/VNP13_User_Guide_ATBD_V2.1.2.pdf)

## Autoría

**Sol Represa** — Trabajo desarrollado como parte de su investigación doctoral.
