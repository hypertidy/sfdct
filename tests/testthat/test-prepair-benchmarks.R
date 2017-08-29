context("prepair-benchmarks")

#A 'bowtie' polygon:
bt_wkt <- "POLYGON ((0 0, 0 10, 10 0, 10 10, 0 0))"
#Square with wrong orientation:
wo_wkt <- "POLYGON ((0 0, 0 10, 10 10, 10 0, 0 0))"
#Inner ring with one edge sharing part of an edge of the outer ring:
ir_or_wkt <- "POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0), (5 2,5 7,10 7, 10 2, 5 2))"
##Dangling edge:
de_wkt <- "POLYGON ((0 0, 10 0, 15 5, 10 0, 10 10, 0 10, 0 0))"
#Outer ring not closed:
or_wkt <- "POLYGON ((0 0, 10 0, 10 10, 0 10))"
#Two adjacent inner rings:
ar_wkt <- "POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0), (1 1, 1 8, 3 8, 3 1, 1 1), (3 1, 3 8, 5 8, 5 1, 3 1))"
#Polygon with an inner ring inside another inner ring:
irir_wkt <- "POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0), (2 8, 5 8, 5 2, 2 2, 2 8), (3 3, 4 3, 3 4, 3 3))"
library(sf)
from_wkt <- function(x) st_as_sf(data.frame(geometry = x), wkt = "geometry")
is_valid_wkt <- function(x) st_is_valid(from_wkt(x))
fix_wkt <- function(x) st_union(ct_triangulate(from_wkt(x)), by_feature = TRUE)
test_that("bowtie is fixed", {
  wkt <- bt_wkt
  expect_warning(the_test <- is_valid_wkt(wkt), "Self-intersection")
  expect_false(the_test)
  expect_true(st_is_valid(fix_wkt(wkt)))
})

test_that("Square with wrong orientation", {
  wkt <- wo_wkt
  context("st_is_valid does not care about orientation")
  ##expect_warning(the_test <- is_valid_wkt(wkt), "Self-intersection")
  the_test <- is_valid_wkt(wkt)
  expect_true(the_test)

  context("the fix is ok")
  expect_true(st_is_valid(fix_wkt(wkt)))
  context(" round-trip is identical")
  expect_true(sf::st_as_text( st_geometry(from_wkt(wkt))) == wkt)
  context(" round-trip after fix is a different string")
  expect_false(sf::st_as_text( st_geometry(fix_wkt(wkt))) == wkt)
})

test_that("Inner ring with one edge sharing part of an edge of the outer ring:", {
  wkt <- ir_or_wkt
  expect_warning(the_test <- is_valid_wkt(wkt), "Self-intersection")
  expect_false(the_test)
  expect_true(st_is_valid(fix_wkt(wkt)))
})

test_that("Dangling edge", {
  wkt <- de_wkt
  expect_warning(the_test <- is_valid_wkt(wkt), "Self-intersection")
  expect_false(the_test)
  expect_true(st_is_valid(fix_wkt(wkt)))
})
#

# test_that("Outer ring not closed", {
#     wkt <- or_wkt
#     expect_error(is_valid_wkt(wkt), "IllegalArgumentException: Points of LinearRing do not form a closed linestring")
#     ##expect_false(the_test)
#     expect_true(st_is_valid(fix_wkt(wkt)))
# )

test_that("#Two adjacent inner rings:", {
  wkt <- ar_wkt
  expect_warning(the_test <- is_valid_wkt(wkt), "Self-intersection")
  expect_false(the_test)
  expect_true(st_is_valid(fix_wkt(wkt)))
})

test_that("Polygon with an inner ring inside another inner ring", {
  wkt <- irir_wkt
  expect_warning(the_test <- is_valid_wkt(wkt), "Holes are nested at or near point 3 3")
  expect_false(the_test)
  expect_true(st_is_valid(fix_wkt(wkt)))
})
