prj <- "+proj=omerc +lonc=165 +lat_0=-22 +alpha=23 +k=0.99984 +x_0=0 +y_0=0 +no_uoff +gamma=23 +ellps=WGS84 +units=m +no_defs"



#install.packages("sfdct")
library(sfdct)
library(sf)
data("wrld_simpl", package = "maptools")
amap <- st_buffer(st_as_sf(wrld_simpl[, "NAME", drop = FALSE]), dist = 0)
## kludges to get properties of the data as they are
## without geographic or metadata assumptions about what
## I'm trying to do
areas_native <- as.numeric(st_area(st_set_crs(amap, NA)))
w <- ct_triangulate(amap, a = 1)
wp <- st_cast(st_transform(w, prj))

library(dplyr)
## note that st_length is native length because it's not longlat
## and so not geoid-aware so we good ...
wpf <- dplyr::filter(wp[as.numeric(st_length(wp)) < 3e7, ])
plot(wpf, border = NA)


