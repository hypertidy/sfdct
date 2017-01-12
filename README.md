<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/r-gris/sfdct.svg?branch=master)](https://travis-ci.org/r-gris/sfdct) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/r-gris/sfdct?branch=master&svg=true)](https://ci.appveyor.com/project/r-gris/sfdct) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/sfdct)](https://cran.r-project.org/package=sfdct)

sfdct
====

The goal of sfct is to provide constrained triangulations of simple features.

Example
-------

This is a basic example which shows you how to decompose a MULTIPOLYGON `sf` data frame object into a GEOMETRYCOLLECTION `sf` data frame object made of triangles:

``` r
library(sf)
#> Linking to GEOS 3.5.0, GDAL 2.1.1, proj.4 4.9.3
library(sfct)
nc <- st_read(system.file("shape/nc.shp", package="sf"))
#> Reading layer `nc' from data source `C:\Users\mdsumner\Documents\R\win-library\3.3\sf\shape\nc.shp' using driver `ESRI Shapefile'
#> converted into: MULTIPOLYGON
#> Simple feature collection with 100 features and 14 fields
#> geometry type:  MULTIPOLYGON
#> dimension:      XY
#> bbox:           xmin: -84.32385 ymin: 33.88199 xmax: -75.45698 ymax: 36.58965
#> epsg (SRID):    4267
#> proj4string:    +proj=longlat +datum=NAD27 +no_defs
(nc_triangles <- ct_triangulate(nc))
#> Simple feature collection with 100 features and 14 fields
#> geometry type:  GEOMETRYCOLLECTION
#> dimension:      XY
#> bbox:           xmin: -84.32385 ymin: 33.88199 xmax: -75.45698 ymax: 36.58965
#> epsg (SRID):    4267
#> proj4string:    +proj=longlat +datum=NAD27 +no_defs
#> First 20 features:
#>     AREA PERIMETER CNTY_ CNTY_ID        NAME  FIPS FIPSNO CRESS_ID BIR74
#> 1  0.114     1.442  1825    1825        Ashe 37009  37009        5  1091
#> 2  0.061     1.231  1827    1827   Alleghany 37005  37005        3   487
#> 3  0.143     1.630  1828    1828       Surry 37171  37171       86  3188
#> 4  0.070     2.968  1831    1831   Currituck 37053  37053       27   508
#> 5  0.153     2.206  1832    1832 Northampton 37131  37131       66  1421
#> 6  0.097     1.670  1833    1833    Hertford 37091  37091       46  1452
#> 7  0.062     1.547  1834    1834      Camden 37029  37029       15   286
#> 8  0.091     1.284  1835    1835       Gates 37073  37073       37   420
#> 9  0.118     1.421  1836    1836      Warren 37185  37185       93   968
#> 10 0.124     1.428  1837    1837      Stokes 37169  37169       85  1612
#> 11 0.114     1.352  1838    1838     Caswell 37033  37033       17  1035
#> 12 0.153     1.616  1839    1839  Rockingham 37157  37157       79  4449
#> 13 0.143     1.663  1840    1840   Granville 37077  37077       39  1671
#> 14 0.109     1.325  1841    1841      Person 37145  37145       73  1556
#> 15 0.072     1.085  1842    1842       Vance 37181  37181       91  2180
#> 16 0.190     2.204  1846    1846     Halifax 37083  37083       42  3608
#> 17 0.053     1.171  1848    1848  Pasquotank 37139  37139       70  1638
#> 18 0.199     1.984  1874    1874      Wilkes 37193  37193       97  3146
#> 19 0.081     1.288  1880    1880     Watauga 37189  37189       95  1323
#> 20 0.063     1.000  1881    1881  Perquimans 37143  37143       72   484
#>    SID74 NWBIR74 BIR79 SID79 NWBIR79                       geometry
#> 1      1      10  1364     0      19 GEOMETRYCOLLECTION(POLYGON(...
#> 2      0      10   542     3      12 GEOMETRYCOLLECTION(POLYGON(...
#> 3      5     208  3616     6     260 GEOMETRYCOLLECTION(POLYGON(...
#> 4      1     123   830     2     145 GEOMETRYCOLLECTION(POLYGON(...
#> 5      9    1066  1606     3    1197 GEOMETRYCOLLECTION(POLYGON(...
#> 6      7     954  1838     5    1237 GEOMETRYCOLLECTION(POLYGON(...
#> 7      0     115   350     2     139 GEOMETRYCOLLECTION(POLYGON(...
#> 8      0     254   594     2     371 GEOMETRYCOLLECTION(POLYGON(...
#> 9      4     748  1190     2     844 GEOMETRYCOLLECTION(POLYGON(...
#> 10     1     160  2038     5     176 GEOMETRYCOLLECTION(POLYGON(...
#> 11     2     550  1253     2     597 GEOMETRYCOLLECTION(POLYGON(...
#> 12    16    1243  5386     5    1369 GEOMETRYCOLLECTION(POLYGON(...
#> 13     4     930  2074     4    1058 GEOMETRYCOLLECTION(POLYGON(...
#> 14     4     613  1790     4     650 GEOMETRYCOLLECTION(POLYGON(...
#> 15     4    1179  2753     6    1492 GEOMETRYCOLLECTION(POLYGON(...
#> 16    18    2365  4463    17    2980 GEOMETRYCOLLECTION(POLYGON(...
#> 17     3     622  2275     4     933 GEOMETRYCOLLECTION(POLYGON(...
#> 18     4     200  3725     7     222 GEOMETRYCOLLECTION(POLYGON(...
#> 19     1      17  1775     1      33 GEOMETRYCOLLECTION(POLYGON(...
#> 20     1     230   676     0     310 GEOMETRYCOLLECTION(POLYGON(...
```

See the vignettes for more examples.

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
