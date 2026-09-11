# Changelog

## echor 0.1.10

### New Functions

- [`echoNNCRGetReport()`](https://mps9506.github.io/echor/reference/echoNNCRGetReport.md),
  [`echoNNCRGetViolations()`](https://mps9506.github.io/echor/reference/echoNNCRGetViolations.md),
  [`echoNNCRGetSearch()`](https://mps9506.github.io/echor/reference/echoNNCRGetSearch.md)
  for searching NPDES Noncompliance Reports.

### Bug Fixes

- Update examples in
  [`echoWaterGetFacilityInfo()`](https://mps9506.github.io/echor/reference/echoWaterGetFacilityInfo.md).
  The allowable values for `p_pcomp` were changed by EPA resulting in
  zero values returned. (fixes
  [\#94](https://github.com/mps9506/echor/issues/94))

### Minor Changes

- There is no longer an (unknown) upper limit on the values returned
  when requesting an `sf` dataframe. Previously, ECHO returned
  “clusters” instead of records when a large number of records were
  requested. ECHO no provides a different endpoint to request clusters.
  This package does not currently provide a function to access the
  clusters endpoint.

### Regression

- various \_getFacilityInfo() functions no longer return valid query
  results when query sets would return \>100,000 records. This is a
  change in the ECHO server. You will now receive a message to modify
  the query to return fewer results. (fixes
  [\#93](https://github.com/mps9506/echor/issues/93))

## echor 0.1.9

CRAN release: 2023-06-22

- when server responses != 200 or 202, functions return an invisible
  NULL with a message instead of an error and message. (fixes
  [\#87](https://github.com/mps9506/echor/issues/87))
- removed geojsonsf dependency.
- \_getFacilityInfo() functions return an invisible NULL with message
  instead of stopping with error if too many records are requested in sf
  format.

## echor 0.1.8

CRAN release: 2023-04-23

### Bug Fixes

- various \_getFacilityInfo() functions now properly return records when
  more then 100,000 records are returned. (fixes
  [\#79](https://github.com/mps9506/echor/issues/79))
- \_getFacilityInfo() functions stop and a message is returned if too
  many records are requested in sf format.

### Internal changes

- remove use of
  [`rlang::dots_values()`](https://rlang.r-lib.org/reference/dots_values.html)
  to avoid upcoming soft depreciation. (fixes
  [\#77](https://github.com/mps9506/echor/issues/77))

## echor 0.1.7

CRAN release: 2023-02-13

### Minor Changes

- update email address for author and maintainer.
- reduced dependencies by moving spatial examples to pkgdown articles.

### Bug Fixes

- update url endpoint for metadata services.

### Internal changes

- update pkgdown use and template for consistency with my other
  packages.
- remove rlang::.data selectors for compatibility with new versions of
  purrr and tidyselect.
- fixed messages introduced by new versions of readr/vroom when columns
  are NA.
- vignette is no longer built by CRAN to reduce package dependencies,
  see the pkgdown website for documentation
- remove the depreciated dplyr based progress bar function and use
  progress package.
- functions provide message and return nothing if nslookup fails.

## echor 0.1.6

CRAN release: 2021-08-21

### Bug Fixes

- Removed TidyData in DESCRIPTION.
- Fix output for
  [`echoGetCAAPR()`](https://mps9506.github.io/echor/reference/echoGetCAAPR.md).
- Update base URL used in webservice.

## echor 0.1.5

CRAN release: 2020-08-05

### Minor Changes

- [`httr::RETRY()`](https://httr.r-lib.org/reference/RETRY.html) used
  throughout. (fixes [\#49](https://github.com/mps9506/echor/issues/49))
- Add CITATION.
- vignette and readme use ggspatial instead of ggmap. (fixes
  [\#52](https://github.com/mps9506/echor/issues/52))

## echor 0.1.4

CRAN release: 2020-01-29

- [`downloadDMRs()`](https://mps9506.github.io/echor/reference/downloadDMRs.md)
  passes arguments properly. This fixes
  [\#43](https://github.com/mps9506/echor/issues/43).

## echor 0.1.3

CRAN release: 2019-09-18

### Major Changes (possibly breaking)

- [`echoGetEffluent()`](https://mps9506.github.io/echor/reference/echoGetEffluent.md)
  and
  [`downloadDMRs()`](https://mps9506.github.io/echor/reference/downloadDMRs.md)
  return columns (or nested columns) as characters only.

### Minor changes

- fix vignette (closes
  [\#44](https://github.com/mps9506/echor/issues/44))
- import tidyr (v1.0.0)
- utilize httptest for unit testing

## echor 0.1.2

CRAN release: 2019-02-03

### New functions

- [`downloadDMRs()`](https://mps9506.github.io/echor/reference/downloadDMRs.md)
  Returns a tidy dataframe with dmr reports. (closes
  [\#38](https://github.com/mps9506/echor/issues/38))

### Updated functions

- [`echoGetEffluent()`](https://mps9506.github.io/echor/reference/echoGetEffluent.md)
  uses a different API call to returns a flat dmr report (one plant at a
  time). Existing arguments remain the same and still returns a
  dataframe. (closes [\#37](https://github.com/mps9506/echor/issues/37))

## echor 0.1.1

CRAN release: 2018-09-11

- Single function returns air and water data;
  [`echoGetFacilities()`](https://mps9506.github.io/echor/reference/echoGetFacilities.md)
  and
  [`echoGetReports()`](https://mps9506.github.io/echor/reference/echoGetReports.md)
  wrap the individual functions to streamline functions that users need
  to be familiar with. (closes
  [\#33](https://github.com/mps9506/echor/issues/33))
- Added
  [`echoWaterGetMeta()`](https://mps9506.github.io/echor/reference/echoWaterGetMeta.md)
  and
  [`echoAirGetMeta()`](https://mps9506.github.io/echor/reference/echoAirGetMeta.md)
  functions to retrieve column metadata returned by
  [`echoWaterGetFacilityInfo()`](https://mps9506.github.io/echor/reference/echoWaterGetFacilityInfo.md)
  and
  [`echoAirGetFacilityInfo()`](https://mps9506.github.io/echor/reference/echoAirGetFacilityInfo.md);
  specify columns returned by respective functions by including qcolumns
  argument in respective functions. (closes
  [\#28](https://github.com/mps9506/echor/issues/28)).
- Added default `qcolumns` argument to
  [`echoWaterGetFacilityInfo()`](https://mps9506.github.io/echor/reference/echoWaterGetFacilityInfo.md)
  to ensure reasonable default columns are returned
  ([\#29](https://github.com/mps9506/echor/issues/29)).
- [`echoWaterGetFacilityInfo()`](https://mps9506.github.io/echor/reference/echoWaterGetFacilityInfo.md)
  properly returns large datasets. The new internal function
  `getDownload()` downloads the entire CSV of queried data as a
  dataframe (closes [\#27](https://github.com/mps9506/echor/issues/27)).
- Added default `qcolumns` argument to
  [`echoAirGetFacilityInfo()`](https://mps9506.github.io/echor/reference/echoAirGetFacilityInfo.md)
  to ensure reasonable default columns are returned
  ([\#29](https://github.com/mps9506/echor/issues/29)).
- [`echoAirGetFacilityInfo()`](https://mps9506.github.io/echor/reference/echoAirGetFacilityInfo.md)
  properly returns large datasets. The new internal function
  `getDownload()` downloads the entire CSV of queried data as a
  dataframe (closes [\#27](https://github.com/mps9506/echor/issues/27)).
- [`echoSDWGetSystems()`](https://mps9506.github.io/echor/reference/echoSDWGetSystems.md)
  downloads data for public drinking water systems.
- [`echoSDWGetMeta()`](https://mps9506.github.io/echor/reference/echoSDWGetMeta.md)
  downloads metadata for columns returned by
  [`echoSDWGetSystems()`](https://mps9506.github.io/echor/reference/echoSDWGetSystems.md)
- Unit tests for functions that rely on EPA ECHO API utilize
  `skip_on_cran()` instead of `httptest::with_mock_API()`
- Imported functions are called explicitly eg. `pkg::fun()`

## echor 0.1.0

CRAN release: 2018-04-23

- Added a `NEWS.md` file to track changes to the package.
- Initial Release
