# sfdct 0.0.2

* introduced use of sp::over so that intersection tests are fast enough, will 
clean this up in future

* now properly returns GEOMETRYCOLLECTION of POLYGON triangles for sfg, sfc, and sf classes. Previous versions always returned either sf or sfc, so this wasn't consistent. 

* more coverage of types, will at least work for the non-exotics in an sf dataframe

* first release


