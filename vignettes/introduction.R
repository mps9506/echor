## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  fig.asp = 1 / 1.6,
  out.width = "75%",
  fig.width = 5,
  fig.retina = NULL,
  dpi = 96,
  collapse = TRUE,
  comment = "#>"
)

options(crayon.enabled = NULL)

library(kableExtra)
library(httptest)
library(dplyr)

path <- here::here("vignettes/int")

api_root <- "https://echodata.epa.gov/echo/"

set_redactor(function (response) {
  response %>%
    gsub_response(api_root, "", fixed = TRUE)
})

set_requester(function (request) {
  request %>%
    gsub_request(api_root, "", fixed = TRUE)
})

httptest::start_vignette(path = path)

## -----------------------------------------------------------------------------
library(echor)
meta <- echoAirGetMeta()
meta

## -----------------------------------------------------------------------------
library(echor)

## Retrieve information about facilities within a geographic location
df <- echoAirGetFacilityInfo(output = "df",
                             xmin = '-96.387509',
                             ymin = '30.583572',
                             xmax = '-96.281422',
                             ymax = '30.640008',
                             qcolumns = "1,2,3,22,23")

## ----echo=FALSE, message=FALSE, warning=FALSE---------------------------------
knitr::kable(head(df), "html") %>%
  kable_styling() %>%
  scroll_box(height = "200px")

## -----------------------------------------------------------------------------
df <- echoGetCAAPR(p_id = '110000350174')

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(head(df), "html") %>%
  kable_styling() %>%
  scroll_box(width = "100%", height = "200px")

## -----------------------------------------------------------------------------
df <- echoWaterGetFacilityInfo(xmin = '-96.407563', ymin = '30.554395', 
                               xmax = '-96.25947',  ymax = '30.751984', 
                               output = 'df', qcolumns = "1,2,3,4,5,6,7")

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(head(df), "html") %>%
  kable_styling() %>%
  scroll_box(width = "100%", height = "200px")

## -----------------------------------------------------------------------------
df <- echoGetEffluent(p_id = 'tx0119407', parameter_code = '50050')

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(head(df), "html") %>%
  kable_styling() %>%
  scroll_box(width = "100%", height = "200px")

## -----------------------------------------------------------------------------
echoWaterGetParams(term = "Oxygen, dissolved")

## -----------------------------------------------------------------------------
df <- tibble::tibble(permit = c('TX0119407', 'TX0062677'))
df <- downloadDMRs(df, idColumn = permit)
df <- df %>%
  tidyr::unnest(dmr)
tibble::glimpse(df)

## ----message=FALSE, warning=FALSE, paged.print=FALSE, width="100%"------------

library(ggplot2)
library(ggspatial)
library(dplyr)
library(sf)

## Download data as a simple feature
df <- echoWaterGetFacilityInfo(xmin = '-96.407563', ymin = '30.554395',
                                        xmax = '-96.25947', ymax = '30.751984',
                                        output = 'sf')

## Make the map
ggplot(df) +
  annotation_map_tile(zoomin = 0, progress = "none") +
  geom_sf(inherit.aes = FALSE, shape = 21, 
          color = "darkred", fill = "darkred", 
          size = 2) +
  labs(x = "Longitude", y = "Latitude", 
       title = "NPDES permits near Texas A&M",
       caption = "Source: EPA ECHO database")

## ----include = FALSE----------------------------------------------------------
httptest::end_vignette()

