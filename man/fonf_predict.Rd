\name{fonf_predict}
\alias{fonf_predict}
\title{Predict With a Trained Hybrid Deep Tensor Network}
\description{
Generates point predictions and, optionally, distribution-free conformal
prediction bands for a \code{\link{fonf_fit}} model given new functional and
scalar covariates.
}
\usage{
fonf_predict(object,
             func_cov_new,
             scalar_cov_new = NULL,
             interval = c("none", "conformal"))
}
\arguments{
\item{object}{An object of class \code{"fonf_dl"} returned by
              \code{\link{fonf_fit}}.}
\item{func_cov_new}{List of length \eqn{P}; element \eqn{p} is an
                    \eqn{n_{\text{new}} \times G_p} matrix that stores the new
                    subjects’ functional predictor
                    \eqn{X_{\text{new},i}^{(p)}(s_{pj})}.}
\item{scalar_cov_new}{Optional \eqn{n_{\text{new}} \times d_z} numeric matrix of
                      scalar covariates \eqn{Z_{\text{new},i}}.  If the original
                      model was fitted without scalar covariates, set this to
                      \code{NULL}.}
\item{interval}{Type of prediction to return:
  \describe{
    \item{\code{"none"}}{Point estimates only.}
    \item{\code{"conformal"}}{Point estimates plus lower/upper bands that
          achieve marginal coverage \eqn{1-\alpha} (see Details).}
  }}
}
\details{
Let \eqn{f_\mathrm{hat}} denote the trained network and let
\eqn{(x_i, z_i)} be the design-matrix rows for a new subject, built with the
same tensor-product bases used in training.  \code{fonf_predict}:

\enumerate{
\item Builds the design matrix with \code{design_matrix_build}.
\item Standardises it with the training means and scales stored in the fitted
      object.
\item Computes the predictions, then reshapes the vector into an
      \eqn{n_{\text{new}} \times M} matrix, where \eqn{M =} \code{object$py}.
}

\subsection{Conformal bands}{
If \code{interval == "conformal"} the returned bands are
\eqn{\hat Y_i(t_m) \;\pm\; q_{1-\alpha}}, where \eqn{q_{1-\alpha}} is the
\eqn{(1-\alpha)}-quantile of the absolute residuals on the calibration set
chosen during training.  Split-conformal theory (Lei \emph{et al.}, 2018)
guarantees marginal coverage \eqn{1-\alpha} at each grid point, without
distributional assumptions beyond independent rows.
}
}
\value{
\describe{
  \item{\code{interval = "none"}}{A numeric matrix with
        \eqn{nrow = n_{new}} and \code{ncol = py} containing point
        predictions.}
  \item{\code{interval = "conformal"}}{A list with components
        \code{mean}, \code{lower}, and \code{upper}, each a matrix whose
        columns are named \code{"t1"}, \code{"t2"}, \dots, \code{"tM"}.}
}}
\references{
Lei, J., G'Sell, M., Rinaldo, A., Tibshirani, R. and Wasserman, L. (2018).
Distribution-Free Predictive Inference for Regression.
\emph{Journal of the American Statistical Association}, 113(523), 1094–1111.
}
\author{Ufuk Beyaztas, Gizel Bakicierler Sezer, and Han Lin Shang}
\note{The feature grids supplied here must match those used at training time,
and the length of the prediction vector must be divisible by
\code{object$py}; otherwise an error is raised.}
\seealso{\code{\link{fonf_fit}}, \code{\link{dgp_mixed}}}
\examples{
## Not run:
# --------------------------------------------------------------
# 1. Train a model on simulated data
# --------------------------------------------------------------
# simdata <- dgp_mixed(100, 101, model = "nonlinear")
# mdl <- fonf_fit(resp = simdata$y,
#                 func_cov = simdata$x,
#                 scalar_cov = simdata$x.scl)
#
# --------------------------------------------------------------
# 2. Predict on new subjects with conformal bands
# --------------------------------------------------------------
# test <- dgp_mixed(250, 101, model = "nonlinear")
# band <- fonf_predict(mdl,
#                      func_cov_new   = test$x,
#                      scalar_cov_new = test$x.scl,
#                      interval       = "conformal")
# pred_mean <- band$mean
## End(Not run)
}
