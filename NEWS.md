# sfdct 0.0.3

* first CRAN release 

* fixed lurking bug in all-POINT logic, ... was passed to pslg 

# sfdct 0.0.2

* GEOMETRYCOLLECTION is now supported with an internal function only

* GEOMETRYCOLLECTION now supported, but only as sub-geometries treated like features - a future release will triangulate a simplicial complex of the GC

* introduced use of sp::over so that intersection tests are fast enough, will 
clean this up in future

* now properly returns GEOMETRYCOLLECTION of POLYGON triangles for sfg, sfc, and sf classes. Previous versions always returned either sf or sfc, so this wasn't consistent. 

* more coverage of types, will at least work for the non-exotics in an sf dataframe

* first release



