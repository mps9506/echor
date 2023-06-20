## Test environments

* GitHub Actions (macOS), release
* GitHub Actions (windows), release
* GitHub Actions (ubuntu-22.04.2), release, devel
* R-hub (windows), devel
* R-hub (fedora-clang-devel) devel
* win-builder (windows), devel

## R CMD check results

0 errors | 0 warnings | 1 note

## Reverse dependencies

There are currently no downstream dependencies for this package.

## Comments

* This release fixes current check errors in examples. All functions now 
correctly return a message with no warning or error when internet resources are 
not available or have changed.

Other comments:

* Examples are wrapped in \donttest{} since they rely on an internet connection 
and API will rate limit when automatically tested or run.

