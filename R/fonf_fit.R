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
                     verbose               = 1) {

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

  subj_id <- rep(seq_len(n), each = py)
  cal_subj  <- sample(seq_len(n), size = floor(cal_prop * n))
  cal_rows  <- which(subj_id %in% cal_subj)
  train_rows<- setdiff(seq_len(length(y_vec)), cal_rows)

  X_scaled <- scale(X[train_rows, ])
  center <- attr(X_scaled, "scaled:center");
  scale_ <- attr(X_scaled, "scaled:scale")
  X_cal_scaled   <- scale(X[cal_rows, ], center = center, scale = scale_)

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
    x = X_scaled,
    y = y_vec[train_rows],
    epochs = epochs,
    batch_size = batch_size,
    validation_split = val_split,
    callbacks = list(cb_es, cb_lr),
    verbose = verbose
  )

  cal_pred <- as.numeric(model %>% predict(X_cal_scaled, verbose = verbose))
  abs_res  <- abs(y_vec[cal_rows] - cal_pred)
  q_hat    <- as.numeric(quantile(abs_res, probs = 1 - alpha, type = 8))

  structure(list(model       = model,
                 center      = center,
                 scale       = scale_,
                 py          = dm$py,
                 nbasis_y    = nbasis_y,
                 nbasis_x    = nbasis_x,
                 q_hat       = q_hat,
                 alpha       = alpha,
                 history     = history),
            class = "fonf_dl")
}
