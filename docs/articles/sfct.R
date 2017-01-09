## ----example-------------------------------------------------------------
library(sf)
library(sfct)
nc <- st_read(system.file("shape/nc.shp", package="sf"))
nc_triangles <- ct_triangulate(nc)
plot(nc_triangles[, c("PERIMETER", "NAME")])

## ----hone----------------------------------------------------------------
i_feature <- 25
nc1 <- nc[c(i_feature, unlist(st_touches(nc[i_feature, ], nc))), ]
plot(nc1[, c("AREA", "NAME")])

## subvert st_area because we really don't want m^2
st_crs(nc1) <- NA
areas <- st_area(nc1)
st_crs(nc1) <- st_crs(nc)
nc1_triangles <- ct_triangulate(nc1, a = min(areas)/5)
plot(nc1_triangles[, c("AREA", "NAME")])

nc2_triangles <- ct_triangulate(nc1, a = min(st_area(nc1))/25)
plot(nc2_triangles[, c("AREA", "NAME")])


## ----MULTIPOINT----------------------------------------------------------
mtriangs <- ct_triangulate(st_cast(nc1, "MULTIPOINT"), a = 0.001)
plot(mtriangs[, 1], col = viridisLite::viridis(nrow(mtriangs)))

