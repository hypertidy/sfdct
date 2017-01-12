context("basic ct")

library(sf)
nc <- st_read(system.file("shape/nc.shp", package="sf"))
nc_triangles <- ct_triangulate(nc)

test_that("ct works", {
  expect_that(nc_triangles, is_a("sf"))
  expect_that(as.character(unique(st_geometry_type(nc_triangles))), equals("GEOMETRYCOLLECTION"))
})

test_that("different inputs work", {
  ## replace with st_cast when 0.2.8 comes out
  st_geometry(nc) <- st_sfc(lapply(st_geometry(nc), function(x) st_multipoint(do.call(rbind, unlist(x, recursive = FALSE)))), crs = st_crs(nc))
  expect_that(ct_triangulate(nc[4, ]), is_a("sf"))

})
