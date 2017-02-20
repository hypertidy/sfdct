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
 # x <- unlist(x, recursive = FALSE)
  x <- st_cast(x, "MULTILINESTRING")
  rapply(unclass(x), f = df_data,
         classes = c("numeric", "matrix"), how = "list")
}


#' Constrained Delaunay Triangulation
#'
#' Triangulate simple features including the input edges as constraints, rather than
#' being bounded to the convex hull.
#'
#' This is not a Delaunay Triangulation by default, but is "mostly-Delaunay". Use the `D = TRUE` option,
#' passed to the underlying function in RTriangle to ensure the criterion is met, as well as edge constraints.
#'
#'
#' All POLYGON, LINESTRING, MULTIPOLYGON, and MULTILINESTRING inputs (including those in GEOMETRYCOLLECTION)
#' are broken down into line segments that are included in the mesh. Holes are removed
#' by default, but can be retained with the \code{trim} argument.
#'
#' The triangles are collected as POLYGONs within a GEOMETRYCOLLECTION, and in the case of an `sf` object
#' it's returned within the original input data frame.
#'
#' There's no way in this package to retain the set of shared vertices, or the segment or
#' the triangle indices. It is a fundamental feature of the standard, that this information is not represented.
#'
#' Further arguments may be passed down to the underlying triangulation function \code{\link[RTriangle]{triangulate}}.
#' Note that planar coordinates are assumed, no matter what projection the input is in. There's no
#' sensible meaning to a value for \code{a} in units m^2 for a layer that is in longitude/latitude, for those
#' use "area in square degrees", the straightforward meaning in planar coordinates.
#' These arguments are, from the documention of that function:
#' \itemize{
##' \item{a}{ a Maximum triangle area. If specified, triangles cannot be
##' larger than this area.}
##' \item{q}{ Minimum triangle angle in degrees.}
##' \item{Y}{ If \code{TRUE} prohibits the insertion of Steiner points
##' on the mesh boundary.}
##' \item{j}{ If \code{TRUE} jettisons vertices that are not part of
##' the final triangulation from the output.}
##' \item{D}{ If \code{TRUE} produce a conforming Delaunay
##' triangulation. This ensures that all the triangles in the mesh are
##' truly Delaunay, and not merely constrained Delaunay.  This option
##' invokes Ruppert's original algorithm, which splits every
##' subsegment whose diametral circle is encroached.  It usually
##' increases the number of vertices and triangles.}
##' \item{S}{ Specifies the maximum number of added Steiner points.}
##' \item{V}{ Verbosity level. Specify higher values  for more detailed
##' information about what the Triangle library is doing.}
##' \item{Q}{ If \code{TRUE} suppresses all explanation of what the
##' Triangle library is doing, unless an error occurs. }
##' }
#' @note GEOMETRYCOLLECTION as input is not yet supported.
#' @param x simple feature geometry or data frame
#' @param trim drop triangles that fall "outside" i.e. "holes" and non-convex regions, \code{TRUE} by default
#' @param ... arguments for \code{\link[RTriangle]{triangulate}}, see details
#' @return simple feature column \code{\link[sf]{st_sfc}} or data frame \code{\link[sf]{st_sfc}}
#' @export
#' @importFrom sf st_cast
#' @examples
#' library(sf)
#' nc <- st_read(system.file("shape/nc.shp", package="sf"))
#' nc_triangles <- ct_triangulate(nc[, c("NAME", "geometry")])
#' plot(nc[, "NAME"])
#' plot(nc_triangles, add = TRUE, col = NA, lty = "dotted")
#' idx <- c(4, 5, 6, 7, 8, 20, 21)
#' op <- par(mfrow = c(2, 1))
#' if (packageVersion("sf") <= '0.2.8'){
#' nc <- st_transform(nc, "+proj=eqc +ellps=WGS84")
#' }
#'
#' plot(st_triangulate(nc[idx, c("NAME", "geometry")]), col = "grey")
#' plot(ct_triangulate(nc[idx, c("NAME", "geometry")]))
#'
ct_triangulate <- function(x,  ...) {
  UseMethod("ct_triangulate")
}
#' @export
#' @name ct_triangulate
ct_triangulate.POINT <- function(x, trim = TRUE,...) {
  warning("cannot deal with POINT, returning empty POLYGON in GEOMETRYCOLLECTION")
  return(st_geometrycollection(st_polygon(dim = "XY")))
}
#' @export
#' @name ct_triangulate
ct_triangulate.MULTIPOINT <- function(x, trim = TRUE,...) {
  xa <- m_or_v_XY(x)
  xa <- xa[!duplicated(paste(xa[, 1], xa[, 2], sep = "_")), , drop = FALSE]
  if (nrow(xa) < 2) {
    warning("fewer than 3 coordinates, returning empty POLYGON in GEOMETRYCOLLECTION")
    return(st_geometrycollection(st_polygon(dim = "XY")))
  }
  tr <- RTriangle::triangulate(RTriangle::pslg(xa), ...)
  g <- st_geometrycollection(lapply(split(as.vector(t(tr$T)), rep(seq_len(nrow(tr$T)), each = 3)),
                                    function(x) structure(list(tr$P[c(x, x[1L]), ]), class = c("XY", "POLYGON", "sfg"))))
  return(g)
}

#' @export
#' @name ct_triangulate
ct_triangulate.GEOMETRYCOLLECTION <- function(x, trim = TRUE, ...){
  ## note that this treats each sub-geometry like a feature within a set
  ## each sub's edges won't affect the others
  ## we need a simplicial complex to do GC properly
  st_geometrycollection(unlist(lapply(lapply(x, ct_triangulate, trim = trim, ...), unclass), recursive= FALSE))
}

randoms <- function(n, b = 8L) {
  unlist(lapply(split(sample(c(letters, 0:9), n * b, replace = TRUE), rep(seq_len(n), each = b)), paste, collapse = ""))
}
## go full simplicial complex
## normalizing verts is hard
#' @importFrom tibble as_tibble tibble
#' @importFrom dplyr bind_rows
#'
get_everything <- function(x) {
  coords <- dplyr::bind_rows(paths_as_df(x), .id = "branch_")
  coords[["vertex_"]] <- as.integer(factor(paste(coords[["x"]], coords[["y"]], sep = "-")))
  b_link_v <- coords[, c("branch_", "vertex_")]
  vertices <- coords[!duplicated(b_link_v[["vertex_"]]), c("x", "y", "vertex_")]
  vertices <- vertices[order(vertices[["vertex_"]]), ]

  segments <- do.call(rbind, lapply(split(b_link_v[["vertex_"]], b_link_v[["branch_"]]),
                                  function(x) path_to_seg(x))
  )
  #return(list(vertices, segments))
  vertices <- tibble::as_tibble(vertices)
  vertices[[".vertex"]] <- randoms(nrow(vertices))
  segments <- tibble::as_tibble(segments)
  segments[[".segment"]] <- randoms(nrow(segments))
  segments[["V1"]] <- vertices[[".vertex"]][segments[["V1"]]]
  segments[["V2"]] <- vertices[[".vertex"]][segments[["V2"]]]
  list(vertices = vertices, segments = segments)
}

ct_triangulate_sc <- function(x, ...) {
  vs <- lapply(x, get_everything)
  vertices <- dplyr::bind_rows(lapply(vs, "[[", "vertices"))
  segments <- dplyr::bind_rows(lapply(vs, "[[", "segments"))
  #vXv <- tibble::tibble(.vertex = vertices[[".vertex"]], VERTEX = as.integer(factor(paste(vertices$x, vertices$y, sep = "_"))))
  vertices[["VERTEX"]] <- as.integer(factor(paste(vertices$x, vertices$y, sep = "_")))
  segments[["VERTEX1"]] <- vertices[["VERTEX"]][match(segments[["V1"]], vertices$.vertex)]
  segments[["VERTEX2"]] <- vertices[["VERTEX"]][match(segments[["V2"]], vertices$.vertex)]

  vertices <- vertices[!duplicated(vertices$VERTEX), ]
  segments[["V1"]] <- seq_len(nrow(vertices))[match(segments$VERTEX1, vertices$VERTEX)]
  segments[["V2"]] <- seq_len(nrow(vertices))[match(segments$VERTEX2, vertices$VERTEX)]

  ps <- RTriangle::pslg(P = as.matrix(vertices[, c("x", "y")]), S = as.matrix(segments[, c("V1", "V2")]))
  tr <- RTriangle::triangulate(ps, ...)
  g <- lapply(split(as.vector(t(tr$T)), rep(seq_len(nrow(tr$T)), each = 3)),
              function(x) structure(list(tr$P[c(x, x[1L]), ]), class = c("XY", "POLYGON", "sfg")))

  st_geometrycollection(g)
}
#' @export
#' @importFrom sp over
#' @importFrom sf st_point st_set_crs
#' @importFrom methods as
#' @name ct_triangulate
ct_triangulate.sfg <- function(x, trim = TRUE, ...){
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

  g <- lapply(split(as.vector(t(tr$T)), rep(seq_len(nrow(tr$T)), each = 3)),
                     function(x) structure(list(tr$P[c(x, x[1L]), ]), class = c("XY", "POLYGON", "sfg")))
  drop <- rep(FALSE, length(g))
  if (trim && (inherits(x, "POLYGON") | inherits(x, "MULTIPOLYGON"))) {


    ## TODO test per-object not per entire set ...
    #drop <- unlist(lapply(st_intersects(st_centroid(st_geometrycollection(g)), x), length)) < 1L
    triangle_centroid <- function(x) cbind(mean(x[,1]), mean(x[,2]))
    sp_points <- as(st_sfc(lapply(g, function(x) sf::st_point(triangle_centroid(x[[1]])))), "Spatial")
    sp_poly <- as(sf::st_set_crs(st_geometry(x), NA), "Spatial")
    drop <- is.na(sp::over(sp_points, sp_poly))
    ## gosh no
    #triangle_centroid <- function(x) cbind(mean(x[,1]), mean(x[,2]))
    ## this is really slow, need to shortcircuit this basic test
    #test <- st_intersects(st_sfc(lapply(g, function(x) st_point(triangle_centroid(x[[1]])))), x)
    #drop <- unlist(test) < 1L
  }

  st_geometrycollection(g[!drop])
}

#' @export
#' @name ct_triangulate
#' @importFrom sf st_precision st_crs st_sfc
ct_triangulate.sfc <- function(x, ...) {
  st_sfc(lapply(x, ct_triangulate, ...), crs = st_crs(x), precision = st_precision(x))
}

# ct_triangulate.GEOMETRYCOLLECTION <- function(x, ...) {
#   st_geometrycollection(unlist(lapply(lapply(x, ct_triangulate), function(x) unclass(x)), recursive = FALSE))
# }
#' @export
#' @name ct_triangulate
#' @importFrom sf st_geometry_type st_geometry st_sfc st_polygon st_sf st_geometrycollection st_centroid st_intersects st_geometry<- st_crs
ct_triangulate.sf <- function(x, trim = TRUE, ...) {
  types <- st_geometry_type(x)
  if (all(types == "POINT")) {
    message("all POINT, returning one feature triangulated")
    xa <- do.call(rbind, lapply(st_geometry(x), function(xy) m_or_v_XY(xy)))
    dupes <- duplicated(as.data.frame(xa))
    if (any(dupes)) {
      message(sprintf("removing %i duplicated coordinates", sum(dupes)))
      xa <- xa[!dupes, , drop = FALSE]
    }
    if (nrow(xa) < 2) {
      warning("less than 3 coordinates, returning empty POLYGON")
      return(st_sf(npoints = nrow(x), geometry = st_sfc(st_polygon(dim = "XY"), crs = st_crs(x))))
    }
    tr <- RTriangle::triangulate(RTriangle::pslg(xa), ...)
    g <- st_sfc(st_geometrycollection(lapply(split(as.vector(t(tr$T)), rep(seq_len(nrow(tr$T)), each = 3)),
                       function(x) structure(list(tr$P[c(x, x[1L]), ]),class = c("XY", "POLYGON", "sfg")))), crs = st_crs(x))

    return(st_sf(npoints = nrow(x), geometry = g))
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
