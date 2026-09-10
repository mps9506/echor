# Downloads EPA ECHO permitted air emitter information

Returns a dataframe or simplefeature dataframe of permitted facilities
returned by the query. Uses EPA's ECHO API:
<https://echo.epa.gov/tools/web-services/facility-search-air#!/Facilities/get_air_rest_services_get_facility_info>

## Usage

``` r
echoAirGetFacilityInfo(output = "df", verbose = FALSE, ...)
```

## Arguments

- output:

  Character string specifying output format. `output = 'df'` for a
  dataframe or `output = 'sf'` for a simple features spatial dataframe.
  See (<https://CRAN.R-project.org/package=sf>) for more information
  about simple features.

- verbose:

  Logical, indicating whether to provide processing and retrieval
  messages. Defaults to FALSE

- ...:

  Further arguments passed as query parameters in request sent to EPA
  ECHO's API. For more options see:
  <https://echo.epa.gov/tools/web-services/facility-search-water#!/Facility_Information/get_air_rest_services_get_facility_info>
  for a complete list of parameter options. Examples provided below.

## Value

dataframe or sf dataframe suitable for plotting

## Examples

``` r
# \donttest{
## These examples require an internet connection to run

## Retrieve table of facilities by bounding box
echoAirGetFacilityInfo(p_c1lon = '-96.407563',
p_c1lat = '30.554395',
p_c2lon = '-96.25947',
p_c2lat = '30.751984',
output = 'df')
#> # A tibble: 40 × 7
#>    AIRName                   SourceID AIRStreet AIRCity AIRState AIRNAICS FacLat
#>    <chr>                     <chr>    <chr>     <chr>   <chr>    <chr>     <dbl>
#>  1 AGGIE CLEANERS            0600000… 111 COLL… COLLEG… TX       999999     30.6
#>  2 ALENCO, DIV OF RELIANT B… TX00000… 615 CARS… BRYAN   TX       332312     30.6
#>  3 ALL SEASONS 1 HR CLEANERS 0600000… 2501 TEX… COLLEG… TX       999999     30.6
#>  4 BLUEBONNET PAVING         TX00000… HWY. 60,… COLLEG… TX       999999     30.6
#>  5 BRIARCREST DRY CLEANERS   0600000… 1887 BRI… BRYAN   TX       999999     30.7
#>  6 BRYAN CERAMICS PLANT      TX00000… 1500 IND… BRYAN   TX       325188 …   30.7
#>  7 BRYAN CLEANERS & LAUNDRY  0600000… 1803 HOL… COLLEG… TX       999999     30.6
#>  8 BRYAN HICKS GAS PLANT     TX00000… 3747 OLD… BRYAN   TX       999999     30.7
#>  9 CITGO PETROLEUM CORPORAT… TX00000… 1714 FIN… BRYAN   TX       999999     30.7
#> 10 CITY OF BRYAN             TX00000… 1.5 MI W… BRYAN   TX       999999     30.6
#> # ℹ 30 more rows

## Retrieve a simple features dataframe by bounding box
spatialdata <- echoAirGetFacilityInfo(p_c1lon = '-96.407563',
p_c1lat = '30.554395',
p_c2lon = '-96.25947',
p_c2lat = '30.751984',
output = 'sf')

# }
```
