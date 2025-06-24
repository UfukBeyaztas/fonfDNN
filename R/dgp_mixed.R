dgp_mixed <- function(n,
                      j,
                      model   = c("linear", "nonlinear"),
                      n_func  = 5L,
                      n_scl   = 3L,
                      seed    = NULL) {

  model <- match.arg(model)
  if(!is.null(seed)) set.seed(seed)

  sx <- seq(0, 1, length.out = j)
  sy <- seq(0, 1, length.out = j)

  build_fX <- function(k) {
    ksi <- if(k <= 3)
      matrix(rnorm(n,  4, sd = 1 / k), n, 1)
    else
      matrix(rnorm(n,  0, sd = 4 / k^4), n, 1)

    phi <- if(k <= 3)
      sin((k+1) * pi * sx)
    else
      cos((k-2) * pi * sx)

    ksi %*% t(phi)
  }

  fX <- lapply(seq_len(n_func), build_fX)

  fBeta <- list(
    function(s, t)  exp(-2*(s-0.5)^2) * sin(6*pi*t),
    function(s, t)  cos(6*pi*s) * exp(-2*(t-0.5)^2),
    function(s, t)  sin(5*pi*s) * cos(5*pi*t),
    function(s, t)  4 * s * t * exp(-2*(s^2 + t^2)),
    function(s, t)  5 * sqrt(s+0.1) * log(t+1)
  )
  vBeta <- lapply(fBeta, function(f) outer(sx, sy, f))

  strong_idx <- 1:3
  fY_signal <- Reduce("+", lapply(strong_idx, function(k) {
    fX[[k]] %*% vBeta[[k]] / j
  }))

  bt <- list(
    sin(4 * pi * sy),
    cos(5 * pi * sy),
    2 * sin(3*pi*sy) * exp(-sy)
  )

  x_scl <- replicate(n_scl, rnorm(n, 2, 1), simplify = "matrix")
  scalar_signal <- Reduce("+", Map(function(z, b) z %*% t(b),
                                   as.data.frame(x_scl), bt))

  base_signal <- fY_signal + scalar_signal

  if(model == "nonlinear") {
    nl_surf1 <- outer(sx, sy, function(s,t) 12 * exp(-15*((s-0.4)^2 + (t-0.6)^2)))
    term1 <- (fX[[1]] * fX[[2]]) %*% nl_surf1 / j

    proj_X3 <- rowMeans(fX[[3]] %*% vBeta[[3]] / j)  # Scalar per subject
    b2t <- 8 * sin(6*pi*sy) * cos(2*pi*sy)
    term2 <- outer(sin(2*pi*proj_X3), b2t)

    nl_surf3 <- outer(sx, sy, function(s,t) 10 * s * t * exp(-3*s*t))
    term3 <- (fX[[4]] * x_scl[,1]) %*% nl_surf3 / j

    b4t <- 7 * exp(-sy) * cos(4*pi*sy)
    term4 <- outer(x_scl[,2]^2 * x_scl[,3], b4t)

    b5t <- 6 * sy * sin(3*pi*sy)
    term5 <- outer(atan(rowMeans(fX[[5]]) * x_scl[,1]), b5t)

    nl_sum <- term1 + term2 + term3 + term4 + term5

    base_norm <- sqrt(mean(base_signal^2))
    nl_norm <- sqrt(mean(nl_sum^2))
    nl_sum <- nl_sum * (2.0 * base_norm / nl_norm)

    fY_true <- base_signal + nl_sum
  } else {
    fY_true <- base_signal
  }

  if(!requireNamespace("goffda", quietly = TRUE))
    stop("Package 'goffda' is required for OU noise-generation.")

  err <- goffda::r_ou(n = n, t = sy, mu = 0, alpha = 3, sigma = 0.7,
                      x0 = rnorm(n, 0, 0.3))$data

  signal_sd <- sd(as.vector(fY_true))
  noise_sd <- sd(as.vector(err))
  err <- err * (0.1 * signal_sd / noise_sd)

  fY_obs <- fY_true + err

  list(
    y       = fY_obs,
    yt      = fY_true,
    x       = fX,
    x.scl   = x_scl,
    meta    = list(sx = sx, sy = sy, beta = vBeta, model = model)
  )
}
