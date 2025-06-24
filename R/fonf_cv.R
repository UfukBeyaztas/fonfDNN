fonf_cv <- function(resp, func_cov, scalar_cov = NULL,
                    par, nfolds = 5) {

  n <- nrow(resp); K <- length(func_cov)
  fold <- sample(rep(seq_len(nfolds), length.out = n))
  mse  <- numeric(nfolds)

  for (k in seq_len(nfolds)) {
    idx_v <- fold == k; idx_t <- !idx_v

    par_s <- sanitize_basis(par, K)

    fit <- do.call(fonf_fit,
                   c(list(resp       = resp[idx_t, , drop = FALSE],
                          func_cov   = lapply(func_cov, `[`, idx_t , , drop = FALSE),
                          scalar_cov = if (!is.null(scalar_cov)) scalar_cov[idx_t , , drop = FALSE],
                          verbose    = 0),
                     par_s))

    pred <- fonf_predict(fit,
                         lapply(func_cov, `[`, idx_v , , drop = FALSE),
                         if (!is.null(scalar_cov)) scalar_cov[idx_v , , drop = FALSE],
                         interval = "none")

    mse[k] <- mean((pred - resp[idx_v, , drop = FALSE])^2)
  }
  mean(mse)
}
