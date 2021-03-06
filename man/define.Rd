% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/toolsDaniel.R
\name{define}
\alias{define}
\alias{insert}
\alias{branch}
\title{Define parameter transformations by \code{define()}, \code{branch()} and \code{insert()}}
\usage{
define(trafo, expr, ..., conditionMatch = NULL)

insert(trafo, expr, ..., conditionMatch = NULL)

branch(trafo, table = NULL, conditions = rownames(table))
}
\arguments{
\item{trafo}{named character vector of parametric expressions or object 
of class \code{eqnvec}}

\item{expr}{character of the form \code{"lhs ~ rhs"} where both \code{lhs}
and \code{rhs} can contain a number of symbols for which vaues are passed
by the \code{...} argument}

\item{...}{used to pass values for symbols as named arguments}

\item{conditionMatch}{optional character, Use as regular expression to apply the reparameterization only to conditions containing conditionMatch}

\item{table}{table of covariates as data frame. Rownames are used as unique identifier,
usually called "conditions", and columns represent covariates associated with these conditions.}

\item{conditions}{character vector with condition names. Overwrites the rownames of table.}
}
\value{
object of the same class as trafo or list thereof, if \code{branch()} has been
used.
}
\description{
Define parameter transformations by \code{define()}, \code{branch()} and \code{insert()}
}
\examples{
# Define some parameter names
parameters <- c("A", "B", "k1", "k2")
# Define a covariate table
covtable <- data.frame(dose = c(1, 1, 10), 
                       inhibitor = c("no", "inh", "no"), 
                       row.names = c("Low_noInh", "Low_Inh", "High_noInh"))

# Start with an empty transformation
trans <- NULL

# Generate the identity transformation for parameters
trans <- define(trans, "x ~ x", x = parameters); print(trans)

# Insert exp(x) wherever you find x
trans <- insert(trans, "x ~ exp(x)", x = parameters); print(trans)

# Some new expressions instead of k1 and k2
trans <- insert(trans, "x ~ y", x = c("k1", "k2"), y = c("q1 + q2", "q1 - q2")); print(trans)

# Define some parameters as 0
trans <- define(trans, "x ~ 0", x = "B"); print(trans)

# The parameter name can also be directly used in the formula
trans <- insert(trans, "q1 ~ Q"); print(trans)

# Replicate the transformation 3 times with the rownames of covtable as list names
trans <- branch(trans, table = covtable); print(trans)

# Insert the rhs wherever the lhs is found in the transformation
# column names of covtable can be used to perform specific replacements
# for each transformation
trans <- insert(trans, "x ~ x_inh", x = c("Q", "q2"), inh = inhibitor); print(trans)

# Also numbers can be inserted
trans <- define(trans, "A ~ dose", dose = dose); print(trans)


# Turn that into a parameter transformation function
p <- P(trans)
parnames <- getParameters(p)
pars <- rnorm(length(parnames))
names(pars) <- parnames

p(pars)


# Advanced tricks exploiting the quoting-mechanism when capturing "..."

mydataframe <- data.frame(
  name = rep(letters[1:2], each = 3),
  value = 1:6,
  time = rep(1:3, 2),
  sigma = 0.1,
  par1 = rep(0:1, each = 3),
  par2 = rep(9:10, each = 3),
  par3 = rep(1:3, each = 2),
  stringsAsFactors = FALSE
)

parameters <- c("a", "b", "par1", "par2", "par3")
pars_to_insert <- c("par1", "par2")
# pars_to_insert <- intersect(getParameters(g*x), names(data)) # this would be the usual way when setting up a model

trafo <- define(NULL, "x~x", x = parameters) 
trafo <- branch(trafo, covariates(as.datalist(mydataframe)))

# Trick 1: Access values from covariates()-Table with get/mget. 
    # The names of the parameters which are supplied in the covariates()-table have to be supplied manually.
trafo <- insert(trafo, "name ~ value", value = unlist(mget(pars_to_insert)), name = pars_to_insert)

# Trick 2: Access symbols from current condition-specific trafo with .currentSymbols, access current condition-specific trafo by .currentTrafo
    # The input passed by the dots is "quoted" (substituted) and eval()'ed in the environment of the lapply(1:length(conditions), function(i) {})
trafo <- insert(trafo, "x~exp(X)", x = .currentSymbols, X = toupper(.currentSymbols))

# Trick 3: Condition specificity. There are two ways to do this
  # 1. Apply reparametrization only for specific conditions using Regular Expressions for the conditionMatch argument. This matches the condition name agains a regex
trafo <- define(NULL, "x~x", x = parameters) 
trafo <- branch(trafo, covariates(as.datalist(mydataframe)))

insert(trafo, "x~x_par3", x = "a", conditionMatch = "^0_9", par3 = par3)  # Conditions starting with 0_9
insert(trafo, "x~0", x = "a", conditionMatch = "^(?!0_9)")                # Conditions NOT starting with 0_9
  # 2. Specify conditions by boolean arguments
insert(trafo, "x~x_par2", par1 == 0, x = parameters, par2 = par2)       # Conditions which satisfy par1 == 0
  # Special case: Pass two arguments with the same name. This is only possible if one of them is logical and the other is not.
insert(trafo, "x~x_par2", par2 == 9, x = .currentSymbols, par2 = par2)       # Conditions which satisfy par2 == 9





}
