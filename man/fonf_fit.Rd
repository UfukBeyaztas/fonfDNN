\name{fonf_fit}
\alias{fonf_fit}
\title{Fit a Hybrid Deep Tensor Network for Function-on-Function Regression with Mixed Predictors}
\description{
Trains the hybrid deep tensor network (HDTN) of \emph{Beyaztas and Bakicierler Sezer (2025)} to predict a \emph{functional response} from multiple functional and scalar covariates.
The model combines a first-layer tensor-product B-spline representation (capturing linear functional effects) with fully-connected dense layers (capturing higher-order nonlinear interactions) and supplies finite-sample, distribution-free prediction bands via conformal inference.
}
\usage{
fonf_fit(resp,
         func_cov,
         scalar_cov            = NULL,
         nbasis_y              = NULL,
         nbasis_x              = NULL,
         hidden_layers         = 2,
         neurons_per_layer     = c(32, 32),
         activations_in_layers = c("relu", "linear"),
         epochs                = 100,
         batch_size            = 32,
         val_split             = 0.1,
         learning_rate         = 1e-3,
         patience_param        = 15,
         dropout_rate          = 0.1,
         l2_lambda             = 1e-4,
         cal_prop              = 0.2,
         alpha                 = 0.2,
         verbose               = 1)
}
\arguments{
  \item{resp}{\eqn{n \times M} numeric matrix; row \eqn{i} stores the functional response
              \eqn{Y_i(t_m)} evaluated on a common grid \eqn{t_1,\dots,t_M\subset\mathcal I_y}.}
  \item{func_cov}{List of length \eqn{P}.  Element \eqn{p} is an \eqn{n \times G_p} matrix that
                  holds the functional predictor \eqn{X_i^{(p)}(s_{pj})} on its own grid
                  \eqn{s_{p1},\dots,s_{pG_p}\subset\mathcal I_{x_p}}.}
  \item{scalar_cov}{Optional \eqn{n \times d_z} numeric matrix of scalar covariates
                    \eqn{\mathbf Z_i\in\mathbb R^{d_z}}.}
  \item{nbasis_y}{Number of B-spline basis functions for the response domain
                  (\eqn{K_y}); chosen automatically when \code{NULL}.}
  \item{nbasis_x}{Integer vector of length \eqn{P}; element \eqn{p} gives the number of
                  input-domain basis functions \eqn{K_{x}^{(p)}}.
                  Automatically selected when \code{NULL}.}
  \item{hidden_layers}{Number \eqn{R} of fully-connected hidden layers.}
  \item{neurons_per_layer}{Vector of length \code{hidden_layers} giving the width
                           (\eqn{D_r}) of each dense layer.}
  \item{activations_in_layers}{Character vector of length \code{hidden_layers}
                               with Keras activation names ("relu", "tanh", etc.).}
  \item{epochs}{Maximum training epochs.}
  \item{batch_size}{Mini-batch size for stochastic optimisation.}
  \item{val_split}{Proportion of the \emph{training rows} (not subjects) held out for
                  on-line validation during training.}
  \item{learning_rate}{Initial learning rate for the Adam optimiser
                       (with cosine decay scheduler).}
  \item{patience_param}{Early-stopping patience; training stops when validation loss
                        fails to improve for this many epochs.}
  \item{dropout_rate}{Dropout probability applied after every dense hidden layer.}
  \item{l2_lambda}{\eqn{\ell_2} (ridge) penalty applied to dense-layer weights.}
  \item{cal_prop}{Proportion of subjects set aside for the conformal
                  \emph{calibration} set.}
  \item{alpha}{Mis-coverage level for conformal prediction bands
               (e.g. \code{0.2} yields \eqn{80\%} bands).}
  \item{verbose}{Passed to \code{keras}; larger values give more console output.}
}
\details{
Let \eqn{Y_i(t)\in L^2(\mathcal I_y)} be the response curve for subject \eqn{i},
\eqn{X_i^{(p)}(s)\in L^2(\mathcal I_{x_p})}, \eqn{p \in \{1,\dots,P\}}, the functional
predictors, and \eqn{\mathbf Z_i\in\mathbb R^{d_z}} scalar predictors.
The HDTN targets the nonlinear FoFR model

\deqn{
Y_i(t)\;=\;g\!\left\{\beta_0(t)
            \;+\;\sum_{p=1}^P\langle
                 X_i^{(p)},\beta_p(\cdot,t)\rangle_{L^2}
            \;+\;\mathbf Z_i^\top\theta(t)\right\}
            \;+\;\varepsilon_i(t),\quad t\in\mathcal I_y,
}
with identity link \eqn{g(u)=u} in the present implementation.

\strong{Tensor-product layer}.  Each bivariate coefficient surface is expanded
\deqn{\beta_p(s,t)=\sum_{k=1}^{K_{x}^{(p)}}\sum_{\ell=1}^{K_y}
                   w^{(p)}_{k\ell}\,\phi_k^{(p)}(s)\psi_\ell(t),}
yielding first-layer weights \eqn{w^{(p)}_{k\ell}} to be learned.
Subject-specific functional features are
\eqn{\tilde\varphi_{ik}^{(p)}=\langle X_i^{(p)},\phi_k^{(p)}\rangle_{L^2}}
and
\eqn{u_{i\ell}^{(p)}=\sum_k\tilde\varphi_{ik}^{(p)}\,w^{(p)}_{k\ell}}.

\strong{Dense layers}.  The concatenated feature vector
\eqn{\mathbf h_i^{(0)}=\bigl(u_{i\cdot}^{(1)\top},\dots,u_{i\cdot}^{(P)\top},
\mathbf Z_i^\top\bigr)^\top}
is propagated through \eqn{R} fully-connected layers
\eqn{\mathbf h_i^{(r)} = \sigma_r\!\bigl(W^{(r)}\mathbf h_i^{(r-1)}+b^{(r)}\bigr)}
with dropout and ridge penalty \eqn{\lambda\|W^{(r)}\|_F^2/2}.
The final linear layer outputs \eqn{\hat\eta_i(t_m)}, giving
\eqn{\hat Y_i(t_m)=\hat\eta_i(t_m)} for identity link.

\strong{Loss and optimisation}.
Training minimises mean integrated squared error
plus the ridge penalty,
\eqn{
\mathcal L =
\frac1{nM}\sum_{i=1}^n\sum_{m=1}^{M}
  \bigl\{Y_i(t_m)-\hat Y_i(t_m)\bigr\}^2
      +\frac{\lambda}{2}\sum_{r=1}^R\|W^{(r)}\|_F^2,
}
via Adam with cosine-decay learning rate.

\strong{Conformal prediction}.
A calibration subset \eqn{C} (size \code{cal_prop * n} subjects) yields residuals
\eqn{e_{jm}=|Y_j(t_m)-\hat Y_j(t_m)|}.
The empirical \eqn{1-\alpha} quantile
\eqn{q_{1-\alpha}} of \code{length(C)*M} pooled residuals provides a
\emph{constant-width} \eqn{(1-\alpha)} band
\eqn{\bigl[\hat Y_i(t_m)-q_{1-\alpha},\; \hat Y_i(t_m)+q_{1-\alpha}\bigr]} for
every new subject \eqn{i} and grid point \eqn{t_m}.  Finite-sample marginal
coverage is guaranteed (Lei, G'Sell, \emph{et al.}, 2018).
}
\value{
An object of class \code{"fonf_dl"} to be consumed by \code{\link{fonf_predict}}:

\item{model}{Trained Keras model.}
\item{center, scale}{Vectors used to standardise the design matrix.}
\item{py}{Number of response grid points (\eqn{M}).}
\item{nbasis_y, nbasis_x}{Basis dimensions actually used.}
\item{q_hat}{Half-width \eqn{q_{1-\alpha}} of the conformal prediction band.}
\item{alpha}{User-supplied mis-coverage level.}
\item{history}{\code{keras_training_history} object returned by \code{fit()}.}
}
\references{
Lei, J., G'Sell, M., Rinaldo, A., Tibshirani, R. and Wasserman, L. (2018).
\emph{Distribution-Free Predictive Inference for Regression}.
\emph{Journal of the American Statistical Association}, 113(523), 1094-1111.
}
\author{Ufuk Beyaztas, Gizel Bakicierler Sezer, and Han Lin Shang}
\note{Requires TensorFlow/Keras (tested with TensorFlow >= 2.16).}
\seealso{\code{\link{fonf_predict}}, \code{\link[keras]{keras_model_sequential}}}
\examples{
## Not run:
# -------------------------------------------------------------
# 1. Simulate training data
# -------------------------------------------------------------
# n <- 100
# simdata <- dgp_mixed(n, 101, model = "nonlinear")

# y    <- simdata$y
# yt   <- simdata$yt          # (true curves, if needed)
# x    <- simdata$x           # list of functional predictors
# xscl <- simdata$x.scl       # scalar predictors

# -------------------------------------------------------------
# 2. Fit the hybrid deep tensor network
# -------------------------------------------------------------
# nfof_model <- fonf_fit(resp       = y,
#                        func_cov   = x,
#                        scalar_cov = xscl)
## End(Not run)
}
