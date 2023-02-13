## Test environments

* GitHub Actions (macOS), release
* GitHub Actions (windows), release
* GitHub Actions (ubuntu-20.04), release, devel
* R-hub (windows), devel
* R-hub (fedora-clang-devel) devel
* win-builder (windows), devel

## R CMD check results

0 errors | 0 warnings | 1 note

## Reverse dependencies

There are currently no downstream dependencies for this package.

## Comments

* This release changes the email address for the maintainer, the old address is
still and active for confirmation. 
* This is a minor release including minor bug fixes and reduces package 
dependencies on long-building packages.

Other comments:

* Examples are wrapped in \donttest{} since they rely on an internet connection 
  and API will rate limit when automatically tested or run.

