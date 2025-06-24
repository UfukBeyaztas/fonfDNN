sanitize_basis <- function(par, K) {
  if (!is.null(par$nbasis_y))
    par$nbasis_y <- as.numeric(flatten1(par$nbasis_y))[1]

  if (!is.null(par$nbasis_x)) {
    par$nbasis_x <- as.numeric(flatten1(par$nbasis_x))
    par$nbasis_x <- rep(par$nbasis_x, length.out = K)
  }
  par
}
