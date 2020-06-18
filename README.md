
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
[![DOI](https://zenodo.org/badge/122131508.svg)](https://zenodo.org/badge/latestdoi/122131508)

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
remotes::install_github("mps9506/echor")
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
                               ymax = '30.640008',
                               p_ptype = "NPD")

head(df)
#> # A tibble: 3 x 26
#>   CWPName SourceID CWPStreet CWPCity CWPState CWPStateDistrict CWPZip
#>   <chr>   <chr>    <chr>     <chr>   <chr>    <chr>            <chr> 
#> 1 CENTRA~ TX00027~ 222 IREL~ COLLEG~ TX       09               77843 
#> 2 HEAT T~ TX01065~ 0.25MI S~ COLLEG~ TX       09               77845 
#> 3 TURKEY~ TX00624~ 3000FT W~ BRYAN   TX       09               77807 
#> # ... with 19 more variables: MasterExternalPermitNmbr <chr>, RegistryID <chr>,
#> #   CWPCounty <chr>, CWPEPARegion <chr>, FacDerivedHuc <chr>, FacLat <dbl>,
#> #   FacLong <dbl>, CWPTotalDesignFlowNmbr <dbl>,
#> #   CWPActualAverageFlowNmbr <dbl>, ReceivingMs4Name <chr>,
#> #   AssociatedPollutant <chr>, MsgpPermitType <chr>, CWPPermitStatusDesc <chr>,
#> #   CWPPermitTypeDesc <chr>, CWPIssueDate <date>, CWPEffectiveDate <date>,
#> #   CWPExpirationDate <date>, CWPSNCStatusDate <date>, StateAuthGen <chr>
```

The ECHO database can provide over 270 different columns. echor returns
a subset of these columns that should work for most users. However, you
can specify what data you want returned. Use `echoWaterGetMeta()` to
return a dataframe with column numbers, names, and descriptions to
identify the columns you want returned. Then include the column numbers
as a comma separated string in the `qcolumns` argument. In the example
below, the `qcolumns` argument indicates the dataframe will include
plant name, 8-digit HUC, latitude, longitude, and total design flow.

``` r
df <- echoWaterGetFacilityInfo(output = "df", 
                               xmin = '-96.387509', 
                               ymin = '30.583572', 
                               xmax = '-96.281422', 
                               ymax = '30.640008',
                               qcolumns = '1,14,23,24,25',
                               p_ptype = "NPD")
head(df)
#> # A tibble: 3 x 6
#>   CWPName            SourceID  FacDerivedHuc FacLat FacLong CWPTotalDesignFlowN~
#>   <chr>              <chr>     <chr>          <dbl>   <dbl>                <dbl>
#> 1 CENTRAL UTILITY P~ TX0002747 12070103        30.6   -96.3                 0.93
#> 2 HEAT TRANSFER RES~ TX0106526 12070101        30.6   -96.4                NA   
#> 3 TURKEY CREEK WWTP  TX0062472 12070101        30.6   -96.4                 0.75
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
                               ymax = '30.640008',
                               p_ptype = "NPD")

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
  theme_ipsum(plot_margin = margin(5, 5, 5, 5)) +
  labs(x = "Longitude", y = "Latitude", 
       title = "NPDES permits near Texas A&M",
       caption = "Source: EPA ECHO database")
```

<img src="man/figures/README-example3-1.png" width="672" />

### Download discharge/emissions data

Use `echoGetEffluent()` or `echoGetCAAPR()` to download tidy dataframes
of permitted water discharger Discharge Monitoring Report (DMR) or
permitted emitters Clean Air Act annual emissions reports. Please note
that all variables are returned as *character* vectors.

``` r
df <- echoGetEffluent(p_id = 'tx0119407', parameter_code = '00300')

df <- df %>%
  mutate(dmr_value_nmbr = as.numeric(dmr_value_nmbr),
         monitoring_period_end_date = as.Date(monitoring_period_end_date,
                                              "%m/%d/%Y")) %>%
  filter(!is.na(dmr_value_nmbr) & limit_value_type_code == "C1")

ggplot(df) +
  geom_line(aes(monitoring_period_end_date, dmr_value_nmbr)) +
  theme_ipsum(grid = "Y") +
  labs(x = "Monitoring period date",
       y = "Dissolved oxygen concentration (mg/l)",
       title = "Reported minimum dissolved oxygen concentration",
       subtitle = "NPDES ID = TX119407",
       caption = "Source: EPA ECHO")
```

<img src="man/figures/README-unnamed-chunk-2-1.png" width="672" />

## Session Info

``` r
sessioninfo::platform_info()
#>  setting  value                       
#>  version  R version 4.0.0 (2020-04-24)
#>  os       Windows 10 x64              
#>  system   x86_64, mingw32             
#>  ui       RTerm                       
#>  language (EN)                        
#>  collate  English_United States.1252  
#>  ctype    English_United States.1252  
#>  tz       America/Chicago             
#>  date     2020-06-17
sessioninfo::package_info()
#>  package     * version    date       lib source        
#>  assertthat    0.2.1      2019-03-21 [1] CRAN (R 4.0.0)
#>  backports     1.1.6      2020-04-05 [1] CRAN (R 4.0.0)
#>  bitops        1.0-6      2013-08-17 [1] CRAN (R 4.0.0)
#>  broom         0.5.6      2020-04-20 [1] CRAN (R 4.0.0)
#>  cellranger    1.1.0      2016-07-27 [1] CRAN (R 4.0.0)
#>  class         7.3-16     2020-03-25 [2] CRAN (R 4.0.0)
#>  classInt      0.4-3      2020-04-07 [1] CRAN (R 4.0.0)
#>  cli           2.0.2      2020-02-28 [1] CRAN (R 4.0.0)
#>  colorspace    1.4-1      2019-03-18 [1] CRAN (R 4.0.0)
#>  crayon        1.3.4      2017-09-16 [1] CRAN (R 4.0.0)
#>  curl          4.3        2019-12-02 [1] CRAN (R 4.0.0)
#>  DBI           1.1.0      2019-12-15 [1] CRAN (R 4.0.0)
#>  dbplyr        1.4.3      2020-04-19 [1] CRAN (R 4.0.0)
#>  digest        0.6.25     2020-02-23 [1] CRAN (R 4.0.0)
#>  dplyr       * 0.8.5      2020-03-07 [1] CRAN (R 4.0.0)
#>  e1071         1.7-3      2019-11-26 [1] CRAN (R 4.0.0)
#>  echor       * 0.1.4.9999 2020-06-17 [1] local         
#>  ellipsis      0.3.0      2019-09-20 [1] CRAN (R 4.0.0)
#>  evaluate      0.14       2019-05-28 [1] CRAN (R 4.0.0)
#>  extrafont   * 0.17       2014-12-08 [1] CRAN (R 4.0.0)
#>  extrafontdb   1.0        2012-06-11 [1] CRAN (R 4.0.0)
#>  fansi         0.4.1      2020-01-08 [1] CRAN (R 4.0.0)
#>  farver        2.0.3      2020-01-16 [1] CRAN (R 4.0.0)
#>  forcats     * 0.5.0      2020-03-01 [1] CRAN (R 4.0.0)
#>  fs            1.4.1      2020-04-04 [1] CRAN (R 4.0.0)
#>  gdtools       0.2.2      2020-04-03 [1] CRAN (R 4.0.0)
#>  generics      0.0.2      2018-11-29 [1] CRAN (R 4.0.0)
#>  geojsonsf     1.3.3      2020-03-18 [1] CRAN (R 4.0.0)
#>  ggmap       * 3.0.0      2019-02-04 [1] CRAN (R 4.0.0)
#>  ggplot2     * 3.3.0      2020-03-05 [1] CRAN (R 4.0.0)
#>  ggrepel     * 0.8.2      2020-03-08 [1] CRAN (R 4.0.0)
#>  glue          1.4.0      2020-04-03 [1] CRAN (R 4.0.0)
#>  gtable        0.3.0      2019-03-25 [1] CRAN (R 4.0.0)
#>  haven         2.2.0      2019-11-08 [1] CRAN (R 4.0.0)
#>  hms           0.5.3      2020-01-08 [1] CRAN (R 4.0.0)
#>  hrbrthemes  * 0.8.0      2020-03-06 [1] CRAN (R 4.0.0)
#>  htmltools     0.4.0      2019-10-04 [1] CRAN (R 4.0.0)
#>  httr          1.4.1      2019-08-05 [1] CRAN (R 4.0.0)
#>  jpeg          0.1-8.1    2019-10-24 [1] CRAN (R 4.0.0)
#>  jsonlite      1.6.1      2020-02-02 [1] CRAN (R 4.0.0)
#>  KernSmooth    2.23-16    2019-10-15 [2] CRAN (R 4.0.0)
#>  knitr         1.28       2020-02-06 [1] CRAN (R 4.0.0)
#>  labeling      0.3        2014-08-23 [1] CRAN (R 4.0.0)
#>  lattice       0.20-41    2020-04-02 [2] CRAN (R 4.0.0)
#>  lifecycle     0.2.0      2020-03-06 [1] CRAN (R 4.0.0)
#>  lubridate     1.7.8      2020-04-06 [1] CRAN (R 4.0.0)
#>  magrittr      1.5        2014-11-22 [1] CRAN (R 4.0.0)
#>  modelr        0.1.7      2020-04-30 [1] CRAN (R 4.0.0)
#>  munsell       0.5.0      2018-06-12 [1] CRAN (R 4.0.0)
#>  nlme          3.1-147    2020-04-13 [2] CRAN (R 4.0.0)
#>  pillar        1.4.3      2019-12-20 [1] CRAN (R 4.0.0)
#>  pkgconfig     2.0.3      2019-09-22 [1] CRAN (R 4.0.0)
#>  plyr          1.8.6      2020-03-03 [1] CRAN (R 4.0.0)
#>  png           0.1-7      2013-12-03 [1] CRAN (R 4.0.0)
#>  purrr       * 0.3.4      2020-04-17 [1] CRAN (R 4.0.0)
#>  R6            2.4.1      2019-11-12 [1] CRAN (R 4.0.0)
#>  Rcpp          1.0.4.6    2020-04-09 [1] CRAN (R 4.0.0)
#>  readr       * 1.3.1      2018-12-21 [1] CRAN (R 4.0.0)
#>  readxl        1.3.1      2019-03-13 [1] CRAN (R 4.0.0)
#>  reprex        0.3.0      2019-05-16 [1] CRAN (R 4.0.0)
#>  RgoogleMaps   1.4.5.3    2020-02-12 [1] CRAN (R 4.0.0)
#>  rjson         0.2.20     2018-06-08 [1] CRAN (R 4.0.0)
#>  rlang         0.4.6      2020-05-02 [1] CRAN (R 4.0.0)
#>  rmarkdown     2.1        2020-01-20 [1] CRAN (R 4.0.0)
#>  rstudioapi    0.11       2020-02-07 [1] CRAN (R 4.0.0)
#>  Rttf2pt1      1.3.8      2020-01-10 [1] CRAN (R 4.0.0)
#>  rvest         0.3.5      2019-11-08 [1] CRAN (R 4.0.0)
#>  scales        1.1.0      2019-11-18 [1] CRAN (R 4.0.0)
#>  sessioninfo   1.1.1      2018-11-05 [1] CRAN (R 4.0.0)
#>  sf          * 0.9-2      2020-04-14 [1] CRAN (R 4.0.0)
#>  sp            1.4-1      2020-02-28 [1] CRAN (R 4.0.0)
#>  stringi       1.4.6      2020-02-17 [1] CRAN (R 4.0.0)
#>  stringr     * 1.4.0      2019-02-10 [1] CRAN (R 4.0.0)
#>  systemfonts   0.2.3      2020-06-09 [1] CRAN (R 4.0.0)
#>  tibble      * 3.0.1      2020-04-20 [1] CRAN (R 4.0.0)
#>  tidyr       * 1.0.2      2020-01-24 [1] CRAN (R 4.0.0)
#>  tidyselect    1.0.0      2020-01-27 [1] CRAN (R 4.0.0)
#>  tidyverse   * 1.3.0      2019-11-21 [1] CRAN (R 4.0.0)
#>  units         0.6-6      2020-03-16 [1] CRAN (R 4.0.0)
#>  utf8          1.1.4      2018-05-24 [1] CRAN (R 4.0.0)
#>  vctrs         0.2.4      2020-03-10 [1] CRAN (R 4.0.0)
#>  withr         2.2.0      2020-04-20 [1] CRAN (R 4.0.0)
#>  xfun          0.13       2020-04-13 [1] CRAN (R 4.0.0)
#>  xml2          1.3.2      2020-04-23 [1] CRAN (R 4.0.0)
#>  yaml          2.2.1      2020-02-01 [1] CRAN (R 4.0.0)
#> 
#> [1] C:/Users/Michael/Documents/R/win-library/4.0
#> [2] C:/Program Files/R/R-4.0.0/library
```
