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
status](https://codecov.io/gh/mps9506/echor/branch/master/graph/badge.svg)](https://codecov.io/github/mps9506/echor?branch=master)
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
    #> #   SDWAIDs <chr>, CWPDateLastInspSt <date>, BiosolidsFlag <chr>

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
spatial plotting or analysis:

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

<img src="man/figures/README-example3-1.png" width="100%" />

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
    #>  version  R version 4.2.3 (2023-03-15)
    #>  os       Ubuntu 22.04.2 LTS
    #>  system   x86_64, linux-gnu
    #>  ui       X11
    #>  language (EN)
    #>  collate  C.UTF-8
    #>  ctype    C.UTF-8
    #>  tz       UTC
    #>  date     2023-04-07
    #>  pandoc   2.19.2 @ /usr/bin/ (via rmarkdown)
    sessioninfo::package_info()
    #>  ! package      * version date (UTC) lib source
    #>    abind          1.4-5   2016-07-21 [1] CRAN (R 4.2.3)
    #>    bit            4.0.5   2022-11-15 [1] CRAN (R 4.2.3)
    #>    bit64          4.0.5   2020-08-30 [1] CRAN (R 4.2.3)
    #>  P class          7.3-21  2023-01-23 [?] CRAN (R 4.2.3)
    #>    classInt       0.4-9   2023-02-28 [1] CRAN (R 4.2.3)
    #>    cli            3.6.1   2023-03-23 [1] CRAN (R 4.2.3)
    #>  P codetools      0.2-19  2023-02-01 [?] CRAN (R 4.2.3)
    #>    colorspace     2.1-0   2023-01-23 [1] CRAN (R 4.2.3)
    #>    crayon         1.5.2   2022-09-29 [1] CRAN (R 4.2.3)
    #>    curl           5.0.0   2023-01-12 [1] CRAN (R 4.2.3)
    #>    DBI            1.1.3   2022-06-18 [1] CRAN (R 4.2.3)
    #>    digest         0.6.31  2022-12-11 [1] CRAN (R 4.2.3)
    #>    dplyr        * 1.1.1   2023-03-22 [1] CRAN (R 4.2.3)
    #>    e1071          1.7-13  2023-02-01 [1] CRAN (R 4.2.3)
    #>    echor        * 0.1.8   2023-04-07 [1] local
    #>    evaluate       0.20    2023-01-17 [1] CRAN (R 4.2.3)
    #>    fansi          1.0.4   2023-01-22 [1] CRAN (R 4.2.3)
    #>    farver         2.1.1   2022-07-06 [1] CRAN (R 4.2.3)
    #>    fastmap        1.1.1   2023-02-24 [1] CRAN (R 4.2.3)
    #>    fs             1.6.1   2023-02-06 [1] CRAN (R 4.2.3)
    #>    generics       0.1.3   2022-07-05 [1] CRAN (R 4.2.3)
    #>    geojsonsf      2.0.3   2022-05-30 [1] CRAN (R 4.2.3)
    #>    ggplot2      * 3.4.2   2023-04-03 [1] CRAN (R 4.2.3)
    #>    ggrepel      * 0.9.3   2023-02-03 [1] CRAN (R 4.2.3)
    #>    ggspatial    * 1.1.7   2022-11-24 [1] CRAN (R 4.2.3)
    #>    glue           1.6.2   2022-02-24 [1] CRAN (R 4.2.3)
    #>    gtable         0.3.3   2023-03-21 [1] CRAN (R 4.2.3)
    #>    highr          0.10    2022-12-22 [1] CRAN (R 4.2.3)
    #>    hms            1.1.3   2023-03-21 [1] CRAN (R 4.2.3)
    #>    htmltools      0.5.5   2023-03-23 [1] CRAN (R 4.2.3)
    #>    httr           1.4.5   2023-02-24 [1] CRAN (R 4.2.3)
    #>    jsonlite       1.8.4   2022-12-06 [1] CRAN (R 4.2.3)
    #>  P KernSmooth     2.23-20 2021-05-03 [?] CRAN (R 4.2.3)
    #>    knitr          1.42    2023-01-25 [1] CRAN (R 4.2.3)
    #>    labeling       0.4.2   2020-10-20 [1] CRAN (R 4.2.3)
    #>  P lattice        0.20-45 2021-09-22 [?] CRAN (R 4.2.3)
    #>    lifecycle      1.0.3   2022-10-07 [1] CRAN (R 4.2.3)
    #>    magrittr       2.0.3   2022-03-30 [1] CRAN (R 4.2.3)
    #>    mpsTemplates * 0.2.0   2023-04-07 [1] Github (mps9506/mpsTemplates@d7a070e)
    #>    munsell        0.5.0   2018-06-12 [1] CRAN (R 4.2.3)
    #>    pillar         1.9.0   2023-03-22 [1] CRAN (R 4.2.3)
    #>    pkgconfig      2.0.3   2019-09-22 [1] CRAN (R 4.2.3)
    #>    plyr           1.8.8   2022-11-11 [1] CRAN (R 4.2.3)
    #>    png            0.1-8   2022-11-29 [1] CRAN (R 4.2.3)
    #>    prettymapr     0.2.4   2022-06-09 [1] CRAN (R 4.2.3)
    #>    prettyunits    1.1.1   2020-01-24 [1] CRAN (R 4.2.3)
    #>    progress       1.2.2   2019-05-16 [1] CRAN (R 4.2.3)
    #>    proxy          0.4-27  2022-06-09 [1] CRAN (R 4.2.3)
    #>    purrr        * 1.0.1   2023-01-10 [1] CRAN (R 4.2.3)
    #>    R6             2.5.1   2021-08-19 [1] CRAN (R 4.2.3)
    #>  P ragg         * 1.2.5   2023-01-12 [?] RSPM (R 4.2.0)
    #>    raster         3.6-20  2023-03-06 [1] CRAN (R 4.2.3)
    #>    Rcpp           1.0.10  2023-01-22 [1] CRAN (R 4.2.3)
    #>    readr          2.1.4   2023-02-10 [1] CRAN (R 4.2.3)
    #>  P renv           0.16.0  2022-09-29 [?] RSPM (R 4.2.0)
    #>    rgdal          1.6-5   2023-03-02 [1] CRAN (R 4.2.3)
    #>    rlang          1.1.0   2023-03-14 [1] CRAN (R 4.2.3)
    #>    rmarkdown      2.21    2023-03-26 [1] CRAN (R 4.2.3)
    #>    rosm           0.2.6   2022-06-09 [1] CRAN (R 4.2.3)
    #>    scales         1.2.1   2022-08-20 [1] CRAN (R 4.2.3)
    #>    sessioninfo    1.2.2   2021-12-06 [1] any (@1.2.2)
    #>    sf           * 1.0-12  2023-03-19 [1] CRAN (R 4.2.3)
    #>    sp             1.6-0   2023-01-19 [1] CRAN (R 4.2.3)
    #>    systemfonts    1.0.4   2022-02-11 [1] CRAN (R 4.2.3)
    #>    terra          1.7-18  2023-03-06 [1] CRAN (R 4.2.3)
    #>  P textshaping    0.3.6   2021-10-13 [?] RSPM (R 4.2.0)
    #>    tibble         3.2.1   2023-03-20 [1] CRAN (R 4.2.3)
    #>    tidyr          1.3.0   2023-01-24 [1] CRAN (R 4.2.3)
    #>    tidyselect     1.2.0   2022-10-10 [1] CRAN (R 4.2.3)
    #>    tzdb           0.3.0   2022-03-28 [1] CRAN (R 4.2.3)
    #>    units          0.8-1   2022-12-10 [1] CRAN (R 4.2.3)
    #>    utf8           1.2.3   2023-01-31 [1] CRAN (R 4.2.3)
    #>    vctrs          0.6.1   2023-03-22 [1] CRAN (R 4.2.3)
    #>    vroom          1.6.1   2023-01-22 [1] CRAN (R 4.2.3)
    #>    withr          2.5.0   2022-03-03 [1] CRAN (R 4.2.3)
    #>    xfun           0.38    2023-03-24 [1] CRAN (R 4.2.3)
    #>    yaml           2.3.7   2023-01-23 [1] CRAN (R 4.2.3)
    #> 
    #>  [1] /home/runner/.cache/R/renv/library/echor-4ec080d0/R-4.2/x86_64-pc-linux-gnu
    #>  [2] /home/runner/work/echor/echor/renv/sandbox/R-4.2/x86_64-pc-linux-gnu/e11edd0e
    #> 
    #>  P ── Loaded and on-disk path mismatch.
