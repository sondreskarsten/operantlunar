#' Configure the Python environment for LunarLander
#'
#' Call once before [make_lunar()]. With `python = NULL` the Gymnasium
#' dependency is declared via [reticulate::py_require()] so it is provisioned
#' automatically (including on Posit Connect / shinyapps.io). Supply a path to
#' reuse an existing interpreter that already has `gymnasium[box2d]`.
#'
#' @param python Optional path to a Python interpreter.
#' @return Invisibly `TRUE`.
#' @export
#' @examples
#' \dontrun{
#' lunar_setup()
#' }
lunar_setup <- function(python = NULL) {
  if (is.null(python)) {
    reticulate::py_require("gymnasium[box2d]")
  } else {
    reticulate::use_python(python, required = TRUE)
  }
  invisible(TRUE)
}

#' LunarLander-v3 environment adapter
#'
#' Wraps the Python Gymnasium environment behind the same `reset`/`step`
#' interface as the native-R environments. Actions are 1-based on the R side and
#' translated to Gymnasium's 0-based discrete actions.
#'
#' @return An environment object with `reset`, `step`, `py`, `n_actions`.
#' @export
#' @examples
#' \dontrun{
#' lunar_setup("/usr/bin/python3")
#' env <- make_lunar()
#' env$reset(seed = 0)
#' env$step(1)
#' }
make_lunar <- function() {
  gym <- reticulate::import("gymnasium")
  e <- gym$make("LunarLander-v3", continuous = FALSE)
  reset <- function(seed = NULL) {
    r <- if (is.null(seed)) e$reset() else e$reset(seed = as.integer(seed))
    list(obs = as.numeric(r[[1]]))
  }
  step <- function(action) {
    r <- e$step(as.integer(action - 1L))
    list(obs = as.numeric(r[[1]]), reward = as.numeric(r[[2]]), terminated = as.logical(r[[3]]), truncated = as.logical(r[[4]]))
  }
  list(reset = reset, step = step, py = e, n_actions = 4L)
}

#' Total-variation policy divergence between two agents
#'
#' @param table_a,table_b Tables.
#' @param dist_a,dist_b Action-distribution callables.
#' @param states Character state keys.
#' @return A list with `mean_tv` and `argmax_agreement`.
#' @export
policy_divergence <- function(table_a, dist_a, table_b, dist_b, states) {
  tv <- numeric(length(states))
  agree <- 0
  for (i in seq_along(states)) {
    da <- dist_a(table_a, states[i])
    db <- dist_b(table_b, states[i])
    tv[i] <- 0.5 * sum(abs(da - db))
    if (which.max(da) == which.max(db)) agree <- agree + 1
  }
  list(mean_tv = mean(tv), argmax_agreement = agree / length(states))
}

#' Collect states from random rollouts
#'
#' @param env An environment object.
#' @param featurize Observation-to-key function.
#' @param n_actions Number of actions.
#' @param n_episodes Number of rollouts.
#' @param max_steps Maximum steps per rollout.
#' @param seed Seed.
#' @return A character vector of unique state keys.
#' @export
collect_states <- function(env, featurize, n_actions = 4L, n_episodes = 20L, max_steps = 1000L, seed = 99999L) {
  rnd <- function(table, s) sample.int(n_actions, 1)
  noop <- function(...) invisible(NULL)
  seen <- character(0)
  for (ep in seq_len(n_episodes)) {
    set.seed(seed + ep)
    res <- run_episode(env, make_table(n_actions), rnd, noop, featurize, max_steps = max_steps, train = FALSE, seed = seed + ep)
    seen <- union(seen, res$visited)
  }
  seen
}

#' Differentiate maximizing TD from melioration on LunarLander
#'
#' Trains both rules on LunarLander-v3 and reports evaluation return and policy
#' divergence. Requires [lunar_setup()] first.
#'
#' @param n_train,n_eval Episode counts.
#' @param n_bins Bins for the featurizer.
#' @param alpha_td,gamma,alpha_mel,beta_mel Hyperparameters.
#' @param seed Seed.
#' @return A list of metrics and training-return vectors.
#' @export
#' @examples
#' \dontrun{
#' lunar_setup("/usr/bin/python3")
#' differentiate(n_train = 100, n_eval = 20)
#' }
differentiate <- function(n_train = 300L, n_eval = 50L, n_bins = 7L, alpha_td = 0.1, gamma = 0.99, alpha_mel = 0.05, beta_mel = 1, seed = 0L) {
  env <- make_lunar()
  feat <- lunar_featurizer(n_bins = n_bins)
  a <- td_agent(alpha = alpha_td, gamma = gamma, n_actions = 4L)
  b <- melioration_agent(alpha = alpha_mel, beta = beta_mel, n_actions = 4L)
  table_a <- make_table(4L)
  table_b <- make_table(4L)
  train_a <- run_training(env, table_a, a$select, a$update, feat, n_episodes = n_train, seed = seed)
  train_b <- run_training(env, table_b, b$select, b$update, feat, n_episodes = n_train, seed = seed)
  eval_a <- evaluate_policy(env, table_a, a$greedy, feat, n_episodes = n_eval, seed = seed + 50000L)
  eval_b <- evaluate_policy(env, table_b, b$select, feat, n_episodes = n_eval, seed = seed + 50000L)
  states <- collect_states(make_lunar(), feat)
  div <- policy_divergence(table_a, a$action_dist, table_b, b$action_dist, states)
  list(
    td_eval_mean = mean(eval_a),
    td_eval_sd = stats::sd(eval_a),
    melioration_eval_mean = mean(eval_b),
    melioration_eval_sd = stats::sd(eval_b),
    td_train_last = mean(utils::tail(train_a, 50)),
    melioration_train_last = mean(utils::tail(train_b, 50)),
    policy_divergence = div,
    n_states_compared = length(states),
    train_a = train_a,
    train_b = train_b
  )
}
