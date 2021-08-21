## Test environments

* GitHub Actions (macOS), release
* GitHub Actions (windows), release
* GitHub Actions (ubuntu-20.04), release, devel
* R-hub (fedora-clang-devel) devel

## R CMD check results

0 errors | 0 warnings | 0 notes

## Reverse dependencies

There are currently no downstream dependencies for this package.

## Comments

This is a release of version 0.1.6, it primarily fixes notes and warnings shown on the CRAN check page.
It also updates the API address used by the API.

Other comments:

* Examples are wrapped in \donttest{} since they rely on an internet connection and API will rate limit when automatically tested or run.

