# echor (development version)

## Internal changes
* remove use of `rlang::dots_values()` to avoid upcoming soft depreciation.

# echor (0.1.7)

## Minor Changes
* update email address for author and maintainer.
* reduced dependencies by moving spatial examples to pkgdown articles.

## Bug Fixes
* update url endpoint for metadata services.

## Internal changes
* update pkgdown use and template for consistency with my other packages.
* remove rlang::.data selectors for compatibility with new versions of purrr and tidyselect.
* fixed messages introduced by new versions of readr/vroom when columns are NA.
* vignette is no longer built by CRAN to reduce package dependencies, see the pkgdown website for documentation
* remove the depreciated dplyr based progress bar function and use progress package.
* functions provide message and return nothing if nslookup fails.

# echor 0.1.6

## Bug Fixes

* Removed TidyData in DESCRIPTION.
* Fix output for `echoGetCAAPR()`.
* Update base URL used in webservice.

# echor 0.1.5

## Minor Changes

* `httr::RETRY()` used throughout. (fixes #49)
* Add CITATION.
* vignette and readme use ggspatial instead of ggmap. (fixes #52)

# echor 0.1.4

* `downloadDMRs()` passes arguments properly. This fixes #43.


# echor 0.1.3

## Major Changes (possibly breaking)

* `echoGetEffluent()` and `downloadDMRs()` return columns (or nested columns) as characters only.

## Minor changes

* fix vignette (closes #44)
* import tidyr (v1.0.0)
* utilize httptest for unit testing

# echor 0.1.2

## New functions

* `downloadDMRs()` Returns a tidy dataframe with dmr reports. (closes #38)

## Updated functions

* `echoGetEffluent()` uses a different API call to returns a flat dmr report (one plant at a time). Existing arguments remain the same and still returns a dataframe. (closes #37)

# echor 0.1.1

* Single function returns air and water data; `echoGetFacilities()` and `echoGetReports()` wrap the individual functions to streamline functions that users need to be familiar with. (closes #33)
* Added `echoWaterGetMeta()` and `echoAirGetMeta()` functions to retrieve column metadata returned by `echoWaterGetFacilityInfo()` and `echoAirGetFacilityInfo()`; specify columns returned by respective functions by including qcolumns argument in respective functions.   (closes #28).
* Added default `qcolumns` argument to `echoWaterGetFacilityInfo()` to ensure reasonable default columns are returned (#29).
* `echoWaterGetFacilityInfo()` properly returns large datasets. The new internal function `getDownload()` downloads the entire CSV of queried data as a dataframe (closes #27).
* Added default `qcolumns` argument to `echoAirGetFacilityInfo()` to ensure reasonable default columns are returned (#29).
* `echoAirGetFacilityInfo()`  properly returns large datasets. The new internal function `getDownload()` downloads the entire CSV of queried data as a dataframe (closes #27).
* `echoSDWGetSystems()` downloads data for public drinking water systems.
* `echoSDWGetMeta()` downloads metadata for columns returned by `echoSDWGetSystems()`
* Unit tests for functions that rely on EPA ECHO API utilize `skip_on_cran()` instead of `httptest::with_mock_API()`
* Imported functions are called explicitly eg. `pkg::fun()`

# echor 0.1.0

* Added a `NEWS.md` file to track changes to the package.
* Initial Release
