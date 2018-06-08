<!-- README.md is generated from README.Rmd. Please edit that file -->
echor
=====

[![CRAN
status](https://www.r-pkg.org/badges/version/echor)](https://cran.r-project.org/package=echor)

[![Travis build
status](https://travis-ci.org/mps9506/echor.svg?branch=master)](https://travis-ci.org/mps9506/echor)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/mps9506/echor?branch=master&svg=true)](https://ci.appveyor.com/project/mps9506/echor)
[![Coverage
status](https://codecov.io/gh/mps9506/echor/branch/master/graph/badge.svg)](https://codecov.io/github/mps9506/echor?branch=master)

Overview
--------

echor downloads wastewater discharge and air emission data for EPA
permitted facilities using the [EPA ECHO API](https://echo.epa.gov/).

Installation
------------

echor is on CRAN:

``` r
install.packages("echor")
```

Or install the development version from github:

``` r

devtools::install_github("mps9506/echor")
```

Usage
-----

[Getting
started](https://mps9506.github.io/echor/articles/introduction.html)

[Functions](https://mps9506.github.io/echor/reference/index.html)

Examples
--------

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
#> # A tibble: 6 x 28
#>   ObjectId CWPName   SourceID CWPStreet  CWPCity CWPState CWPStateDistrict
#>   <chr>    <chr>     <chr>    <chr>      <chr>   <chr>    <lgl>           
#> 1 1        BOSSIER ~ LAG8301~ 3228 BARK~ BENTON  LA       NA              
#> 2 2        BROADSTO~ TXR10F5~ NW OF ATL~ BRYAN   TX       NA              
#> 3 3        BROADSTO~ TXR10F5~ NW OF ATL~ BRYAN   TX       NA              
#> 4 4        CITY OF ~ TXR0400~ WITHIN CI~ COLLEG~ TX       NA              
#> 5 5        HEAT TRA~ TX01065~ 0.25MI SW~ COLLEG~ TX       NA              
#> 6 6        HOLLEMAN~ TXR10F4~ NW OF HOL~ COLLEG~ TX       NA              
#> # ... with 21 more variables: CWPZip <chr>,
#> #   MasterExternalPermitNmbr <chr>, RegistryID <chr>, CWPCounty <chr>,
#> #   CWPEPARegion <chr>, FacDerivedHuc <chr>, FacLat <chr>, FacLong <chr>,
#> #   CWPTotalDesignFlowNmbr <chr>, CWPActualAverageFlowNmbr <lgl>,
#> #   ReceivingMs4Name <lgl>, AssociatedPollutant <lgl>,
#> #   MsgpPermitType <lgl>, CWPPermitStatusDesc <chr>,
#> #   CWPPermitTypeDesc <chr>, CWPIssueDate <chr>, CWPEffectiveDate <chr>,
#> #   CWPExpirationDate <chr>, CWPSNCStatusDate <chr>,
#> #   CWPStateWaterBodyCode <chr>, FacMapFlg <chr>
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
#> # A tibble: 6 x 9
#>   ObjectId CWPName       SourceID  RegistryID FacDerivedHuc FacLat FacLong
#>   <chr>    <chr>         <chr>     <chr>      <chr>         <chr>  <chr>  
#> 1 1        BOSSIER PARI~ LAG830191 110016696~ 12070103      30.61~ -96.28~
#> 2 2        BROADSTONE T~ TXR10F50H 110070110~ 12070101      30.60~ -96.38~
#> 3 3        BROADSTONE T~ TXR10F50D 110070110~ 12070101      30.60~ -96.38~
#> 4 4        CITY OF COLL~ TXR040008 110043267~ <NA>          30.59~ -96.30~
#> 5 5        HEAT TRANSFE~ TX0106526 110039192~ 12070101      30.58~ -96.35~
#> 6 6        HOLLEMAN EXT~ TXR10F4N6 110070080~ 12070103      30.58~ -96.33~
#> # ... with 2 more variables: CWPTotalDesignFlowNmbr <chr>, FacMapFlg <chr>
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

![](man/figures/README-example3-1.png)

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

![](man/figures/README-unnamed-chunk-2-1.png)
