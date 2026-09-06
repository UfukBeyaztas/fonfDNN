\name{fonf_fnc}
\alias{fonf_fnc}
\title{Extract and Visualise Estimated Coefficient Surfaces}
\description{
Given a fitted \code{\link{fonf_fit}} model, this helper recovers the
bivariate coefficient surfaces
\eqn{\widehat{\beta}_p(s,t)} that links functional predictor
\eqn{X^{(p)}(s)} to the functional response \eqn{Y(t)},
evaluates them on user-supplied grids, and???optionally???renders compact,
printer-friendly 3-D perspective plots via \pkg{plot3D}.
}
\usage{
fonf_fnc(model,
         y_grid      = NULL,
         x_grid      = NULL,
         plot        = TRUE,
         grid_len    = 101,
         view_theta  = 40,
         view_phi    = 2,
         surface_col = "royalblue",
         border_col  = "black",
         shade_fac   = 0.5,
         title_mgp   = c(2.8, 0.8, 0))
}
\arguments{
\item{model}{Object of class \code{"fonf_dl"} returned by
             \code{\link{fonf_fit}}.}
\item{y_grid}{Numeric vector of evaluation points
              \eqn{t_1,\dots,t_{M}} in the interval \eqn{[0,1]}.
              Defaults to \code{seq(0, 1, length.out = grid_len)}.}
\item{x_grid}{List of length \eqn{P}; element \eqn{p} is the grid
              \eqn{s_{k1},\dots,s_{kL_k}} for predictor \eqn{p}.  Defaults to a
              length-\code{grid_len} equi-spaced grid for every predictor.}
\item{plot}{Logical; if \code{TRUE} (default) one 3-D plot is produced for
            each predictor.}
\item{grid_len}{Length of the default equi-spaced grids when \code{y_grid} or
                an element of \code{x_grid} is \code{NULL}.}
\item{view_theta, view_phi}{Viewing angles (in degrees) passed to
                            \code{\link[plot3D]{persp3D}}.}
\item{surface_col, border_col, shade_fac}{Graphical parameters for the
              surfaces.}
\item{title_mgp}{Margin settings for titles (argument passed to
                 \code{par(mgp = ...)} inside each plot).}
}
\details{
Let \eqn{\bm B_y(t)} denote the vector of \eqn{K_y} response-domain
B-spline basis functions and let \eqn{\bm B_x^{(p)}(s)} denote the vector of
\eqn{K_x^{(p)}} predictor-domain basis functions.  Keras stores the first
dense-layer kernel as a \eqn{D\times D_1} matrix, so its columns correspond
to the first-layer hidden units.  The kernel of the immediately following
dense layer has dimension \eqn{D_1\times D_2}, or \eqn{D_1\times 1} when
the first hidden layer is followed directly by the output unit.

For a positively homogeneous first activation, the invariant coefficient
summary is
\deqn{
\bar w_{k\ell}^{(p)} = \frac{1}{D_1} \sum_{j=1}^{D_1} \|\bm A_{\cdot j}\|_2
W_{j,(p,k,\ell)}^{(1)}.
}
For a linear first activation, the same calculation is performed after
imposing the sign convention that the first nonzero entry of each
downstream weight vector is positive.  Other first-layer activations are
rejected because the required rescaling invariance does not hold.

For predictor \eqn{p}, the coefficient vector is folded into a
\eqn{K_x^{(p)}\times K_y} matrix \eqn{\bm C_p} in the same order used by
the tensor-product design matrix.  The reported surface is then
\deqn{
\widehat\beta_p(s,t) = \bm B_x^{(p)}(s)^\top \bm C_p \bm B_y(t).
}
Accordingly, rows of each returned surface matrix correspond to values of
\eqn{s}, and columns correspond to values of \eqn{t}.  The surface is an
invariant summary of the linear structure entering the network at its input;
it is not a decomposition of the fitted network into separately identified
linear and nonlinear components.
}
\value{
Invisibly returns a \code{list} with components:
\item{beta_hat}{
List of length \eqn{P}; element \eqn{p} is a
\code{length(x_grid[[p]])} by \code{length(y_grid)} matrix containing
\eqn{\widehat{\beta}_p(s,t)}.  Rows correspond to predictor-domain
locations \eqn{s}, and columns correspond to response-domain locations
\eqn{t}.
}
\item{coefficients}{
List of length \eqn{P}; element \eqn{p} is the
\eqn{K_x^{(p)}\times K_y} coefficient matrix used to evaluate
\eqn{\widehat{\beta}_p(s,t)}.
}
\item{y_grid}{Evaluation grid for \eqn{t}.}
\item{x_grid}{Evaluation grids for \eqn{s}.}
\item{plots}{List of closure functions; calling
             \code{plots[[p]]()} re-draws the \eqn{p}-th surface.}
}
\author{Ufuk Beyaztas, Gizel Bakicierler Sezer, and Han Lin Shang}
\note{
Requires the suggested packages \pkg{fda}, \pkg{keras}, and \pkg{plot3D}.
An error is thrown if any are missing.
}
\seealso{\code{\link{fonf_fit}}, \code{\link[plot3D]{persp3D}},
         \code{\link[fda]{eval.basis}}}
\examples{
## Not run:
# --------------------------------------------------------------
# Fit a small model and visualise its coefficient surfaces
# --------------------------------------------------------------
# simdata <- dgp_mixed(100, 101, model = "nonlinear")
#
# y <- simdata$y
# x <- simdata$x
# xscl <- simdata$x.scl
#
# mdl <- fonf_fit(resp = y, func_cov = x, scalar_cov = xscl)
#
# Plot the 2-D functional weights
# surf_obj <- fonf_fnc(model = mdl)
## End(Not run)
}
