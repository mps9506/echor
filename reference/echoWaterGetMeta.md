# Downloads EPA ECHO Water Facility Metadata

Returns variable name and descriptions for parameters returned by
[`echoWaterGetFacilityInfo`](https://mps9506.github.io/echor/reference/echoWaterGetFacilityInfo.md)

## Usage

``` r
echoWaterGetMeta(verbose = FALSE)
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
echoWaterGetMeta()
#> # A tibble: 260 × 6
#>    ColumnName                DataType DataLength ColumnID ObjectName Description
#>    <chr>                     <chr>    <chr>      <chr>    <chr>      <lgl>      
#>  1 CWP_NAME                  VARCHAR2 200        1        CWPName    NA         
#>  2 SOURCE_ID                 VARCHAR2 30         2        SourceID   NA         
#>  3 CWP_STREET                VARCHAR2 200        3        CWPStreet  NA         
#>  4 CWP_CITY                  VARCHAR2 100        4        CWPCity    NA         
#>  5 CWP_STATE                 CHAR     2          5        CWPState   NA         
#>  6 CWP_STATE_DISTRICT        VARCHAR2 5          6        CWPStateD… NA         
#>  7 CWP_ZIP                   VARCHAR2 10         7        CWPZip     NA         
#>  8 MASTER_EXTERNAL_PERMIT_N… VARCHAR2 9          8        MasterExt… NA         
#>  9 REGISTRY_ID               VARCHAR2 50         9        RegistryID NA         
#> 10 EPA_SYSTEM                VARCHAR2 10         10       EPASystem  NA         
#> # ℹ 250 more rows
# }
```
