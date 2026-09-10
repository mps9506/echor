# Downloads detailed NPDES Noncompliance Report (NNCR) violations

Returns a dataframe of detailed violation records for a given fiscal
year quarter, optionally filtered to a single facility (`frs_id`) or
NPDES permit (`npdes_id`). Uses EPA's ECHO API:
<https://echo.epa.gov/tools/web-services/npdes-noncompliance-report>.

## Usage

``` r
echoNNCRGetViolations(verbose = FALSE, ...)
```

## Arguments

- verbose:

  Logical, indicating whether to provide processing and retrieval
  messages. Defaults to FALSE.

- ...:

  Further arguments passed as query parameters in the request sent to
  EPA ECHO's API. `fy_quarter` is required; see `echoNNCRGetQuarters`
  for valid values. For a complete list of parameter options, see the
  web services documentation linked above.

## Value

Returns a dataframe.

## See also

[`echoNNCRGetQuarters`](https://mps9506.github.io/echor/reference/echoNNCRGetQuarters.md)

## Examples

``` r
# \donttest{
## This example requires an internet connection to run

echoNNCRGetViolations(fy_quarter = "FY24Q4", npdes_id = "TX0119407")
#> # A tibble: 0 × 0
# }
```
