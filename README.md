<!-- README.md is generated from README.Rmd. Please edit that file -->

# echor

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/echor)](https://cran.r-project.org/package=echor)
[![echor status
badge](https://mps9506.r-universe.dev/badges/echor)](https://mps9506.r-universe.dev)

[![R build
status](https://github.com/mps9506/echor/workflows/R-CMD-check/badge.svg)](https://github.com/mps9506/echor/actions)
[![Coverage
status](https://codecov.io/gh/mps9506/echor/branch/master/graph/badge.svg)](https://app.codecov.io/github/mps9506/echor?branch=master)
[![DOI](https://zenodo.org/badge/122131508.svg)](https://zenodo.org/badge/latestdoi/122131508)

<!-- badges: end -->

## Overview

echor downloads wastewater discharge and air emission data for EPA
permitted facilities using the [EPA ECHO API](https://echo.epa.gov/).

## Installation

echor is on CRAN:

    install.packages("echor")

Or install the development version:

    install.packages('echor', repos = 'https://mps9506.r-universe.dev')

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

    library(echor)

    ## echoWaterGetFacilityInfo() will return a dataframe or simple features (sf) dataframe.

    df <- echoWaterGetFacilityInfo(output = "df", 
                                   xmin = '-96.387509', 
                                   ymin = '30.583572', 
                                   xmax = '-96.281422', 
                                   ymax = '30.640008',
                                   p_ptype = "NPD")

    head(df)
    #> # A tibble: 4 × 26
    #>   CWPName            SourceID CWPStreet CWPCity CWPState CWPStateDistrict CWPZip
    #>   <chr>              <chr>    <chr>     <chr>   <chr>    <chr>            <chr> 
    #> 1 CARTER CREEK WWTP  TX00471… 2200 NOR… COLLEG… TX       09               77845 
    #> 2 CENTRAL UTILITY P… TX00027… 222 IREL… COLLEG… TX       09               77843 
    #> 3 HEAT TRANSFER RES… TX01065… 0.25MI S… COLLEG… TX       09               77845 
    #> 4 TURKEY CREEK WWTP  TX00624… 3000FT W… BRYAN   TX       09               77807 
    #> # ℹ 19 more variables: MasterExternalPermitNmbr <chr>, RegistryID <chr>,
    #> #   CWPCounty <chr>, CWPEPARegion <chr>, FacDerivedHuc <chr>,
    #> #   CWPNAICSCodes <chr>, FacLat <dbl>, FacLong <dbl>,
    #> #   CWPTotalDesignFlowNmbr <dbl>, DschToMs4 <chr>, ExposedActivity <chr>,
    #> #   NPDESDataGroupsDescs <chr>, MsgpFacilityInspctnSmmry <chr>,
    #> #   MsgpCorrectiveActionSmmry <chr>, AIRIDs <chr>, NPDESIDs <chr>,
    #> #   SDWAIDs <chr>, AlrExceeds1yr <dbl>, CertifiedDate <date>

The ECHO database can provide over 270 different columns. echor returns
a subset of these columns that should work for most users. However, you
can specify what data you want returned. Use `echoWaterGetMeta()` to
return a dataframe with column numbers, names, and descriptions to
identify the columns you want returned. Then include the column numbers
as a comma separated string in the `qcolumns` argument. In the example
below, the `qcolumns` argument indicates the dataframe will include
plant name, 8-digit HUC, latitude, longitude, and total design flow.

    df <- echoWaterGetFacilityInfo(output = "df", 
                                   xmin = '-96.387509', 
                                   ymin = '30.583572', 
                                   xmax = '-96.281422', 
                                   ymax = '30.640008',
                                   qcolumns = '1,14,23,24,25',
                                   p_ptype = "NPD")
    head(df)
    #> # A tibble: 4 × 6
    #>   CWPName                SourceID  FacDerivedHuc CWPNAICSCodes FacLat FacLong
    #>   <chr>                  <chr>     <chr>         <chr>          <dbl>   <dbl>
    #> 1 CARTER CREEK WWTP      TX0047163 12070103      <NA>            30.6   -96.3
    #> 2 CENTRAL UTILITY PLANT  TX0002747 12070103      <NA>            30.6   -96.3
    #> 3 HEAT TRANSFER RESEARCH TX0106526 12070101      <NA>            30.6   -96.4
    #> 4 TURKEY CREEK WWTP      TX0062472 12070101      <NA>            30.6   -96.4

When returned as sf dataframes, the data is suitable for immediate
spatial plotting or analysis **note: the spatial data endpoints do not
currently appear to be functioning**

    library(ggspatial)
    library(sf)
    library(ggrepel)
    library(purrr)

    df <- echoWaterGetFacilityInfo(output = "sf", 
                                   xmin = '-96.387509', 
                                   ymin = '30.583572', 
                                   xmax = '-96.281422', 
                                   ymax = '30.640008',
                                   p_ptype = "NPD")

    ##to make labels, need to map the coords and use geom_text :(
    ## can't help but think there is an easier way to do this

    df <- df %>%
      mutate(
        coords = map(geometry, st_coordinates),
        coords_x = map_dbl(coords, 1),
        coords_y = map_dbl(coords, 2)
      )

    ggplot(df) +
      annotation_map_tile(zoomin = -1, progress = "none") +
      geom_sf(inherit.aes = FALSE, shape = 21, 
              color = "darkred", fill = "darkred", 
              size = 2, alpha = 0.25) +
      geom_label_repel(data = df, aes(x = coords_x, y = coords_y, label = SourceID),
                       point.padding = .5, min.segment.length = 0.1,
                       size = 2, color = "dodgerblue") +
      theme_mps_noto() +
      labs(x = "Longitude", y = "Latitude", 
           title = "NPDES permits near Texas A&M",
           caption = "Source: EPA ECHO database")

### Download discharge/emissions data

Use `echoGetEffluent()` or `echoGetCAAPR()` to download tidy dataframes
of permitted water discharger Discharge Monitoring Report (DMR) or
permitted emitters Clean Air Act annual emissions reports. Please note
that all variables are returned as *character* vectors.

    df <- echoGetEffluent(p_id = 'tx0119407', parameter_code = '00300')

    df <- df %>%
      mutate(dmr_value_nmbr = as.numeric(dmr_value_nmbr),
             monitoring_period_end_date = as.Date(monitoring_period_end_date,
                                                  "%m/%d/%Y")) %>%
      filter(!is.na(dmr_value_nmbr) & limit_value_type_code == "C1")

    ggplot(df) +
      geom_line(aes(monitoring_period_end_date, dmr_value_nmbr)) +
      theme_mps_noto() +
      labs(x = "Monitoring period date",
           y = "Dissolved oxygen concentration (mg/l)",
           title = "Reported minimum dissolved oxygen concentration",
           subtitle = "NPDES ID = TX119407",
           caption = "Source: EPA ECHO")

<img src="man/figures/README-unnamed-chunk-2-1.png" width="672" />

## Session Info

    sessioninfo::platform_info()
    #>  setting  value
    #>  version  R version 4.3.1 (2023-06-16)
    #>  os       Ubuntu 22.04.2 LTS
    #>  system   x86_64, linux-gnu
    #>  ui       X11
    #>  language (EN)
    #>  collate  C.UTF-8
    #>  ctype    C.UTF-8
    #>  tz       UTC
    #>  date     2023-06-20
    #>  pandoc   2.19.2 @ /usr/bin/ (via rmarkdown)
    sessioninfo::package_info()
    #>  ! package      * version    date (UTC) lib source
    #>    bit            4.0.5      2022-11-15 [1] CRAN (R 4.3.1)
    #>    bit64          4.0.5      2020-08-30 [1] CRAN (R 4.3.1)
    #>  P class          7.3-22     2023-05-03 [?] CRAN (R 4.3.1)
    #>    classInt       0.4-9      2023-02-28 [1] CRAN (R 4.3.1)
    #>    cli            3.6.1      2023-03-23 [1] CRAN (R 4.3.1)
    #>    colorspace     2.1-0      2023-01-23 [1] CRAN (R 4.3.1)
    #>    crayon         1.5.2      2022-09-29 [1] CRAN (R 4.3.1)
    #>    curl           5.0.1      2023-06-07 [1] CRAN (R 4.3.1)
    #>    DBI            1.1.3      2022-06-18 [1] CRAN (R 4.3.1)
    #>    digest         0.6.31     2022-12-11 [1] CRAN (R 4.3.1)
    #>    dplyr        * 1.1.2      2023-04-20 [1] CRAN (R 4.3.1)
    #>    e1071          1.7-13     2023-02-01 [1] CRAN (R 4.3.1)
    #>    echor        * 0.1.8.9000 2023-06-20 [1] local
    #>    evaluate       0.21       2023-05-05 [1] CRAN (R 4.3.1)
    #>    fansi          1.0.4      2023-01-22 [1] CRAN (R 4.3.1)
    #>    farver         2.1.1      2022-07-06 [1] CRAN (R 4.3.1)
    #>    fastmap        1.1.1      2023-02-24 [1] CRAN (R 4.3.1)
    #>    fs             1.6.2      2023-04-25 [1] CRAN (R 4.3.1)
    #>    generics       0.1.3      2022-07-05 [1] CRAN (R 4.3.1)
    #>    ggplot2      * 3.4.2      2023-04-03 [1] CRAN (R 4.3.1)
    #>    glue           1.6.2      2022-02-24 [1] CRAN (R 4.3.1)
    #>    gtable         0.3.3      2023-03-21 [1] CRAN (R 4.3.1)
    #>    highr          0.10       2022-12-22 [1] CRAN (R 4.3.1)
    #>    hms            1.1.3      2023-03-21 [1] CRAN (R 4.3.1)
    #>    htmltools      0.5.5      2023-03-23 [1] CRAN (R 4.3.1)
    #>    httr           1.4.6      2023-05-08 [1] CRAN (R 4.3.1)
    #>    jsonlite       1.8.5      2023-06-05 [1] CRAN (R 4.3.1)
    #>  P KernSmooth     2.23-21    2023-05-03 [?] CRAN (R 4.3.1)
    #>    knitr          1.43       2023-05-25 [1] CRAN (R 4.3.1)
    #>    labeling       0.4.2      2020-10-20 [1] CRAN (R 4.3.1)
    #>    lifecycle      1.0.3      2022-10-07 [1] CRAN (R 4.3.1)
    #>    magrittr       2.0.3      2022-03-30 [1] CRAN (R 4.3.1)
    #>  P mpsTemplates * 0.2.0      2023-06-20 [?] Github (mps9506/mpsTemplates@d7a070e)
    #>    munsell        0.5.0      2018-06-12 [1] CRAN (R 4.3.1)
    #>    pillar         1.9.0      2023-03-22 [1] CRAN (R 4.3.1)
    #>    pkgconfig      2.0.3      2019-09-22 [1] CRAN (R 4.3.1)
    #>    plyr           1.8.8      2022-11-11 [1] CRAN (R 4.3.1)
    #>    prettyunits    1.1.1      2020-01-24 [1] CRAN (R 4.3.1)
    #>    progress       1.2.2      2019-05-16 [1] CRAN (R 4.3.1)
    #>    proxy          0.4-27     2022-06-09 [1] CRAN (R 4.3.1)
    #>    purrr          1.0.1      2023-01-10 [1] CRAN (R 4.3.1)
    #>    R6             2.5.1      2021-08-19 [1] CRAN (R 4.3.1)
    #>  P ragg         * 1.2.5      2023-01-12 [?] RSPM (R 4.3.0)
    #>    Rcpp           1.0.10     2023-01-22 [1] CRAN (R 4.3.1)
    #>    readr          2.1.4      2023-02-10 [1] CRAN (R 4.3.1)
    #>  P renv           0.17.3     2023-04-06 [?] RSPM (R 4.3.0)
    #>    rlang          1.1.1      2023-04-28 [1] CRAN (R 4.3.1)
    #>    rmarkdown      2.22       2023-06-01 [1] CRAN (R 4.3.1)
    #>    rstudioapi     0.14       2022-08-22 [1] CRAN (R 4.3.1)
    #>    scales         1.2.1      2022-08-20 [1] CRAN (R 4.3.1)
    #>    sessioninfo    1.2.2      2021-12-06 [1] any (@1.2.2)
    #>    sf             1.0-13     2023-05-24 [1] CRAN (R 4.3.1)
    #>    systemfonts    1.0.4      2022-02-11 [1] CRAN (R 4.3.1)
    #>  P textshaping    0.3.6      2021-10-13 [?] RSPM (R 4.3.0)
    #>    tibble         3.2.1      2023-03-20 [1] CRAN (R 4.3.1)
    #>    tidyr          1.3.0      2023-01-24 [1] CRAN (R 4.3.1)
    #>    tidyselect     1.2.0      2022-10-10 [1] CRAN (R 4.3.1)
    #>    tzdb           0.4.0      2023-05-12 [1] CRAN (R 4.3.1)
    #>    units          0.8-2      2023-04-27 [1] CRAN (R 4.3.1)
    #>    utf8           1.2.3      2023-01-31 [1] CRAN (R 4.3.1)
    #>    vctrs          0.6.3      2023-06-14 [1] CRAN (R 4.3.1)
    #>    vroom          1.6.3      2023-04-28 [1] CRAN (R 4.3.1)
    #>    withr          2.5.0      2022-03-03 [1] CRAN (R 4.3.1)
    #>    xfun           0.39       2023-04-20 [1] CRAN (R 4.3.1)
    #>    yaml           2.3.7      2023-01-23 [1] CRAN (R 4.3.1)
    #> 
    #>  [1] /home/runner/.cache/R/renv/library/echor-4ec080d0/R-4.3/x86_64-pc-linux-gnu
    #>  [2] /home/runner/.cache/R/renv/sandbox/R-4.3/x86_64-pc-linux-gnu/5cd49154
    #> 
    #>  P ── Loaded and on-disk path mismatch.
