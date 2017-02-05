context("basic ct")

library(sf)
nc <- st_read(system.file("shape/nc.shp", package="sf"))
nc_triangles <- ct_triangulate(nc)

## simple freedoms
plot.sf <- function(x, ...) plot(st_geometry(x), ..., col = "transparent")

test_that("ct works", {
  expect_that(nc_triangles, is_a("sf"))
  expect_that(as.character(unique(st_geometry_type(nc_triangles))), equals("GEOMETRYCOLLECTION"))
})

test_that("sf, sfc, sfg all return as input", {
          expect_that(ct_triangulate(nc[1, ]), is_a(class(nc[1, ])))
          expect_that(ct_triangulate(nc[1:4, ]), is_a(class(nc[1:4, ])))

          expect_that(ct_triangulate(st_geometry(nc[1, ])), is_a(class(st_geometry(nc[1, ]))))
          expect_that(ct_triangulate(st_geometry(nc[1:4, ])), is_a(class(st_geometry(nc[1:4, ]))))

          ## drop to a geometry
          expect_that(ct_triangulate(st_geometry(nc[1, ])[[1]]), is_a(class(st_geometry(nc[1, ])[[1]])))
}
)

test_that("different inputs work", {
  ## replace with st_cast when 0.2.8 comes out
  #st_geometry(nc) <- st_sfc(lapply(st_geometry(nc), function(x) st_multipoint(do.call(rbind, unlist(x, recursive = FALSE)))), crs = st_crs(nc))
  nc_mpoint <- st_cast(nc, "MULTIPOINT")
  expect_that(ct_triangulate(nc_mpoint), is_a("sf"))

  expect_warning(ml_nc <- st_cast(nc, "MULTILINESTRING"), "repeating")
  ml_nc %>%     expect_s3_class("sf") %>% ct_triangulate() %>% expect_s3_class("sf")

  ## beware that cast just joins all the paths together
  ## it doesn't drop the first
  l_nc <- st_cast(nc, "LINESTRING")
  l_nc %>%     expect_s3_class("sf") %>% ct_triangulate() %>% expect_s3_class("sf")

  ## but to POLYGON it copies out the extra ones
  expect_warning(p_nc <- st_cast(nc, "POLYGON"), "repeating")
  p_nc %>%     expect_s3_class("sf") %>% ct_triangulate() %>% expect_s3_class("sf")


  ##
  expect_warning(pp_nc <- st_cast(nc, "POINT"), "repeating")
  pp_tri <- pp_nc %>%     expect_s3_class("sf") %>% ct_triangulate() %>% expect_s3_class("sf")
  expect_that(nrow(pp_tri), equals(1L))
})


