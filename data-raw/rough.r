library(sf)
library(sfdct)
n <- 150
a <- ct_triangulate(st_as_sf(data.frame(x =  rnorm(n), y = rnorm(n)), coords = c("x", "y")), a = .01)
n2 <- length(st_geometry(a)[[1]])
b <- st_sf(geometry = st_sfc(unlist(unclass(st_geometry(a)), recursive = FALSE), crs = st_crs(a)),
           b = seq_len(n2))

library(dplyr)
## balance the n-coodrs, fraction sampled, and the minimum area a = argument to ct_triangulate for
## some wild holy polygons
plot(b %>% sample_frac(0.65) %>% st_union(), col = "grey")

## (beware of the a argument being VERY small, especially if you change units)



## above will always be mostly-convex, so try trimming from the outside in
## rather than randomly throwing triangles away

n <- 400
a <- ct_triangulate(st_as_sf(data.frame(x =  rnorm(n), y = rnorm(n)), coords = c("x", "y")), a = NULL)
n2 <- length(st_geometry(a)[[1]])
b <- st_sf(geometry = st_sfc(unlist(unclass(st_geometry(a)), recursive = FALSE), crs = st_crs(a)),
           b = seq_len(n2))

plot(b %>% sample_frac(0.65) %>% st_union(), col = "grey")


## hmm, doesn't work
#a %>% mutate(geometry2 = st_cast(geometry, "LINESTRING")) %>% filter(st_length(geometry2) > 1) %>% plot()

## anyway, chew the polygon down via the big edge triangles around the border
poly <- b %>% filter(st_length(st_cast(geometry, "MULTILINESTRING")) < 2)
plot(poly)


## union the triangles to get a valid simple feature
st_union(poly)
