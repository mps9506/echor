# Downloads permitted facility information

Provides interface for downloading facility information from Clean Air
Act, Clean Water Act, and Safe Drinking Water Act permitted facilities.

## Usage

``` r
echoGetFacilities(program, output = "df", verbose = FALSE, ...)
```

## Arguments

- program:

  Character, either `program = 'caa'`, `program = 'cwa'`, or
  `program = 'sdw'`. `'caa'` retrieves facilities permitted under the
  Clean Air Act, `'cwa'` retrieves facilities permitted under the Clean
  Water Act, and `'sdw'` retrieves facilities permitted under the the
  Safe Drinking Water Act.

- output:

  Character string specifying output format. `output = 'df'` for a
  dataframe or `output = 'sf'` for a simple features spatial dataframe.
  `'sf'` only applies to CAA and CWA queries.

- verbose:

  Logical, indicating whether to provide processing and retrieval
  messages. Defaults to FALSE.

- ...:

  Further arguments passed as query parameters in request sent to EPA
  ECHO's API.

## Value

dataframe or sf dataframe suitable for plotting
