#' @examples
#' library(raster)
#' library(sf)
#' library(spex)
#' nc <- read_sf(system.file("shape/nc.shp", package="sf"))
#' g <- spex(nc) %>% raster(nrow = 5, ncol = 8) %>% polygonize() %>% st_as_sf()
#' g$layer <- 1:nrow(g)
#' x <- intersection_overlay(nc, g)
#' library(dplyr)
#' f1 <- raadfiles::thelist_files(pattern = "parcels_sorell") %>% pull(fullname)
#' f2 <- file.path(getOption("default.datadir"), "data_local/tas.gov.au/TASVEG/tasveg_fixtopology.rds")
#' p <- sf::read_sf(f1)
#' v <- readRDS(f2)
#' p1 <- p[unique(unlist(sf::st_is_within_distance(p[1:10, ],p, 1000))), ]
#' v1 <- v[unique(unlist(sf::st_intersects(v, sf::st_bbox(p1) %>% sf::st_as_sfc()))), ]
intersection_overlay <- function(x, y, ...) {
  x[["x_feature_id"]] <- seq_len(nrow(x))
  y[["y_feature_id"]] <- seq_len(nrow(y))

  y <- sf::st_transform(y, sf::st_crs(y))
  xl <- st_set_crs(sf::st_cast(x, "MULTILINESTRING"), st_crs(x))
  yl <- sf::st_set_crs(sf::st_cast(y, "MULTILINESTRING"), st_crs(x))
  mesh <- sfdct::ct_triangulate(sf::st_union(c(sf::st_geometry(xl), sf::st_geometry(yl))))
  mesh <- sf::st_cast(mesh)
  op <- options(warn = -1)
  on.exit(options(op), add = TRUE)
  #sink(tempfile())
  ## ffs cannot shut st_intersects up
  x_idx <- st_intersects(sf::st_centroid(mesh), x)
  y_idx <- st_intersects(sf::st_centroid(mesh), y)
  #sink(NULL)
  x_idx <- purrr::map_df(x_idx,
                       ~tibble::tibble(layer = "x", source = .x), .id = "index")
  y_idx <- purrr::map_df(y_idx,
                         ~tibble::tibble(layer = "y", source = .x), .id = "index")
  xx <- bind_rows(x_idx, y_idx) %>% dplyr::mutate(index = as.integer(index))

  ## throw away all the n() == 1
  ## group and union all the ones that have the same x,y layer pairing
  xx %>% group_by(index) %>% mutate(n = n()) %>% ungroup() %>% filter(n > 1) %>%
    group_by(index)  ## something something
}


