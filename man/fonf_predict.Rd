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
             interval = c("none", "conformal", "varying", "simultaneous"))
}
\arguments{
\item{object}{An object of class \code{"fonf_dl"} returned by
              \code{\link{fonf_fit}}.}
\item{func_cov_new}{List of length \eqn{P}; element \eqn{p} is an
                    \eqn{n_{\text{new}} \times G_p} matrix that stores the new
                    subjects??? functional predictor
                    \eqn{X_{\text{new},i}^{(p)}(s_{pj})}.}
\item{scalar_cov_new}{Optional \eqn{n_{\text{new}} \times d_z} numeric matrix of
                      scalar covariates \eqn{Z_{\text{new},i}}.  If the original
                      model was fitted without scalar covariates, set this to
                      \code{NULL}.}
\item{interval}{Type of prediction to return:
  \describe{
    \item{\code{"none"}}{
      Point predictions only.
    }
    \item{\code{"conformal"}}{
      Point predictions together with the constant-width conformal band.
      Its finite-sample coverage is marginal over a new subject and an
      independently and uniformly selected response-grid location.
    }
    \item{\code{"varying"}}{
      Point predictions together with a varying-width band whose half-width
      is proportional to the estimated response-domain scale function.
      This band has the same marginal coverage interpretation as
      \code{"conformal"}; the term ``local'' does not signify conditional
      coverage at a fixed covariate value or grid point.
    }
    \item{\code{"simultaneous"}}{
      Point predictions together with a band calibrated to cover the complete
      response trajectory over all recorded grid points simultaneously.
    }
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
Let \eqn{c} denote the number of calibration subjects and let
\eqn{M=\code{object\$py}}.  The constant-width band returned by
\code{interval = "conformal"} is
\deqn{
\hat Y_i(t_m)\ \mathbin{\pm}\ q_{1-\alpha},
}
where \eqn{q_{1-\alpha}} is the
\eqn{\left\lceil(1-\alpha)(c+1)M\right\rceil}th order statistic of the
\eqn{cM} pooled absolute calibration residuals.  If this order exceeds
\eqn{cM}, the half-width is set to \code{Inf}.

The varying-width band returned by \code{interval = "varying"} is
\deqn{
\hat Y_i(t_m)\ \mathbin{\pm}\
q_{1-\alpha}^{\sigma}\hat\sigma(t_m),
}
where \eqn{q_{1-\alpha}^{\sigma}} is computed from the pooled normalized
calibration residuals using the same finite-sample rank.

Under subject-level exchangeability and a data-independent subject-level
training--calibration split, both bands have finite-sample coverage of at
least \eqn{1-\alpha} for a new subject at an independently and uniformly
selected response-grid location.  Their coverage guarantee is marginal over
the new subject and the response grid; it does not imply coverage of at least
\eqn{1-\alpha} separately at every fixed grid point.

The band returned by \code{interval = "simultaneous"} is
\deqn{
\hat Y_i(t_m)\ \mathbin{\pm}\
Q_{1-\alpha}\hat\sigma(t_m),
}
where \eqn{Q_{1-\alpha}} is calibrated from the subject-level maximum
normalized residuals.  This band has simultaneous finite-sample coverage of
at least \eqn{1-\alpha} over all \eqn{M} recorded response-grid points.

None of these guarantees requires independence among the grid-point
residuals within a response curve.  The calibration unit is the complete
subject-level response trajectory.
}
}
\value{
\describe{
  \item{\code{interval = "none"}}{A numeric matrix with
        \eqn{nrow = n_{new}} and \code{ncol = py} containing point
        predictions.}
  \item{\code{interval = "conformal"}, \code{"varying"}, or
      \code{"simultaneous"}}{
      A list with components \code{mean}, \code{lower}, and \code{upper}.
      Each component is an \eqn{n_{\mathrm{new}}\times M} matrix whose
      columns are named \code{"t1"}, \code{"t2"}, \dots, \code{"tM"}.
      The interpretation of the returned band depends on the selected
      \code{interval} argument, as described above.
}
}}
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
