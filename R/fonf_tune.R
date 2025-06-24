fonf_tune <- function(grid,
                      resp, func_cov, scalar_cov = NULL,
                      nfolds = 5) {

  if (!is.data.frame(grid) || nrow(grid) == 0)
    stop("grid must be a non-empty data frame")
  K <- length(func_cov)

  cv_vec <- numeric(nrow(grid))
  for (g in seq_len(nrow(grid))) {

    par <- lapply(grid[g, , drop = FALSE], flatten1)

    if (!is.null(par$hidden_layers)) {
      h <- par$hidden_layers
      par$neurons_per_layer     <- rep(flatten1(par$neurons_per_layer),     h)
      par$activations_in_layers <- rep(flatten1(par$activations_in_layers), h)
    }

    cv_vec[g] <- fonf_cv(resp, func_cov, scalar_cov, par, nfolds)
    message("combination ", g, "/", nrow(grid),
            "  CV-MSE = ", format(cv_vec[g], digits = 6))
  }

  best_row  <- which.min(cv_vec)
  best_pars <- lapply(grid[best_row, , drop = FALSE], flatten1)
  best_pars <- sanitize_basis(best_pars, K)

  if (!is.null(best_pars$hidden_layers)) {
    h <- best_pars$hidden_layers
    best_pars$neurons_per_layer     <- rep(flatten1(best_pars$neurons_per_layer),     h)
    best_pars$activations_in_layers <- rep(flatten1(best_pars$activations_in_layers), h)
  }

  best_model <- do.call(fonf_fit,
                        c(list(resp       = resp,
                               func_cov   = func_cov,
                               scalar_cov = scalar_cov,
                               verbose    = TRUE),
                          best_pars))

  list(results     = data.frame(CV_MSE = cv_vec, grid, row.names = NULL),
       best_params = best_pars,
       best_model  = best_model)
}
