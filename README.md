
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/hypertidy/sfdct.svg?branch=master)](https://travis-ci.org/hypertidy/sfdct) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/hypertidy/sfdct?branch=master&svg=true)](https://ci.appveyor.com/project/hypertidy/sfdct) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/sfdct)](https://cran.r-project.org/package=sfdct) [![Coverage Status](https://img.shields.io/codecov/c/github/hypertidy/sfdct/master.svg)](https://codecov.io/github/hypertidy/sfdct?branch=master)

sfdct
=====

The goal of sfdct is to provide constrained triangulation of simple features.

Limitations
-----------

Triangulation is performed with respect to the vertices and edges *per-feature*. This means that each output feature will be composed of triangles that align to all input edges. This will also correspond to the outer hull of any lines or polygons. In a GEOMETRYCOLLECTION the same alignment only applies to geometries individually within the collection, so lines and polygons and point sets are all triangulated as if they were independent.

A future release will triangulate the GEOMETRYCOLLECTION as it it were one set of edges and vertices. This will also allow an entire data set to be triangulated as one.

It's not yet clear to me how to best maintain the original feature identity for the "entire data set" case, or if this even matters. Please get in touch if you are interested!

More general structures for working with grouped simplicial complex data structures are in the works, but aligning with simple features in this package provides a useful illustration of these nuances and how far we can push the standard tools.

Example
-------

This is a basic example which shows you how to decompose a MULTIPOLYGON `sf` data frame object into a GEOMETRYCOLLECTION `sf` data frame object made of triangles:

``` r
library(sf)
#> Linking to GEOS 3.5.1, GDAL 2.2.3, proj.4 4.9.3
library(sfdct)
nc <- read_sf(system.file("shape/nc.shp", package="sf"), quiet = TRUE)
(nc_triangles <- ct_triangulate(nc[1:5, c("NAME")]))
#> Simple feature collection with 5 features and 1 field
#> geometry type:  GEOMETRYCOLLECTION
#> dimension:      XY
#> bbox:           xmin: -81.74107 ymin: 36.07282 xmax: -75.77316 ymax: 36.58965
#> epsg (SRID):    4267
#> proj4string:    +proj=longlat +datum=NAD27 +no_defs
#> # A tibble: 5 x 2
#>   NAME                              geometry
#>   <chr>                     <simple_feature>
#> 1 Ashe        GEOMETRYCOLLECTION (POLYGON...
#> 2 Alleghany   GEOMETRYCOLLECTION (POLYGON...
#> 3 Surry       GEOMETRYCOLLECTION (POLYGON...
#> 4 Currituck   GEOMETRYCOLLECTION (POLYGON...
#> 5 Northampton GEOMETRYCOLLECTION (POLYGON...

(asub <- st_geometry(nc_triangles)[[4]] )
#> GEOMETRYCOLLECTION (POLYGON ((-76.091064453125 36.5035667419434, -76.1581497192383 36.4126892089844, -76.095085144043 36.3489151000977, -76.091064453125 36.5035667419434)), POLYGON ((-76.1581497192383 36.4126892089844, -76.1609268188477 36.3918991088867, -76.095085144043 36.3489151000977, -76.1581497192383 36.4126892089844)), POLYGON ((-76.095085144043 36.3489151000977, -76.0439529418945 36.3535919189453, -76.0016098022461 36.4189147949219, -76.095085144043 36.3489151000977)), POLYGON ((-76.0016098022461 36.4189147949219, -76.0439529418945 36.3535919189453, -76.0173492431641 36.3377304077148, -76.0016098022461 36.4189147949219)), POLYGON ((-75.9512557983398 36.3654708862305, -76.0016098022461 36.4189147949219, -76.0173492431641 36.3377304077148, -75.9512557983398 36.3654708862305)), POLYGON ((-76.0173492431641 36.3377304077148, -76.0439529418945 36.3535919189453, -76.0328750610352 36.3359756469727, -76.0173492431641 36.3377304077148)), POLYGON ((-76.091064453125 36.5035667419434, -76.095085144043 36.3489151000977, -76.0016098022461 36.4189147949219, -76.091064453125 36.5035667419434)), POLYGON ((-76.1682891845703 36.4270858764648, -76.091064453125 36.5035667419434, -76.1273956298828 36.5571632385254, -76.1682891845703 36.4270858764648)), POLYGON ((-76.1682891845703 36.4270858764648, -76.1581497192383 36.4126892089844, -76.091064453125 36.5035667419434, -76.1682891845703 36.4270858764648)), POLYGON ((-76.1273956298828 36.5571632385254, -76.3302536010742 36.5560569763184, -76.1682891845703 36.4270858764648, -76.1273956298828 36.5571632385254)), POLYGON ((-76.091064453125 36.5035667419434, -76.0459594726562 36.5569534301758, -76.1273956298828 36.5571632385254, -76.091064453125 36.5035667419434)), POLYGON ((-76.0271682739258 36.5567169189453, -75.9762878417969 36.5179252624512, -75.998664855957 36.5566520690918, -76.0271682739258 36.5567169189453)), POLYGON ((-76.0016098022461 36.4189147949219, -75.97607421875 36.4362144470215, -76.091064453125 36.5035667419434, -76.0016098022461 36.4189147949219)), POLYGON ((-76.0332107543945 36.5143737792969, -76.0459594726562 36.5569534301758, -76.091064453125 36.5035667419434, -76.0332107543945 36.5143737792969)), POLYGON ((-75.9512557983398 36.3654708862305, -76.0173492431641 36.3377304077148, -76.0089721679688 36.3195953369141, -75.9512557983398 36.3654708862305)), POLYGON ((-75.9575119018555 36.2594528198242, -75.9137649536133 36.244800567627, -75.9419326782227 36.2943382263184, -75.9575119018555 36.2594528198242)), POLYGON ((-75.9419326782227 36.2943382263184, -75.9512557983398 36.3654708862305, -76.0089721679688 36.3195953369141, -75.9419326782227 36.2943382263184)), POLYGON ((-75.9245910644531 36.3509483337402, -75.9419326782227 36.2943382263184, -75.9137649536133 36.244800567627, -75.9245910644531 36.3509483337402)), POLYGON ((-75.8000564575195 36.1128158569336, -75.9137649536133 36.244800567627, -75.8551635742188 36.1056671142578, -75.8000564575195 36.1128158569336)), POLYGON ((-75.9512557983398 36.3654708862305, -75.9419326782227 36.2943382263184, -75.9245910644531 36.3509483337402, -75.9512557983398 36.3654708862305)), POLYGON ((-75.8551635742188 36.1056671142578, -75.7988510131836 36.0728187561035, -75.8000564575195 36.1128158569336, -75.8551635742188 36.1056671142578)), POLYGON ((-75.8781661987305 36.5558738708496, -75.7831726074219 36.2251930236816, -75.7731552124023 36.2292556762695, -75.8781661987305 36.5558738708496)), POLYGON ((-75.9137649536133 36.244800567627, -75.8000564575195 36.1128158569336, -75.9245910644531 36.3509483337402, -75.9137649536133 36.244800567627)), POLYGON ((-75.9762878417969 36.5179252624512, -75.9772796630859 36.4780158996582, -75.9248046875 36.4739761352539, -75.9762878417969 36.5179252624512)), POLYGON ((-75.97607421875 36.4362144470215, -76.0016098022461 36.4189147949219, -75.9697647094727 36.4151191711426, -75.97607421875 36.4362144470215)), POLYGON ((-75.7831726074219 36.2251930236816, -75.8781661987305 36.5558738708496, -75.901985168457 36.5561981201172, -75.7831726074219 36.2251930236816)), POLYGON ((-75.9248046875 36.4739761352539, -75.9119186401367 36.5425300598145, -75.9762878417969 36.5179252624512, -75.9248046875 36.4739761352539)), POLYGON ((-75.9512557983398 36.3654708862305, -75.9245910644531 36.3509483337402, -75.9281234741211 36.4232444763184, -75.9512557983398 36.3654708862305)), POLYGON ((-75.9119186401367 36.5425300598145, -75.998664855957 36.5566520690918, -75.9762878417969 36.5179252624512, -75.9119186401367 36.5425300598145)))
```

Denser triangles, and optionally `D` for ensuring Delaunay criterion is met.

``` r
st_geometry(ct_triangulate(nc[4, ], a = 0.0007, D = TRUE))
#> Geometry set for 1 feature 
#> geometry type:  GEOMETRYCOLLECTION
#> dimension:      XY
#> bbox:           xmin: -76.33025 ymin: 36.07282 xmax: -75.77316 ymax: 36.55716
#> epsg (SRID):    4267
#> proj4string:    +proj=longlat +datum=NAD27 +no_defs
#> GEOMETRYCOLLECTION (POLYGON ((-76.0277068229108...
```

See the vignettes for more examples.

If you are interested in development in this area see [laridae](https://github.com/hypertidy/laridae) which aims to provide a more powerful facility for finite element decomposition for complex shapes using CGAL. We'll also put an ear-clipping version, from rgl into [silicate](https://github.com/hypertidy/silicate)

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
