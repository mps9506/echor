% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/water.R
\name{echoWaterGetFacilityInfo}
\alias{echoWaterGetFacilityInfo}
\title{Downloads EPA ECHO water facility information}
\usage{
echoWaterGetFacilityInfo(output = "df", verbose = FALSE, ...)
}
\arguments{
\item{output}{Character string specifying output format. \code{output = 'df'} for a dataframe or \code{output = 'sf'} for a simple features spatial dataframe. See (\url{https://CRAN.R-project.org/package=sf}) for more information about simple features.}

\item{verbose}{Logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE}

\item{\dots}{Further arguments passed as query parameters in request sent to EPA ECHO's API. For more options see: \url{https://echo.epa.gov/tools/web-services/facility-search-water#!/Facility_Information/get_cwa_rest_services_get_facility_info} for a complete list of parameter options. Examples provided below.}
}
\value{
returns a dataframe or simple features dataframe
}
\description{
Returns a dataframe or simplefeature dataframe of permitted facilities returned by the query.
Uses EPA's ECHO API: \url{https://echo.epa.gov/tools/web-services/facility-search-water}.
}
\examples{
\donttest{
## These examples require an internet connection to run

## Retrieve table of facilities by bounding box
echoWaterGetFacilityInfo(p_c1lon = '-96.407563',
p_c1lat = '30.554395',
p_c2lon = '-96.25947',
p_c2lat = '30.751984',
p_pcomp = 'POT',
output = 'df')

## Retrieve a simple features dataframe by bounding box
spatialdata <- echoWaterGetFacilityInfo(p_c2lon = '-96.407563',
p_c1lat = '30.554395',
p_c2lon = '-96.25947',
p_c2lat = '30.751984',
p_pcomp = 'POT',
output = 'sf')

}

}
