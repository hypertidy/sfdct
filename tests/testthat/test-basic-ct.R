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

is_empty <- function(x, ...) {
  UseMethod("is_empty")
}
is_empty.sfg <- function(x, ...) !length(x) > 0
is_empty.sfc <- function(x, ...) unlist(lapply(x, is_empty))
is_empty.sf <- function(x, ...) is_empty(st_geometry(x))

test_that("different inputs work", {
  ## replace with st_cast when 0.2.8 comes out
  #st_geometry(nc) <- st_sfc(lapply(st_geometry(nc), function(x) st_multipoint(do.call(rbind, unlist(x, recursive = FALSE)))), crs = st_crs(nc))
  nc_mpoint <- st_cast(nc, "MULTIPOINT")
  expect_that(ct_triangulate(nc_mpoint), is_a("sf"))

  expect_warning(ml_nc <- st_cast(nc, "MULTILINESTRING"), "repeating")
  ml_nc %>%     expect_s3_class("sf") %>% ct_triangulate() %>% expect_s3_class("sf")

  lstri <- st_linestring(st_geometry(ml_nc)[[4]][[1]]) %>% ct_triangulate()
  expect_that(lstri %>% is_empty(), is_false())
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
#
## from ?st_geometrycollection
 g1 <- c(st_geometrycollection(list(st_point(1:2), st_linestring(matrix(1:6,3)))),
   st_geometrycollection(list(st_multilinestring(list(matrix(11:16,3))))))
 g2 <- c(st_geometrycollection(list(st_point(1:2), st_linestring(matrix(1:6,3)))),
   st_multilinestring(list(matrix(11:16,3))), st_point(5:6),
   st_geometrycollection(list(st_point(10:11))))

 test_that("we can triangulate a geometrycollection", {
   #st_geometry(nc_triangles) %>% ct_triangulate() %>% plot(col = "transparent")
#
    #expect_that(st_geometry(nc_triangles) %>% ct_triangulate()  %>% is_empty() %>% all(), is_true())
   expect_that(ct_triangulate(st_geometry(nc_triangles[1:5, ])), is_a("sfc_GEOMETRYCOLLECTION") )
   #expect_that(st_geometry(nc_triangles)[[1]] %>% ct_triangulate()  %>% is_empty(), is_true())
   expect_that(st_geometry(nc_triangles)[[1]] %>% ct_triangulate()  %>% is_empty(), is_false())
#   ## give it one of the polygons from the geometrycollection and it's fine
   expect_that(st_geometry(nc_triangles)[[1]][[1]] %>% ct_triangulate(a = .00001) %>% is_empty()  , is_false())
#
   expect_warning(ct_triangulate(g1), "returning empty")
})
#
#
# data("sfzoo", package= "sc")
# data("sfgc", package= "sc")

test_that("all POINT with args works", {
          library(sf)
          library(sfdct)
          set.seed(1)
          n <- 150
          a <- ct_triangulate(st_as_sf(data.frame(x =  rnorm(n), y = rnorm(n)), coords = c("x", "y")), a = 0.1, D = TRUE)
          expect_that(a, is_a("sf"))
}
          )
#lapply(sfzoo, ct_triangulate)
#ct_triangulate(sfgc) %>% plot(col = "transparent")
