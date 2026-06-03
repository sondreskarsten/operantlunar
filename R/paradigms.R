#' Probability-matching task
#'
#' Fixed reinforcement probabilities per alternative; one choice per step. The
#' reward-maximizing policy is exclusive choice of the richer alternative.
#'
#' @param probs Reinforcement probabilities.
#' @param magnitudes Reinforcement magnitudes.
#' @return An environment object with `reset`, `step`, `probs`, `magnitudes`, `optimal_action`.
#' @export
#' @examples
#' env <- prob_matching_task(c(0.7, 0.3))
#' env$optimal_action
prob_matching_task <- function(probs = c(0.7, 0.3), magnitudes = NULL) {
  n <- length(probs)
  if (is.null(magnitudes)) magnitudes <- rep(1, n)
  reset <- function(seed = NULL) {
    if (!is.null(seed)) set.seed(seed)
    list(obs = 0)
  }
  step <- function(action) {
    r <- if (stats::runif(1) < probs[action]) magnitudes[action] else 0
    list(obs = 0, reward = r, terminated = FALSE, truncated = FALSE)
  }
  list(reset = reset, step = step, probs = probs, magnitudes = magnitudes, optimal_action = which.max(probs * magnitudes))
}

#' Probability-matching experiment
#'
#' @param probs Reinforcement probabilities.
#' @param rules Registry keys.
#' @param n_steps Steps per rule.
#' @param seed Seed.
#' @param tail Fraction used for tail statistics.
#' @return A list with task constants and a tibble of per-rule results.
#' @export
#' @examples
#' \donttest{
#' prob_matching_experiment(n_steps = 8000)
#' }
prob_matching_experiment <- function(probs = c(0.75, 0.25), rules = c("q_learning", "melioration", "melioration_rate"), n_steps = 20000L, seed = 0L, tail = 0.2) {
  opt <- which.max(probs)
  k <- as.integer(n_steps * tail)
  p_match <- probs[1] / sum(probs)
  rows <- lapply(rules, function(nm) {
    ag <- make_agent(nm, n_actions = length(probs), horizon = n_steps)
    res <- run_continuing(prob_matching_task(probs), ag, constant_featurizer(), n_steps = n_steps, seed = seed)
    idx <- (n_steps - k + 1):n_steps
    a <- res$actions[idx]
    tibble::tibble(rule = nm, frac_optimal = mean(a == opt), reward_rate = mean(res$rewards[idx]), p_richer = mean(a == 1))
  })
  list(probs = probs, optimal_action = opt, optimal_rate = max(probs), matching_rate = sum(probs^2) / sum(probs), matching_p_richer = p_match, rules = dplyr::bind_rows(rows))
}

#' Self-control (delay-discounting) environment
#'
#' A fixed-length trial offers a small-sooner versus a large-later reward.
#' Trial length is equalized across choices so reward rate favors the larger
#' reward; a discounting or myopic rule prefers the sooner one.
#'
#' @param ss_amount,ss_delay Small-sooner amount and delay (steps).
#' @param ll_amount,ll_delay Large-later amount and delay (steps).
#' @return An environment object with `reset`, `step`, `trial_length`, `ss`, `ll`.
#' @export
#' @examples
#' env <- self_control_env()
#' env$trial_length
self_control_env <- function(ss_amount = 1, ss_delay = 0, ll_amount = 5, ll_delay = 10) {
  trial_length <- max(ss_delay, ll_delay) + 1L
  st <- new.env(parent = emptyenv())
  st$branch <- 0L
  st$t <- 0L
  st$amt <- 0
  st$delay <- 0L
  reset <- function(seed = NULL) {
    if (!is.null(seed)) set.seed(seed)
    st$branch <- 0L
    st$t <- 0L
    list(obs = 0)
  }
  step <- function(action) {
    if (st$branch == 0L) {
      if (action == 1) {
        st$branch <- 1L
        st$delay <- ss_delay
        st$amt <- ss_amount
      } else {
        st$branch <- 2L
        st$delay <- ll_delay
        st$amt <- ll_amount
      }
      st$t <- 0L
      r <- if (st$delay == 0L) st$amt else 0
      st$t <- st$t + 1L
      if (st$t >= trial_length) {
        st$branch <- 0L
        return(list(obs = 0, reward = r, terminated = FALSE, truncated = FALSE))
      }
      return(list(obs = st$branch * 1000L + st$t, reward = r, terminated = FALSE, truncated = FALSE))
    }
    r <- if (st$t == st$delay) st$amt else 0
    st$t <- st$t + 1L
    if (st$t >= trial_length) {
      st$branch <- 0L
      return(list(obs = 0, reward = r, terminated = FALSE, truncated = FALSE))
    }
    list(obs = st$branch * 1000L + st$t, reward = r, terminated = FALSE, truncated = FALSE)
  }
  list(reset = reset, step = step, trial_length = trial_length, ss = c(ss_amount, ss_delay), ll = c(ll_amount, ll_delay))
}

#' Self-control experiment
#'
#' @param rules Registry keys.
#' @param ss_amount,ss_delay,ll_amount,ll_delay Trial parameters.
#' @param n_steps Steps per rule.
#' @param seed Seed.
#' @param tail_choices Number of trailing choices used for the statistic.
#' @return A list with trial parameters and a tibble of large-later fractions.
#' @export
#' @examples
#' \donttest{
#' self_control_experiment(n_steps = 20000)
#' }
self_control_experiment <- function(rules = c("q_learning", "melioration", "model_based"), ss_amount = 1, ss_delay = 0, ll_amount = 5, ll_delay = 10, n_steps = 40000L, seed = 0L, tail_choices = 200L) {
  feat <- discrete_featurizer()
  rows <- lapply(rules, function(nm) {
    set.seed(seed)
    ag <- make_agent(nm, n_actions = 2L, horizon = n_steps)
    tbl <- make_table(2L)
    env <- self_control_env(ss_amount, ss_delay, ll_amount, ll_delay)
    s <- feat(env$reset(seed = seed)$obs)
    choices <- integer(0)
    for (i in seq_len(n_steps)) {
      a <- ag$select(tbl, s)
      o <- env$step(a)
      s2 <- feat(o$obs)
      ag$update(tbl, s, a, o$reward, s2, FALSE)
      if (s == "0") choices <- c(choices, a)
      s <- s2
    }
    tc <- utils::tail(choices, tail_choices)
    tibble::tibble(rule = nm, frac_LL = mean(tc == 2), n_choices = length(choices))
  })
  list(ss = c(ss_amount, ss_delay), ll = c(ll_amount, ll_delay), rules = dplyr::bind_rows(rows))
}

#' Differential-reinforcement-of-low-rate chamber
#'
#' A response is reinforced only if at least `threshold` steps have elapsed
#' since the previous response.
#'
#' @param threshold Minimum inter-response time.
#' @param magnitude Reinforcement magnitude.
#' @param response_cost Cost per response.
#' @param cap Maximum inter-response time exposed as the observation.
#' @return An environment object with `reset`, `step`, `threshold`.
#' @export
#' @examples
#' env <- drl_chamber(15)
#' env$reset(seed = 0)
drl_chamber <- function(threshold = 15, magnitude = 1, response_cost = 0.02, cap = NULL) {
  if (is.null(cap)) cap <- as.integer(3L * threshold)
  st <- new.env(parent = emptyenv())
  st$since <- 0L
  reset <- function(seed = NULL) {
    if (!is.null(seed)) set.seed(seed)
    st$since <- 0L
    list(obs = 0)
  }
  step <- function(action) {
    r <- 0
    if (action == 1) {
      if (st$since >= threshold) r <- magnitude
      st$since <- 0L
      r <- r - response_cost
    } else {
      st$since <- st$since + 1L
    }
    list(obs = min(st$since, cap), reward = r, terminated = FALSE, truncated = FALSE)
  }
  list(reset = reset, step = step, threshold = threshold)
}

#' DRL experiment
#'
#' @param rules Registry keys.
#' @param threshold Minimum inter-response time.
#' @param n_steps Steps per rule.
#' @param seed Seed.
#' @param tail Fraction used for tail statistics.
#' @return A list with the threshold, optimal response rate, and a tibble.
#' @export
#' @examples
#' \donttest{
#' drl_experiment(n_steps = 20000)
#' }
drl_experiment <- function(rules = c("q_learning", "expected_sarsa", "melioration", "win_stay_lose_shift"), threshold = 15L, n_steps = 40000L, seed = 0L, tail = 0.2) {
  k <- as.integer(n_steps * tail)
  rows <- lapply(rules, function(nm) {
    ag <- make_agent(nm, n_actions = 2L, horizon = n_steps)
    res <- run_continuing(drl_chamber(threshold), ag, discrete_featurizer(), n_steps = n_steps, seed = seed)
    idx <- (n_steps - k + 1):n_steps
    tibble::tibble(rule = nm, response_rate = mean(res$actions[idx] == 1), reward_rate = mean(res$rewards[idx]))
  })
  list(threshold = threshold, optimal_rate = 1 / threshold, rules = dplyr::bind_rows(rows))
}

#' Progressive-ratio schedule
#'
#' The ratio requirement increases by `step` after each reinforcer.
#'
#' @param start Initial ratio.
#' @param inc Ratio increment per reinforcer.
#' @param magnitude Reinforcement magnitude.
#' @param response_cost Cost per response.
#' @return An environment object with `reset`, `step`, `current_ratio`.
#' @export
#' @examples
#' env <- progressive_ratio()
#' env$reset(seed = 0)
progressive_ratio <- function(start = 1, inc = 1, magnitude = 1, response_cost = 0.05) {
  st <- new.env(parent = emptyenv())
  st$req <- start
  st$count <- 0L
  st$ratio <- start
  reset <- function(seed = NULL) {
    if (!is.null(seed)) set.seed(seed)
    st$req <- start
    st$count <- 0L
    st$ratio <- start
    list(obs = 0)
  }
  step <- function(action) {
    r <- 0
    if (action == 1) {
      st$count <- st$count + 1L
      r <- r - response_cost
      if (st$count >= st$req) {
        r <- r + magnitude
        st$count <- 0L
        st$ratio <- st$req
        st$req <- st$req + inc
      }
    }
    list(obs = 0, reward = r, terminated = FALSE, truncated = FALSE)
  }
  list(reset = reset, step = step, current_ratio = function() st$ratio)
}

#' Progressive-ratio experiment
#'
#' @param rules Registry keys.
#' @param inc Ratio increment.
#' @param magnitude Reinforcement magnitude.
#' @param response_cost Cost per response.
#' @param n_steps Steps per rule.
#' @param seed Seed.
#' @return A tibble of breakpoints (highest completed ratio).
#' @export
#' @examples
#' \donttest{
#' progressive_ratio_experiment(n_steps = 20000)
#' }
progressive_ratio_experiment <- function(rules = c("q_learning", "melioration", "win_stay_lose_shift"), inc = 1, magnitude = 1, response_cost = 0.05, n_steps = 40000L, seed = 0L) {
  rows <- lapply(rules, function(nm) {
    set.seed(seed)
    ag <- make_agent(nm, n_actions = 2L, horizon = n_steps)
    tbl <- make_table(2L)
    env <- progressive_ratio(inc = inc, magnitude = magnitude, response_cost = response_cost)
    s <- "S0"
    env$reset(seed = seed)
    breakpoint <- 0
    for (i in seq_len(n_steps)) {
      a <- ag$select(tbl, s)
      o <- env$step(a)
      ag$update(tbl, s, a, o$reward, s, FALSE)
      if (o$reward > 0) breakpoint <- env$current_ratio()
    }
    tibble::tibble(rule = nm, breakpoint = breakpoint)
  })
  dplyr::bind_rows(rows)
}

#' Risk-sensitivity environment
#'
#' A safe option pays a fixed amount; a risky option pays a larger amount with
#' some probability. Means can be matched to isolate variance sensitivity.
#'
#' @param safe Safe payoff.
#' @param risky_high Risky payoff when it pays.
#' @param risky_p Probability the risky option pays.
#' @return An environment object with `reset`, `step`, `safe`, `risky_mean`.
#' @export
#' @examples
#' env <- risk_env()
#' env$risky_mean
risk_env <- function(safe = 1, risky_high = 2, risky_p = 0.5) {
  reset <- function(seed = NULL) {
    if (!is.null(seed)) set.seed(seed)
    list(obs = 0)
  }
  step <- function(action) {
    r <- if (action == 1) safe else if (stats::runif(1) < risky_p) risky_high else 0
    list(obs = 0, reward = r, terminated = FALSE, truncated = FALSE)
  }
  list(reset = reset, step = step, safe = safe, risky_mean = risky_high * risky_p)
}

#' Risk-sensitivity experiment
#'
#' @param rules Registry keys.
#' @param safe,risky_high,risky_p Payoff parameters.
#' @param n_steps Steps per rule.
#' @param seed Seed.
#' @param tail Fraction used for tail statistics.
#' @return A list with payoff constants and a tibble of risky-choice fractions.
#' @export
#' @examples
#' \donttest{
#' risk_experiment(n_steps = 8000)
#' }
risk_experiment <- function(rules = c("q_learning", "melioration", "melioration_rate"), safe = 1, risky_high = 2, risky_p = 0.5, n_steps = 20000L, seed = 0L, tail = 0.2) {
  k <- as.integer(n_steps * tail)
  rows <- lapply(rules, function(nm) {
    ag <- make_agent(nm, n_actions = 2L, horizon = n_steps)
    res <- run_continuing(risk_env(safe, risky_high, risky_p), ag, constant_featurizer(), n_steps = n_steps, seed = seed)
    idx <- (n_steps - k + 1):n_steps
    tibble::tibble(rule = nm, frac_risky = mean(res$actions[idx] == 2), reward_rate = mean(res$rewards[idx]))
  })
  list(safe = safe, risky_mean = risky_high * risky_p, rules = dplyr::bind_rows(rows))
}

#' Reinforcer-devaluation environment
#'
#' Pressing (action 1) yields the current outcome value; withholding (action 2)
#' yields nothing. The outcome can be devalued at test.
#'
#' @param magnitude Initial outcome value.
#' @param response_cost Cost per press.
#' @return An environment object with `reset`, `step`, `devalue`.
#' @export
#' @examples
#' env <- devaluation_env()
#' env$reset(seed = 0)
devaluation_env <- function(magnitude = 1, response_cost = 0.01) {
  st <- new.env(parent = emptyenv())
  st$value <- magnitude
  reset <- function(seed = NULL) {
    if (!is.null(seed)) set.seed(seed)
    list(obs = 0)
  }
  step <- function(action) {
    r <- 0
    if (action == 1) r <- st$value - response_cost
    list(obs = 0, reward = r, terminated = FALSE, truncated = FALSE)
  }
  devalue <- function(new_value = 0) st$value <- new_value
  list(reset = reset, step = step, devalue = devalue)
}

#' Reinforcer-devaluation experiment (habit vs goal-directed)
#'
#' Acquires pressing, then devalues the outcome and tests in extinction with
#' learning frozen. A model-based rule revalues from its model and stops; cached
#' value rules (model-free, melioration) persist.
#'
#' @param rules Registry keys.
#' @param magnitude Outcome value during acquisition.
#' @param response_cost Cost per press (survives devaluation).
#' @param acquire_steps Acquisition length.
#' @param test_steps Test length.
#' @param seed Seed.
#' @return A list with a tibble of acquired and post-devaluation press fractions.
#' @export
#' @examples
#' \donttest{
#' devaluation_experiment(acquire_steps = 4000)
#' }
devaluation_experiment <- function(rules = c("q_learning", "model_based", "melioration"), magnitude = 1, response_cost = 0.01, acquire_steps = 8000L, test_steps = 500L, seed = 0L) {
  rows <- lapply(rules, function(nm) {
    set.seed(seed)
    ag <- make_agent(nm, n_actions = 2L, horizon = acquire_steps)
    tbl <- make_table(2L)
    env <- devaluation_env(magnitude, response_cost)
    s <- "S0"
    env$reset(seed = seed)
    acq <- integer(acquire_steps)
    for (i in seq_len(acquire_steps)) {
      a <- ag$select(tbl, s)
      o <- env$step(a)
      ag$update(tbl, s, a, o$reward, s, FALSE)
      acq[i] <- a
    }
    if (nm == "model_based") {
      na1 <- get0("S0|1", envir = ag$state$Na, inherits = FALSE)
      assign("S0|1", -response_cost * (if (is.null(na1)) 0 else na1), envir = ag$state$Rsum)
      ag$replan()
    }
    env$devalue(0)
    sel <- if (agent_kind(nm) == "maximizer") ag$greedy else ag$select
    press <- 0L
    for (i in seq_len(test_steps)) {
      a <- sel(tbl, s)
      env$step(a)
      press <- press + (a == 1)
    }
    tibble::tibble(rule = nm, acq_press_rate = mean(acq[(acquire_steps - 299L):acquire_steps] == 1), test_press_rate = press / test_steps)
  })
  list(rules = dplyr::bind_rows(rows))
}

#' Concurrent schedule with a changeover delay
#'
#' Switching alternatives starts a lockout of `cod` steps during which no
#' reinforcer is delivered. Without a changeover delay, rapid alternation
#' harvests both schedules and undermatching results.
#'
#' @param schedules List of two schedule objects.
#' @param magnitudes Reinforcement magnitudes.
#' @param cod Changeover-delay length in steps.
#' @return An environment object with `reset`, `step`.
#' @export
#' @examples
#' concurrent_schedule_cod(cod = 2)
concurrent_schedule_cod <- function(schedules = NULL, magnitudes = c(1, 1), cod = 1L) {
  if (is.null(schedules)) schedules <- list(make_schedule("VI", 30), make_schedule("VI", 90))
  st <- new.env(parent = emptyenv())
  st$last <- NA_integer_
  st$lock <- 0L
  reset <- function(seed = NULL) {
    if (!is.null(seed)) set.seed(seed)
    st$last <- NA_integer_
    st$lock <- 0L
    list(obs = 0)
  }
  step <- function(action) {
    for (s in schedules) s$tick()
    if (!is.na(st$last) && action != st$last) st$lock <- cod
    avail <- schedules[[action]]$respond()
    r <- 0
    if (st$lock > 0L) st$lock <- st$lock - 1L else if (avail) r <- magnitudes[action]
    st$last <- action
    list(obs = 0, reward = r, terminated = FALSE, truncated = FALSE)
  }
  list(reset = reset, step = step)
}

#' Changeover-delay demonstration
#'
#' Fits matching slopes for a melioration agent at two changeover delays.
#'
#' @param cods Changeover delays to compare.
#' @param conditions VI mean pairs.
#' @param n_steps Steps per condition.
#' @param seed Seed.
#' @return A tibble with one row per changeover delay.
#' @export
#' @examples
#' \donttest{
#' changeover_delay_demo(n_steps = 8000)
#' }
changeover_delay_demo <- function(cods = c(0L, 4L), conditions = list(c(20, 60), c(30, 90), c(45, 45), c(60, 30), c(90, 30)), n_steps = 20000L, seed = 0L) {
  rows <- lapply(cods, function(cd) {
    n <- length(conditions)
    log_b <- numeric(n)
    log_r <- numeric(n)
    excl <- numeric(n)
    for (k in seq_len(n)) {
      ag <- melioration_agent(n_actions = 2L)
      env <- concurrent_schedule_cod(schedules = list(make_schedule("VI", conditions[[k]][1]), make_schedule("VI", conditions[[k]][2])), cod = cd)
      res <- run_continuing(env, ag, constant_featurizer(), n_steps = n_steps, seed = seed + k)
      a <- res$actions
      r <- res$rewards
      b1 <- sum(a == 1)
      b2 <- sum(a == 2)
      rr1 <- sum(a == 1 & r > 0)
      rr2 <- sum(a == 2 & r > 0)
      excl[k] <- max(b1, b2) / (b1 + b2)
      log_b[k] <- if (b1 > 0 && b2 > 0) log(b1 / b2) else NA_real_
      log_r[k] <- if (rr1 > 0 && rr2 > 0) log(rr1 / rr2) else NA_real_
    }
    ok <- is.finite(log_b) & is.finite(log_r)
    slope <- if (sum(ok) >= 2) unname(stats::coef(stats::lm(log_b[ok] ~ log_r[ok]))[2]) else NA_real_
    tibble::tibble(cod = cd, slope = slope, mean_exclusivity = mean(excl))
  })
  dplyr::bind_rows(rows)
}
