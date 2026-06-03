#' LunarLander observation bounds
#'
#' @format Numeric vectors of length 8.
#' @export
lunar_low <- c(-2.5, -2.5, -10, -10, -6.2831855, -10, 0, 0)

#' @rdname lunar_low
#' @export
lunar_high <- c(2.5, 2.5, 10, 10, 6.2831855, 10, 1, 1)

#' Bin edges for the LunarLander observation
#'
#' @param low,high Numeric bounds (length 8).
#' @param n_bins Number of bins per continuous dimension.
#' @return A list of interior edge vectors.
#' @export
#' @examples
#' make_bin_edges()
make_bin_edges <- function(low = lunar_low, high = lunar_high, n_bins = 7) {
  Map(function(lo, hi) seq(lo, hi, length.out = n_bins + 1)[-c(1, n_bins + 1)], low, high)
}

#' LunarLander state featurizer
#'
#' Bins the 8-dimensional observation into a character state key. Leg-contact
#' dimensions (7, 8) are rounded rather than binned.
#'
#' @param edges Edge list from [make_bin_edges()]; built if `NULL`.
#' @param n_bins Number of bins per continuous dimension.
#' @param binary_dims Indices treated as binary.
#' @return A function mapping an observation vector to a character key.
#' @export
#' @examples
#' f <- lunar_featurizer()
#' f(lunar_low)
#' f(lunar_high)
lunar_featurizer <- function(edges = NULL, n_bins = 7, binary_dims = c(7L, 8L)) {
  if (is.null(edges)) edges <- make_bin_edges(n_bins = n_bins)
  function(obs) {
    key <- integer(length(obs))
    for (i in seq_along(obs)) {
      if (i %in% binary_dims) {
        key[i] <- as.integer(round(obs[i]))
      } else {
        key[i] <- findInterval(obs[i], edges[[i]])
      }
    }
    paste(key, collapse = "_")
  }
}

#' Constant single-state featurizer
#'
#' @param state Character key returned for every observation.
#' @return A function mapping any observation to `state`.
#' @export
#' @examples
#' constant_featurizer()(runif(8))
constant_featurizer <- function(state = "S0") {
  function(obs) state
}

#' Scalar (1-D) featurizer
#'
#' @param n_bins Number of bins.
#' @param lo,hi Range of the scalar.
#' @param dim Index of the scalar within the observation.
#' @return A function mapping an observation to a character key.
#' @export
#' @examples
#' interval_featurizer()(0.5)
interval_featurizer <- function(n_bins = 20, lo = 0, hi = 1, dim = 1L) {
  edges <- seq(lo, hi, length.out = n_bins + 1)[-c(1, n_bins + 1)]
  function(obs) as.character(findInterval(obs[dim], edges))
}
