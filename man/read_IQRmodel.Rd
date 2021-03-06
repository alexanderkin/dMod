% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/IQRtools.R
\name{read_IQRmodel}
\alias{read_IQRmodel}
\title{IQR QSP Model}
\usage{
read_IQRmodel(input, errmodel = NULL, regression = NULL, fix = NULL,
  estimate = NULL, ndoses = 1, ...)
}
\arguments{
\item{input}{character pointing to the model, see \code{\link[IQRtools]{IQRmodel}} for details.}

\item{errmodel}{eqnvec to define the error model, 
e.g. \code{eqnvec(OUTPUT1 = "sigma_abs_1 * OUTPUT1 + sigma_rel_1")}. If NULL, no error model is returned.}

\item{regression}{character vector containing names of regression parameters.}

\item{fix}{character vector denoting which parameters and initial
values to fix during parameter estimation.}

\item{estimate}{character vector denoting which parameters and initial values to estimate.
If \code{estimate} is provided, \code{fix} is overwritten.}

\item{ndoses}{the maximal number of administrations to prepare for.}

\item{...}{arguments going to \code{\link{odemodel}()}.}
}
\value{
list
}
\description{
IQR QSP Model
}
