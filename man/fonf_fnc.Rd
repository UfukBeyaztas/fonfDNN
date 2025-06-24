\name{fonf_fnc}
\alias{fonf_fnc}
\title{Extract and Visualise Estimated Coefficient Surfaces}
\description{
Given a fitted \code{\link{fonf_fit}} model, this helper recovers the
bivariate coefficient surfaces
\eqn{\widehat{\beta}_p(t,s)} that link functional predictor
\eqn{X^{(p)}(s)} to the functional response \eqn{Y(t)},
evaluates them on user-supplied grids, and—optionally—renders compact,
printer-friendly 3-D perspective plots via \pkg{plot3D}.
}
\usage{
fonf_fnc(model,
         y_grid      = NULL,
         x_grid      = NULL,
         agg_fun     = mean,
         plot        = TRUE,
         grid_len    = 101,
         view_theta  = 40,
         view_phi    = 2,
         surface_col = "royalblue",
         border_col  = "black",
         shade_fac   = 0.5,
         title_mgp   = c(2.8, 0.8, 0),
         ...)
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
\item{agg_fun}{Function used to collapse the first-layer tensor weights into a
               single set of B-spline coefficients.  With the default
               \code{mean}:

               \eqn{\widehat{\beta}_p(t,s)=
               \frac{1}{D_1}\sum_{d=1}^{D_1} w_d^{(p)}
               \;B_y(t)\;B_x^{(p)}(s).}}
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
\item{\dots}{Currently ignored, reserved for future extensions.}
}
\details{
Let \eqn{B_y(t)} be the vector of \eqn{K_y} B-spline basis functions for
\eqn{t} and let \eqn{B_x^{(p)}(s)} be the vector of
\eqn{K_x^{(p)}} basis functions for \eqn{s} in predictor \eqn{p}.
The first layer of the network stores a weight matrix
\eqn{W^{(1)}} whose rows correspond to the spline products
\eqn{B_y(t)\,B_x^{(p)}(s)}.  For each predictor \eqn{p} we:

\enumerate{
  \item Extract the contiguous block of \eqn{K_y K_x^{(p)}} weights.
  \item Fold it into a \eqn{K_y \times K_x^{(p)}} matrix \eqn{C_k}.
  \item Evaluate \eqn{\widehat{\beta}_p(t,s)=B_y(t)^{\top} C_k B_x^{(p)}(s)}
        on the requested grids.
}

If \code{plot = TRUE} every surface is drawn with
\code{\link[plot3D]{persp3D}}; otherwise the numeric matrices are returned
silently.
}
\value{
Invisibly returns a \code{list} with components:
\item{beta_hat}{List of length \eqn{P}; element \eqn{p} is a
                \code{length(y_grid) by length(x_grid[[p]])} matrix
                containing \eqn{\widehat{\beta}_p(t,s)}.}
\item{y_grid}{Evaluation grid for \eqn{t}.}
\item{x_grid}{Evaluation grids for \eqn{s}.}
\item{plots}{List of closure functions; calling
             \code{plots[[p]]()} re-draws the \eqn{p}-th surface.}
}
\author{Ufuk Beyaztas, Gizel Bakicierler Sezer, Deniz Inan}
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
