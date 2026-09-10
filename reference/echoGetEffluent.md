# Downloads EPA ECHO DMR records of dischargers with NPDES permits

Uses EPA ECHO API to download the Discharge Monitoring Record (DMR) of a
single plant, identified with p_id. Please note that the p_id is case
sensitive.

## Usage

``` r
echoGetEffluent(p_id, verbose = FALSE, ...)
```

## Arguments

- p_id:

  Character string specify the identifier for the service. Required.
  Case sensitive.

- verbose:

  Logical, indicating whether to provide processing and retrieval
  messages. Defaults to FALSE

- ...:

  Further arguments passed on as query parameters sent to EPA's ECHO
  API. For more options see:
  <https://echo.epa.gov/tools/web-services/effluent-charts#!/Effluent_Charts/get_eff_rest_services_get_effluent_chart>

## Value

Returns a dataframe.

## Examples

``` r
# \donttest{
## This example requires an internet connection to run

## Retrieve single DMR for flow

echoGetEffluent(p_id = 'tx0119407', parameter_code = '50050')
#> # A tibble: 82 × 64
#>    activity_id npdes_id  version_nmbr perm_feature_id perm_feature_nmbr
#>    <chr>       <chr>     <chr>        <chr>           <chr>            
#>  1 3602064155  TX0119407 5            3600435311      001              
#>  2 3602064155  TX0119407 5            3600435311      001              
#>  3 3602064155  TX0119407 5            3600435311      001              
#>  4 3602064155  TX0119407 5            3600435311      001              
#>  5 3602064155  TX0119407 5            3600435311      001              
#>  6 3602064155  TX0119407 5            3600435311      001              
#>  7 3602064155  TX0119407 5            3600435311      001              
#>  8 3602064155  TX0119407 5            3600435311      001              
#>  9 3602064155  TX0119407 5            3600435311      001              
#> 10 3602064155  TX0119407 5            3600435311      001              
#> # ℹ 72 more rows
#> # ℹ 59 more variables: perm_feature_type_code <chr>,
#> #   perm_feature_type_desc <chr>, limit_set_id <chr>,
#> #   limit_set_schedule_id <chr>, limit_id <chr>, limit_season_id <chr>,
#> #   limit_type_code <chr>, limit_begin_date <chr>, limit_end_date <chr>,
#> #   nmbr_of_submission <chr>, parameter_code <chr>, parameter_desc <chr>,
#> #   monitoring_location_code <chr>, monitoring_location_desc <chr>, …
# }
```
