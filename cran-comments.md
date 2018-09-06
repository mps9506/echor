## Test environments

* local Windows 10, R 3.5.0
* travis-ci: R 3.5.0, R-devel
* appveyor: R 3.5.1
* win-builder (devel)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Reverse dependencies

There are currently no downstream dependencies for this package.

## Comments

This is a release of version 0.1.1.

* Examples are wrapped in \donttest{} since they rely on an internet connection and responses from the server can take time.

* Most tests are \skip_on_cran() for the same reason. However, full tests are run on Travis and Appveyor.
