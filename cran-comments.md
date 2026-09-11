## Test environments

* GitHub Actions (macOS), release
* GitHub Actions (windows), release
* GitHub Actions (ubuntu-24.04.5), release, devel, oldrel
* win-builder (windows), release, devel

## R CMD check results

0 errors | 0 warnings | 1 note

## Reverse dependencies

There are currently no downstream dependencies for this package.

## Comments

* This minor release provides several new functions and updates arguments for consistency with changes in the source web API.

Other comments:

* Examples are wrapped in \donttest{} since they rely on an internet connection 
and API will rate limit when automatically tested or run.

