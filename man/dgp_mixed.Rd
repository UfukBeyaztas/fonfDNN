\name{dgp_mixed}
\alias{dgp_mixed}
\title{Simulate Mixed Functional–Scalar Data for Function–on–Function Regression}
\description{
Generates synthetic datasets that mimic the structure analysed in
\emph{Beyaztas and Bakicierler Sezer (2025)}: a functional response
observed on a dense grid, multiple functional predictors, and multiple scalar
predictors.  Two regimes are available:

\itemize{
  \item \code{"linear"}: response driven solely by linear integral effects.
  \item \code{"nonlinear"}: adds strong, smooth nonlinear interactions
        (functional \eqn{\times} functional, functional \eqn{\times} scalar,
        scalar \eqn{\times} scalar) scaled to dominate the linear part.
}
Every dataset also includes Ornstein–Uhlenbeck (OU) process noise to emulate
realistic autocorrelated measurement error.
}
\usage{
dgp_mixed(n, j,
          model   = c("linear", "nonlinear"),
          n_func  = 5L,
          n_scl   = 3L,
          seed    = NULL)
}
\arguments{
\item{n}{Number of subjects/curves.}
\item{j}{Grid length \eqn{M}; all functional objects are evaluated on
         \code{seq(0, 1, length.out = j)}.}
\item{model}{Character string choosing the data-generating mechanism;
             partial matching is supported.}
\item{n_func}{Number \eqn{P} of functional predictors to simulate.}
\item{n_scl}{Number \eqn{d_z} of scalar predictors.}
\item{seed}{Optional integer for reproducibility (\code{set.seed(seed)}).}
}
\details{
Let \eqn{X_i^{(p)}(s)} denote functional predictor \eqn{p=1,\dots,P} and \eqn{\mathbf Z_i \in \mathbb R^{d_z}} the scalar predictor vector for subject
\eqn{i \in \{1,\dots,n\}}.  The latent \emph{signal} generating the functional response on grid points \eqn{t_1,\dots,t_M} is

\deqn{
\eta_i(t)=
\underbrace{\sum_{p=1}^{P}\int_0^1 X_i^{(p)}(s)\,\beta_p(s,t)\,ds}_{\text{linear functional effects}}
+\underbrace{\mathbf Z_i^\top\gamma(t)}_{\text{scalar effects}}
+\mathcal N\!L_i(t),
}

where \eqn{P=3} ''strong'' functional predictors drive the linear component, \eqn{\beta_p} are pre-specified wavy B-spline surfaces (see code), and
\eqn{\gamma(t)} are smooth one-dimensional bases. If \code{model == "linear"} we set \eqn{\mathcal N\!L_i(t)\equiv 0};
otherwise \eqn{\mathcal N\!L_i(t)} equals the \emph{sum} of five carefully designed nonlinear terms (quadratic functional interactions, sinusoidal
transforms, scalar–functional products, etc.) rescaled so that
\deqn{\mathrm{SD}\{\mathcal N\!L\}\approx 2\,\mathrm{SD}\{\text{linear signal}\}.}

The \emph{observed} response is
\deqn{
Y_i(t_m)=\eta_i(t_m)+\varepsilon_i(t_m),\qquad
\varepsilon_i \sim \mathrm{OU}(0,\alpha=3,\sigma=0.7),
}

i.e. an Ornstein–Uhlenbeck process discretised on the same grid.  Noise is scaled so that its empirical standard
deviation equals \eqn{10\%} of the signal standard deviation.
}
\value{
A named \code{list}:

\item{y}{\eqn{n \times j} matrix of noisy responses \eqn{Y_i(t_m)}.}
\item{yt}{\eqn{n \times j} matrix of true signals \eqn{\eta_i(t_m)}.}
\item{x}{\code{list} of length \code{P}; each element is an
          \eqn{n \times j} matrix of functional predictors
          \eqn{X_i^{(p)}(s_m)}.}
\item{x.scl}{\eqn{n \times d_z} numeric matrix of scalar predictors
             \eqn{\mathbf Z_i}.}
\item{meta}{List containing grids \code{sx}, \code{sy}, true beta surfaces
            (\code{beta}), and the \code{model} flag.}
}
\references{
Kokoszka, P. and Reimherr, M. (2017). \emph{Introduction to Functional Data Analysis}. Chapman and Hall/CRC.
}
\author{Ufuk Beyaztas, Gizel Bakicierler Sezer, and Han Lin Shang}
\note{
Requires the suggested package \pkg{goffda} for OU noise generation.
}
\seealso{\code{\link{fonf_fit}}, \code{\link[goffda]{r_ou}}}
\examples{
## Not run:
# --------------------------------------------------------------
# Simulate a nonlinear training set and inspect its structure
# --------------------------------------------------------------
# n <- 100                      # sample size
# simdata <- dgp_mixed(n, 101, model = "nonlinear")

# y    <- simdata$y             # noisy response curves
# yt   <- simdata$yt            # true (noise-free) curves
# x    <- simdata$x             # list of functional predictors
# xscl <- simdata$x.scl         # scalar predictors
## End(Not run)
}
