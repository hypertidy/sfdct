## Test environments
* local Windows install, R 3.3.2
* ubuntu 14.04 (on travis-ci), R 3.3.2
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

New submission

Possibly mis-spelled words in DESCRIPTION:
  Delaunay (5:32)
  triangulations (5:41)
  
Package has a FOSS license but eventually depends on the following
package which restricts use:
  RTriangle
  
Found the following (possibly) invalid URLs:
  URL: https://cran.r-project.org/package=sfct
    From: README.md
    Status: 404
    Message: Not Found
    
* This is a new release.

* These words are as intended. 

* The license is GPL-3, but with the on-dependency of RTriangle. It is intended that
future code could include options for other dependencies to replace or optionally replace this one. 

* The CRAN link pre-empts existence on CRAN. 

## Reverse dependencies

This is a new release, so there are no reverse dependencies.



