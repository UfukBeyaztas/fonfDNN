\name{fonf_tune}
\alias{fonf_tune}
\title{Simple Grid–Search Hyper-parameter Tuner for \code{fonf_fit}}
\description{
Evaluates every row of a user-supplied hyper-parameter grid via
\eqn{K}-fold cross-validation (\code{fonf_cv}), reports the
cross-validated mean-squared error (CV–MSE), and then refits the best
combination on the \emph{full} data set.
The implementation is deliberately lightweight—single-core, base \R{} only—so it
runs on any system where \pkg{fonf} installs.
}
\usage{
fonf_tune(grid,
          resp, func_cov, scalar_cov = NULL,
          nfolds = 5)
}
\arguments{
\item{grid}{A data frame created by \code{fonf_param_grid} describing
            the hyper-parameter combinations to be tested.  Each column
            corresponds to an argument of \code{\link{fonf_fit}}.}
\item{resp}{Numeric matrix of size \eqn{n \times p_y}; functional response
            curves sampled on a common grid.}
\item{func_cov}{List of length \eqn{P}; element \eqn{p} is an
                \eqn{n \times G_p} matrix containing the \eqn{p}-th functional
                predictor.}
\item{scalar_cov}{Optional \eqn{n \times q} numeric matrix of scalar
                  predictors.  Omit or set to \code{NULL} if none.}
\item{nfolds}{Number of folds used by \code{fonf_cv} (default 5).}
}
\details{
\subsection{How it works}{
For each row \eqn{g = 1,\dots,G} of \code{grid}:

\enumerate{
  \item The row is coerced to a named \code{list} of arguments compatible with
        \code{\link{fonf_fit}} (vectors such as \code{neurons_per_layer} are
        replicated to the correct length).
  \item \code{fonf_cv} performs \eqn{K}-fold CV and stores the average
        test MSE in \code{cv_vec[g]}.
}
After all rows are processed the index of the minimum
\eqn{CV\!-\!MSE} is selected, the corresponding parameter list
is re-sanitised by \code{sanitize_basis()}, and a final model is fitted on the
whole data via \code{\link{fonf_fit}} with \code{verbose = TRUE}.
}
}
\value{
\describe{
  \item{results}{Data frame combining the original \code{grid} and a new column
                 \code{CV_MSE} (lower is better).}
  \item{best_params}{Named list containing the best-performing hyper-parameters
                     in a format ready for \code{\link{fonf_fit}}.}
  \item{best_model}{Object of class \code{"fonf_dl"} fitted on the full data
                    with \code{best_params}.}
}}
\author{Ufuk Beyaztas, Gizel Bakicierler Sezer, and Han Lin Shang}
\note{
\itemize{
  \item This function is single-threaded.  For large grids consider a parallel
        wrapper (e.g. \pkg{future.apply}).
  \item Internal helpers \code{flatten1()} and \code{sanitize_basis()}
        are not exported but are documented in the source code.
}
}
\examples{
## Not run:
# -------------------------------------------------------------
# 1. Simulate training data
# -------------------------------------------------------------
# n <- 100
# simdata <- dgp_mixed(n, 101, model = "nonlinear")
#
# y    <- simdata$y
# x    <- simdata$x
# xscl <- simdata$x.scl
#
# --------------------------------------------------------------
# 2. Construct a small hyper-parameter grid
# --------------------------------------------------------------
# grid <- fonf_param_grid(
#   hidden_layers         = c(1, 2),
#   neurons_per_layer     = list(32, c(64, 32)),
#   activations_in_layers = list("relu", c("relu", "linear")),
#   learning_rate         = c(1e-3, 5e-4),
#   epochs                = 25
# )
#
# --------------------------------------------------------------
# 3. Tune and refit
# --------------------------------------------------------------
# tune_out <- fonf_tune(grid,
#                       resp       = y,
#                       func_cov   = x,
#                       scalar_cov = xscl,
#                       nfolds     = 5)
#
# tune_out$results           # CV table
# best_mod <- tune_out$best_model
## End(Not run)
}
