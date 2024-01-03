library(maps)
library(dplyr)
library(sf)

crs <- "+proj=laea +lat_0=-90 +lon_0=147 +ellps=WGS84"
antarctica <- map(plot = FALSE, fill = TRUE) %>% st_as_sf() %>% dplyr::filter(ID == "Antarctica") %>% st_transform(crs)
#plot(antarctica)

hole_in_antarctica <- st_sfc(st_buffer(st_point(c(0, 0)), dist = 5e5), crs = crs)

antarctica <- rbind(antarctica, st_sf(ID = "not Antarctica", geom = hole_in_antarctica))
usethis::use_data(antarctica, compress = "xz")
