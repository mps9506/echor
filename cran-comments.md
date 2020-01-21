## Test environments

* local Windows 10, R 3.5.2
* travis-ci: R 3.6.2, R-devel
* appveyor: R 3.6.2
* win-builder R 3.6.2, R-devel

## R CMD check results

0 errors | 0 warnings | 0 notes

## Reverse dependencies

There are currently no downstream dependencies for this package.

## Comments

This is a release of version 0.1.4

Other comments:

* This release resolves the 1 NOTE in the CRAN Package Check Results caused by an unused declared Import. The release also resolves bugs caused by an update to the web API.

* Examples are wrapped in \donttest{} since they rely on an internet connection and responses from the server can take time.

* Most tests are \skip_on_cran() for the same reason. However, full tests are run on Travis and Appveyor.
