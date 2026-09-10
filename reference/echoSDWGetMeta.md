# Downloads EPA ECHO Safe Drinking Water Facilities Metadata

Downloads EPA ECHO Safe Drinking Water Facilities Metadata

## Usage

``` r
echoSDWGetMeta(verbose = FALSE)
```

## Arguments

- verbose:

  Logical, indicating whether to provide processing and retrieval
  messages. Defaults to FALSE

## Value

returns a dataframe

## Examples

``` r
# \donttest{
## These examples require an internet connection to run

# returns a dataframe of
echoSDWGetMeta()
#> # A tibble: 79 × 6
#>    ColumnName       DataType DataLength ColumnID ObjectName     Description
#>    <chr>            <chr>    <chr>      <chr>    <chr>          <lgl>      
#>  1 PWS_NAME         VARCHAR2 100        1        PWSName        NA         
#>  2 PWSID            VARCHAR2 9          2        PWSId          NA         
#>  3 CITIES_SERVED    VARCHAR2 4000       3        CitiesServed   NA         
#>  4 STATE_CODE       VARCHAR2 2          4        StateCode      NA         
#>  5 ZIP_CODES_SERVED VARCHAR2 4000       5        ZipCodesServed NA         
#>  6 COUNTIES_SERVED  VARCHAR2 4000       6        CountiesServed NA         
#>  7 EPA_REGION       VARCHAR2 2          7        EPARegion      NA         
#>  8 REGISTRY_ID      VARCHAR2 50         8        RegistryID     NA         
#>  9 INDIAN_COUNTRY   CHAR     1          9        IndianCountry  NA         
#> 10 PWS_TYPE_CODE    VARCHAR2 6          10       PWSTypeCode    NA         
#> # ℹ 69 more rows
# }
```
