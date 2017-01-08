context("basic ct")

library(sf)
nc <- st_read(system.file("shape/nc.shp", package="sf"))
nc_triangles <- ct_triangulate(nc)

test_that("ct works", {
  expect_that(nc_triangles, is_a("sf"))
  expect_that(as.character(unique(st_geometry_type(nc_triangles))), equals("GEOMETRYCOLLECTION"))
})

test_that("different inputs work", {
  expect_that(ct_triangulate(st_cast(nc[4, ], "MULTIPOINT")), is_a("sf"))

})
