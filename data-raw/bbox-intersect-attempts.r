library(sfdct)
data("antarctica")
set.seed(1)
pts <- st_transform(sf::st_as_sf(as.data.frame(geosphere::randomCoordinates(5e4)), crs = st_crs(4326), coords  = c("lon", "lat")),
                    crs = st_crs(antarctica))


x$geometry = do.call(st_sfc, c(lapply(seq_len(nrow(x)),
                                      function(i) st_point(unlist(x[i, coords]), dim = dim))))

## st_as_sf is hopelessly slow
sf_point <- function(x, ..., coords) {

}
st_as_sf.data.frame <- function (x, ..., agr = NA_agr_, coords, wkt, dim = "XYZ", remove = TRUE)
{
  if (!missing(wkt)) {
    if (remove)
      x[[wkt]] = st_as_sfc(as.character(x[[wkt]]))
    else x$geometry = st_as_sfc(as.character(x[[wkt]]))
  }
  else if (!missing(coords)) {
    x$geometry = do.call(st_sfc, c(lapply(seq_len(nrow(x)),
                                          function(i) st_point(unlist(x[i, coords]), dim = dim))))
    xc <- lapply(split(as.vector(t(as.matrix(x[, coords]))), rep(seq_len(nrow(x)), each = length(coords))), st_point)
    if (remove)
      x[coords] = NULL
  }
  st_sf(x, ..., agr = agr)
}
sf::st_as_sf(as.data.frame(geosphere::randomCoordinates(5e4)), crs = st_crs(4326), coords  = c("lon", "lat"))

plot(antarctica[1, ]$geometry, col = "transparent")
pts$antarctica <- unlist(lapply(st_intersects(pts, antarctica[1, ]), length)) > 0
plot(st_geometry(pts[pts$antarctica, ]), add = TRUE)

system.time({
  st_intersects(pts, antarctica[1, ])
})

antarctica_triangles <- sfdct::ct_triangulate(antarctica[1, ])
plot(antarctica_triangles, col = "transparent")
pts$antarctica_triangles <- unlist(lapply(st_intersects(pts, antarctica_triangles), length)) > 0
plot(st_geometry(pts[pts$antarctica_triangles, ]), add = TRUE)



library(sf)

y <- xp <- antarctica[1, ]
x <- pts <- st_transform(sf::st_as_sf(as.data.frame(geosphere::randomCoordinates(1e3)), crs = st_crs(4326), coords  = c("lon", "lat")),
                    crs = st_crs(antarctica))
library(dplyr)
bboxes <- function(x) {
  UseMethod("bboxes")
}
bboxes.sf <- function(x) {
  p <- sc::PATH(x)
  ## just drop the holes
 tab <-   inner_join(inner_join(p$vertex, p$path_link_vertex, "vertex_"), p$path, "path_")
 if ("island_" %in% names(tab)) tab <- tab[is.na(tab$island_) | as.integer(tab$island_) == 1L, ]
 #return(tab)
 tab  %>% group_by(path_) %>% summarize(xmin = min(x_), xmax = max(x_), ymin = min(y_), ymax = max(y_))

}

intersect_bbox <- function(x, y) {
  p1 <- sc::sc_coord(x)
  bb <- bboxes(y)
  bb <- bind_rows(lapply(seq_len(nrow(p1)), function(x) bb), .id = "point")
  ind <- as.integer((inner_join(mutate(p1, point = as.character(row_number())), bb, "point") %>%
    filter(x_ >= xmin & x_ <= xmax & y_ >= ymin & y_ <= ymax) )$point)
  x$intersects <- rep(FALSE, nrow(p1))
  x$intersects[ind] <- unlist(lapply(st_intersects(st_set_crs(x[ind, ], NA), st_set_crs(y, NA)), length)) > 0
  x
}


tibble_box <- function(x) UseMethod("tibble_box")
tibble_box.tbl_df <- function(x) {
  summarize_all(x, c("min", "max"))
}
tibble_box.sfc <- function(x) {
  bind_rows(lapply(x, tibble_box), .id = "feature")
}
tibble_box.sf <- function(x) {
  tibble_box(st_geometry(x))
}
tibble_box.sfg <- function(x) {

}


x <- sc::sc_coord(st_geometry(nc)[[1]])
tibble_box(x)
