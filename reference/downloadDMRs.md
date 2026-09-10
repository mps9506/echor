# Download Multiple DMRs

Returns DMRs in a nested list using
[`echoGetEffluent()`](https://mps9506.github.io/echor/reference/echoGetEffluent.md).
Uses a dataframe with a column of p_id numbers. Please note that p_id's
are case sensitive.

## Usage

``` r
downloadDMRs(df, idColumn, pBar = TRUE, verbose = FALSE, ...)
```

## Arguments

- df:

  dataframe with column of id numbers

- idColumn:

  unquoted string, name of column containing the p_id permit numbers

- pBar:

  logical, display a progress bar? Defaults to TRUE

- verbose:

  logical, indicating whether to provide processing and retrieval
  messages. Defaults to FALSE. Suggest leaving this FALSE if
  `pBar = TRUE`.

- ...:

  additional arguments passed to echoGetEffluent

## Value

dataframe df, with a column containing the discharge monitoring reports
downloaded with echoGetEffluentSummary

## Examples

``` r
# \donttest{
## This example requires an internet connection to run

## Retrieve multiple DMRs for flow

df <- tibble::tibble("id" = c('TX0119407', 'TX0132187'))
df <- downloadDMRs(df, id)
# }
```
