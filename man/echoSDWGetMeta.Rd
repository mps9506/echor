% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sdw.R
\name{echoSDWGetMeta}
\alias{echoSDWGetMeta}
\title{Downloads EPA ECHO Safe Drinking Water Facilities Metadata}
\usage{
echoSDWGetMeta(verbose = FALSE)
}
\arguments{
\item{verbose}{Logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE}
}
\value{
returns a dataframe
}
\description{
Downloads EPA ECHO Safe Drinking Water Facilities Metadata
}
\examples{
\donttest{
## These examples require an internet connection to run

# returns a dataframe of
echoSDWGetMeta()
}
}
