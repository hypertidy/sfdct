library(maps)
library(sf)
library(maptools)

map_world <- st_as_sf(map(plot = FALSE, fill = TRUE) )
devtools::use_data(map_world, compress = "xz")
