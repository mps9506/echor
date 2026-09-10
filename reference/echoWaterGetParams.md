# Search parameter codes for Clean Water Act permits on EPA ECHO

Returns a dataframe of parameter codes and descriptions.

## Usage

``` r
echoWaterGetParams(term = NULL, code = NULL, verbose = FALSE)
```

## Arguments

- term:

  Character string specifying the parameter search term. Partial or
  complete search phrase or word.

- code:

  Character string specifying the parameter search code value.

- verbose:

  Logical, indicating whether to provide processing and retrieval
  messages. Defaults to FALSE

## Value

Returns a dataframe.

## Examples

``` r
# \donttest{
## These examples require an internet connection to run

## Retrieve parameter codes for dissolved oxygen
echoWaterGetParams(term = "Oxygen, dissolved")
#> # A tibble: 5 × 2
#>   ValueCode ValueDescription                     
#>   <chr>     <chr>                                
#> 1 00300     Oxygen, dissolved [DO]               
#> 2 51646     Oxygen, dissolved [DO] maximum       
#> 3 51645     Oxygen, dissolved [DO] minimum       
#> 4 00301     Oxygen, dissolved percent saturation 
#> 5 00399     Oxygen, dissolved, % of time violated

echoWaterGetParams(code = "00300")
#> # A tibble: 1 × 2
#>   ValueCode ValueDescription      
#>   <chr>     <chr>                 
#> 1 00300     Oxygen, dissolved [DO]
# }
```
