# echor 0.1.5 (unreleased)

## Minor Changes

* `httr::RETRY()` used throughout. (fixes #49)
* Add CITATION

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
