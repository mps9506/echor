# Searches the NPDES Noncompliance Report (NNCR)

Returns a dataframe of permits and their summarized violation counts for
a given fiscal year quarter, matching the search criteria. Uses EPA's
ECHO API:
<https://echo.epa.gov/tools/web-services/npdes-noncompliance-report>.

## Usage

``` r
echoNNCRGetSearch(verbose = FALSE, ...)
```

## Arguments

- verbose:

  Logical, indicating whether to provide processing and retrieval
  messages. Defaults to FALSE.

- ...:

  Further arguments passed as query parameters in the request sent to
  EPA ECHO's API. `fy_quarter` is required; see `echoNNCRGetQuarters`
  for valid values. For a complete list of parameter options, including
  Django-style field lookups such as `permit_state__in` or
  `permit_name__icontains`, see the web services documentation linked
  above.

## Value

Returns a dataframe.

## See also

[`echoNNCRGetQuarters`](https://mps9506.github.io/echor/reference/echoNNCRGetQuarters.md)

## Examples

``` r
# \donttest{
## This example requires an internet connection to run

echoNNCRGetSearch(fy_quarter = "FY24Q4", permit_state = "TX")
#> Request failed [500]. Retrying in 1 seconds...
#> Request failed [500]. Retrying in 3.3 seconds...
#> There was a server error, try again later.
# }
```
