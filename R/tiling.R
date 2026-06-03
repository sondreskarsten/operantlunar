#' Observation bounds for known environments
#'
#' Effective clipping bounds used to build tile coders. Fails loudly for an
#' unknown id rather than guessing.
#'
#' @param id Gymnasium environment id.
#' @return A list with numeric `low` and `high` vectors.
#' @export
#' @examples
#' gym_bounds("CartPole-v1")
gym_bounds <- function(id = "CartPole-v1") {
  switch(id,
    "CartPole-v1" = list(low = c(-2.4, -3.5, -0.21, -3.5), high = c(2.4, 3.5, 0.21, 3.5)),
    "MountainCar-v0" = list(low = c(-1.2, -0.07), high = c(0.6, 0.07)),
    "Acrobot-v1" = list(low = c(-1, -1, -1, -1, -12.57, -28.27), high = c(1, 1, 1, 1, 12.57, 28.27)),
    "LunarLander-v3" = list(low = lunar_low, high = lunar_high),
    "LunarLander-v2" = list(low = lunar_low, high = lunar_high),
    stop("no observation bounds registered for env id: ", id)
  )
}

#' Hashed tile coder
#'
#' Coarse coding with overlapping offset tilings, hashed into a fixed feature
#' space so memory stays bounded in higher dimensions.
#'
#' @param low,high Observation bounds.
#' @param n_tilings Number of overlapping tilings.
#' @param bins Bins per dimension per tiling.
#' @param table_size Size of the hashed feature space.
#' @return A list with `encode` (observation to active indices), `n_features`, `n_tilings`.
#' @export
#' @examples
#' tc <- tile_coder(c(-1, -1), c(1, 1))
#' tc$encode(c(0, 0))
tile_coder <- function(low, high, n_tilings = 8L, bins = 8L, table_size = 8192L) {
  low <- as.numeric(low)
  high <- as.numeric(high)
  d <- length(low)
  width <- (high - low) / bins
  encode <- function(obs) {
    obs <- pmin(pmax(as.numeric(obs), low), high)
    idx <- integer(n_tilings)
    for (t in seq_len(n_tilings)) {
      off <- ((t - 1) / n_tilings) * width
      coords <- floor((obs - low + off) / width)
      h <- (t * 97) %% table_size
      for (j in seq_len(d)) h <- (h * 31 + coords[j]) %% table_size
      idx[t] <- h + 1L
    }
    idx
  }
  list(encode = encode, n_features = table_size, n_tilings = n_tilings)
}
