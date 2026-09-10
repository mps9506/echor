# Downloads a NPDES Noncompliance Report (NNCR) facility/permit report

Returns compliance and enforcement history for one or more facilities or
NPDES permits at a time, across all available quarters. Uses EPA's ECHO
API:
<https://echo.epa.gov/tools/web-services/npdes-noncompliance-report>.

## Usage

``` r
echoNNCRGetReport(verbose = FALSE, ...)
```

## Arguments

- verbose:

  Logical, indicating whether to provide processing and retrieval
  messages. Defaults to FALSE.

- ...:

  Further arguments passed as query parameters in the request sent to
  EPA ECHO's API. One of `frs_id`, `frs_id__in`, `permits__npdes_id`, or
  `permits__npdes_id__in` is required. For a complete list of parameter
  options, see the web services documentation linked above.

## Value

Returns a dataframe. Nested facility, permit, and violation-level detail
returned by the service is preserved as list-columns.

## Examples

``` r
# \donttest{
## This example requires an internet connection to run

echoNNCRGetReport(permits__npdes_id = "TX0119407")
#> # A tibble: 1 × 11
#>   frs_id     frs_name frs_address frs_city frs_state frs_zip epa_region huc_code
#>   <chr>      <chr>    <chr>       <chr>    <chr>     <chr>   <chr>      <chr>   
#> 1 110009771… SKIDMOR… 1125 BLACK… SKIDMORE TX        78389   06         1210040…
#> # ℹ 3 more variables: watershed <chr>, permits <list>, attains <list>
# }
```
