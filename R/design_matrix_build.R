design_matrix_build <- function(X_func,
                                Z_scalar   = NULL,
                                nbasis_y   = NULL,
                                nbasis_x   = NULL,
                                gpy        = NULL,
                                gpx        = NULL,
                                py) {

  K   <- length(X_func)
  n   <- nrow(X_func[[1]])
  if (py < 2) stop("Functional response must have more than 2 grid points.")
  if (is.null(nbasis_y)) nbasis_y <- 15
  if (is.null(nbasis_x)) nbasis_x <- rep(15, K)
  nbasis_x <- rep(nbasis_x, length.out = K)

  if (is.null(gpy)) gpy <- seq(0, 1, length.out = py)
  basis_y  <- create.bspline.basis(range(gpy), nbasis = nbasis_y)
  eval_y   <- eval.basis(gpy, basis_y)

  blocks <- list()

  for (k in seq_len(K)) {

    px_k <- ncol(X_func[[k]])
    if (px_k < 2)
      stop("Predictor ", k, " has zero/one grid points; cannot build basis.")

    gpx_k <- if (is.null(gpx) || is.null(gpx[[k]]))
      seq(0, 1, length.out = px_k) else gpx[[k]]

    basis_xk <- create.bspline.basis(range(gpx_k), nbasis = nbasis_x[k])
    eval_xk  <- eval.basis(gpx_k, basis_xk)
    diff_x   <- gpx_k[2] - gpx_k[1]

    coef_xk  <- X_func[[k]] %*% eval_xk * diff_x
    blocks[[paste0("func", k)]] <- kronecker(coef_xk, eval_y)
  }

  if (!is.null(Z_scalar)) {
    Z_mat <- as.matrix(Z_scalar); q <- ncol(Z_mat)
    for (j in seq_len(q)) {
      blocks[[paste0("scalar", j)]] <-
        kronecker(matrix(Z_mat[, j], n, 1), eval_y)
    }
  }

  X_design <- do.call(cbind, blocks)

  list(X = X_design,
       eval_y = eval_y,
       n = n, py = py,
       nbasis_y = nbasis_y,
       nbasis_x = nbasis_x)
}
