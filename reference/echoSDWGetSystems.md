# Downloads public water system information

Returns a dataframe of permitted public water systems returned by the
query. Uses EPA's ECHO API:
<https://echo.epa.gov/tools/web-services/facility-search-drinking-water#!/Safe_Drinking_Water/get_sdw_rest_services_get_systems>.

## Usage

``` r
echoSDWGetSystems(verbose = FALSE, ...)
```

## Arguments

- verbose:

  Logical, indicating whether to provide processing and retrieval
  messages. Defaults to FALSE

- ...:

  Further arguments passed as query parameters in request sent to EPA
  ECHO's API. For more options see:
  <https://echo.epa.gov/tools/web-services/facility-search-drinking-water#!/Safe_Drinking_Water/get_sdw_rest_services_get_systems>
  for a complete list of parameter options. Examples provided below.

## Value

returns a dataframe

## Examples

``` r
# \donttest{
## These examples require an internet connection to run
echoSDWGetSystems(p_co = "Brazos", p_st = "tx")
#> # A tibble: 40 × 76
#>    PWSName  PWSId CitiesServed StateCode ZipCodesServed CountiesServed EPARegion
#>    <chr>    <chr> <chr>        <chr>     <chr>          <chr>          <chr>    
#>  1 ABBATE … TX02… NA           TX        NA             Brazos         06       
#>  2 AL LEON… TX02… NA           TX        NA             Brazos         06       
#>  3 B J'S C… TX02… NA           TX        NA             Brazos         06       
#>  4 BENCHLE… TX02… NA           TX        NA             Brazos         06       
#>  5 BOBBITT… TX02… NA           TX        NA             Brazos         06       
#>  6 BRUSHY … TX02… NA           TX        NA             Brazos         06       
#>  7 CAFE SU… TX02… NA           TX        NA             Brazos         06       
#>  8 CAROUSE… TX02… NA           TX        NA             Brazos         06       
#>  9 CITY OF… TX02… NA           TX        NA             Brazos         06       
#> 10 CITY OF… TX02… NA           TX        NA             Brazos         06       
#> # ℹ 30 more rows
#> # ℹ 69 more variables: RegistryID <chr>, IndianCountry <chr>,
#> #   PWSTypeCode <chr>, PWSTypeDesc <chr>, PrimarySourceCode <chr>,
#> #   PrimarySourceDesc <chr>, PopulationServedCount <dbl>,
#> #   PWSActivityCode <chr>, PWSActivityDesc <chr>, OwnerTypeCode <chr>,
#> #   OwnerDesc <chr>, QtrsWithVio <dbl>, QtrsWithSNC <dbl>,
#> #   SeriousViolator <chr>, HealthFlag <chr>, MrFlag <chr>, PnFlag <chr>, …
# }
```
