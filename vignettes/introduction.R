## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  fig.asp = 1 / 1.6,
  out.width = "75%",
  fig.width = 5,
  fig.retina = NULL,
  dpi = 96,
  collapse = TRUE,
  comment = "#>"
)

## ------------------------------------------------------------------------
library(echor)

## Retrieve information about facilities within a geographic location
df <- echoAirGetFacilityInfo(output = "df",
                               xmin = '-96.387509',
                               ymin = '30.583572',
                               xmax = '-96.281422',
                               ymax = '30.640008')
knitr::kable(head(df))

## ------------------------------------------------------------------------
df <- echoGetCAAPR(p_id = '110000350174')
knitr::kable(head(df))

## ------------------------------------------------------------------------
df <- echoWaterGetFacilityInfo(xmin = '-96.407563', ymin = '30.554395', 
                               xmax = '-96.25947',  ymax = '30.751984', 
                               output = 'df')

## ----echo=FALSE----------------------------------------------------------
knitr::kable(head(df))

## ------------------------------------------------------------------------
df <- echoGetEffluent(p_id = 'tx0119407', parameter_code = '50050')

## ----echo=FALSE----------------------------------------------------------
knitr::kable(head(df))

## ------------------------------------------------------------------------
echoWaterGetParams(term = "Oxygen, dissolved")

## ----echo=TRUE, message=FALSE, warning=FALSE, paged.print=FALSE----------
library(ggplot2)
library(ggmap)
library(dplyr)
library(purrr)
library(sf)
library(ggrepel)
## This example requires the development version of ggplot with support
## for geom_sf()
df <- echoWaterGetFacilityInfo(xmin = '-96.407563', ymin = '30.554395',
                                        xmax = '-96.25947', ymax = '30.751984',
                                        output = 'sf')
## Download a basemap
collegestation <- get_map(location = c(-96.387509, 30.583572,
                                       -96.281422, 30.640008), 
                          zoom = 14, maptype = "toner")

## Need some coordinates to create labels
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
  labs(x = "Longitude", y = "Latitude", 
       title = "NPDES permits near Texas A&M",
       caption = "Source: EPA ECHO database")

