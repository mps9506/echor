# Downloads EPA ECHO water facility information

Returns a dataframe or simplefeature dataframe of permitted facilities
returned by the query. Uses EPA's ECHO API:
<https://echo.epa.gov/tools/web-services/facility-search-water>.

## Usage

``` r
echoWaterGetFacilityInfo(output = "df", verbose = FALSE, ...)
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
  <https://echo.epa.gov/tools/web-services/facility-search-water#!/Facility_Information/get_cwa_rest_services_get_facility_info>
  for a complete list of parameter options. Examples provided below.

## Value

returns a dataframe or simple features dataframe

## Examples

``` r
# \donttest{
## These examples require an internet connection to run

## Retrieve table of facilities by bounding box
echoWaterGetFacilityInfo(p_c1lon = '-96.407563',
p_c1lat = '30.554395',
p_c2lon = '-96.25947',
p_c2lat = '30.751984',
p_pcomp = 'POT',
output = 'df')
#> # A tibble: 4 × 26
#>   CWPName            SourceID CWPStreet CWPCity CWPState CWPStateDistrict CWPZip
#>   <chr>              <chr>    <chr>     <chr>   <chr>    <chr>            <chr> 
#> 1 BURTON CREEK WWTP  TX00226… 300 PARK… BRYAN   TX       09               77802 
#> 2 CARTERS CREEK WWTP TX00471… 2200 N F… COLLEG… TX       09               77845 
#> 3 TAMU MAIN CAMPUS … TX01081… 9685 WHI… COLLEG… TX       09               77843 
#> 4 TURKEY CREEK WWTP  TX00624… 3000FT W… BRYAN   TX       09               77807 
#> # ℹ 19 more variables: MasterExternalPermitNmbr <chr>, RegistryID <chr>,
#> #   EPASystem <chr>, Statute <chr>, FacStdCountyName <chr>,
#> #   CWPNAICSCodes <chr>, FacLat <dbl>, FacLong <dbl>,
#> #   CWPTotalDesignFlowNmbr <dbl>, AIRIDs <chr>, FacPopDen <dbl>,
#> #   CWPTerminationDate <date>, CWPMajorMinorStatusFlag <chr>,
#> #   NPDESDataGroupsDescs <chr>, CWPInspectionCount <dbl>,
#> #   CWPDaysLastInspection <dbl>, CWPDateLastInspEPA <date>, …

## Retrieve a simple features dataframe by bounding box
spatialdata <- echoWaterGetFacilityInfo(p_c2lon = '-96.407563',
p_c1lat = '30.554395',
p_c2lon = '-96.25947',
p_c2lat = '30.751984',
p_pcomp = 'POT',
output = 'sf')
#> A bounding box query requires that latitude and longitude values for two corners are provided.

# }
```
