# Downloads available NPDES Noncompliance Report (NNCR) fiscal year quarters

Returns the fiscal year quarters (\`fy_quarter\`) available for use with
[`echoNNCRGetSearch`](https://mps9506.github.io/echor/reference/echoNNCRGetSearch.md),
[`echoNNCRGetViolations`](https://mps9506.github.io/echor/reference/echoNNCRGetViolations.md),
and
[`echoGetReports`](https://mps9506.github.io/echor/reference/echoGetReports.md),
along with the quarter's date range and release status. Uses EPA's ECHO
API:
<https://echo.epa.gov/tools/web-services/npdes-noncompliance-report>.

## Usage

``` r
echoNNCRGetQuarters(verbose = FALSE)
```

## Arguments

- verbose:

  Logical, indicating whether to provide processing and retrieval
  messages. Defaults to FALSE.

## Value

Returns a dataframe.

## Examples

``` r
# \donttest{
## This example requires an internet connection to run

echoNNCRGetQuarters()
#> # A tibble: 25 × 5
#>    quarter_start_date quarter_end_date fy_quarter gov_release public_release
#>    <chr>              <chr>            <chr>      <chr>       <chr>         
#>  1 2020-07-01         2020-09-30       FY20Q4     N           N             
#>  2 2020-10-01         2020-12-31       FY21Q1     Y           Y             
#>  3 2021-01-01         2021-03-31       FY21Q2     Y           Y             
#>  4 2021-04-01         2021-06-30       FY21Q3     Y           Y             
#>  5 2021-07-01         2021-09-30       FY21Q4     Y           Y             
#>  6 2021-10-01         2021-12-31       FY22Q1     Y           Y             
#>  7 2022-01-01         2022-03-31       FY22Q2     Y           Y             
#>  8 2022-04-01         2022-06-30       FY22Q3     Y           Y             
#>  9 2022-07-01         2022-09-30       FY22Q4     Y           Y             
#> 10 2022-10-01         2022-12-31       FY23Q1     Y           Y             
#> # ℹ 15 more rows
# }
```
