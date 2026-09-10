# Check responses

Checks for valid server response and passes silently or produces a
useful message.

## Usage

``` r
resp_check(response)
```

## Arguments

- response:

  response a \[httr::GET()\] request result returned from the API

## Value

nothing if check is passed, or an informative message if not passed.
