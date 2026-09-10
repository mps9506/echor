# Downloads self reported discharge and emissions data

Downloads self reported discharge and emissions data

## Usage

``` r
echoGetReports(program, p_id, verbose = FALSE, ...)
```

## Arguments

- program:

  Character, one of `program = 'caa'`, `program = 'cwa'`, or
  `program = 'nncr'`. `'caa'` retrieves facilities permitted under the
  Clean Air Act, `'cwa'` retrieves facilities permitted under the Clean
  Water Act, and `'nncr'` retrieves NPDES Noncompliance Report (NNCR)
  data for a facility or NPDES permit.

- p_id:

  Character string specify the identifier for the service. For
  `program = 'nncr'`, this is treated as the NPDES permit ID
  (`permits__npdes_id`). Required.

- verbose:

  Logical, indicating whether to provide processing and retrieval
  messages. Defaults to FALSE.

- ...:

  Further arguments passed on as query parameters sent to EPA's ECHO
  API.

## Value

Returns a dataframe
