#' Mean reward rate of a policy
#'
#' @param env An environment object.
#' @param agent An agent.
#' @param featurize Observation-to-key function.
#' @param n_steps Steps to evaluate.
#' @param seed Seed.
#' @param greedy Whether to follow the greedy policy.
#' @return The mean per-step reward.
#' @export
#' @examples
#' \donttest{
#' value_of_policy(prob_matching_task(), make_agent("q_learning", 2L), constant_featurizer(), 2000)
#' }
value_of_policy <- function(env, agent, featurize, n_steps = 5000L, seed = 0L, greedy = TRUE) {
  set.seed(seed)
  tbl <- make_table(2L)
  s <- featurize(env$reset(seed = seed)$obs)
  total <- 0
  sel <- if (greedy) agent$greedy else agent$select
  for (i in seq_len(n_steps)) {
    a <- sel(tbl, s)
    o <- env$step(a)
    total <- total + o$reward
    s <- featurize(o$obs)
  }
  total / n_steps
}

#' Regret against an optimal rate
#'
#' @param achieved Achieved reward rate.
#' @param optimal Optimal reward rate.
#' @return The non-negative regret.
#' @export
#' @examples
#' regret(0.4, 0.48)
regret <- function(achieved, optimal) max(0, optimal - achieved)

#' Classify behavior from a maximize score
#'
#' @param score A value in the unit interval where 1 is reward-maximizing.
#' @param max_cut,mel_cut Thresholds.
#' @return One of "maximizing", "intermediate", "matching".
#' @export
#' @examples
#' classify_rule(0.95)
classify_rule <- function(score, max_cut = 0.8, mel_cut = 0.4) {
  if (is.na(score)) NA_character_ else if (score >= max_cut) "maximizing" else if (score >= mel_cut) "intermediate" else "matching"
}

#' Generalized-matching sensitivity and bias
#'
#' Fits log response ratio on log reinforcement ratio. Sensitivity is the slope,
#' bias the exponentiated intercept. Optional bootstrap resamples conditions.
#'
#' @param log_r Log reinforcement ratios.
#' @param log_b Log behavior ratios.
#' @param n_boot Bootstrap replicates (0 to skip).
#' @param seed Seed for the bootstrap.
#' @return A list with `sensitivity`, `bias`, `r_squared`, and optional CIs.
#' @export
#' @examples
#' matching_sensitivity_bias(log(c(0.3, 1, 3)), log(c(0.28, 1.02, 2.9)))
matching_sensitivity_bias <- function(log_r, log_b, n_boot = 0, seed = 0L) {
  ok <- is.finite(log_r) & is.finite(log_b)
  lr <- log_r[ok]
  lb <- log_b[ok]
  fit <- stats::lm(lb ~ lr)
  sens <- unname(stats::coef(fit)[2])
  bias <- unname(exp(stats::coef(fit)[1]))
  out <- list(sensitivity = sens, bias = bias, r_squared = summary(fit)$r.squared, n = length(lr))
  if (n_boot > 0) {
    set.seed(seed)
    bs <- vapply(seq_len(n_boot), function(i) {
      idx <- sample.int(length(lr), replace = TRUE)
      unname(stats::coef(stats::lm(lb[idx] ~ lr[idx]))[2])
    }, numeric(1))
    out$sensitivity_ci <- unname(stats::quantile(bs, c(0.025, 0.975)))
  }
  out
}

#' Fit Herrnstein's single-alternative hyperbola
#'
#' Response rate B = k r / (r + r0) against reinforcement rate r.
#'
#' @param reinforcement_rate Reinforcement rates.
#' @param response_rate Response rates.
#' @return A list with `k`, `r0`, and fitted values.
#' @export
#' @examples
#' fit_herrnstein_hyperbola(c(0.02, 0.05, 0.1, 0.2), c(0.3, 0.5, 0.65, 0.78))
fit_herrnstein_hyperbola <- function(reinforcement_rate, response_rate) {
  d <- data.frame(r = reinforcement_rate, B = response_rate)
  fit <- stats::nls(B ~ k * r / (r + r0), data = d, start = list(k = max(d$B) * 1.1, r0 = stats::median(d$r)), algorithm = "port", lower = c(k = 0, r0 = 1e-6))
  co <- stats::coef(fit)
  list(k = unname(co["k"]), r0 = unname(co["r0"]), fitted = stats::fitted(fit))
}

#' Herrnstein single-alternative VI experiment
#'
#' Runs a melioration agent on a single variable-interval lever across a range
#' of schedule values and records reinforcement and response rates.
#'
#' @param vi_values Variable-interval means (steps).
#' @param magnitude Reinforcement magnitude.
#' @param response_cost Cost per response.
#' @param n_steps Steps per condition.
#' @param seed Seed.
#' @param tail Fraction used for tail statistics.
#' @return A tibble with one row per schedule value.
#' @export
#' @examples
#' \donttest{
#' herrnstein_experiment(n_steps = 8000)
#' }
herrnstein_experiment <- function(vi_values = c(5, 10, 20, 40, 80, 160), magnitude = 1, response_cost = 0.05, n_steps = 20000L, seed = 0L, tail = 0.3) {
  single_vi_press <- function(vi) {
    sch <- make_schedule("VI", vi)
    reset <- function(seed = NULL) {
      if (!is.null(seed)) set.seed(seed)
      list(obs = 0)
    }
    step <- function(action) {
      sch$tick()
      r <- 0
      if (action == 1) {
        avail <- sch$respond()
        r <- (if (avail) magnitude else 0) - response_cost
      }
      list(obs = 0, reward = r, terminated = FALSE, truncated = FALSE)
    }
    list(reset = reset, step = step)
  }
  k <- as.integer(n_steps * tail)
  rows <- lapply(vi_values, function(vi) {
    ag <- melioration_agent(n_actions = 2L)
    res <- run_continuing(single_vi_press(vi), ag, constant_featurizer(), n_steps = n_steps, seed = seed)
    idx <- (n_steps - k + 1):n_steps
    tibble::tibble(vi = vi, reinforcement_rate = mean(res$rewards[idx] > 0), response_rate = mean(res$actions[idx] == 1))
  })
  dplyr::bind_rows(rows)
}

#' Fit a delay-discounting function
#'
#' @param delays Delays.
#' @param indiff Indifference amounts (subjective value of the larger reward).
#' @param model "hyperbolic" (A/(1+k d)) or "exponential" (A exp(-k d)).
#' @return A list with `k`, `A`, `model`, and fitted values.
#' @export
#' @examples
#' fit_discounting(c(2, 5, 10, 20), c(4.5, 3.5, 2.4, 1.4))
fit_discounting <- function(delays, indiff, model = c("hyperbolic", "exponential")) {
  model <- match.arg(model)
  d <- data.frame(delay = delays, v = indiff)
  if (model == "hyperbolic") {
    fit <- stats::nls(v ~ A / (1 + k * delay), data = d, start = list(A = max(d$v), k = 0.1), algorithm = "port", lower = c(A = 0, k = 0))
  } else {
    fit <- stats::nls(v ~ A * exp(-k * delay), data = d, start = list(A = max(d$v), k = 0.05), algorithm = "port", lower = c(A = 0, k = 0))
  }
  co <- stats::coef(fit)
  list(k = unname(co["k"]), A = unname(co["A"]), model = model, fitted = stats::fitted(fit))
}

#' Differentiation matrix across rules and paradigms
#'
#' Runs each rule on each paradigm and scores it in the unit interval, where 1 is
#' reward-maximizing and lower values indicate matching or suboptimal behavior.
#' The capstone instrument: it reads out where each learning rule sits on the
#' maximize-vs-meliorate axis.
#'
#' @param rules Registry keys.
#' @param paradigms Any of "prob_matching", "trap", "drl", "self_control".
#' @param n_steps Steps per (rule, paradigm) cell.
#' @param seed Seed.
#' @return A list with `long`, `wide`, and `classification` tibbles.
#' @export
#' @examples
#' \donttest{
#' differentiation_matrix(rules = c("q_learning", "melioration"), n_steps = 8000)
#' }
differentiation_matrix <- function(rules = c("q_learning", "expected_sarsa", "double_q", "actor_critic", "melioration", "melioration_rate", "win_stay_lose_shift"),
                                   paradigms = c("prob_matching", "trap", "drl", "self_control"), n_steps = 30000L, seed = 0L) {
  clamp <- function(z) min(max(z, 0), 1)
  score_cell <- function(nm, par) {
    if (par == "prob_matching") {
      probs <- c(0.75, 0.25)
      ag <- make_agent(nm, n_actions = 2L, horizon = n_steps)
      res <- run_continuing(prob_matching_task(probs), ag, constant_featurizer(), n_steps = n_steps, seed = seed)
      k <- as.integer(n_steps * 0.2)
      mean(res$actions[(n_steps - k + 1):n_steps] == which.max(probs))
    } else if (par == "trap") {
      e0 <- melioration_trap()
      opt <- e0$optimum()$rate_opt
      mat <- e0$matching_point()$rate_match
      ag <- make_agent(nm, n_actions = 2L, horizon = n_steps)
      res <- run_continuing(melioration_trap(), ag, interval_featurizer(n_bins = 20L), n_steps = n_steps, seed = seed)
      k <- as.integer(n_steps * 0.2)
      ach <- mean(res$rewards[(n_steps - k + 1):n_steps])
      clamp((ach - mat) / (opt - mat))
    } else if (par == "drl") {
      threshold <- 15L
      magnitude <- 1
      response_cost <- 0.02
      ag <- make_agent(nm, n_actions = 2L, horizon = n_steps)
      res <- run_continuing(drl_chamber(threshold, magnitude, response_cost), ag, discrete_featurizer(), n_steps = n_steps, seed = seed)
      k <- as.integer(n_steps * 0.2)
      ach <- mean(res$rewards[(n_steps - k + 1):n_steps])
      clamp(ach / ((magnitude - response_cost) / (threshold + 1)))
    } else if (par == "self_control") {
      feat <- discrete_featurizer()
      set.seed(seed)
      ag <- make_agent(nm, n_actions = 2L, horizon = n_steps)
      tbl <- make_table(2L)
      env <- self_control_env()
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
      mean(utils::tail(choices, 200L) == 2)
    } else {
      NA_real_
    }
  }
  long <- dplyr::bind_rows(lapply(rules, function(nm) {
    dplyr::bind_rows(lapply(paradigms, function(par) {
      tibble::tibble(rule = nm, kind = agent_kind(nm), paradigm = par, score = score_cell(nm, par))
    }))
  }))
  mat <- tapply(long$score, list(long$rule, long$paradigm), function(z) z[1])
  mat <- mat[rules, paradigms, drop = FALSE]
  wide <- tibble::as_tibble(cbind(rule = rownames(mat), as.data.frame(mat, stringsAsFactors = FALSE)))
  classification <- dplyr::bind_rows(lapply(rules, function(nm) {
    sc <- long$score[long$rule == nm]
    tibble::tibble(rule = nm, kind = agent_kind(nm), mean_score = mean(sc, na.rm = TRUE), label = classify_rule(mean(sc, na.rm = TRUE)))
  }))
  list(long = long, wide = wide, classification = classification)
}
