#' SARSA agent (on-policy bootstrap)
#'
#' Bootstraps with an action sampled from the current epsilon-greedy policy.
#'
#' @inheritParams td_agent
#' @return A list of agent callables.
#' @export
#' @examples
#' names(sarsa_agent())
sarsa_agent <- function(alpha = 0.1, gamma = 0.99, eps_start = 1, eps_end = 0.05, eps_decay_steps = 150000, n_actions = 4L) {
  st <- new.env(parent = emptyenv())
  st$step <- 0
  epsilon <- function() {
    frac <- min(1, st$step / eps_decay_steps)
    eps_start + (eps_end - eps_start) * frac
  }
  eps_sample <- function(v, eps) if (stats::runif(1) < eps) sample.int(n_actions, 1) else which.max(v)
  select <- function(table, s) {
    st$step <- st$step + 1
    if (stats::runif(1) < epsilon()) return(sample.int(n_actions, 1))
    which.max(table_get(table, s, n_actions))
  }
  update <- function(table, s, a, r, s2, done) {
    v <- table_get(table, s, n_actions)
    if (isTRUE(done)) {
      target <- r
    } else {
      v2 <- table_get(table, s2, n_actions)
      ap <- eps_sample(v2, epsilon())
      target <- r + gamma * v2[ap]
    }
    v[a] <- v[a] + alpha * (target - v[a])
    assign(s, v, envir = table)
  }
  greedy <- function(table, s) which.max(table_get(table, s, n_actions))
  action_dist <- function(table, s) {
    d <- numeric(n_actions)
    d[which.max(table_get(table, s, n_actions))] <- 1
    d
  }
  list(select = select, update = update, greedy = greedy, action_dist = action_dist, state = st)
}

#' Double Q-learning agent (de-biased maximization)
#'
#' @inheritParams td_agent
#' @return A list of agent callables.
#' @export
#' @examples
#' names(double_q_agent())
double_q_agent <- function(alpha = 0.1, gamma = 0.99, eps_start = 1, eps_end = 0.05, eps_decay_steps = 150000, n_actions = 4L) {
  st <- new.env(parent = emptyenv())
  st$step <- 0
  st$qb <- new.env(parent = emptyenv())
  epsilon <- function() {
    frac <- min(1, st$step / eps_decay_steps)
    eps_start + (eps_end - eps_start) * frac
  }
  getb <- function(s) {
    v <- get0(s, envir = st$qb, inherits = FALSE)
    if (is.null(v)) numeric(n_actions) else v
  }
  select <- function(table, s) {
    st$step <- st$step + 1
    if (stats::runif(1) < epsilon()) return(sample.int(n_actions, 1))
    which.max(table_get(table, s, n_actions) + getb(s))
  }
  update <- function(table, s, a, r, s2, done) {
    if (stats::runif(1) < 0.5) {
      qa <- table_get(table, s, n_actions)
      if (isTRUE(done)) target <- r else target <- r + gamma * getb(s2)[which.max(table_get(table, s2, n_actions))]
      qa[a] <- qa[a] + alpha * (target - qa[a])
      assign(s, qa, envir = table)
    } else {
      qb <- getb(s)
      if (isTRUE(done)) target <- r else target <- r + gamma * table_get(table, s2, n_actions)[which.max(getb(s2))]
      qb[a] <- qb[a] + alpha * (target - qb[a])
      assign(s, qb, envir = st$qb)
    }
  }
  greedy <- function(table, s) which.max(table_get(table, s, n_actions) + getb(s))
  action_dist <- function(table, s) {
    q <- table_get(table, s, n_actions) + getb(s)
    d <- numeric(n_actions)
    d[which.max(q)] <- 1
    d
  }
  list(select = select, update = update, greedy = greedy, action_dist = action_dist, state = st)
}

#' Actor-critic agent (policy gradient with a TD critic)
#'
#' Maximizes via a bootstrapped critic, but selects from an explicit softmax
#' policy like melioration does.
#'
#' @param alpha_theta Policy learning rate.
#' @param alpha_v Critic learning rate.
#' @param gamma Discount factor.
#' @param beta Inverse temperature.
#' @param n_actions Number of actions.
#' @return A list of agent callables.
#' @export
#' @examples
#' names(actor_critic_agent())
actor_critic_agent <- function(alpha_theta = 0.1, alpha_v = 0.1, gamma = 0.99, beta = 1, n_actions = 4L) {
  st <- new.env(parent = emptyenv())
  st$v <- new.env(parent = emptyenv())
  getv <- function(s) {
    x <- get0(s, envir = st$v, inherits = FALSE)
    if (is.null(x)) 0 else x
  }
  select <- function(table, s) {
    p <- softmax(table_get(table, s, n_actions), beta)
    sample.int(n_actions, 1, prob = p)
  }
  update <- function(table, s, a, r, s2, done) {
    v_s <- getv(s)
    v_s2 <- if (isTRUE(done)) 0 else getv(s2)
    delta <- r + gamma * v_s2 - v_s
    assign(s, v_s + alpha_v * delta, envir = st$v)
    th <- table_get(table, s, n_actions)
    p <- softmax(th, beta)
    one <- numeric(n_actions)
    one[a] <- 1
    th <- th + alpha_theta * delta * (one - p)
    assign(s, th, envir = table)
  }
  greedy <- function(table, s) which.max(table_get(table, s, n_actions))
  action_dist <- function(table, s) softmax(table_get(table, s, n_actions), beta)
  list(select = select, update = update, greedy = greedy, action_dist = action_dist, state = st)
}

#' Win-stay-lose-shift agent (operant heuristic)
#'
#' @param n_actions Number of actions.
#' @param p_explore Probability of a random action regardless of history.
#' @return A list of agent callables.
#' @export
#' @examples
#' names(win_stay_lose_shift_agent())
win_stay_lose_shift_agent <- function(n_actions = 2L, p_explore = 0) {
  st <- new.env(parent = emptyenv())
  st$next_a <- NA_integer_
  select <- function(table, s) {
    if (is.na(st$next_a) || stats::runif(1) < p_explore) st$next_a <- sample.int(n_actions, 1)
    st$next_a
  }
  update <- function(table, s, a, r, s2, done) {
    if (r > 0) {
      st$next_a <- a
    } else {
      others <- setdiff(seq_len(n_actions), a)
      st$next_a <- others[sample.int(length(others), 1)]
    }
  }
  greedy <- function(table, s) if (is.na(st$next_a)) 1L else st$next_a
  action_dist <- function(table, s) {
    d <- numeric(n_actions)
    d[if (is.na(st$next_a)) 1L else st$next_a] <- 1
    d
  }
  list(select = select, update = update, greedy = greedy, action_dist = action_dist, state = st)
}

#' Rate-tracking melioration agent (Herrnstein-Vaughan)
#'
#' Tracks an estimated local reinforcement rate per alternative and selects in
#' proportion to it, equalizing local rates. Reproduces matching by a different
#' mechanism than the gradient-bandit [melioration_agent()].
#'
#' @param alpha Learning rate for the local-rate estimate.
#' @param n_actions Number of actions.
#' @param floor Minimum rate to keep selection probabilities positive.
#' @return A list of agent callables.
#' @export
#' @examples
#' names(melioration_rate_agent())
melioration_rate_agent <- function(alpha = 0.05, n_actions = 2L, floor = 1e-3) {
  st <- new.env(parent = emptyenv())
  getr <- function(s) {
    v <- get0(s, envir = st, inherits = FALSE)
    if (is.null(v)) rep(floor, n_actions) else v
  }
  select <- function(table, s) {
    rt <- getr(s)
    sample.int(n_actions, 1, prob = rt / sum(rt))
  }
  update <- function(table, s, a, r, s2, done) {
    rt <- getr(s)
    rt[a] <- rt[a] + alpha * (r - rt[a])
    rt <- pmax(rt, floor)
    assign(s, rt, envir = st)
  }
  greedy <- function(table, s) which.max(getr(s))
  action_dist <- function(table, s) {
    rt <- getr(s)
    rt / sum(rt)
  }
  list(select = select, update = update, greedy = greedy, action_dist = action_dist, state = st)
}

#' Model-based planning agent (goal-directed control)
#'
#' Learns a tabular transition/reward model and acts greedily with respect to a
#' value function refreshed by periodic value iteration. Intended for small
#' discrete environments; the model is exact rather than approximated.
#'
#' @inheritParams td_agent
#' @param replan_every Steps between value-iteration refreshes.
#' @param vi_sweeps Sweeps per refresh.
#' @return A list of agent callables.
#' @export
#' @examples
#' names(model_based_agent())
model_based_agent <- function(gamma = 0.99, eps_start = 1, eps_end = 0.05, eps_decay_steps = 150000, n_actions = 4L, replan_every = 200L, vi_sweeps = 30L) {
  st <- new.env(parent = emptyenv())
  st$step <- 0
  st$N <- new.env(parent = emptyenv())
  st$Rsum <- new.env(parent = emptyenv())
  st$Na <- new.env(parent = emptyenv())
  st$V <- new.env(parent = emptyenv())
  st$states <- character(0)
  epsilon <- function() {
    frac <- min(1, st$step / eps_decay_steps)
    eps_start + (eps_end - eps_start) * frac
  }
  getV <- function(s) {
    x <- get0(s, envir = st$V, inherits = FALSE)
    if (is.null(x)) 0 else x
  }
  qval <- function(s, a) {
    key <- paste0(s, "|", a)
    na <- get0(key, envir = st$Na, inherits = FALSE)
    if (is.null(na) || na == 0) return(0)
    rhat <- get0(key, envir = st$Rsum, inherits = FALSE) / na
    trans <- get0(key, envir = st$N, inherits = FALSE)
    ev <- sum((trans / na) * vapply(names(trans), getV, numeric(1)))
    rhat + gamma * ev
  }
  replan <- function() {
    for (sweep in seq_len(vi_sweeps)) {
      for (s in st$states) {
        best <- -Inf
        for (a in seq_len(n_actions)) {
          q <- qval(s, a)
          if (q > best) best <- q
        }
        assign(s, best, envir = st$V)
      }
    }
  }
  select <- function(table, s) {
    st$step <- st$step + 1
    if (!(s %in% st$states)) st$states <- c(st$states, s)
    if (stats::runif(1) < epsilon()) return(sample.int(n_actions, 1))
    which.max(vapply(seq_len(n_actions), function(a) qval(s, a), numeric(1)))
  }
  update <- function(table, s, a, r, s2, done) {
    key <- paste0(s, "|", a)
    na <- get0(key, envir = st$Na, inherits = FALSE)
    assign(key, (if (is.null(na)) 0 else na) + 1, envir = st$Na)
    rs <- get0(key, envir = st$Rsum, inherits = FALSE)
    assign(key, (if (is.null(rs)) 0 else rs) + r, envir = st$Rsum)
    trans <- get0(key, envir = st$N, inherits = FALSE)
    if (is.null(trans)) trans <- numeric(0)
    trans[s2] <- (if (is.na(trans[s2])) 0 else trans[s2]) + 1
    assign(key, trans, envir = st$N)
    if (!(s2 %in% st$states)) st$states <- c(st$states, s2)
    if (st$step %% replan_every == 0) replan()
  }
  greedy <- function(table, s) which.max(vapply(seq_len(n_actions), function(a) qval(s, a), numeric(1)))
  action_dist <- function(table, s) {
    d <- numeric(n_actions)
    d[which.max(vapply(seq_len(n_actions), function(a) qval(s, a), numeric(1)))] <- 1
    d
  }
  list(select = select, update = update, greedy = greedy, action_dist = action_dist, state = st, replan = replan)
}

#' Agent registry
#'
#' @return A named list of agent constructors, each taking `n_actions` and `...`.
#' @export
agent_registry <- function() {
  list(
    q_learning = function(n_actions, ...) td_agent(n_actions = n_actions, ...),
    sarsa = function(n_actions, ...) sarsa_agent(n_actions = n_actions, ...),
    expected_sarsa = function(n_actions, ...) expected_sarsa_agent(n_actions = n_actions, ...),
    double_q = function(n_actions, ...) double_q_agent(n_actions = n_actions, ...),
    boltzmann_q = function(n_actions, ...) boltzmann_td_agent(n_actions = n_actions, ...),
    actor_critic = function(n_actions, ...) actor_critic_agent(n_actions = n_actions, ...),
    model_based = function(n_actions, ...) model_based_agent(n_actions = n_actions, ...),
    melioration = function(n_actions, ...) melioration_agent(n_actions = n_actions, ...),
    melioration_rate = function(n_actions, ...) melioration_rate_agent(n_actions = n_actions, ...),
    win_stay_lose_shift = function(n_actions, ...) win_stay_lose_shift_agent(n_actions = n_actions, ...)
  )
}

#' Construct an agent by name
#'
#' Exploration for the value-bootstrapping rules is scaled to `horizon`.
#'
#' @param name Registry key.
#' @param n_actions Number of actions.
#' @param horizon Number of steps the agent will run (sets epsilon decay).
#' @param ... Passed to the underlying constructor.
#' @return A list of agent callables.
#' @export
#' @examples
#' names(make_agent("sarsa", n_actions = 2L, horizon = 5000L))
make_agent <- function(name = "q_learning", n_actions = 2L, horizon = 20000L, ...) {
  reg <- agent_registry()
  eps_family <- c("q_learning", "sarsa", "expected_sarsa", "double_q", "model_based")
  if (name %in% eps_family) {
    reg[[name]](n_actions = n_actions, eps_decay_steps = max(1L, as.integer(horizon %/% 2)), ...)
  } else {
    reg[[name]](n_actions = n_actions, ...)
  }
}

#' Behavioral class of a rule
#'
#' @param name Registry key.
#' @return One of "maximizer", "meliorator", "heuristic".
#' @export
#' @examples
#' agent_kind("melioration")
agent_kind <- function(name) {
  meliorators <- c("melioration", "melioration_rate")
  heuristics <- c("win_stay_lose_shift")
  if (name %in% meliorators) "meliorator" else if (name %in% heuristics) "heuristic" else "maximizer"
}
