#' Create a state-action value table
#'
#' The table is an environment mapping character state keys to numeric vectors
#' of length `n_actions` (interpreted as Q-values or preferences depending on
#' the rule).
#'
#' @param n_actions Number of actions (unused at construction; kept for clarity).
#' @return An environment used as a mutable table.
#' @export
#' @examples
#' make_table()
make_table <- function(n_actions = 4L) {
  new.env(parent = emptyenv())
}

#' Get a row from the table, defaulting to zeros
#'
#' @param table A table from [make_table()].
#' @param s Character state key.
#' @param n_actions Number of actions.
#' @return Numeric vector of length `n_actions`.
#' @export
table_get <- function(table, s, n_actions) {
  v <- get0(s, envir = table, inherits = FALSE)
  if (is.null(v)) numeric(n_actions) else v
}

#' Run a single episode
#'
#' @param env An environment object exposing `reset(seed)` and `step(action)`.
#' @param table A table from [make_table()].
#' @param select Action-selection callable.
#' @param update Learning-update callable.
#' @param featurize Observation-to-key function.
#' @param max_steps Maximum steps.
#' @param train Whether to call `update`.
#' @param seed Optional seed.
#' @return A list with `total`, `steps`, and `visited`.
#' @export
run_episode <- function(env, table, select, update, featurize, max_steps = 1000L, train = TRUE, seed = NULL) {
  r0 <- env$reset(seed = seed)
  s <- featurize(r0$obs)
  total <- 0
  steps <- 0L
  visited <- vector("list", max_steps)
  repeat {
    a <- select(table, s)
    out <- env$step(a)
    s2 <- featurize(out$obs)
    if (train) update(table, s, a, out$reward, s2, out$terminated)
    steps <- steps + 1L
    visited[[steps]] <- s
    total <- total + out$reward
    s <- s2
    if (isTRUE(out$terminated) || isTRUE(out$truncated) || steps >= max_steps) break
  }
  list(total = total, steps = steps, visited = unlist(visited[seq_len(steps)]))
}

#' Train an agent for several episodes
#'
#' @inheritParams run_episode
#' @param n_episodes Number of episodes.
#' @return Numeric vector of episode returns.
#' @export
run_training <- function(env, table, select, update, featurize, n_episodes = 500L, max_steps = 1000L, seed = 0L) {
  returns <- numeric(n_episodes)
  for (ep in seq_len(n_episodes)) {
    set.seed(seed + ep)
    res <- run_episode(env, table, select, update, featurize, max_steps = max_steps, train = TRUE, seed = seed + ep)
    returns[ep] <- res$total
  }
  returns
}

#' Evaluate a fixed policy
#'
#' @inheritParams run_episode
#' @param n_episodes Number of evaluation episodes.
#' @return Numeric vector of episode returns.
#' @export
evaluate_policy <- function(env, table, select, featurize, n_episodes = 50L, max_steps = 1000L, seed = 10000L) {
  noop <- function(...) invisible(NULL)
  returns <- numeric(n_episodes)
  for (ep in seq_len(n_episodes)) {
    set.seed(seed + ep)
    res <- run_episode(env, table, select, noop, featurize, max_steps = max_steps, train = FALSE, seed = seed + ep)
    returns[ep] <- res$total
  }
  returns
}
