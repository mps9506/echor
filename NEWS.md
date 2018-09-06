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
* Intial Release
