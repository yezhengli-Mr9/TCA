% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/TCA.R
\name{tca}
\alias{tca}
\title{Fitting the TCA model}
\usage{
tca(X, W, C1 = NULL, C1.map = NULL, C2 = NULL, refit_W = FALSE,
  refit_W.features = NULL, refit_W.sparsity = 500,
  refit_W.sd_threshold = 0.02, tau = NULL, parallel = FALSE,
  num_cores = NULL, max_iters = 10, log_file = "TCA.log",
  debug = FALSE, verbose = TRUE)
}
\arguments{
\item{X}{An \code{m} by \code{n} matrix of measurements of \code{m} features for \code{n} observations. Each column in \code{X} is assumed to be a mixture of \code{k} different sources. Note that \code{X} must include row names and column names and that NA values are currently not supported. \code{X} should not include features that are constant across all observations.}

\item{W}{An \code{n} by \code{k} matrix of weights - the weights of \code{k} sources for each of the \code{n} mixtures (observations). All the weights must be positive and each row, corresponding to the weights of a single observation, must sum up to 1. Note that \code{W} must include row names and column names and that NA values are currently not supported. In case where only initial estimates of \code{W} are available, \code{tca} can be set to re-estimate \code{W} (see \code{refit_W}).}

\item{C1}{An \code{n} by \code{p1} design matrix of covariates that may affect the hidden source-specific values (possibly a different effect on each source). Note that \code{C1} must include row names and column names and should not include an intercept term. NA values are currently not supported.}

\item{C1.map}{An \code{p1} by \code{k} matrix of 0/1 values, indicating for each of the \code{p1} covariates in \code{C1} whether to consider its potential effects on the values of each of the \code{k} sources (e.g., if position \code{i,j} in \code{C1.map} is 1 then the potential effect of the \code{i}-th covariate in \code{C1} on the {j}-th source will be considered). If \code{C1.map == NULL} then effects for all covariates in \code{C1} in each of the sources will be considered.}

\item{C2}{An \code{n} by \code{p2} design matrix of covariates that may affect the mixture (i.e. rather than directly the sources of the mixture; for example, variables that capture biases in the collection of the measurements). Note that \code{C2} must include row names and column names and should not include an intercept term. NA values are currently not supported.}

\item{refit_W}{A logical value indicating whether to re-estimate the input \code{W} under the TCA model.}

\item{refit_W.features}{A vector with the names of the features in \code{X} to consider when re-estimating \code{W} (i.e. when \code{refit_W == TRUE}). This is useful since oftentimes just a subset of the features in \code{X} will be informative for estimating \code{W}. If \code{refit_W.features == NULL} then the ReFACTor algorithm will be used for performing feature selection (see also \code{refit_W.sparsity, refit_W.sd_threshold}).}

\item{refit_W.sparsity}{A numeric value indicating the number of features to select using the ReFACTor algorithm when re-estimating \code{W} (activated only if \code{refit_W == TRUE} and \code{refit_W.features == NULL}). Note that \code{refit_W.sparsity} must be lower or equal to the number of features in \code{X}. For more information, see the argument \code{sparsity} in \link{refactor}.}

\item{refit_W.sd_threshold}{A numeric value indicating a standard deviation threshold to be used for excluding low-variance features in \code{X} (activated only if \code{refit_W == TRUE} and \code{refit_W.features == NULL}). For more information, see the argument \code{sd_threshold} in \link{refactor}.}

\item{tau}{A non-negative numeric value of the standard deviation of the measurement noise (i.e. the i.i.d. component of variation in the model). If \code{tau == NULL} then \code{tca} will estimate \code{tau}.}

\item{parallel}{A logical value indicating whether to use parallel computing (possible when using a multi-core machine).}

\item{num_cores}{A numeric value indicating the number of cores to use (activated only if \code{parallel == TRUE}). If \code{num_cores == NULL} then all available cores except for one will be used.}

\item{max_iters}{A numeric value indicating the maximal number of iterations to use in the optimization of the TCA model (\code{max_iters} iterations will be used as long as the optimization does not converge in earlier iterations).}

\item{log_file}{A path to an output log file. Note that if the file \code{log_file} already exists then logs will be appended to the end of the file. Set \code{log_file} to \code{NULL} to prevent output from being saved into a file; note that if \code{verbose == TRUE} then no output file will be generated regardless of the value of \code{log_file}.}

\item{debug}{A logical value indicating whether to set the logger to a more detailed debug level; please set \code{debug} to \code{TRUE} before reporting issues.}

\item{verbose}{A logical value indicating whether to print logs.}
}
\value{
A list with the estimated parameters of the model. This list can be then used as the input to other functions such as \code{tcareg}.
\item{W}{An \code{n} by \code{k} matrix of weights. If \code{refit_W == TRUE} then this is the re-estimated \code{W}; otherwise this is the input \code{W}}
\item{mus_hat}{An \code{m} by \code{k} matrix of estimates for the mean of each source in each feature.}
\item{sigmas_hat}{An \code{m} by \code{k} matrix of estimates for the standard deviation of each source in each feature.}
\item{tau_hat}{An estimate of the standard deviation of the i.i.d. component of variation in \code{X}. If an input value was provided for \code{tau} (i.e. \code{tau != NULL}) then \code{tau_hat == tau}.}
\item{gammas_hat}{An \code{m} by \code{k*p1} matrix of the estimated effects of the \code{p1} factors in \code{C1} on each of the \code{m} features in \code{X}, where the first \code{p1} columns are the source-specific effects of the \code{p1} factors on the first source, the following \code{p1} columns are the source-specific effects on the second source and so on.}
\item{deltas_hat}{An \code{m} by \code{p2} matrix of the estimated effects of the \code{p2} factors in \code{C2} on the mixture values of each of the \code{m} features in \code{X}.}
}
\description{
Fits the TCA model for an input matrix of observations coming from a mixture of \code{k} sources, under the assumption that each observation is a mixture of unique source-specific values (in each feature in the data). For example, in the context of tissue-level bulk DNA methylation data coming from a mixture of cell types (i.e. the input is methylation sites by individuals), \code{tca} allows to model the methylation of each individual as a mixture of cell-type-specific methylation levels that are unique to the individual.
}
\details{
The TCA model assumes that the hidden source-specific values are random variables. Formally, denote by \eqn{Z_{hj}^i} the source-specific value of observation \eqn{i} in feature \eqn{j} source \eqn{h}, the TCA model assumes: \deqn{Z_{hj}^i \sim N(\mu_{hj},\sigma_{hj}^2)} where \eqn{\mu_{hj},\sigma_{hj}} represent the mean and standard deviation that are specific to feature \eqn{j} source \eqn{h}. The model further assumes that the observed value of observation \eqn{i} in feature \eqn{j} is a mixture of \eqn{k} different sources: \deqn{X_{ji} =  \sum_{h=1}^k W_{ih}Z_{hj}^i + \epsilon_{ji}} where \eqn{W_{ih}} is the non-negative proportion of source \eqn{h} in the mixture of observation \eqn{i} such that \eqn{\sum_{h=1}^kW_{ih} = 1}, and \eqn{\epsilon_{ji} \sim N(0,\tau^2)} is an i.i.d. component of variation that models measurement noise. Note that the mixture proportions in \eqn{W} are, in general, unique for each individual, therefore each entry in the data matrix \eqn{X} is coming from a unique distribution (i.e. a different mean and a different variance).

In cases where the true \code{W} is unknown, \code{tca} can be provided with initial estimates of \code{W} and then re-estimate \code{W} as part of the optimization procedure (see argument \code{refit_W}). These initial estimates should not be random but rather capture the information in \code{W} to some extent. When the argument \code{refit_W} is used, it is typically the case that only a subset of the features should be used for re-estimating \code{W}. Therefore, when re-estimating \code{W}, \code{tca} performs feature selection using the ReFACTor algorithm; alternatively, it can also be provided with a user-specified list of features to be used in the re-estimation (see argument \code{refit_W.features}).

Factors that systematically affect the source-specific values \eqn{Z_{hj}^i} can be further considered (see argument \code{C1}). In that case, we assume: \deqn{Z_{hj}^i \sim N(\mu_{hj}+c^{(1)}_i \gamma_j^h,\sigma_{hj}^2)} where \eqn{c^{(1)}_i} is a row vector from \code{C1}, corresponding to the values of the \eqn{p_1} factors for observation \eqn{i}, and \eqn{\gamma_j^h} is a vector of \eqn{p_1} corresponding effect sizes.

Factors that systematically affect the mixture values \eqn{X_{ji}}, such as variables that capture biases in the collection of the measurements, can also be considered (see argument \code{C2}). In that case, we assume: \deqn{X_{ji} \sim \sum_{h=1}^k W_{ih}Z_{hj}^i + c^{(2)}_i \delta_j + \epsilon_{ij}} where \eqn{c^{(2)}_i} is a row vector from \code{C2}, corresponding to the values of the \eqn{p_2} factors for observation \eqn{i}, and \eqn{\delta_j} is a vector of \eqn{p_2} corresponding effect sizes.
}
\section{Note}{
 The function \code{tca} may require a long running time when the input matrix \code{X} is very large; to alleviate this, it is strongly advised to use the \code{parallel} argument, given that a multi-core machine is available.
}

\examples{
data <- test_data(100, 20, 3, 1, 1, 0.01)
tca.mdl <- tca(X = data$X, W = data$W, C1 = data$C1, C2 = data$C2)

}
\references{
Rahmani E, Schweiger R, Rhead B, Criswell LA, Barcellos LF, Eskin E, Rosset S, Sankararaman S, Halperin E. Cell-type-specific resolution epigenetics without the need for cell sorting or single-cell biology. Nature Communications 2018.

Rahmani E, Zaitlen N, Baran Y, Eng C, Hu D, Galanter J, Oh S, Burchard EG, Eskin E, Zou J, Halperin E. Sparse PCA corrects for cell type heterogeneity in epigenome-wide association studies. Nature Methods 2016.
}
