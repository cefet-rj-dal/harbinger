% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/hcp_cf_lr.R
\name{hcp_cf_lr}
\alias{hcp_cf_lr}
\title{Change Finder using LR}
\usage{
hcp_cf_lr(sw_size = 30)
}
\arguments{
\item{sw_size}{Sliding window size}
}
\value{
\code{hcp_cf_lr} object
}
\description{
Change-point detection is related to event/trend change detection. Change Finder LR detects change points based on deviations relative to linear regression model \url{doi:10.1109/TKDE.2006.1599387}.
}
\examples{
library(daltoolbox)

#loading the example database
data(har_examples)

#Using example 6
dataset <- har_examples$example6
head(dataset)

# setting up time series regression model
model <- hcp_cf_lr()

# fitting the model
model <- fit(model, dataset$serie)

detection <- detect(model, dataset$serie)

# filtering detected events
print(detection |> dplyr::filter(event==TRUE))

}