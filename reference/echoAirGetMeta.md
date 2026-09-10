# Downloads EPA ECHO Air Facility Metadata

Returns variable name and descriptions for parameters returned by
[`echoAirGetFacilityInfo`](https://mps9506.github.io/echor/reference/echoAirGetFacilityInfo.md)

## Usage

``` r
echoAirGetMeta(verbose = FALSE)
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
echoAirGetMeta()
#> # A tibble: 163 × 6
#>    ColumnName                DataType DataLength ColumnID ObjectName Description
#>    <chr>                     <chr>    <chr>      <chr>    <chr>      <lgl>      
#>  1 AIR_NAME                  VARCHAR2 200        1        AIRName    NA         
#>  2 SOURCE_ID                 VARCHAR2 30         2        SourceID   NA         
#>  3 AIR_STREET                VARCHAR2 200        3        AIRStreet  NA         
#>  4 AIR_CITY                  VARCHAR2 100        4        AIRCity    NA         
#>  5 AIR_STATE                 CHAR     2          5        AIRState   NA         
#>  6 LOCAL_CONTROL_REGION_CODE CHAR     3          6        LocalCont… NA         
#>  7 AIR_ZIP                   VARCHAR2 10         7        AIRZip     NA         
#>  8 REGISTRY_ID               VARCHAR2 50         8        RegistryID NA         
#>  9 AIR_COUNTY                VARCHAR2 100        9        AIRCounty  NA         
#> 10 AIR_EPA_REGION            CHAR     2          10       AIREPAReg… NA         
#> # ℹ 153 more rows
# }
```
