fonf_fnc <- function(model,
                     y_grid     = NULL,
                     x_grid     = NULL,
                     agg_fun    = mean,
                     plot       = TRUE,
                     grid_len   = 101,
                     view_theta = 40,
                     view_phi   =   2,
                     surface_col= "royalblue",
                     border_col = "black",
                     shade_fac  = 0.5,
                     title_mgp  = c(2.8, 0.8, 0),
                     ...) {

  if (!inherits(model, "fonf_dl"))
    stop("'model' must be the list returned by fonf_fit()")

  if (!requireNamespace("fda",    quietly = TRUE)) stop("Need package 'fda'")
  if (!requireNamespace("plot3D", quietly = TRUE)) stop("Need package 'plot3D'")
  if (!requireNamespace("keras",  quietly = TRUE)) stop("Need package 'keras'")

  nb_y <- model$nbasis_y
  nb_x <- model$nbasis_x
  K    <- length(nb_x)

  if (is.null(y_grid))
    y_grid <- seq(0, 1, length.out = grid_len)

  if (is.null(x_grid))
    x_grid <- lapply(nb_x, function(m) seq(0, 1, length.out = grid_len))
  if (length(x_grid) != K)
    stop("'x_grid' must be a list of length ", K)

  By_full <- fda::eval.basis(
    y_grid,
    fda::create.bspline.basis(range(y_grid), nb_y))

  Bx_full <- mapply(
    function(g, m)
      fda::eval.basis(
        g,
        fda::create.bspline.basis(range(g), nbasis = m)),
    g = x_grid, m = nb_x, SIMPLIFY = FALSE)

  W1 <- keras::get_weights(model$model)[[1]]
  w  <- apply(W1, 1, agg_fun)

  block_sizes  <- nb_y * nb_x
  block_start  <- cumsum(c(1, block_sizes))[1:K]
  block_end    <- block_start + block_sizes - 1

  beta_hat <- vector("list", K)
  plots    <- vector("list", K)

  for (k in seq_len(K)) {

    Ck <- matrix(w[block_start[k]:block_end[k]], nb_y, nb_x[k], byrow = TRUE)
    surf <- By_full %*% Ck %*% t(Bx_full[[k]])
    beta_hat[[k]] <- surf

    if (plot) {
      plots[[k]] <- local({
        surf_k <- surf
        xs_k   <- x_grid[[k]]
        ys_k   <- y_grid
        kk     <- k
        function() {
          op <- graphics::par(mgp = title_mgp)
          on.exit(graphics::par(op))
          plot3D::persp3D(
            x = xs_k, y = ys_k, z = surf_k,
            col       = surface_col,
            border    = border_col,
            shade     = shade_fac,
            lwd       = 0.5,
            theta     = view_theta,
            phi       = view_phi,
            expand    = 0.5,
            xlab      = "s",
            ylab      = "t",
            zlab      = "",
            ticktype  = "detailed",
            cex.axis  = 0.9,
            main      = paste0("beta_", kk, "(t,s)")
          )
        }
      })
    }
  }

  if (plot) {
    old <- graphics::par(ask = TRUE); on.exit(graphics::par(old), add = TRUE)
    lapply(plots, function(f) f())
  }

  invisible(list(
    beta_hat = beta_hat,
    y_grid   = y_grid,
    x_grid   = x_grid,
    plots    = plots
  ))
}
