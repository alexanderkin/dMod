% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dModFrameClass.R, R/dataClass.R
\name{covariates.tbl_df}
\alias{covariates.tbl_df}
\alias{covariates}
\alias{covariates.datalist}
\alias{covariates.data.frame}
\title{Access the covariates in the data}
\usage{
\method{covariates}{tbl_df}(x, hypothesis = 1)

covariates(x)

\method{covariates}{datalist}(x)

\method{covariates}{data.frame}(x)
}
\arguments{
\item{x}{Either a \link{datalist} or a \code{data.frame} with mandatory columns \code{c("name", "time", "value", "sigma")} or a \link{dMod.frame}}

\item{hypothesis}{The hypothesis in the dMod.frame}
}
\value{
The \code{condition.grid} of the data
}
\description{
Access the covariates in the data
}
