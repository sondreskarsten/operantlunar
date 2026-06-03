#' Softmax with inverse temperature
#'
#' @param x Numeric vector.
#' @param beta Inverse temperature.
#' @return Probability vector.
#' @export
#' @examples
#' softmax(c(0, 1, -1, 0.5))
softmax <- function(x, beta = 1) {
  z <- beta * (x - max(x))
  e <- exp(z)
  e / sum(e)
}

#' Q-learning agent (law of effect with foresight)
#'
#' Off-policy temporal-difference control with epsilon-greedy selection.
#'
#' @param alpha Learning rate.
#' @param gamma Discount factor.
#' @param eps_start,eps_end,eps_decay_steps Epsilon schedule.
#' @param n_actions Number of actions.
#' @return A list of agent callables.
#' @export
#' @examples
#' a <- td_agent()
#' names(a)
td_agent <- function(alpha = 0.1, gamma = 0.99, eps_start = 1, eps_end = 0.05, eps_decay_steps = 150000, n_actions = 4L) {
  st <- new.env(parent = emptyenv())
  st$step <- 0
  epsilon <- function() {
    frac <- min(1, st$step / eps_decay_steps)
    eps_start + (eps_end - eps_start) * frac
  }
  select <- function(table, s) {
    st$step <- st$step + 1
    if (stats::runif(1) < epsilon()) return(sample.int(n_actions, 1))
    which.max(table_get(table, s, n_actions))
  }
  update <- function(table, s, a, r, s2, done) {
    v <- table_get(table, s, n_actions)
    target <- if (isTRUE(done)) r else r + gamma * max(table_get(table, s2, n_actions))
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

#' Melioration agent (myopic linear-operator preference)
#'
#' A gradient-bandit reinforcement-preference rule: no temporal bootstrapping,
#' probability-matching selection. Reproduces the matching law.
#'
#' @param alpha Learning rate.
#' @param beta Inverse temperature for selection.
#' @param n_actions Number of actions.
#' @param baseline Whether to subtract a per-state running-mean reward baseline.
#' @return A list of agent callables.
#' @export
#' @examples
#' b <- melioration_agent()
#' names(b)
melioration_agent <- function(alpha = 0.1, beta = 1, n_actions = 4L, baseline = TRUE) {
  base <- new.env(parent = emptyenv())
  select <- function(table, s) {
    p <- softmax(table_get(table, s, n_actions), beta)
    sample.int(n_actions, 1, prob = p)
  }
  update <- function(table, s, a, r, s2, done) {
    v <- table_get(table, s, n_actions)
    p <- softmax(v, beta)
    if (baseline) {
      c0 <- get0(s, envir = base, inherits = FALSE)
      if (is.null(c0)) c0 <- c(0, 0)
      c0[2] <- c0[2] + 1
      c0[1] <- c0[1] + (r - c0[1]) / c0[2]
      assign(s, c0, envir = base)
      b <- c0[1]
    } else {
      b <- 0
    }
    one <- numeric(n_actions)
    one[a] <- 1
    v <- v + alpha * (r - b) * (one - p)
    assign(s, v, envir = table)
  }
  greedy <- function(table, s) which.max(table_get(table, s, n_actions))
  action_dist <- function(table, s) softmax(table_get(table, s, n_actions), beta)
  list(select = select, update = update, greedy = greedy, action_dist = action_dist)
}

#' Expected-SARSA agent (on-policy bootstrap)
#'
#' @inheritParams td_agent
#' @return A list of agent callables.
#' @export
#' @examples
#' expected_sarsa_agent()$select
expected_sarsa_agent <- function(alpha = 0.1, gamma = 0.99, eps_start = 1, eps_end = 0.05, eps_decay_steps = 150000, n_actions = 4L) {
  st <- new.env(parent = emptyenv())
  st$step <- 0
  epsilon <- function() {
    frac <- min(1, st$step / eps_decay_steps)
    eps_start + (eps_end - eps_start) * frac
  }
  policy <- function(v, eps) {
    d <- rep(eps / n_actions, n_actions)
    d[which.max(v)] <- d[which.max(v)] + 1 - eps
    d
  }
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
      target <- r + gamma * sum(policy(v2, epsilon()) * v2)
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

#' Boltzmann Q-learning agent (softmax selection over Q)
#'
#' @inheritParams td_agent
#' @param beta Inverse temperature for selection.
#' @return A list of agent callables.
#' @export
#' @examples
#' boltzmann_td_agent()$select
boltzmann_td_agent <- function(alpha = 0.1, gamma = 0.99, beta = 1, n_actions = 4L) {
  select <- function(table, s) {
    p <- softmax(table_get(table, s, n_actions), beta)
    sample.int(n_actions, 1, prob = p)
  }
  update <- function(table, s, a, r, s2, done) {
    v <- table_get(table, s, n_actions)
    target <- if (isTRUE(done)) r else r + gamma * max(table_get(table, s2, n_actions))
    v[a] <- v[a] + alpha * (target - v[a])
    assign(s, v, envir = table)
  }
  greedy <- function(table, s) which.max(table_get(table, s, n_actions))
  action_dist <- function(table, s) softmax(table_get(table, s, n_actions), beta)
  list(select = select, update = update, greedy = greedy, action_dist = action_dist)
}

#' One Bush-Mosteller probability-space update
#'
#' @param p Probability vector.
#' @param action Index of the emitted response (1-based).
#' @param reinforced Logical, whether the response was reinforced.
#' @param alpha Learning rate.
#' @param scheme Either "R-I" (reward-inaction) or "R-P" (reward-penalty).
#' @return Updated probability vector.
#' @export
#' @examples
#' bush_mosteller_step(c(0.5, 0.5), 1, TRUE)
bush_mosteller_step <- function(p, action, reinforced, alpha = 0.1, scheme = "R-I") {
  p <- as.numeric(p)
  k <- length(p)
  if (isTRUE(reinforced)) {
    p[action] <- p[action] + alpha * (1 - p[action])
    for (j in seq_len(k)) if (j != action) p[j] <- p[j] - alpha * p[j]
  } else if (scheme == "R-P") {
    p[action] <- p[action] - alpha * p[action]
    for (j in seq_len(k)) if (j != action) p[j] <- p[j] + alpha * (1 - p[j]) / (k - 1)
  }
  p / sum(p)
}
