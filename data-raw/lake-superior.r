u <- "https://github.com/r-gris/polyggon/raw/master/inst/extdata/water_lake_superior_basin.gpkg"
download.file(u, file.path("data-raw", basename(u)), mode = "wb")

library(sf)
lakesuperior <- read_sf(file.path("data-raw", basename(u)), quiet = TRUE)
devtools::use_data(lakesuperior, compress="xz", overwrite = TRUE)
