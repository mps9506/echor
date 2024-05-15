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
                                   p_c1lon = '-96.387509', 
                                   p_c1lat = '30.583572', 
                                   p_c2lon = '-96.281422', 
                                   p_c2lat = '30.640008',
                                   p_ptype = "NPD")

    head(df)
    #> # A tibble: 4 × 26
    #>   CWPName            SourceID CWPStreet CWPCity CWPState CWPStateDistrict CWPZip
    #>   <chr>              <chr>    <chr>     <chr>   <chr>    <chr>            <chr> 
    #> 1 CARTERS CREEK WWTP TX00471… 2200 NOR… COLLEG… TX       09               77845 
    #> 2 CENTRAL UTILITY P… TX00027… 1584 TAMU COLLEG… TX       09               77843 
    #> 3 HEAT TRANSFER RES… TX01065… 0.25MI S… COLLEG… TX       09               77845 
    #> 4 TURKEY CREEK WWTP  TX00624… 3000FT W… BRYAN   TX       09               77807 
    #> # ℹ 19 more variables: MasterExternalPermitNmbr <chr>, RegistryID <chr>,
    #> #   EPASystem <chr>, Statute <chr>, FacStdCountyName <chr>,
    #> #   CWPNAICSCodes <chr>, FacLat <dbl>, FacLong <dbl>,
    #> #   CWPTotalDesignFlowNmbr <dbl>, AIRIDs <chr>, CensusBlockGroup <chr>,
    #> #   MileavgOver90CountSt <dbl>, MileOver90CountSt <dbl>,
    #> #   SupOver80CountUsSearch <chr>, SupMileavgOver80CountUs <dbl>,
    #> #   SupMileOver80CountUs <dbl>, SupMileOver80CountUsSearch <chr>, …

The ECHO database can provide over 270 different columns. echor returns
a subset of these columns that should work for most users. However, you
can specify what data you want returned. Use `echoWaterGetMeta()` to
return a dataframe with column numbers, names, and descriptions to
identify the columns you want returned. Then include the column numbers
as a comma separated string in the `qcolumns` argument. In the example
below, the `qcolumns` argument indicates the dataframe will include
plant name, 8-digit HUC, latitude, longitude, and total design flow.

    df <- echoWaterGetFacilityInfo(output = "df", 
                                   p_c1lon = '-96.387509', 
                                   p_c1lat = '30.583572', 
                                   p_c2lon = '-96.281422', 
                                   p_c2lat = '30.640008',
                                   qcolumns = '1,14,23,24,25',
                                   p_ptype = "NPD")
    head(df)
    #> # A tibble: 4 × 6
    #>   CWPName                SourceID  FacStdCountyName CWPNAICSCodes FacLat FacLong
    #>   <chr>                  <chr>     <chr>            <chr>          <dbl>   <dbl>
    #> 1 CARTERS CREEK WWTP     TX0047163 BRAZOS COUNTY    <NA>            30.6   -96.3
    #> 2 CENTRAL UTILITY PLANT  TX0002747 BRAZOS COUNTY    <NA>            30.6   -96.3
    #> 3 HEAT TRANSFER RESEARCH TX0106526 BRAZOS COUNTY    <NA>            30.6   -96.4
    #> 4 TURKEY CREEK WWTP      TX0062472 BRAZOS COUNTY    <NA>            30.6   -96.4

When returned as sf dataframes, the data is suitable for immediate
spatial plotting or analysis.

    library(ggspatial)
    library(sf)
    library(ggrepel)
    library(prettymapr)

    df <- echoWaterGetFacilityInfo(output = "sf", 
                                   p_c1lon = '-96.387509', 
                                   p_c1lat = '30.583572', 
                                   p_c2lon = '-96.281422', 
                                   p_c2lat = '30.640008',
                                   p_ptype = "NPD")


    ggplot(df) +
      annotation_map_tile(zoomin = -1, progress = "none") +
      geom_sf(inherit.aes = FALSE, shape = 21, 
              color = "darkred", fill = "darkred", 
              size = 2, alpha = 0.25) +
      geom_label_repel(data = df, aes(label = SourceID,
                                      geometry = geometry),
                       stat = "sf_coordinates",
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
    #>  version  R version 4.4.0 (2024-04-24)
    #>  os       Ubuntu 22.04.4 LTS
    #>  system   x86_64, linux-gnu
    #>  ui       X11
    #>  language (EN)
    #>  collate  C.UTF-8
    #>  ctype    C.UTF-8
    #>  tz       UTC
    #>  date     2024-05-15
    #>  pandoc   3.1.11 @ /opt/hostedtoolcache/pandoc/3.1.11/x64/ (via rmarkdown)

    sessioninfo::package_info()
    #>  ! package      * version    date (UTC) lib source
    #>    abind          1.4-5      2016-07-21 [1] CRAN (R 4.4.0)
    #>    bit            4.0.5      2022-11-15 [1] CRAN (R 4.4.0)
    #>    bit64          4.0.5      2020-08-30 [1] CRAN (R 4.4.0)
    #>  P class          7.3-22     2023-05-03 [?] CRAN (R 4.4.0)
    #>    classInt       0.4-10     2023-09-05 [1] CRAN (R 4.4.0)
    #>    cli            3.6.2      2023-12-11 [1] CRAN (R 4.4.0)
    #>  P codetools      0.2-20     2024-03-31 [?] CRAN (R 4.4.0)
    #>    colorspace     2.1-0      2023-01-23 [1] CRAN (R 4.4.0)
    #>    crayon         1.5.2      2022-09-29 [1] CRAN (R 4.4.0)
    #>    curl           5.2.1      2024-03-01 [1] CRAN (R 4.4.0)
    #>    DBI            1.2.2      2024-02-16 [1] CRAN (R 4.4.0)
    #>    digest         0.6.35     2024-03-11 [1] CRAN (R 4.4.0)
    #>    dplyr        * 1.1.4      2023-11-17 [1] CRAN (R 4.4.0)
    #>    e1071          1.7-14     2023-12-06 [1] CRAN (R 4.4.0)
    #>    echor        * 0.1.9.9999 2024-05-15 [1] local
    #>    evaluate       0.23       2023-11-01 [1] CRAN (R 4.4.0)
    #>    fansi          1.0.6      2023-12-08 [1] CRAN (R 4.4.0)
    #>    farver         2.1.2      2024-05-13 [1] CRAN (R 4.4.0)
    #>    fastmap        1.2.0      2024-05-15 [1] CRAN (R 4.4.0)
    #>    fs             1.6.4      2024-04-25 [1] CRAN (R 4.4.0)
    #>    generics       0.1.3      2022-07-05 [1] CRAN (R 4.4.0)
    #>    ggplot2      * 3.5.1      2024-04-23 [1] CRAN (R 4.4.0)
    #>    ggrepel      * 0.9.5      2024-01-10 [1] CRAN (R 4.4.0)
    #>    ggspatial    * 1.1.9      2023-08-17 [1] CRAN (R 4.4.0)
    #>    glue           1.7.0      2024-01-09 [1] CRAN (R 4.4.0)
    #>    gtable         0.3.5      2024-04-22 [1] CRAN (R 4.4.0)
    #>    highr          0.10       2022-12-22 [1] CRAN (R 4.4.0)
    #>    hms            1.1.3      2023-03-21 [1] CRAN (R 4.4.0)
    #>    htmltools      0.5.8.1    2024-04-04 [1] CRAN (R 4.4.0)
    #>    httr           1.4.7      2023-08-15 [1] CRAN (R 4.4.0)
    #>    jsonlite       1.8.8      2023-12-04 [1] CRAN (R 4.4.0)
    #>  P KernSmooth     2.23-22    2023-07-10 [?] CRAN (R 4.4.0)
    #>    knitr          1.46       2024-04-06 [1] CRAN (R 4.4.0)
    #>    labeling       0.4.3      2023-08-29 [1] CRAN (R 4.4.0)
    #>  P lattice        0.22-6     2024-03-20 [?] CRAN (R 4.4.0)
    #>    lifecycle      1.0.4      2023-11-07 [1] CRAN (R 4.4.0)
    #>    magrittr       2.0.3      2022-03-30 [1] CRAN (R 4.4.0)
    #>  P mpsTemplates * 0.2.0      2024-05-15 [?] Github (mps9506/mpsTemplates@d7a070e)
    #>    munsell        0.5.1      2024-04-01 [1] CRAN (R 4.4.0)
    #>    pillar         1.9.0      2023-03-22 [1] CRAN (R 4.4.0)
    #>    pkgconfig      2.0.3      2019-09-22 [1] CRAN (R 4.4.0)
    #>    plyr           1.8.9      2023-10-02 [1] CRAN (R 4.4.0)
    #>    png            0.1-8      2022-11-29 [1] CRAN (R 4.4.0)
    #>    prettymapr   * 0.2.5      2024-02-23 [1] CRAN (R 4.4.0)
    #>    prettyunits    1.2.0      2023-09-24 [1] CRAN (R 4.4.0)
    #>    progress       1.2.3      2023-12-06 [1] CRAN (R 4.4.0)
    #>    proxy          0.4-27     2022-06-09 [1] CRAN (R 4.4.0)
    #>    purrr          1.0.2      2023-08-10 [1] CRAN (R 4.4.0)
    #>    R6             2.5.1      2021-08-19 [1] CRAN (R 4.4.0)
    #>  P ragg         * 1.3.1      2024-05-06 [?] RSPM (R 4.4.0)
    #>    raster         3.6-26     2023-10-14 [1] CRAN (R 4.4.0)
    #>    Rcpp           1.0.12     2024-01-09 [1] CRAN (R 4.4.0)
    #>    readr          2.1.5      2024-01-10 [1] CRAN (R 4.4.0)
    #>    renv           1.0.7      2024-04-11 [1] RSPM (R 4.4.0)
    #>    rlang          1.1.3      2024-01-10 [1] CRAN (R 4.4.0)
    #>    rmarkdown      2.26       2024-03-05 [1] CRAN (R 4.4.0)
    #>    rosm           0.3.0      2023-08-27 [1] CRAN (R 4.4.0)
    #>    scales         1.3.0      2023-11-28 [1] CRAN (R 4.4.0)
    #>    sessioninfo    1.2.2      2021-12-06 [1] any (@1.2.2)
    #>    sf           * 1.0-16     2024-03-24 [1] CRAN (R 4.4.0)
    #>    sp             2.1-4      2024-04-30 [1] CRAN (R 4.4.0)
    #>    systemfonts    1.1.0      2024-05-15 [1] CRAN (R 4.4.0)
    #>    terra          1.7-71     2024-01-31 [1] CRAN (R 4.4.0)
    #>  P textshaping    0.3.7      2023-10-09 [?] RSPM (R 4.4.0)
    #>    tibble         3.2.1      2023-03-20 [1] CRAN (R 4.4.0)
    #>    tidyr          1.3.1      2024-01-24 [1] CRAN (R 4.4.0)
    #>    tidyselect     1.2.1      2024-03-11 [1] CRAN (R 4.4.0)
    #>    tzdb           0.4.0      2023-05-12 [1] CRAN (R 4.4.0)
    #>    units          0.8-5      2023-11-28 [1] CRAN (R 4.4.0)
    #>    utf8           1.2.4      2023-10-22 [1] CRAN (R 4.4.0)
    #>    vctrs          0.6.5      2023-12-01 [1] CRAN (R 4.4.0)
    #>    vroom          1.6.5      2023-12-05 [1] CRAN (R 4.4.0)
    #>    withr          3.0.0      2024-01-16 [1] CRAN (R 4.4.0)
    #>    xfun           0.44       2024-05-15 [1] CRAN (R 4.4.0)
    #>    yaml           2.3.8      2023-12-11 [1] CRAN (R 4.4.0)
    #> 
    #>  [1] /home/runner/.cache/R/renv/library/echor-4ec080d0/linux-ubuntu-jammy/R-4.4/x86_64-pc-linux-gnu
    #>  [2] /home/runner/.cache/R/renv/sandbox/linux-ubuntu-jammy/R-4.4/x86_64-pc-linux-gnu/3df92652
    #> 
    #>  P ── Loaded and on-disk path mismatch.
