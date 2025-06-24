fonf_predict <- function(object,
                         func_cov_new,
                         scalar_cov_new = NULL,
                         interval = c("none", "conformal")) {

  interval <- match.arg(interval)
  if (!inherits(object, "fonf_dl")) stop("object must be of class 'fonf_dl'")
  py <- object$py

  dm_new <- design_matrix_build(X_func   = func_cov_new,
                                Z_scalar = scalar_cov_new,
                                nbasis_y = object$nbasis_y,
                                nbasis_x = object$nbasis_x,
                                py       = object$py)
  X_new <- dm_new$X

  X_scaled <- scale(X_new, center = object$center, scale = object$scale)

  # --- Predict ----------------------------------------------------------------
  y_pred_vec <- as.numeric(object$model %>% predict(X_scaled))

  n_new <- length(y_pred_vec) / py
  if (n_new %% 1 != 0) stop("Prediction length not divisible by py : dimension mismatch")

  y_pred_mat <- t(matrix(y_pred_vec, nrow = py, ncol = n_new))
  colnames(y_pred_mat) <- paste0("t", seq_len(py))

  if (interval == "none") return(y_pred_mat)

  q <- object$q_hat
  list(mean = y_pred_mat,
       lower = y_pred_mat - q,
       upper = y_pred_mat + q)
}
