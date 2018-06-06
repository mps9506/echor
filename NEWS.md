# echor 0.1.1
* Added `echoWaterGetMeta()` function to retrieve metadata about possible arguments that can be included within `echoWaterGetFacilityInfo()` (closes #28)
* Added default `q_columns` argument to `echoWaterGetFacilityInfo()` to ensure reasonable default columns are returned (#29).
* `echoWaterGetFacilityInfo()` handles clusters returned by ECHO. The function checks if the returned JSON is a cluster, if it is, it uses the qid from the query and the new internal function `echoWaterGetQID()` to return a large data frame of results. Results are limited to 5,000 records.


# echor 0.1.0

* Added a `NEWS.md` file to track changes to the package.
* Intial Release
