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

* This release provides minor bug fixes for end users and removes 
  `rlang::dots_values()` due to upcoming soft depreciation.

Other comments:

* Examples are wrapped in \donttest{} since they rely on an internet connection 
  and API will rate limit when automatically tested or run.

