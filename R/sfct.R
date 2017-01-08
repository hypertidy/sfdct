## worker for sf vector/matrix coords
## XY only
m_or_v_XY <- function(x) {
  x <- unclass(x)
  if (is.null(dim(x))) x <- matrix(x, nrow = 1L)
  x[, 1:2, drop = FALSE]
}

## see st_cast and c.sfg
Paste0 <- function (lst)  lapply(lst, unclass)

# path of indexes to pairs in a matrix
#' @importFrom utils head
path_to_seg <- function (x) {
  head(suppressWarnings(matrix(x, nrow = length(x) + 1, ncol = 2,
                               byrow = FALSE)), -2L)
}

# turn sf coords into a data frame
#' @importFrom stats setNames
df_data <- function(x) setNames(as.data.frame(m_or_v_XY(x)), c("x", "y"))

## convert everything to a flat list of data frames
## (hierarchy matches sp, everything is a POLYGON/MULTILINESTRING)
paths_as_df <- function(x) {
  x <- st_cast(x, "MULTILINESTRING")
  rapply(unclass(x), f = df_data,
         classes = c("numeric", "matrix"), how = "list")
}


#' Constrained Delaunay Triangulation
#'
#' Triangulate simple features including the input edges as constraints, rather than
#' being bounded to the trim hull.
#'
#' This is not a Delaunay Triangulation, but is "mostly-Delaunay". All POLYGON, LINESTRING, MULTIPOLYGON and MULTILINESTRING inputs
#' are broken down into line segments that are included in the mesh. Holes are removed
#' by default, but can be retained with the \code{trim} argument.
#'
#' The triangles are collected as POLYGONs within a GEOMETRYCOLLECTION, and in the case of an `sf` object
#' it's returned within the original input data frame.
#'
#' There's no way currently to retain the set of shared vertices, or the segment or
#' the triangle indices.
#' @note GEOMETRYCOLLECTION as input is not yet supported.
#' @param x simple feature geometry or data frame
#' @param trim drop triangles that fall "outside" i.e. "holes" and non-convex regions, \code{TRUE} by default
#' @param ... arguments for methods
#'
#' @return simple feature column or data frame
#' @export
#' @importFrom sf st_cast
#' @examples
#' library(sf)
#' nc <- st_read(system.file("shape/nc.shp", package="sf"))
#' nc_triangles <- ct_triangulate(nc[, "NAME"])
#' plot(nc[, "NAME"])
#' plot(nc_triangles, add = TRUE, col = NA, lty = "dotted")
#' idx <- c(4, 5, 6, 7, 8, 20, 21)
#' op <- par(mfrow = c(2, 1))
#' if (packageVersion("sf") <= '0.2.8'){
#' nc <- st_transform(nc, "+proj=eqc +ellps=WGS84")
#' }
#' plot(st_triangulate(nc[idx, "NAME"]), col = "grey")
#' plot(ct_triangulate(nc[idx, "NAME"]))
#'
#' par(op)
#' \dontrun{
#'   library(rworldmap)
#'   data(countriesLow)
#'   sworld <- st_as_sf(countriesLow)
#'   local_places <- c("Indonesia", "Papua New Guinea", "New Zealand", "Australia")
#'   sworld <- sworld[sworld$SOVEREIGNT %in%  local_places, ]
#'   ## the centre of the universe
#'   llprj <- "+proj=laea +ellps=WGS84 +lat_0=-42 +lon_0=147 +no_defs"
#'   sworld <- st_transform(sworld, crs = llprj)
#'
#'   x <- ct_triangulate(sworld)
#'   plot(x[, "SOVEREIGNT"], main = "constrained vs convex\n Delaunay triangulation")
#'   acols <- sf::sf.colors(nrow(sworld)
#'   plot(st_triangulate(sworld), col = acols, alpha = 0.3), border = NA, add = TRUE)
#' }
ct_triangulate <- function(x,  ...) {
  UseMethod("ct_triangulate")
}
#' @export
#' @name ct_triangulate
ct_triangulate.sfg <- function(x, trim = TRUE, ...){
  if (inherits(x, "POINT")) {
     warning("cannot deal with POINT, returning empty POLYGON")
    return(st_polygon(dim = "XY"))
  }
  if (inherits(x, "MULTIPOINT")) {
    xa <- m_or_v_XY(x)
    xa <- xa[!duplicated(paste(xa[, 1], xa[, 2], sep = "_")), , drop = FALSE]
    if (nrow(xa) < 2) {
      warning("fewer than 3 coordinates, returning empty POLYGON")
      return(st_polygon(dim = "XY"))
    }
    tr <- RTriangle::triangulate(RTriangle::pslg(xa), ...)
    g <- st_geometrycollection(lapply(split(as.vector(t(tr$T)), rep(seq_len(nrow(tr$T)), each = 3)),
                       function(x) st_polygon(list(tr$P[c(x, x[1L]), ]))))
    return(g)
  }
  if (inherits(x, "GEOMETRYCOLLECTION")) {
    warning("GEOMETRYCOLLECTION triangulation not yet supported, returning empty geometry")
    return(st_geometrycollection())
  }
  coords <- dplyr::bind_rows(paths_as_df(x), .id = "branch_")
  coords[["vertex_"]] <- as.integer(factor(paste(coords[["x"]], coords[["y"]], sep = "-")))
  b_link_v <- coords[, c("branch_", "vertex_")]
  vertices <- coords[!duplicated(b_link_v[["vertex_"]]), c("x", "y", "vertex_")]
  vertices <- vertices[order(vertices[["vertex_"]]), ]

  segments <- do.call(rbind, lapply(split(b_link_v[["vertex_"]], b_link_v[["branch_"]]),
                                    function(x) path_to_seg(x))
  )
  ps <- RTriangle::pslg(P = as.matrix(vertices[, c("x", "y")]), S = segments)
  tr <- RTriangle::triangulate(ps, ...)
  ## now intersect triangle centroids with original layer to drop holes

  g <- st_sfc(lapply(split(as.vector(t(tr$T)), rep(seq_len(nrow(tr$T)), each = 3)),
                     function(x) st_polygon(list(tr$P[c(x, x[1L]), ]))), crs = st_crs(x))
  drop <- rep(FALSE, length(g))
  if (trim) {
    drop <- unlist(lapply(st_intersects(st_centroid(g), x), length)) < 1L
  }
  g[!drop]
}
#' @export
#' @name ct_triangulate
#' @importFrom sf st_geometry_type st_geometry st_sfc st_polygon st_sf st_geometrycollection st_centroid st_intersects st_geometry<- st_crs
ct_triangulate.sf <- function(x, trim = TRUE, ...) {
  types <- st_geometry_type(x)
  if (all(types == "POINT")) {
    message("all POINT, returning one feature triangulated")
    xa <- do.call(rbind, lapply(st_geometry(x), function(xy) m_or_v_XY(xy)))
    if (nrow(xa) < 2) {
      warning("less than 3 coordinates, returning empty POLYGON")
      return(st_sf(npoints = nrow(x), geometry = st_sfc(st_polygon(dim = "XY"), crs = st_crs(x))))
    }
    tr <- RTriangle::triangulate(RTriangle::pslg(xa, ...))
    g <- st_sfc(lapply(split(as.vector(t(tr$T)), rep(seq_len(nrow(tr$T)), each = 3)),
                       function(x) st_polygon(list(tr$P[c(x, x[1L]), ]))), crs = st_crs(x))
    return(st_sf(npoints = nrow(x), geometry = st_sfc(st_polygon(dim = "XY"), crs = st_crs(x))))
  }



  gtlist <- vector("list", nrow(x))
  gcolname <- attr(x, "sf_column")
  geoms <- st_geometry(x)
  #st_geometry(x) <- NULL
  for (i in seq_along(gtlist)) {
    gtriangles <- st_geometrycollection(ct_triangulate(geoms[[i]], trim = trim, ...))
    gtlist[[i]] <- gtriangles
  }
  st_geometry(x) <- st_sfc(gtlist, crs = st_crs(x))
  x
}
