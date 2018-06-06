# echor 0.1.1

* Added `echoWaterGetMeta()` and `echoAirGetMeta()` functions to retrieve metadata about possible arguments that can be included within `echoWaterGetFacilityInfo()` and `echoAirGetFacilityInfo()` (closes #28).
* Added default `q_columns` argument to `echoWaterGetFacilityInfo()` to ensure reasonable default columns are returned (#29).
* `echoWaterGetFacilityInfo()` handles clusters returned by ECHO. The function checks if the returned JSON is a cluster, if it is, it uses the qid from the query and the new internal function `echoWaterGetQID()` to return a large data frame of results. Results are limited to 5,000 records (closes #27).
* Added default `q_columns` argument to `echoAirGetFacilityInfo()` to ensure reasonable default columns are returned (#29).
* `echoAirGetFacilityInfo()` handles clusters returned by ECHO. The function checkis if the returned JSON is a cluster, if it is, it uses the qid from the query and the new internal function `echoAirGetQID()` to return a large data frame of results. Results are limited to 5,000 records (closes #27).


# echor 0.1.0

* Added a `NEWS.md` file to track changes to the package.
* Intial Release
