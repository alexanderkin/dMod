% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/IQRtools.R
\name{summary.IQRsysProjectMulti}
\alias{summary.IQRsysProjectMulti}
\title{Summarize Multi IQRsysProject}
\usage{
\method{summary}{IQRsysProjectMulti}(object, ..., FLAGreport = FALSE,
  pathname = attr(object, "input"))
}
\arguments{
\item{object}{object of class \code{IQRsysProjectMulti}}

\item{...}{currently not used}

\item{FLAGreport}{If \code{TRUE} then the table text is annotated by formatting suitable for IQReport. 
If \code{FALSE} (default), then just text for display.}

\item{pathname}{Write the summary to a file in \code{pathname}. If \code{NULL}, no output is written.}
}
\description{
Summarize Multi IQRsysProject
}
\seealso{
\code{\link{as_IQRsysProjectMulti}}
}
