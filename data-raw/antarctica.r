library(maps)
library(dplyr)
library(sf)
antarctica <- map(plot = FALSE, fill = TRUE) %>% st_as_sf() %>% dplyr::filter(ID == "Antarctica") %>% st_transform("+proj=laea +lat_0=-90 +lon_0=147 +ellps=WGS84")
#plot(antarctica)

hole_in_antarctica <- st_sfc(st_buffer(st_point(c(0, 0)), dist = 5e5))

antarctica <- st_set_crs(rbind(antarctica, st_sf(ID = "not Antarctica", geometry = hole_in_antarctica)), st_crs(antarctica))
devtools::use_data(antarctica, compress = "xz")
