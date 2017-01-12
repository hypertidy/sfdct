## ----example-------------------------------------------------------------
library(sf)
library(sfdct)
nc <- st_read(system.file("shape/nc.shp", package="sf"))
nc_triangles <- ct_triangulate(nc)
plot(nc_triangles[, c("PERIMETER", "NAME")])

