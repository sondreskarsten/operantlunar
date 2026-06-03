#' Reinforcement schedule primitives
#'
#' Each returns a list with `tick()` (advance time) and `respond()` (register a
#' response, returning whether it is reinforced).
#'
#' @param n Ratio requirement (FR/VR).
#' @param t Interval in steps (FI/VI).
#' @return A schedule object.
#' @name schedules_family
#' @export
#' @examples
#' s <- sched_VR(5)
#' s$respond()
sched_FR <- function(n = 5) {
  st <- new.env(parent = emptyenv())
  st$count <- 0
  list(
    tick = function() invisible(NULL),
    respond = function() {
      st$count <- st$count + 1
      if (st$count >= n) {
        st$count <- 0
        TRUE
      } else {
        FALSE
      }
    }
  )
}

#' @rdname schedules_family
#' @export
sched_VR <- function(n = 5) {
  list(
    tick = function() invisible(NULL),
    respond = function() stats::runif(1) < 1 / n
  )
}

#' @rdname schedules_family
#' @export
sched_FI <- function(t = 10) {
  st <- new.env(parent = emptyenv())
  st$timer <- 0
  list(
    tick = function() st$timer <- st$timer + 1,
    respond = function() {
      if (st$timer >= t) {
        st$timer <- 0
        TRUE
      } else {
        FALSE
      }
    }
  )
}

#' @rdname schedules_family
#' @export
sched_VI <- function(t = 10) {
  st <- new.env(parent = emptyenv())
  st$armed <- FALSE
  list(
    tick = function() if (!st$armed && stats::runif(1) < 1 / t) st$armed <- TRUE,
    respond = function() {
      if (st$armed) {
        st$armed <- FALSE
        TRUE
      } else {
        FALSE
      }
    }
  )
}

#' Build a schedule by name
#'
#' @param kind One of "FR", "VR", "FI", "VI".
#' @param param Ratio or interval parameter.
#' @return A schedule object.
#' @export
#' @examples
#' make_schedule("VI", 30)
make_schedule <- function(kind = "VR", param = 5) {
  switch(kind, FR = sched_FR(param), VR = sched_VR(param), FI = sched_FI(param), VI = sched_VI(param))
}

#' Single-operandum operant chamber
#'
#' Actions: 1 = respond, 2 = withhold. Levers: reinforcement magnitude,
#' punishment probability/magnitude, response cost, and extinction.
#'
#' @param schedule A schedule object.
#' @param magnitude Reinforcement magnitude.
#' @param punish_prob,punish_mag Punishment contingency.
#' @param response_cost Cost subtracted per response.
#' @param extinction Whether reinforcement is withheld.
#' @return An environment object with `reset`, `step`, and `set_extinction`.
#' @export
#' @examples
#' ch <- operant_chamber()
#' ch$reset(seed = 0)
#' ch$step(1)
operant_chamber <- function(schedule = NULL, magnitude = 1, punish_prob = 0, punish_mag = 1, response_cost = 0, extinction = FALSE) {
  if (is.null(schedule)) schedule <- make_schedule("VR", 5)
  st <- new.env(parent = emptyenv())
  st$extinction <- extinction
  reset <- function(seed = NULL) {
    if (!is.null(seed)) set.seed(seed)
    list(obs = 0)
  }
  step <- function(action) {
    schedule$tick()
    r <- 0
    if (action == 1) {
      if (!st$extinction && schedule$respond()) r <- r + magnitude
      if (stats::runif(1) < punish_prob) r <- r - punish_mag
      r <- r - response_cost
    }
    list(obs = 0, reward = r, terminated = FALSE, truncated = FALSE)
  }
  set_extinction <- function(flag) st$extinction <- flag
  list(reset = reset, step = step, set_extinction = set_extinction)
}

#' Concurrent two-operandum schedule
#'
#' @param schedules List of two schedule objects.
#' @param magnitudes Reinforcement magnitudes.
#' @return An environment object with `reset` and `step`.
#' @export
#' @examples
#' concurrent_schedule(list(make_schedule("VI", 30), make_schedule("VI", 90)))
concurrent_schedule <- function(schedules = NULL, magnitudes = c(1, 1)) {
  if (is.null(schedules)) schedules <- list(make_schedule("VI", 30), make_schedule("VI", 90))
  reset <- function(seed = NULL) {
    if (!is.null(seed)) set.seed(seed)
    list(obs = 0)
  }
  step <- function(action) {
    for (s in schedules) s$tick()
    r <- if (schedules[[action]]$respond()) magnitudes[action] else 0
    list(obs = 0, reward = r, terminated = FALSE, truncated = FALSE)
  }
  list(reset = reset, step = step)
}

#' Melioration trap environment
#'
#' Two alternatives; A's local reinforcement probability falls as A is chosen
#' more (`a - ca * x`), B's is `b - cb * (1 - x)`, with `x` a leaky fraction of
#' recent A-choices. Parameters can be chosen so the matching point differs from
#' the rate-maximizing optimum.
#'
#' @param a,b Intercepts of the two payoff functions.
#' @param ca,cb Slopes against allocation.
#' @param leak Leak rate of the allocation trace.
#' @return An environment object with `reset`, `step`, `optimum`, `matching_point`, `rates`.
#' @export
#' @examples
#' tr <- melioration_trap()
#' tr$optimum()
#' tr$matching_point()
melioration_trap <- function(a = 0.8, b = 0.4, ca = 0.5, cb = 0, leak = 0.02) {
  st <- new.env(parent = emptyenv())
  st$x <- 0.5
  rates <- function(x) c(a - ca * x, b - cb * (1 - x))
  clip <- function(p) min(max(p, 0), 1)
  reset <- function(seed = NULL) {
    if (!is.null(seed)) set.seed(seed)
    st$x <- 0.5
    list(obs = st$x)
  }
  step <- function(action) {
    pr <- rates(st$x)
    p <- clip(if (action == 1) pr[1] else pr[2])
    r <- if (stats::runif(1) < p) 1 else 0
    choice_a <- if (action == 1) 1 else 0
    st$x <- (1 - leak) * st$x + leak * choice_a
    list(obs = st$x, reward = r, terminated = FALSE, truncated = FALSE)
  }
  optimum <- function(grid = 201) {
    xs <- seq(0, 1, length.out = grid)
    g <- vapply(xs, function(x) {
      pr <- rates(x)
      x * clip(pr[1]) + (1 - x) * clip(pr[2])
    }, numeric(1))
    list(x_opt = xs[which.max(g)], rate_opt = max(g))
  }
  matching_point <- function() {
    x <- min(max((a - b + cb) / (ca + cb), 0), 1)
    pr <- rates(x)
    list(x_match = x, rate_match = x * clip(pr[1]) + (1 - x) * clip(pr[2]))
  }
  list(reset = reset, step = step, optimum = optimum, matching_point = matching_point, rates = rates)
}

#' Run an agent on a continuing (non-episodic) environment
#'
#' @param env An environment object.
#' @param agent An agent.
#' @param featurize Observation-to-key function.
#' @param n_steps Number of steps.
#' @param seed Seed.
#' @param train Whether to update.
#' @return A list with `rewards`, `actions`, `xs`, and the `table`.
#' @export
run_continuing <- function(env, agent, featurize, n_steps = 50000L, seed = 0L, train = TRUE) {
  set.seed(seed)
  tbl <- make_table(2L)
  out_r <- numeric(n_steps)
  out_a <- integer(n_steps)
  out_x <- numeric(n_steps)
  r0 <- env$reset(seed = seed)
  s <- featurize(r0$obs)
  for (i in seq_len(n_steps)) {
    a <- agent$select(tbl, s)
    o <- env$step(a)
    s2 <- featurize(o$obs)
    if (train) agent$update(tbl, s, a, o$reward, s2, isTRUE(o$terminated))
    out_r[i] <- o$reward
    out_a[i] <- a
    out_x[i] <- o$obs[1]
    s <- s2
  }
  list(rewards = out_r, actions = out_a, xs = out_x, table = tbl)
}

#' Melioration-trap experiment
#'
#' Trains Q-learning, expected-SARSA, and melioration on the trap and reports
#' tail allocation and reward rate against the analytic optimum and matching point.
#'
#' @param n_steps Steps per rule.
#' @param n_bins Bins for the allocation state.
#' @param gamma Discount for the maximizing rules.
#' @param alpha_q,alpha_mel Learning rates.
#' @param seed Seed.
#' @param tail Fraction of the run used for tail statistics.
#' @return A list with `optimum`, `matching_point`, and a tibble of `rules`.
#' @export
#' @examples
#' \donttest{
#' melioration_trap_experiment(n_steps = 20000)
#' }
melioration_trap_experiment <- function(n_steps = 60000L, n_bins = 20L, gamma = 0.99, alpha_q = 0.2, alpha_mel = 0.1, seed = 0L, tail = 0.2) {
  e0 <- melioration_trap()
  opt <- e0$optimum()
  match <- e0$matching_point()
  feat <- interval_featurizer(n_bins = n_bins)
  k <- as.integer(n_steps * tail)
  rules <- list(
    q_learning = td_agent(alpha = alpha_q, gamma = gamma, eps_decay_steps = n_steps %/% 2, n_actions = 2L),
    expected_sarsa = expected_sarsa_agent(alpha = alpha_q, gamma = gamma, eps_decay_steps = n_steps %/% 2, n_actions = 2L),
    melioration = melioration_agent(alpha = alpha_mel, beta = 1, n_actions = 2L)
  )
  rows <- lapply(names(rules), function(nm) {
    res <- run_continuing(melioration_trap(), rules[[nm]], feat, n_steps = n_steps, seed = seed)
    idx <- (n_steps - k + 1):n_steps
    tibble::tibble(
      rule = nm,
      reward_rate_tail = mean(res$rewards[idx]),
      x_tail = mean(res$xs[idx]),
      frac_A_tail = mean(res$actions[idx] == 1)
    )
  })
  list(optimum = opt, matching_point = match, rules = dplyr::bind_rows(rows))
}

#' Fit the generalized matching law for an arbitrary schedule pair
#'
#' @param make_pair Function mapping a parameter to a list of two schedules.
#' @param params List of parameter pairs.
#' @param alpha_mel,beta Melioration hyperparameters.
#' @param n_steps Steps per condition.
#' @param seed Seed.
#' @return A list with `slope`, `bias`, `mean_exclusivity`, `n_graded`.
#' @export
fit_matching_general <- function(make_pair, params, alpha_mel = 0.1, beta = 1, n_steps = 20000L, seed = 0L) {
  n <- length(params)
  log_b <- numeric(n)
  log_r <- numeric(n)
  excl <- numeric(n)
  for (k in seq_len(n)) {
    ag <- melioration_agent(alpha = alpha_mel, beta = beta, n_actions = 2L)
    env <- concurrent_schedule(schedules = make_pair(params[[k]]))
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
  if (sum(ok) >= 2) {
    fit <- stats::lm(log_b[ok] ~ log_r[ok])
    slope <- unname(stats::coef(fit)[2])
    bias <- unname(exp(stats::coef(fit)[1]))
  } else {
    slope <- NA_real_
    bias <- NA_real_
  }
  list(slope = slope, bias = bias, mean_exclusivity = mean(excl), n_graded = sum(ok))
}

#' Matching slopes across schedule types
#'
#' @param n_steps Steps per condition.
#' @param seed Seed.
#' @return A tibble with one row per concurrent schedule type.
#' @export
#' @examples
#' \donttest{
#' schedule_matching_table(n_steps = 8000)
#' }
schedule_matching_table <- function(n_steps = 20000L, seed = 0L) {
  vi_vi <- fit_matching_general(function(p) list(make_schedule("VI", p[1]), make_schedule("VI", p[2])),
                                list(c(20, 60), c(30, 90), c(45, 45), c(60, 30), c(90, 30), c(40, 120), c(120, 40)),
                                n_steps = n_steps, seed = seed)
  vr_vr <- fit_matching_general(function(p) list(make_schedule("VR", p[1]), make_schedule("VR", p[2])),
                                list(c(8, 24), c(12, 36), c(18, 18), c(24, 12), c(36, 12), c(16, 48), c(48, 16)),
                                n_steps = n_steps, seed = seed)
  vi_vr <- fit_matching_general(function(p) list(make_schedule("VI", p[1]), make_schedule("VR", p[2])),
                                list(c(30, 30), c(45, 20), c(60, 15), c(90, 12), c(30, 12), c(60, 24), c(90, 30)),
                                n_steps = n_steps, seed = seed)
  dplyr::bind_rows(
    tibble::tibble(schedule = "conc_VI_VI", slope = vi_vi$slope, bias = vi_vi$bias, mean_exclusivity = vi_vi$mean_exclusivity, n_graded = vi_vi$n_graded),
    tibble::tibble(schedule = "conc_VR_VR", slope = vr_vr$slope, bias = vr_vr$bias, mean_exclusivity = vr_vr$mean_exclusivity, n_graded = vr_vr$n_graded),
    tibble::tibble(schedule = "conc_VI_VR", slope = vi_vr$slope, bias = vi_vr$bias, mean_exclusivity = vi_vr$mean_exclusivity, n_graded = vi_vr$n_graded)
  )
}

#' Extinction experiment
#'
#' Acquires responding under three schedules, then withholds reinforcement and
#' measures resistance to extinction.
#'
#' @param acquire_steps,extinction_steps Phase lengths.
#' @param alpha Learning rate.
#' @param response_cost Cost per response.
#' @param q0 Optimistic initial value.
#' @param seed Seed.
#' @param window Rolling window for the rate.
#' @param threshold Extinction rate threshold.
#' @return A tibble with one row per acquisition schedule.
#' @export
#' @examples
#' \donttest{
#' extinction_experiment(acquire_steps = 4000, extinction_steps = 4000)
#' }
extinction_experiment <- function(acquire_steps = 8000L, extinction_steps = 8000L, alpha = 0.02, response_cost = 0.02, q0 = 1, seed = 0L, window = 300L, threshold = 0.2) {
  scheds <- list(CRF = list("FR", 1), VR5 = list("VR", 5), VI10 = list("VI", 10))
  rows <- lapply(names(scheds), function(nm) {
    kind <- scheds[[nm]][[1]]
    param <- scheds[[nm]][[2]]
    set.seed(seed)
    ag <- td_agent(alpha = alpha, gamma = 0, eps_start = 1, eps_end = 0.05, eps_decay_steps = acquire_steps %/% 2, n_actions = 2L)
    tbl <- make_table(2L)
    assign("S0", c(q0, q0), envir = tbl)
    env <- operant_chamber(schedule = make_schedule(kind, param), response_cost = response_cost)
    s <- "S0"
    acq <- integer(acquire_steps)
    for (t in seq_len(acquire_steps)) {
      a <- ag$select(tbl, s)
      o <- env$step(a)
      ag$update(tbl, s, a, o$reward, s, FALSE)
      acq[t] <- a
    }
    env$set_extinction(TRUE)
    responses <- 0L
    ste <- extinction_steps
    recent <- integer(0)
    for (t in seq_len(extinction_steps)) {
      a <- ag$select(tbl, s)
      o <- env$step(a)
      ag$update(tbl, s, a, o$reward, s, FALSE)
      responses <- responses + (a == 1)
      recent <- c(recent, as.integer(a == 1))
      if (length(recent) > window) recent <- recent[-1]
      if (length(recent) == window && mean(recent) < threshold) {
        ste <- t
        break
      }
    }
    tibble::tibble(
      schedule = nm,
      acq_response_rate = mean(acq[(acquire_steps - window + 1):acquire_steps] == 1),
      responses_in_extinction = responses,
      steps_to_extinction = ste
    )
  })
  dplyr::bind_rows(rows)
}

#' Run the full operant battery
#'
#' @param seed Seed.
#' @return A list with `melioration_trap`, `schedule_matching`, `extinction`.
#' @export
#' @examples
#' \donttest{
#' operant_battery()
#' }
operant_battery <- function(seed = 0L) {
  list(
    melioration_trap = melioration_trap_experiment(seed = seed),
    schedule_matching = schedule_matching_table(seed = seed),
    extinction = extinction_experiment(seed = seed)
  )
}
