#http://atriplex.info/blog/index.php/2017/05/24/polygon-intersection-and-summary-with-sf/

#download.file("http://atriplex.info/files/grid.gpkg", "extdata/atriplex/grid.gpkg",mode="wb")

#download.file("http://atriplex.info/files/veg.gpkg", "extdata/atriplex/veg.gpkg",mode="wb")

library(sf)
grid <- read_sf("extdata/atriplex/grid.gpkg") #%>% names()
veg <- read_sf("extdata/atriplex/veg.gpkg") #%>% names()
g <- st_geometry(grid)
grid <- st_set_geometry(grid, NULL)
grid$geometry <- NULL
grid <- st_set_geometry(grid, g)

## combined data
library(dplyr)
merged <- rbind(grid %>% select(geometry) %>% mutate(layer = "grid"),
veg %>% select(geometry) %>% mutate(layer = "veg")) %>% mutate(ID = row_number())
