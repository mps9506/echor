## Test environments

* local Windows 10, R 3.5.2
* travis-ci: R 3.6.1, R-devel
* appveyor: R 3.6.1
* win-builder (devel)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Reverse dependencies

There are currently no downstream dependencies for this package.

## Comments

This is a release of version 0.1.3,

Other comments:

* This release resolves build failures introduced with the v1.0.0 release of tidyr.

* Examples are wrapped in \donttest{} since they rely on an internet connection and responses from the server can take time.

* Most tests are \skip_on_cran() for the same reason. However, full tests are run on Travis and Appveyor.
