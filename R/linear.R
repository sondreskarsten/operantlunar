#' Linear semi-gradient SARSA agent (tile features)
#'
#' Operates on raw observations, encoding them with a tile coder. Bootstraps
#' with an action sampled from the epsilon-greedy policy.
#'
#' @param coder A tile coder from [tile_coder()].
#' @param n_actions Number of actions.
#' @param alpha Step size (divided across tilings internally).
#' @param gamma Discount factor.
#' @param eps_start,eps_end Exploration schedule endpoints.
#' @param eps_decay_steps Steps over which to decay; derived from `horizon` if NULL.
#' @param horizon Expected number of steps.
#' @return A list with `select`, `update`, `greedy`, `state`.
#' @export
#' @examples
#' a <- linear_sarsa_agent(tile_coder(c(-1, -1), c(1, 1)))
#' names(a)
linear_sarsa_agent <- function(coder, n_actions = 2L, alpha = 0.1, gamma = 0.99, eps_start = 1, eps_end = 0.05, eps_decay_steps = NULL, horizon = 150000L) {
  if (is.null(eps_decay_steps)) eps_decay_steps <- max(1L, as.integer(horizon %/% 2))
  st <- new.env(parent = emptyenv())
  st$step <- 0
  st$W <- matrix(0, coder$n_features, n_actions)
  epsilon <- function() {
    frac <- min(1, st$step / eps_decay_steps)
    eps_start + (eps_end - eps_start) * frac
  }
  qvec <- function(idx) colSums(st$W[idx, , drop = FALSE])
  select <- function(obs) {
    st$step <- st$step + 1
    if (stats::runif(1) < epsilon()) return(sample.int(n_actions, 1))
    which.max(qvec(coder$encode(obs)))
  }
  update <- function(obs, a, r, obs2, done) {
    idx <- coder$encode(obs)
    q_sa <- sum(st$W[idx, a])
    if (isTRUE(done)) {
      target <- r
    } else {
      qv2 <- qvec(coder$encode(obs2))
      ap <- if (stats::runif(1) < epsilon()) sample.int(n_actions, 1) else which.max(qv2)
      target <- r + gamma * qv2[ap]
    }
    st$W[idx, a] <- st$W[idx, a] + (alpha / coder$n_tilings) * (target - q_sa)
  }
  greedy <- function(obs) which.max(qvec(coder$encode(obs)))
  list(select = select, update = update, greedy = greedy, state = st)
}

#' Linear melioration agent (tile features)
#'
#' Feature-based gradient bandit with a running-reward baseline and no
#' bootstrapping. Myopic by construction.
#'
#' @param coder A tile coder from [tile_coder()].
#' @param n_actions Number of actions.
#' @param alpha Step size.
#' @param beta Inverse temperature.
#' @return A list with `select`, `update`, `greedy`, `state`.
#' @export
#' @examples
#' a <- linear_melioration_agent(tile_coder(c(-1, -1), c(1, 1)))
#' names(a)
linear_melioration_agent <- function(coder, n_actions = 2L, alpha = 0.1, beta = 1) {
  st <- new.env(parent = emptyenv())
  st$H <- matrix(0, coder$n_features, n_actions)
  st$rbar <- 0
  st$n <- 0
  prefs <- function(idx) colSums(st$H[idx, , drop = FALSE])
  select <- function(obs) {
    p <- softmax(prefs(coder$encode(obs)), beta)
    sample.int(n_actions, 1, prob = p)
  }
  update <- function(obs, a, r, obs2, done) {
    st$n <- st$n + 1
    st$rbar <- st$rbar + (r - st$rbar) / st$n
    idx <- coder$encode(obs)
    p <- softmax(prefs(idx), beta)
    one <- numeric(n_actions)
    one[a] <- 1
    st$H[idx, ] <- st$H[idx, ] + alpha * (r - st$rbar) * matrix(one - p, length(idx), n_actions, byrow = TRUE)
  }
  greedy <- function(obs) which.max(prefs(coder$encode(obs)))
  list(select = select, update = update, greedy = greedy, state = st)
}

#' Run one episode with a linear agent
#'
#' @param env An environment object.
#' @param agent A linear agent.
#' @param max_steps Step cap.
#' @param train Whether to update weights.
#' @param seed Reset seed.
#' @param policy "learn", "greedy", or "select".
#' @return The episode return.
#' @export
run_episode_linear <- function(env, agent, max_steps = 500L, train = TRUE, seed = NULL, policy = c("learn", "greedy", "select")) {
  policy <- match.arg(policy)
  obs <- env$reset(seed = seed)$obs
  total <- 0
  for (i in seq_len(max_steps)) {
    a <- if (policy == "greedy") agent$greedy(obs) else agent$select(obs)
    o <- env$step(a)
    if (train) agent$update(obs, a, o$reward, o$obs, isTRUE(o$terminated))
    total <- total + o$reward
    obs <- o$obs
    if (isTRUE(o$terminated) || isTRUE(o$truncated)) break
  }
  total
}

#' Train a linear agent over episodes
#'
#' @param env An environment object.
#' @param agent A linear agent.
#' @param n_episodes Number of episodes.
#' @param max_steps Step cap per episode.
#' @param seed Seed.
#' @return A numeric vector of episode returns.
#' @export
run_training_linear <- function(env, agent, n_episodes = 300L, max_steps = 500L, seed = 0L) {
  returns <- numeric(n_episodes)
  for (ep in seq_len(n_episodes)) {
    set.seed(seed + ep)
    returns[ep] <- run_episode_linear(env, agent, max_steps = max_steps, train = TRUE, seed = seed + ep, policy = "learn")
  }
  returns
}

#' Evaluate a linear agent's policy
#'
#' @param env An environment object.
#' @param agent A linear agent.
#' @param policy "greedy" or "select".
#' @param n_episodes Number of episodes.
#' @param max_steps Step cap per episode.
#' @param seed Seed.
#' @return A numeric vector of episode returns.
#' @export
evaluate_policy_linear <- function(env, agent, policy = c("greedy", "select"), n_episodes = 20L, max_steps = 500L, seed = 10000L) {
  policy <- match.arg(policy)
  rs <- numeric(n_episodes)
  for (ep in seq_len(n_episodes)) {
    set.seed(seed + ep)
    rs[ep] <- run_episode_linear(env, agent, max_steps = max_steps, train = FALSE, seed = seed + ep, policy = policy)
  }
  rs
}

#' Differentiate rules under linear function approximation
#'
#' Trains linear SARSA (bootstrapping) and linear melioration (myopic) on a
#' Gymnasium environment with shared tile features. This is the function-
#' approximation analogue of the tabular differentiation, and the intended way
#' to make the LunarLander comparison conclusive rather than a binning artifact.
#'
#' @param id Gymnasium environment id.
#' @param n_train,n_eval Episode counts.
#' @param max_steps Step cap per episode.
#' @param n_tilings,bins,table_size Tile-coder configuration.
#' @param seed Seed.
#' @param make_kwargs List passed to `gymnasium.make`.
#' @return A list with the env id, a summary tibble, and learning curves.
#' @export
#' @examples
#' \dontrun{
#' lunar_setup("/usr/bin/python3")
#' differentiate_fa("CartPole-v1", n_train = 200)
#' }
differentiate_fa <- function(id = "CartPole-v1", n_train = 300L, n_eval = 20L, max_steps = 500L, n_tilings = 8L, bins = 8L, table_size = 8192L, seed = 0L, make_kwargs = list()) {
  b <- gym_bounds(id)
  coder <- tile_coder(b$low, b$high, n_tilings = n_tilings, bins = bins, table_size = table_size)
  build <- function() do.call(make_gym, c(list(id = id), make_kwargs))
  e1 <- build()
  na <- e1$n_actions
  q <- linear_sarsa_agent(coder, n_actions = na, horizon = as.integer(n_train * max_steps))
  curve_q <- run_training_linear(e1, q, n_episodes = n_train, max_steps = max_steps, seed = seed)
  eval_q <- evaluate_policy_linear(build(), q, policy = "greedy", n_episodes = n_eval, max_steps = max_steps, seed = seed + 50000L)
  e2 <- build()
  mel <- linear_melioration_agent(coder, n_actions = na)
  curve_m <- run_training_linear(e2, mel, n_episodes = n_train, max_steps = max_steps, seed = seed)
  eval_m <- evaluate_policy_linear(build(), mel, policy = "select", n_episodes = n_eval, max_steps = max_steps, seed = seed + 50000L)
  tail_n <- max(1L, n_train %/% 5L)
  list(
    id = id,
    summary = tibble::tibble(
      rule = c("linear_sarsa", "linear_melioration"),
      eval_return = c(mean(eval_q), mean(eval_m)),
      train_return_tail = c(mean(utils::tail(curve_q, tail_n)), mean(utils::tail(curve_m, tail_n)))
    ),
    curves = list(linear_sarsa = curve_q, linear_melioration = curve_m)
  )
}
