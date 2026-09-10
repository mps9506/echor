# Download EPA ECHO emissions inventory report data

Download EPA ECHO emissions inventory report data

## Usage

``` r
echoGetCAAPR(p_id, verbose = FALSE, ...)
```

## Arguments

- p_id:

  character string specify the identifier for the service. Required.

- verbose:

  Logical, indicating whether to provide processing and retrieval
  messages. Defaults to FALSE

- ...:

  Additional arguments

## Value

dataframe

## Examples

``` r
# \donttest{
## This example requires an internet connection to run

echoGetCAAPR(p_id = '110000350174')
#> # A tibble: 450 × 15
#>    Name       SourceID Street City  State Zip   County Region Latitude Longitude
#>    <chr>      <chr>    <chr>  <chr> <chr> <chr> <chr>  <chr>     <dbl>     <dbl>
#>  1 SUTTON ST… 1100003… 801 S… WILM… NC    28401 NEW H… 04         34.3     -78.0
#>  2 SUTTON ST… 1100003… 801 S… WILM… NC    28401 NEW H… 04         34.3     -78.0
#>  3 SUTTON ST… 1100003… 801 S… WILM… NC    28401 NEW H… 04         34.3     -78.0
#>  4 SUTTON ST… 1100003… 801 S… WILM… NC    28401 NEW H… 04         34.3     -78.0
#>  5 SUTTON ST… 1100003… 801 S… WILM… NC    28401 NEW H… 04         34.3     -78.0
#>  6 SUTTON ST… 1100003… 801 S… WILM… NC    28401 NEW H… 04         34.3     -78.0
#>  7 SUTTON ST… 1100003… 801 S… WILM… NC    28401 NEW H… 04         34.3     -78.0
#>  8 SUTTON ST… 1100003… 801 S… WILM… NC    28401 NEW H… 04         34.3     -78.0
#>  9 SUTTON ST… 1100003… 801 S… WILM… NC    28401 NEW H… 04         34.3     -78.0
#> 10 SUTTON ST… 1100003… 801 S… WILM… NC    28401 NEW H… 04         34.3     -78.0
#> # ℹ 440 more rows
#> # ℹ 5 more variables: Pollutant <fct>, UnitsOfMeasure <fct>, Program <fct>,
#> #   Year <int>, Discharge <dbl>
# }
```
