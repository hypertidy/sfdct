
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![R build
status](https://github.com/hypertidy/sfdct/workflows/R-CMD-check/badge.svg)](https://github.com/hypertidy/sfdct/actions)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/sfdct)](https://cran.r-project.org/package=sfdct)
[![R build
status](https://github.com/hypertidy/sfdct/workflows/pkgdown/badge.svg)](https://github.com/hypertidy/sfdct/actions)
[![R build
status](https://github.com/hypertidy/sfdct/workflows/test-coverage/badge.svg)](https://github.com/hypertidy/sfdct/actions)
<!-- badges: end -->

# sfdct

The goal of sfdct is to provide constrained triangulation of simple
features.

## Limitations

Triangulation is performed with respect to the vertices and edges
*per-feature*. This means that each output feature will be composed of
triangles that align to all input edges. This will also correspond to
the outer hull of any lines or polygons. In a GEOMETRYCOLLECTION the
same alignment only applies to geometries individually within the
collection, so lines and polygons and point sets are all triangulated as
if they were independent.

A future release will triangulate the GEOMETRYCOLLECTION as it it were
one set of edges and vertices. This will also allow an entire data set
to be triangulated as one.

It’s not yet clear to me how to best maintain the original feature
identity for the “entire data set” case, or if this even matters. Please
get in touch if you are interested\!

More general structures for working with grouped simplicial complex data
structures are in the works, but aligning with simple features in this
package provides a useful illustration of these nuances and how far we
can push the standard tools.

## Example

This is a basic example which shows you how to decompose a MULTIPOLYGON
`sf` data frame object into a GEOMETRYCOLLECTION `sf` data frame object
made of triangles:

``` r
library(sf)
#> Linking to GEOS 3.8.0, GDAL 3.0.4, PROJ 7.0.0
library(sfdct)
nc <- read_sf(system.file("shape/nc.shp", package="sf"), quiet = TRUE)
(nc_triangles <- ct_triangulate(nc[1:5, c("NAME")]))
#> Simple feature collection with 5 features and 1 field
#> geometry type:  GEOMETRYCOLLECTION
#> dimension:      XY
#> bbox:           xmin: -81.74107 ymin: 36.07282 xmax: -75.77316 ymax: 36.58965
#> geographic CRS: NAD27
#> # A tibble: 5 x 2
#>   NAME                                                                  geometry
#>   <chr>                                                 <GEOMETRYCOLLECTION [°]>
#> 1 Ashe       GEOMETRYCOLLECTION (POLYGON ((-81.54084 36.27251, -81.47276 36.234…
#> 2 Alleghany  GEOMETRYCOLLECTION (POLYGON ((-81.24069 36.37942, -81.23989 36.365…
#> 3 Surry      GEOMETRYCOLLECTION (POLYGON ((-80.87086 36.32462, -80.87438 36.233…
#> 4 Currituck  GEOMETRYCOLLECTION (POLYGON ((-76.09106 36.50357, -76.15815 36.412…
#> 5 Northampt… GEOMETRYCOLLECTION (POLYGON ((-77.53808 36.30246, -77.58008 36.328…

(asub <- st_geometry(nc_triangles)[[4]] )
#> GEOMETRYCOLLECTION (POLYGON ((-76.09106 36.50357, -76.15815 36.41269, -76.09509 36.34892, -76.09106 36.50357)), POLYGON ((-76.15815 36.41269, -76.16093 36.3919, -76.09509 36.34892, -76.15815 36.41269)), POLYGON ((-76.09509 36.34892, -76.04395 36.35359, -76.00161 36.41891, -76.09509 36.34892)), POLYGON ((-76.00161 36.41891, -76.04395 36.35359, -76.01735 36.33773, -76.00161 36.41891)), POLYGON ((-75.95126 36.36547, -76.00161 36.41891, -76.01735 36.33773, -75.95126 36.36547)), POLYGON ((-76.01735 36.33773, -76.04395 36.35359, -76.03288 36.33598, -76.01735 36.33773)), POLYGON ((-76.09106 36.50357, -76.09509 36.34892, -76.00161 36.41891, -76.09106 36.50357)), POLYGON ((-76.16829 36.42709, -76.09106 36.50357, -76.1274 36.55716, -76.16829 36.42709)), POLYGON ((-76.16829 36.42709, -76.15815 36.41269, -76.09106 36.50357, -76.16829 36.42709)), POLYGON ((-76.1274 36.55716, -76.33025 36.55606, -76.16829 36.42709, -76.1274 36.55716)), POLYGON ((-76.09106 36.50357, -76.04596 36.55695, -76.1274 36.55716, -76.09106 36.50357)), POLYGON ((-76.02717 36.55672, -75.97629 36.51793, -75.99866 36.55665, -76.02717 36.55672)), POLYGON ((-76.00161 36.41891, -75.97607 36.43621, -76.09106 36.50357, -76.00161 36.41891)), POLYGON ((-76.03321 36.51437, -76.04596 36.55695, -76.09106 36.50357, -76.03321 36.51437)), POLYGON ((-75.95126 36.36547, -76.01735 36.33773, -76.00897 36.3196, -75.95126 36.36547)), POLYGON ((-75.95751 36.25945, -75.91376 36.2448, -75.94193 36.29434, -75.95751 36.25945)), POLYGON ((-75.94193 36.29434, -75.95126 36.36547, -76.00897 36.3196, -75.94193 36.29434)), POLYGON ((-75.92459 36.35095, -75.94193 36.29434, -75.91376 36.2448, -75.92459 36.35095)), POLYGON ((-75.80006 36.11282, -75.91376 36.2448, -75.85516 36.10567, -75.80006 36.11282)), POLYGON ((-75.95126 36.36547, -75.94193 36.29434, -75.92459 36.35095, -75.95126 36.36547)), POLYGON ((-75.85516 36.10567, -75.79885 36.07282, -75.80006 36.11282, -75.85516 36.10567)), POLYGON ((-75.87817 36.55587, -75.78317 36.22519, -75.77316 36.22926, -75.87817 36.55587)), POLYGON ((-75.91376 36.2448, -75.80006 36.11282, -75.92459 36.35095, -75.91376 36.2448)), POLYGON ((-75.97629 36.51793, -75.97728 36.47802, -75.9248 36.47398, -75.97629 36.51793)), POLYGON ((-75.97607 36.43621, -76.00161 36.41891, -75.96976 36.41512, -75.97607 36.43621)), POLYGON ((-75.78317 36.22519, -75.87817 36.55587, -75.90199 36.5562, -75.78317 36.22519)), POLYGON ((-75.9248 36.47398, -75.91192 36.54253, -75.97629 36.51793, -75.9248 36.47398)), POLYGON ((-75.95126 36.36547, -75.92459 36.35095, -75.92812 36.42324, -75.95126 36.36547)), POLYGON ((-75.91192 36.54253, -75.99866 36.55665, -75.97629 36.51793, -75.91192 36.54253)))
```

Denser triangles, and optionally `D` for ensuring Delaunay criterion is
met.

``` r
st_geometry(ct_triangulate(nc[4, ], a = 0.0007, D = TRUE))
#> Geometry set for 1 feature 
#> geometry type:  GEOMETRYCOLLECTION
#> dimension:      XY
#> bbox:           xmin: -76.33025 ymin: 36.07282 xmax: -75.77316 ymax: 36.55716
#> geographic CRS: NAD27
#> GEOMETRYCOLLECTION (POLYGON ((-76.02771 36.4037...
```

See the vignettes for more examples.

If you are interested in development in this area see
[laridae](https://github.com/hypertidy/laridae) which aims to provide a
more powerful facility for finite element decomposition for complex
shapes using CGAL. We’ll also put an ear-clipping version, from rgl into
[silicate](https://github.com/hypertidy/silicate)

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.
