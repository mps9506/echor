<!-- README.md is generated from README.Rmd. Please edit that file -->
    ## -- Attaching packages --------------------------------------------------------------------------------- tidyverse 1.2.1 --

    ## v ggplot2 2.2.1.9000     v purrr   0.2.4     
    ## v tibble  1.4.2          v dplyr   0.7.4     
    ## v tidyr   0.7.2          v stringr 1.2.0     
    ## v readr   1.1.1          v forcats 0.2.0

    ## -- Conflicts ------------------------------------------------------------------------------------ tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

    ## More than one version of regular/bold/italic found for Roboto Condensed. Skipping setup for this font.

echor
=====

Coming soon ...

Overview
--------

The goal of echor is to download dishcarge and emission data from the EPA ECHO database in a tidy format.

Installation
------------

``` r

devtools::install_github("mps9506/echor")
```

Example
-------

### Download information about facilities with an NPDES permit

We can look up plants by permit id, bounding box, and numerous other parameters. I plan on providing documentation of available parameters. However, arguments can be looked up here: [get\_cwa\_rest\_services\_get\_facility\_info](https://echo.epa.gov/tools/web-services/facility-search-water#!/Facility_Information/get_cwa_rest_services_get_facility_info)

``` r
library(tidyverse)
library(echor)
df <- echoWaterGetFacilityInfo(output = "df", xmin = '-96.407563',
                               ymin = '30.554395', xmax = '-96.25947',
                               ymax = '30.751984')

head(df)
```

``` r
df <- echoWaterGetFacilityInfo(output = "df", xmin = '-96.407563',
                               ymin = '30.554395', xmax = '-96.25947',
                               ymax = '30.751984')
knitr::kable(head(df), format = 'markdown')
```

<table style="width:100%;">
<colgroup>
<col width="2%" />
<col width="6%" />
<col width="2%" />
<col width="10%" />
<col width="3%" />
<col width="2%" />
<col width="3%" />
<col width="1%" />
<col width="5%" />
<col width="2%" />
<col width="2%" />
<col width="4%" />
<col width="2%" />
<col width="5%" />
<col width="6%" />
<col width="3%" />
<col width="5%" />
<col width="2%" />
<col width="3%" />
<col width="4%" />
<col width="3%" />
<col width="2%" />
<col width="3%" />
<col width="4%" />
<col width="4%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">ObjectId</th>
<th align="left">CWPName</th>
<th align="left">SourceID</th>
<th align="left">CWPStreet</th>
<th align="left">CWPCity</th>
<th align="left">CWPState</th>
<th align="left">CWPStateDistrict</th>
<th align="left">CWPZip</th>
<th align="left">MasterExternalPermitNmbr</th>
<th align="left">CWPCounty</th>
<th align="left">CWPEPARegion</th>
<th align="left">FacFederalAgencyCode</th>
<th align="left">FacLong</th>
<th align="left">CWPFacilityTypeIndicator</th>
<th align="left">BioReportingObligations2017</th>
<th align="left">StormWaterArea</th>
<th align="left">SpeciesCriticalHabitalFlag</th>
<th align="left">SwpppUrl</th>
<th align="left">ExposedActivity</th>
<th align="left">AssociatedPollutant</th>
<th align="left">TypeOfMonitoring</th>
<th align="left">TypeOfWater</th>
<th align="left">EjscreenFlagUs</th>
<th align="left">PctileProximityNPDESUs</th>
<th align="left">PctileProximityNplUs</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">1</td>
<td align="left">AGGIE ACRES WWTP</td>
<td align="left">TX0132187</td>
<td align="left">800 FT SE OF N DOWLING RD APPROX 600 FT SW OF WALN</td>
<td align="left">COLLEGE STATION</td>
<td align="left">TX</td>
<td align="left">NA</td>
<td align="left">77845</td>
<td align="left">NA</td>
<td align="left">Brazos</td>
<td align="left">06</td>
<td align="left">NA</td>
<td align="left">-96.291099</td>
<td align="left">NON-POTW</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">N</td>
<td align="left">NA</td>
<td align="left">NA</td>
</tr>
<tr class="even">
<td align="left">2</td>
<td align="left">AGRIVEST SWINE FEEDLOT</td>
<td align="left">TX0121240</td>
<td align="left">SWISHER COUNTY</td>
<td align="left">BRYAN</td>
<td align="left">TX</td>
<td align="left">NA</td>
<td align="left">00000</td>
<td align="left">NA</td>
<td align="left">Swisher</td>
<td align="left">06</td>
<td align="left">NA</td>
<td align="left">-96.36552</td>
<td align="left">NON-POTW</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">N</td>
<td align="left">NA</td>
<td align="left">NA</td>
</tr>
<tr class="odd">
<td align="left">3</td>
<td align="left">ATKINS STREET POWER STATION</td>
<td align="left">TX0027952</td>
<td align="left">601 ATKINS STREET</td>
<td align="left">BRYAN</td>
<td align="left">TX</td>
<td align="left">NA</td>
<td align="left">77801</td>
<td align="left">NA</td>
<td align="left">Brazos</td>
<td align="left">06</td>
<td align="left">NA</td>
<td align="left">-96.37165</td>
<td align="left">NON-POTW</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">Y</td>
<td align="left">92.1</td>
<td align="left">67.3</td>
</tr>
<tr class="even">
<td align="left">4</td>
<td align="left">ATOFINA CHEMICALS, INC.</td>
<td align="left">TX0108863</td>
<td align="left">SW OF THE MO PACIFIC RR &amp;</td>
<td align="left">BRYAN</td>
<td align="left">TX</td>
<td align="left">NA</td>
<td align="left">77801</td>
<td align="left">NA</td>
<td align="left">Brazos</td>
<td align="left">06</td>
<td align="left">NA</td>
<td align="left">-96.37303</td>
<td align="left">NON-POTW</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">Y</td>
<td align="left">92.1</td>
<td align="left">67.3</td>
</tr>
<tr class="odd">
<td align="left">5</td>
<td align="left">BARTLETT 1</td>
<td align="left">TX0120421</td>
<td align="left">SWISHER COUNTY</td>
<td align="left">AMARILLO</td>
<td align="left">TX</td>
<td align="left">NA</td>
<td align="left">00000</td>
<td align="left">NA</td>
<td align="left">Swisher</td>
<td align="left">06</td>
<td align="left">NA</td>
<td align="left">-96.36552</td>
<td align="left">NON-POTW</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">N</td>
<td align="left">NA</td>
<td align="left">NA</td>
</tr>
<tr class="even">
<td align="left">6</td>
<td align="left">BOSSIER PARISH RESOURCE CENTER</td>
<td align="left">LAG830191</td>
<td align="left">3228 BARKDALE BLVD</td>
<td align="left">BENTON</td>
<td align="left">LA</td>
<td align="left">NA</td>
<td align="left">71111</td>
<td align="left">LAG830000</td>
<td align="left">Bossier</td>
<td align="left">06</td>
<td align="left">NA</td>
<td align="left">-96.28182</td>
<td align="left">NON-POTW</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">NA</td>
<td align="left">N</td>
<td align="left">23.7</td>
<td align="left">48.8</td>
</tr>
</tbody>
</table>

This can be retrieved as a geojson and plotted as well:

``` r
library(ggmap)
library(sf)
#> Linking to GEOS 3.6.1, GDAL 2.2.0, proj.4 4.9.3
library(ggrepel)

df <- echoWaterGetFacilityInfo(output = "sp", 
                               xmin = '-96.407563', 
                               ymin = '30.554395', 
                               xmax = '-96.25947', 
                               ymax = '30.751984')
#> No encoding supplied: defaulting to UTF-8.

collegestation <- get_map(location = c(lon = -96.3395,
                                       lat = 30.6127), 
                          zoom = 13, maptype = "toner")
#> maptype = "toner" is only available with source = "stamen".
#> resetting to source = "stamen"...
#> Map from URL : http://maps.googleapis.com/maps/api/staticmap?center=30.6127,-96.3395&zoom=13&size=640x640&scale=2&maptype=terrain&sensor=false
#> Map from URL : http://tile.stamen.com/toner/13/1902/3362.png
#> Map from URL : http://tile.stamen.com/toner/13/1903/3362.png
#> Map from URL : http://tile.stamen.com/toner/13/1904/3362.png
#> Map from URL : http://tile.stamen.com/toner/13/1902/3363.png
#> Map from URL : http://tile.stamen.com/toner/13/1903/3363.png
#> Map from URL : http://tile.stamen.com/toner/13/1904/3363.png
#> Map from URL : http://tile.stamen.com/toner/13/1902/3364.png
#> Map from URL : http://tile.stamen.com/toner/13/1903/3364.png
#> Map from URL : http://tile.stamen.com/toner/13/1904/3364.png

##to make labels, need to map the coords using purrr::map() and use geom_text :(
## can't help but think there is an easier way to do this

df <- df %>%
  mutate(
    coords = map(geometry, st_coordinates),
    coords_x = map_dbl(coords, 1),
    coords_y = map_dbl(coords, 2)
  )

ggmap(collegestation, extent = "device") + 
  geom_sf(data = df, inherit.aes = FALSE, color = "dodgerblue") +
  geom_text_repel(data = df, aes(x = coords_x, y = coords_y, label = SourceID),
                  size = 2, color = "dodgerblue") +
  theme_ipsum_rc() +
  labs(x = "Longitude", y = "Latitude", 
       title = "NPDES permits near Texas A&M",
       caption = "Source: EPA ECHO database")
#> Warning: `panel.margin` is deprecated. Please use `panel.spacing` property
#> instead
#> Coordinate system already present. Adding new coordinate system, which will replace the existing one.
#> Warning: Removed 19 rows containing missing values (geom_text_repel).
```

![](man/figures/README-example2-1.png)
