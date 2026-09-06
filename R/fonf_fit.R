fonf_fit <- function(resp,
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
                     verbose               = 1,
                     block_coords          = NULL) {

  dm <- design_matrix_build(X_func   = func_cov,
                            Z_scalar = scalar_cov,
                            nbasis_y = nbasis_y,
                            nbasis_x = nbasis_x,
                            py       = dim(resp)[2])
  nbasis_y <- dm$nbasis_y
  nbasis_x <- dm$nbasis_x
  X  <- dm$X
  n  <- dm$n
  py <- dm$py

  y_vec <- as.vector(t(resp))


  if (!is.numeric(cal_prop) || length(cal_prop) != 1 ||
      !is.finite(cal_prop) || cal_prop <= 0 || cal_prop >= 1) {
    stop("'cal_prop' must be a finite number strictly between 0 and 1.")
  }

  if (!is.numeric(val_split) || length(val_split) != 1 ||
      !is.finite(val_split) || val_split <= 0 || val_split >= 1) {
    stop("'val_split' must be a finite number strictly between 0 and 1.")
  }

  if (!is.numeric(alpha) || length(alpha) != 1 ||
      !is.finite(alpha) || alpha <= 0 || alpha >= 1) {
    stop("'alpha' must be a finite number strictly between 0 and 1.")
  }

  subj_id <- rep(seq_len(n), each = py)
  n_cal_target <- floor(cal_prop * n)

  if (n_cal_target < 1) {
    stop("'cal_prop' produces an empty calibration set.")
  }

  if (is.null(block_coords)) {
    cal_subj <- sample(
      seq_len(n),
      size = n_cal_target
    )
  } else {

    coords <- as.matrix(block_coords)

    if (!is.numeric(coords) ||
        nrow(coords) != n ||
        ncol(coords) < 1 ||
        any(!is.finite(coords))) {
      stop(
        paste(
          "'block_coords' must be NULL or a finite numeric",
          "n x q matrix with one row for each subject."
        )
      )
    }

    nb <- min(
      n - 1,
      max(2, as.integer(round(1 / cal_prop)))
    )

    if (nrow(unique(coords)) < nb) {
      stop(
        "The number of distinct coordinate vectors is smaller than the requested number of spatial blocks."
      )
    }

    km <- kmeans(
      coords,
      centers = nb,
      nstart = 10
    )

    block_order <- sample(seq_len(nb))
    block_sizes <- tabulate(km$cluster, nbins = nb)
    cumulative_size <- cumsum(block_sizes[block_order])

    number_selected <- which(
      cumulative_size >= n_cal_target
    )[1]

    selected_blocks <- block_order[
      seq_len(number_selected)
    ]

    cal_subj <- which(
      km$cluster %in% selected_blocks
    )
  }

  cal_subj   <- sort(unique(cal_subj))
  train_subj <- setdiff(seq_len(n), cal_subj)

  if (length(train_subj) < 2) {
    stop("At least two non-calibration subjects are required.")
  }

  ## Complete subjects reserved for validation
  n_val_sub <- max(1L, floor(val_split * length(train_subj)))
  n_val_sub <- min(n_val_sub, length(train_subj) - 1)

  val_subj <- tail(train_subj, n_val_sub)
  fit_subj <- setdiff(train_subj, val_subj)

  cal_rows   <- which(subj_id %in% cal_subj)
  train_rows <- which(subj_id %in% train_subj)
  fit_rows   <- which(subj_id %in% fit_subj)
  val_rows   <- which(subj_id %in% val_subj)

  X_scaled <- scale(X[train_rows, , drop = FALSE])
  center <- attr(X_scaled, "scaled:center")
  scale_ <- attr(X_scaled, "scaled:scale")

  X_cal_scaled <- scale(
    X[cal_rows, , drop = FALSE],
    center = center,
    scale = scale_
  )

  fit_idx <- match(fit_rows, train_rows)
  val_idx <- match(val_rows, train_rows)

  model <- keras_model_sequential()
  model %>% layer_dense(units = neurons_per_layer[1],
                        activation = activations_in_layers[1],
                        input_shape = ncol(X_scaled),
                        kernel_regularizer = regularizer_l2(l2_lambda)) %>%
    layer_dropout(rate = dropout_rate)

  if (hidden_layers > 1) {
    for (i in 2:hidden_layers) {
      model %>% layer_dense(units = neurons_per_layer[i],
                            activation = activations_in_layers[i],
                            kernel_regularizer = regularizer_l2(l2_lambda)) %>%
        layer_dropout(rate = dropout_rate)
    }
  }
  model %>% layer_dense(units = 1)

  optimiser <- optimizer_adam(learning_rate = learning_rate)
  model %>% compile(loss = "mse", optimizer = optimiser, metrics = list("mse"))

  cb_es  <- callback_early_stopping(monitor = "val_loss",
                                    patience = patience_param,
                                    restore_best_weights = TRUE)
  cb_lr  <- callback_reduce_lr_on_plateau(monitor = "val_loss", factor = 0.5,
                                          patience = floor(patience_param/2),
                                          verbose = verbose)

  history <- model %>% fit(
    x = X_scaled[fit_idx, , drop = FALSE],
    y = y_vec[fit_rows],
    epochs = epochs,
    batch_size = batch_size,
    validation_data = list(
      X_scaled[val_idx, , drop = FALSE],
      y_vec[val_rows]
    ),
    callbacks = list(cb_es, cb_lr),
    verbose = verbose
  )

  val_pred <- as.numeric(
    model %>% predict(
      X_scaled[val_idx, , drop = FALSE],
      verbose = 0
    )
  )

  val_res <- y_vec[val_rows] - val_pred
  m_val   <- ((val_rows - 1) %% py) + 1

  s_raw <- sqrt(
    as.numeric(
      tapply(
        val_res^2,
        factor(m_val, levels = seq_len(py)),
        mean
      )
    )
  )

  bad_scale <- !is.finite(s_raw)

  if (any(bad_scale)) {
    finite_scale <- s_raw[!bad_scale]

    if (length(finite_scale) == 0) {
      stop("The validation scale could not be estimated.")
    }

    s_raw[bad_scale] <- mean(finite_scale)
  }

  mean_scale <- mean(s_raw)

  if (!is.finite(mean_scale) || mean_scale <= 0) {
    stop(
      paste(
        "The validation residual scale is zero or non-finite;",
        "varying-width and simultaneous bands cannot be constructed."
      )
    )
  }

  By <- dm$eval_y
  scale_coef <- qr.solve(By, s_raw)
  s_smooth <- as.numeric(By %*% scale_coef)

  sigma0  <- 0.05 * mean_scale
  sigma_t <- pmax(s_smooth, sigma0)

  if (any(!is.finite(sigma_t)) || any(sigma_t <= 0)) {
    stop("The estimated scale function must be finite and strictly positive.")
  }

  cal_pred <- as.numeric(
    model %>% predict(X_cal_scaled, verbose = verbose)
  )

  abs_res <- abs(y_vec[cal_rows] - cal_pred)
  m_cal   <- ((cal_rows - 1) %% py) + 1
  sub_cal <- ((cal_rows - 1) %/% py) + 1

  norm_res <- abs_res / sigma_t[m_cal]
  n_cal <- length(cal_subj)

  ord_q <- function(v, k) {
    if (anyNA(v) || any(!is.finite(v))) {
      stop("Conformal scores must be finite and non-missing.")
    }

    k <- as.integer(k)

    if (k < 1) {
      stop("The conformal order-statistic index must be positive.")
    }

    if (k > length(v)) {
      return(Inf)
    }

    sort.int(v, partial = k)[k]
  }

  q_hat <- ord_q(
    abs_res,
    ceiling((1 - alpha) * (n_cal + 1) * py)
  )

  q_sig <- ord_q(
    norm_res,
    ceiling((1 - alpha) * (n_cal + 1) * py)
  )

  S_j <- as.numeric(tapply(norm_res, sub_cal, max))

  if (length(S_j) != n_cal) {
    stop("One simultaneous conformal score is required for each calibration subject.")
  }

  Q_sim <- ord_q(
    S_j,
    ceiling((1 - alpha) * (n_cal + 1))
  )

  structure(
    list(
      model    = model,
      center   = center,
      scale    = scale_,
      py       = dm$py,
      nbasis_y        = nbasis_y,
      nbasis_x        = nbasis_x,
      first_activation = tolower(
        as.character(activations_in_layers[1])
      ),
      sigma_t         = sigma_t,
      q_hat    = q_hat,
      q_sig    = q_sig,
      Q_sim    = Q_sim,
      alpha    = alpha,
      history  = history
    ),
    class = "fonf_dl"
  )
}
