fonf_fnc <- function(model,
                     y_grid      = NULL,
                     x_grid      = NULL,
                     plot        = TRUE,
                     grid_len    = 101,
                     view_theta  = 40,
                     view_phi    = 2,
                     surface_col = "royalblue",
                     border_col  = "black",
                     shade_fac   = 0.5,
                     title_mgp   = c(2.8, 0.8, 0)) {

  if (!inherits(model, "fonf_dl")) {
    stop("'model' must be an object returned by fonf_fit().")
  }

  if (!requireNamespace("fda", quietly = TRUE)) {
    stop("Package 'fda' is required.")
  }

  if (plot && !requireNamespace("plot3D", quietly = TRUE)) {
    stop("Package 'plot3D' is required when 'plot = TRUE'.")
  }

  if (!requireNamespace("keras", quietly = TRUE)) {
    stop("Package 'keras' is required.")
  }

  nb_y <- model$nbasis_y
  nb_x <- model$nbasis_x
  n_func <- length(nb_x)

  if (is.null(y_grid)) {
    y_grid <- seq(0, 1, length.out = grid_len)
  }

  y_grid <- as.numeric(y_grid)

  if (length(y_grid) < 2 ||
      any(!is.finite(y_grid)) ||
      any(y_grid < 0 | y_grid > 1) ||
      is.unsorted(y_grid)) {
    stop(
      "'y_grid' must contain at least two ordered, finite points in [0, 1]."
    )
  }

  if (is.null(x_grid)) {
    x_grid <- lapply(
      seq_len(n_func),
      function(k) seq(0, 1, length.out = grid_len)
    )
  }

  if (!is.list(x_grid) || length(x_grid) != n_func) {
    stop("'x_grid' must be a list with one element per functional predictor.")
  }

  x_grid <- lapply(
    x_grid,
    function(g) {
      if (is.null(g)) {
        g <- seq(0, 1, length.out = grid_len)
      }

      g <- as.numeric(g)

      if (length(g) < 2 ||
          any(!is.finite(g)) ||
          any(g < 0 | g > 1) ||
          is.unsorted(g)) {
        stop(
          "Each element of 'x_grid' must contain at least two ordered, finite points in [0, 1]."
        )
      }

      g
    }
  )

  basis_y <- fda::create.bspline.basis(
    rangeval = c(0, 1),
    nbasis = nb_y
  )

  By_full <- fda::eval.basis(y_grid, basis_y)

  Bx_full <- mapply(
    function(g, m) {
      basis_x <- fda::create.bspline.basis(
        rangeval = c(0, 1),
        nbasis = m
      )

      fda::eval.basis(g, basis_x)
    },
    g = x_grid,
    m = nb_x,
    SIMPLIFY = FALSE
  )

  network_weights <- keras::get_weights(model$model)

  if (length(network_weights) < 3) {
    stop("The fitted network does not contain the required dense-layer kernels.")
  }

  W1 <- as.matrix(network_weights[[1]])
  W_next <- as.matrix(network_weights[[3]])

  if (nrow(W_next) != ncol(W1)) {
    stop("The first and second dense-layer kernels have incompatible dimensions.")
  }

  first_activation <- model$first_activation

  if (is.null(first_activation) ||
      length(first_activation) != 1) {
    stop(
      paste(
        "The fitted object does not record its first-layer activation;",
        "refit the model using the revised fonf_fit()."
      )
    )
  }

  first_activation <- tolower(first_activation)
  downstream_norm <- sqrt(rowSums(W_next^2))

  if (first_activation %in% c("relu", "leaky_relu")) {

    downstream_weight <- downstream_norm

  } else if (first_activation == "linear") {

    anchor_sign <- apply(
      W_next,
      1,
      function(z) {
        nonzero <- which(z != 0)

        if (length(nonzero) == 0) {
          return(1)
        }

        sign(z[nonzero[1L]])
      }
    )

    downstream_weight <- downstream_norm * anchor_sign

  } else {

    stop(
      paste0(
        "The coefficient-surface interpretation is not invariant for ",
        "first activation '", first_activation, "'. ",
        "Use a positively homogeneous first activation such as 'relu', ",
        "or use 'linear' with the implemented sign convention."
      )
    )
  }

  W1_weighted <- sweep(
    W1,
    MARGIN = 2,
    STATS = downstream_weight,
    FUN = "*"
  )

  w_bar <- rowMeans(W1_weighted)

  block_sizes <- nb_x * nb_y
  block_start <- c(
    1,
    head(cumsum(block_sizes), -1) + 1
  )
  block_end <- cumsum(block_sizes)

  beta_hat <- vector("list", n_func)
  coef_mat <- vector("list", n_func)
  plots <- vector("list", n_func)

  for (k in seq_len(n_func)) {

    coefficient_vector <- w_bar[
      block_start[k]:block_end[k]
    ]

    Ck <- matrix(
      coefficient_vector,
      nrow = nb_x[k],
      ncol = nb_y,
      byrow = TRUE
    )

    surf <- Bx_full[[k]] %*% Ck %*% t(By_full)

    coef_mat[[k]] <- Ck
    beta_hat[[k]] <- surf

    if (plot) {
      plots[[k]] <- local({
        surface_k <- surf
        s_grid_k <- x_grid[[k]]
        t_grid_k <- y_grid
        predictor_number <- k

        function() {
          old_par <- graphics::par(mgp = title_mgp)
          on.exit(graphics::par(old_par))

          plot3D::persp3D(
            x = s_grid_k,
            y = t_grid_k,
            z = surface_k,
            col = surface_col,
            border = border_col,
            shade = shade_fac,
            lwd = 0.5,
            theta = view_theta,
            phi = view_phi,
            expand = 0.5,
            xlab = "s",
            ylab = "t",
            zlab = "",
            ticktype = "detailed",
            cex.axis = 0.9,
            main = paste0(
              "beta_",
              predictor_number,
              "(s,t)"
            )
          )
        }
      })
    }
  }

  if (plot) {
    old_par <- graphics::par(ask = TRUE)
    on.exit(graphics::par(old_par), add = TRUE)

    invisible(
      lapply(plots, function(plot_function) plot_function())
    )
  }

  invisible(
    list(
      beta_hat = beta_hat,
      coefficients = coef_mat,
      y_grid = y_grid,
      x_grid = x_grid,
      plots = plots
    )
  )
}
