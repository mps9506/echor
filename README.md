<!-- README.md is generated from README.Rmd. Please edit that file -->

# echor

[![CRAN
status](https://www.r-pkg.org/badges/version/echor)](https://cran.r-project.org/package=echor)

[![Travis build
status](https://travis-ci.org/mps9506/echor.svg?branch=master)](https://travis-ci.org/mps9506/echor)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/mps9506/echor?branch=master&svg=true)](https://ci.appveyor.com/project/mps9506/echor)
[![Coverage
status](https://codecov.io/gh/mps9506/echor/branch/master/graph/badge.svg)](https://codecov.io/github/mps9506/echor?branch=master)

## Overview

echor downloads wastewater discharge and air emission data for EPA
permitted facilities using the [EPA ECHO API](https://echo.epa.gov/).

## Installation

echor is on CRAN:

``` r
install.packages("echor")
```

Or install the development version from github:

``` r

devtools::install_github("mps9506/echor")
```

## Usage

[Getting
started](https://mps9506.github.io/echor/articles/introduction.html)

[Functions](https://mps9506.github.io/echor/reference/index.html)

## Examples

### Download information about facilities with an NPDES permit

We can look up plants by permit id, bounding box, and numerous other
parameters. I plan on providing documentation of available parameters.
However, arguments can be looked up here:
[get\_cwa\_rest\_services\_get\_facility\_info](https://echo.epa.gov/tools/web-services/facility-search-water#!/Facility_Information/get_cwa_rest_services_get_facility_info)

``` r
library(tidyverse)
library(echor)

## echoWaterGetFacilityInfo() will return a dataframe or simple features (sf) dataframe.

df <- echoWaterGetFacilityInfo(output = "df", 
                               xmin = '-96.387509', 
                               ymin = '30.583572', 
                               xmax = '-96.281422', 
                               ymax = '30.640008')

head(df)
#> # A tibble: 6 x 26
#>   CWPName   SourceID  CWPStreet   CWPCity CWPState CWPStateDistrict CWPZip
#>   <chr>     <chr>     <chr>       <chr>   <chr>    <chr>            <chr> 
#> 1 BOSSIER ~ LAG830191 3228 BARKD~ BENTON  LA       ""               71111 
#> 2 BROADSTO~ TXR10F50H NW OF ATLA~ BRYAN   TX       ""               77807 
#> 3 BROADSTO~ TXR10F50D NW OF ATLA~ BRYAN   TX       ""               77807 
#> 4 CITY OF ~ TXR040008 WITHIN CIT~ COLLEG~ TX       ""               77842 
#> 5 HEAT TRA~ TX0106526 0.25MI SW ~ COLLEG~ TX       ""               77845 
#> 6 HOLLEMAN~ TXR10F4N6 NW OF HOLL~ COLLEG~ TX       ""               77840 
#> # ... with 19 more variables: MasterExternalPermitNmbr <chr>,
#> #   RegistryID <chr>, CWPCounty <chr>, CWPEPARegion <chr>,
#> #   FacDerivedHuc <chr>, FacLat <dbl>, FacLong <dbl>,
#> #   CWPTotalDesignFlowNmbr <dbl>, CWPActualAverageFlowNmbr <dbl>,
#> #   ReceivingMs4Name <chr>, AssociatedPollutant <chr>,
#> #   MsgpPermitType <chr>, CWPPermitStatusDesc <chr>,
#> #   CWPPermitTypeDesc <chr>, CWPIssueDate <date>, CWPEffectiveDate <date>,
#> #   CWPExpirationDate <date>, CWPSNCStatusDate <date>,
#> #   CWPStateWaterBodyCode <chr>
```

The ECHO database can provide over 270 different columns. echor returns
a subset of these columns that should work for most users. However, you
can specify what data you want returned. Use `echoWaterGetMeta()` to
return a dataframe with column numbers, names, and descriptions to
identify the columns you want returned. Then include the column numbers
as a comma seperated string in the `qcolumns` argument. In the example
below, the `qcolumns` argument indicates the dataframe will include
plant name, 8-digit HUC, latitute, longitude, and total design flow.

``` r
df <- echoWaterGetFacilityInfo(output = "df", 
                               xmin = '-96.387509', 
                               ymin = '30.583572', 
                               xmax = '-96.281422', 
                               ymax = '30.640008',
                               qcolumns = '1,14,23,24,25')
head(df)
#> # A tibble: 6 x 6
#>   CWPName         SourceID FacDerivedHuc FacLat FacLong CWPTotalDesignFlo~
#>   <chr>           <chr>    <chr>          <dbl>   <dbl>              <dbl>
#> 1 BOSSIER PARISH~ LAG8301~ 12070103        30.6   -96.3                 NA
#> 2 BROADSTONE TRA~ TXR10F5~ 12070101        30.6   -96.4                 NA
#> 3 BROADSTONE TRA~ TXR10F5~ 12070101        30.6   -96.4                 NA
#> 4 CITY OF COLLEG~ TXR0400~ ""              30.6   -96.3                 NA
#> 5 HEAT TRANSFER ~ TX01065~ 12070101        30.6   -96.4                 NA
#> 6 HOLLEMAN EXTEN~ TXR10F4~ 12070103        30.6   -96.3                 NA
```

When returned as sf dataframes, the data is suitable for immediate
spatial plotting or analysis:

``` r
library(ggmap)
library(sf)
library(ggrepel)
## This example requires the development version of ggplot with support
## for geom_sf()
## and uses theme_ipsum_rc() from library(hrbrthemes)


df <- echoWaterGetFacilityInfo(output = "sf", 
                               xmin = '-96.387509', 
                               ymin = '30.583572', 
                               xmax = '-96.281422', 
                               ymax = '30.640008')

collegestation <- get_map(location = c(-96.387509, 30.583572,
                                       -96.281422, 30.640008), 
                          zoom = 14, maptype = "toner")

##to make labels, need to map the coords and use geom_text :(
## can't help but think there is an easier way to do this

df <- df %>%
  mutate(
    coords = map(geometry, st_coordinates),
    coords_x = map_dbl(coords, 1),
    coords_y = map_dbl(coords, 2)
  )

ggmap(collegestation) + 
  geom_sf(data = df, inherit.aes = FALSE, shape = 21, 
          color = "darkred", fill = "darkred", 
          size = 2, alpha = 0.25) +
  geom_label_repel(data = df, aes(x = coords_x, y = coords_y, label = SourceID),
                   point.padding = .5, min.segment.length = 0.1,
                   size = 2, color = "dodgerblue") +
  theme_ipsum_rc() +
  labs(x = "Longitude", y = "Latitude", 
       title = "NPDES permits near Texas A&M",
       caption = "Source: EPA ECHO database")
```

![](man/figures/README-example3-1.png)<!-- -->

### Download discharge/emissions data

Use `echoGetEffluent()` or `echoGetCAAPR()` to download tidy dataframes
of permitted water discharger Discharge Monitoring Report (DMR) or
permitted emitters Clean Air Act annual emissions reports.

``` r
df <- echoGetEffluent(p_id = 'tx0119407', parameter_code = '00300')

df <- df %>%
  filter(!is.na(DMRValueNmbr) & ValueTypeCode == "C1")

ggplot(df) +
  geom_line(aes(MonitoringPeriodEndDate, DMRValueNmbr)) +
  theme_ipsum_rc(grid = "Y") +
  labs(x = "Monitoring period date",
       y = "Dissolved oxygen concentration (mg/l)",
       title = "Reported minimum dissolved oxygen concentration",
       subtitle = "NPDES ID = TX119407",
       caption = "Source: EPA ECHO")
```

![](man/figures/README-unnamed-chunk-2-1.png)<!-- -->

## Test Results

``` r
library(echor)

date()
#> [1] "Fri Aug 03 16:46:28 2018"

devtools::test()
#> v | OK F W S | Context
#> 
/ |  0       | core functions return expected errors
- |  1       | core functions return expected errors
\ |  2       | core functions return expected errors
| |  3       | core functions return expected errors
/ |  4       | core functions return expected errors
- |  5       | core functions return expected errors
\ |  6       | core functions return expected errors
| |  7       | core functions return expected errors
/ |  8       | core functions return expected errors
- |  9       | core functions return expected errors
\ | 10       | core functions return expected errors
v | 10       | core functions return expected errors
#> 
/ |  0       | core functions return expected objects
- |  0   1   | core functions return expected objects
\ |  0   2   | core functions return expected objects
| |  1   2   | core functions return expected objects
/ |  2   2   | core functions return expected objects
- |  2 1 2   | core functions return expected objects[1] "# Status message: Success"          
#> [2] "# Status message: OK"               
#> [3] "# Status message: Success: (200) OK"
#> 
\ |  2 1 3   | core functions return expected objectsCannot open data source C:\Users\michael.schramm\AppData\Local\Temp\Rtmpa4wMKJ\spoutput27187fb65e8f.geojson
#> 
| |  2 2 3   | core functions return expected objects
x |  2 2 3   | core functions return expected objects [1.7 s]
#> -----------------------------------------------------------------------------------------------------
#> test-expected_objects.R:7: warning: core functions return tbl_df
#> number of columns of result is not a multiple of vector length (arg 2)
#> 
#> test-expected_objects.R:7: warning: core functions return tbl_df
#> 1 parsing failure.
#> row # A tibble: 1 x 5 col     row col   expected  actual    file         expected   <int> <chr> <chr>     <chr>     <chr>        actual 1     2 <NA>  1 columns 2 columns <raw vector> file # A tibble: 1 x 5
#> 
#> 
#> test-expected_objects.R:13: error: core functions return tbl_df
#> object 'Year1' not found
#> 1: echoGetCAAPR(p_id = "110000350174") at C:\BACKUP\Documents\Data-Analysis-Projects\echor/tests/testthat/test-expected_objects.R:13
#> 2: tidyr::gather_(pollutant, "Year", "Discharge", c("Year1", "Year2", "Year3", "Year4", "Year5", "Year6", 
#>        "Year7", "Year8", "Year9", "Year10")) at C:\BACKUP\Documents\Data-Analysis-Projects\echor/R/air.R:246
#> 3: gather_.data.frame(pollutant, "Year", "Discharge", c("Year1", "Year2", "Year3", "Year4", "Year5", "Year6", 
#>        "Year7", "Year8", "Year9", "Year10"))
#> 4: gather(data, key = !!key_col, value = !!value_col, !!!gather_cols, na.rm = na.rm, convert = convert, factor_key = factor_key)
#> 5: gather.data.frame(data, key = !!key_col, value = !!value_col, !!!gather_cols, na.rm = na.rm, convert = convert, 
#>        factor_key = factor_key)
#> 6: unname(tidyselect::vars_select(names(data), !!!quos))
#> 7: tidyselect::vars_select(names(data), !!!quos)
#> 8: vars_select_eval(.vars, quos)
#> 9: map_if(quos, !is_helper, overscope_eval_next, overscope = overscope)
#> 10: map(.x[sel], .f, ...)
#> 11: .f(.x[[i]], ...)
#> 
#> test-expected_objects.R:51: warning: core functions return sf
#> GDAL Error 4: Failed to read GeoJSON data
#> 
#> test-expected_objects.R:51: error: core functions return sf
#> Open failed.
#> 1: echoAirGetFacilityInfo(p_pid = "NC0000003706500036", output = "sf", verbose = FALSE) at C:\BACKUP\Documents\Data-Analysis-Projects\echor/tests/testthat/test-expected_objects.R:51
#> 2: convertSF(buildOutput) at C:\BACKUP\Documents\Data-Analysis-Projects\echor/R/air.R:122
#> 3: sf::read_sf(t) at C:\BACKUP\Documents\Data-Analysis-Projects\echor/R/utils.R:138
#> 4: st_as_sf(tibble::as_tibble(as.data.frame(st_read(..., quiet = quiet, stringsAsFactors = stringsAsFactors))))
#> 5: tibble::as_tibble(as.data.frame(st_read(..., quiet = quiet, stringsAsFactors = stringsAsFactors)))
#> 6: as.data.frame(st_read(..., quiet = quiet, stringsAsFactors = stringsAsFactors))
#> 7: st_read(..., quiet = quiet, stringsAsFactors = stringsAsFactors)
#> 8: st_read.default(..., quiet = quiet, stringsAsFactors = stringsAsFactors)
#> 9: CPL_read_ogr(dsn, layer, as.character(options), quiet, type, promote_to_multi, int64_as_string)
#> -----------------------------------------------------------------------------------------------------
#> 
#> == Results ==========================================================================================
#> Duration: 1.8 s
#> 
#> OK:       12
#> Failed:   2
#> Warnings: 3
#> Skipped:  0
```
