flatten1 <- function(x) {
  if (is.list(x) && length(x) == 1)               x <- x[[1]]
  if (is.list(x) && all(vapply(x, is.atomic, TRUE))) x <- unlist(x)
  x
}
