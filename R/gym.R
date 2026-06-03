#' Discrete-observation featurizer
#'
#' Maps an integer-coded observation to its character key.
#'
#' @return A function mapping an observation to a character key.
#' @export
#' @examples
#' discrete_featurizer()(3)
discrete_featurizer <- function() {
  function(obs) as.character(round(obs[1]))
}

#' Generic Gymnasium environment adapter
#'
#' Wraps any discrete-action Gymnasium environment behind the native
#' `reset`/`step` interface (R 1-based actions to Gymnasium 0-based). Requires
#' [lunar_setup()] (or `RETICULATE_PYTHON`) to be configured.
#'
#' @param id Gymnasium environment id.
#' @param ... Passed to `gymnasium.make`.
#' @return An environment object with `reset`, `step`, `py`, `n_actions`, `id`.
#' @export
#' @examples
#' \dontrun{
#' lunar_setup("/usr/bin/python3")
#' env <- make_gym("CartPole-v1")
#' env$reset(seed = 0)
#' }
make_gym <- function(id = "CartPole-v1", ...) {
  gym <- reticulate::import("gymnasium")
  e <- gym$make(id, ...)
  reset <- function(seed = NULL) {
    r <- if (is.null(seed)) e$reset() else e$reset(seed = as.integer(seed))
    list(obs = as.numeric(r[[1]]))
  }
  step <- function(action) {
    r <- e$step(as.integer(action - 1L))
    list(obs = as.numeric(r[[1]]), reward = as.numeric(r[[2]]), terminated = as.logical(r[[3]]), truncated = as.logical(r[[4]]))
  }
  list(reset = reset, step = step, py = e, n_actions = as.integer(e$action_space$n), id = id)
}

#' Differentiate rules on a tabular Gymnasium environment
#'
#' Trains rules on a discrete-observation environment (e.g. FrozenLake) and
#' reports success rate under the learned policy. Maximizing rules propagate the
#' terminal reward; myopic melioration cannot.
#'
#' @param id Gymnasium environment id.
#' @param rules Registry keys.
#' @param n_train,n_eval Episode counts.
#' @param max_steps Step cap per episode.
#' @param seed Seed.
#' @param make_kwargs List passed to `gymnasium.make`.
#' @return A list with the env id and a tibble of per-rule results.
#' @export
#' @examples
#' \dontrun{
#' lunar_setup("/usr/bin/python3")
#' differentiate_gym("FrozenLake-v1", n_train = 1500, make_kwargs = list(is_slippery = FALSE))
#' }
differentiate_gym <- function(id = "FrozenLake-v1", rules = c("q_learning", "melioration", "model_based"),
                              n_train = 2000L, n_eval = 200L, max_steps = 200L, seed = 0L, make_kwargs = list(is_slippery = TRUE)) {
  build <- function() do.call(make_gym, c(list(id = id), make_kwargs))
  feat <- discrete_featurizer()
  rows <- lapply(rules, function(nm) {
    env <- build()
    n_actions <- env$n_actions
    ag <- make_agent(nm, n_actions = n_actions, horizon = as.integer(n_train * 15L))
    tbl <- make_table(n_actions)
    train <- run_training(env, tbl, ag$select, ag$update, feat, n_episodes = n_train, max_steps = max_steps, seed = seed)
    sel <- if (agent_kind(nm) == "maximizer") ag$greedy else ag$select
    ev <- evaluate_policy(env, tbl, sel, feat, n_episodes = n_eval, max_steps = max_steps, seed = seed + 50000L)
    tibble::tibble(rule = nm, train_success_tail = mean(utils::tail(train, max(1L, n_train %/% 5L)) > 0), eval_success = mean(ev > 0), eval_return = mean(ev))
  })
  list(id = id, rules = dplyr::bind_rows(rows))
}
