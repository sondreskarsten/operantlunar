#' Fixed-interval chamber with an elapsed-time observation
#'
#' A single-operandum FI schedule that exposes time since the last reinforcer as
#' the observation, so a value agent can bring responding under temporal control.
#' Actions: 1 = respond, 2 = withhold.
#'
#' @param interval Fixed interval in steps.
#' @param magnitude Reinforcement magnitude.
#' @param response_cost Cost per response.
#' @param cap Maximum elapsed value exposed as the observation.
#' @return An environment object with `reset` and `step`.
#' @export
#' @examples
#' ch <- fi_chamber(20)
#' ch$reset(seed = 0)
#' ch$step(1)
fi_chamber <- function(interval = 20, magnitude = 1, response_cost = 0.02, cap = NULL) {
  if (is.null(cap)) cap <- as.integer(2L * interval)
  st <- new.env(parent = emptyenv())
  st$elapsed <- 0L
  reset <- function(seed = NULL) {
    if (!is.null(seed)) set.seed(seed)
    st$elapsed <- 0L
    list(obs = 0)
  }
  step <- function(action) {
    st$elapsed <- st$elapsed + 1L
    r <- 0
    if (action == 1) {
      if (st$elapsed >= interval) {
        r <- magnitude
        st$elapsed <- 0L
      }
      r <- r - response_cost
    }
    list(obs = min(st$elapsed, cap), reward = r, terminated = FALSE, truncated = FALSE)
  }
  list(reset = reset, step = step, interval = interval)
}

#' Build a cumulative record
#'
#' The canonical operant plot's data: cumulative responses against step, with
#' reinforced steps flagged.
#'
#' @param actions Integer vector of actions (1 = respond).
#' @param rewards Optional reward vector; positive values flag reinforcers.
#' @return A tibble with `step`, `responses`, `reinforcer`.
#' @export
#' @examples
#' cumulative_record(c(1, 2, 1, 1), c(0, 0, 1, 0))
cumulative_record <- function(actions, rewards = NULL) {
  resp <- as.integer(actions == 1)
  tibble::tibble(
    step = seq_along(actions),
    responses = cumsum(resp),
    reinforcer = if (is.null(rewards)) rep(FALSE, length(actions)) else rewards > 0
  )
}

#' Cumulative record of an agent on a single-operandum schedule
#'
#' Trains an agent on a one-lever schedule, then returns the cumulative record of
#' a steady-state tail window.
#'
#' @param kind,param Schedule kind and parameter.
#' @param magnitude,response_cost Reinforcement magnitude and per-response cost.
#' @param agent Registry key for the agent.
#' @param n_steps Total steps.
#' @param window Tail window length for the record.
#' @param seed Seed.
#' @return A tibble cumulative record (see [cumulative_record()]).
#' @export
#' @examples
#' \donttest{
#' schedule_record_demo("VR", 10, n_steps = 4000)
#' }
schedule_record_demo <- function(kind = "VR", param = 10, magnitude = 1, response_cost = 0.02, agent = "melioration", n_steps = 6000L, window = 400L, seed = 0L) {
  ag <- make_agent(agent, n_actions = 2L, horizon = n_steps)
  env <- operant_chamber(schedule = make_schedule(kind, param), magnitude = magnitude, response_cost = response_cost)
  res <- run_continuing(env, ag, constant_featurizer(), n_steps = n_steps, seed = seed)
  idx <- (n_steps - window + 1):n_steps
  cumulative_record(res$actions[idx], res$rewards[idx])
}

#' Fixed-interval temporal-control demonstration
#'
#' Trains a softmax value agent on [fi_chamber()] and summarises responding as a
#' function of time since the last reinforcer. A reward-driven agent withholds
#' early and responds near/after the interval (break-and-run temporal control);
#' the smoothly graded biological scallop requires temporal generalisation that a
#' tabular agent lacks.
#'
#' @param interval Fixed interval in steps.
#' @param beta Softmax inverse temperature.
#' @param alpha,gamma Learning rate and discount.
#' @param response_cost Cost per response.
#' @param n_steps Total steps.
#' @param window Tail window for the summary.
#' @param seed Seed.
#' @return A list with `by_time` (tibble of response rate by elapsed time) and a
#'   `record` cumulative record.
#' @export
#' @examples
#' \donttest{
#' fi_temporal_demo(interval = 20, n_steps = 30000)
#' }
fi_temporal_demo <- function(interval = 20, beta = 6, alpha = 0.1, gamma = 0.99, response_cost = 0.15, n_steps = 30000L, window = 8000L, seed = 0L) {
  ag <- boltzmann_td_agent(alpha = alpha, gamma = gamma, beta = beta, n_actions = 2L)
  env <- fi_chamber(interval = interval, response_cost = response_cost)
  res <- run_continuing(env, ag, discrete_featurizer(), n_steps = n_steps, seed = seed)
  state_all <- c(0, res$xs[-length(res$xs)])
  idx <- (n_steps - window + 1):n_steps
  elapsed <- state_all[idx]
  responded <- as.integer(res$actions[idx] == 1)
  agg <- stats::aggregate(responded, by = list(elapsed = elapsed), FUN = mean)
  by_time <- tibble::tibble(elapsed = agg$elapsed, response_rate = agg$x)
  list(by_time = by_time[order(by_time$elapsed), ], record = cumulative_record(res$actions[idx], res$rewards[idx]), interval = interval)
}

#' Behavioral-signature registry
#'
#' Maps each operant phenomenon in [operant_glossary()] to the agent and paradigm
#' that demonstrate it, what the demonstration shows, and an honest status: a
#' reward-driven agent reproduces reward-rational signatures but not quirks that
#' depend on temporal generalisation, molar feedback, or non-optimal pausing.
#'
#' @return A tibble with `signature`, `glossary_term`, `agent`, `paradigm`,
#'   `shows`, `status`, `note`.
#' @export
#' @examples
#' behavioral_signatures()
behavioral_signatures <- function() {
  tibble::tribble(
    ~group, ~signature, ~glossary_term, ~agent, ~paradigm, ~shows, ~status, ~note,
    "Applied-robust core", "DRA / FCT reallocation", "Differential reinforcement of alternative behaviour (DRA)", "q_learning", "DRA chamber (baseline then treatment)",
    "When the problem response is put on extinction and an alternative is reinforced, behaviour reallocates from the problem response to the alternative.", "reproduced",
    "The contingency engine under DRA/FCT, the most robustly replicated applied effect. Reproduces the reallocation mechanism, not the clinical apparatus (no functional analysis, prompting, or programmed generalisation).",
    "Applied-robust core", "Extinction", "Extinction", "q_learning", "operant chamber, reinforcement withdrawn",
    "Responding declines once reinforcement stops; behaviour acquired on leaner schedules is more resistant.", "reproduced",
    "Extinction is a necessary component of DRA/FCT; the partial-reinforcement extinction effect is visible across acquisition schedules.",
    "Applied-robust core", "DRL (low-rate spacing)", "Variable-interval (VI)", "q_learning", "DRL chamber (IRT state)",
    "The agent learns to space responses, holding rate near 1/threshold to earn reinforcement.", "reproduced",
    "Requires the inter-response-time observation. Maps to clinical DRL for high-rate behaviour.",
    "Applied-robust core", "Self-control / delay discounting", "Operant conditioning", "q_learning vs melioration", "self-control env",
    "The far-sighted agent chooses the large-later reward; the myopic agent stays impulsive.", "reproduced",
    "Model-based and Q-learning are self-controlled; gradient-bandit melioration is impulsive. Behavioural-economic, increasingly applied.",
    "Basic-science (not applied-robust)", "Melioration vs maximisation", "Maximisation vs melioration", "melioration vs q_learning", "melioration trap",
    "Melioration settles at the matching allocation (~0.8) and earns less than the optimum (~0.4) that the maximiser reaches.", "reproduced",
    "The package's conceptual core; a basic-science choice phenomenon, not a robust applied effect.",
    "Basic-science (not applied-robust)", "Matching law", "Matching law", "melioration", "single VI lever (Herrnstein)",
    "Response rate rises with reinforcement rate along a hyperbola (Herrnstein's law).", "reproduced",
    "Robust in the lab; in applied settings mainly descriptive and needs adjunct procedures (changeover delays, timers) to appear orderly, not a robust prescriptive tool.",
    "Basic-science (not applied-robust)", "FI temporal control", "Fixed-interval (FI)", "boltzmann_td", "FI chamber (elapsed-time state)",
    "Responding is withheld early in the interval and concentrated near/after its end (break-and-run).", "reproduced",
    "The smoothly graded biological scallop needs temporal generalisation a tabular agent lacks.",
    "Basic-science (not applied-robust)", "Cumulative record (steady rate)", "Variable-ratio (VR)", "melioration", "single VR / FR lever",
    "Steady high-rate responding gives a straight, steep cumulative record.", "reproduced",
    "Ratio schedules sustain near-maximal responding when reinforcement exceeds response cost.",
    "Basic-science (not applied-robust)", "VR vs VI rate difference", "Variable-ratio (VR)", "melioration", "single VR vs VI lever",
    "Classically VR sustains higher rates than VI.", "not reproduced",
    "Depends on the molar feedback function; a single-state agent cannot represent it.",
    "Basic-science (not applied-robust)", "FR post-reinforcement pause", "Fixed-ratio (FR)", "melioration", "single FR lever",
    "Classically a pause follows each reinforcer before the ratio is run.", "not reproduced",
    "Pausing delays reinforcement, so a reward-maximiser does not pause; the pause is a ratio-strain quirk.",
    "Basic-science (not applied-robust)", "Undermatching / changeover delay", "Changeover delay (COD)", "melioration", "concurrent VI-VI with COD",
    "Changeover delays classically sharpen matching toward slope 1.", "partial",
    "A single-state gradient bandit does not capture the molecular switching mechanism."
  )
}

#' Plot a cumulative record
#'
#' @param cr A cumulative record from [cumulative_record()] or
#'   [schedule_record_demo()].
#' @param title Plot title.
#' @return A ggplot object.
#' @export
plot_cumulative_record <- function(cr, title = "Cumulative record") {
  ggplot2::ggplot(cr, ggplot2::aes(step, responses)) +
    ggplot2::geom_step(colour = "#3b7dd8") +
    ggplot2::geom_rug(data = cr[cr$reinforcer, , drop = FALSE], ggplot2::aes(x = step), sides = "b", colour = "firebrick", inherit.aes = FALSE) +
    ggplot2::labs(x = "step", y = "cumulative responses", title = title) +
    ggplot2::theme_minimal()
}

#' Plot fixed-interval temporal control
#'
#' Response rate as a function of time since the last reinforcer; the dashed line
#' marks the interval. A reward-driven agent withholds early and responds at the
#' boundary (break-and-run).
#'
#' @param demo Output of [fi_temporal_demo()].
#' @return A ggplot object.
#' @export
plot_fi_temporal <- function(demo) {
  ggplot2::ggplot(demo$by_time, ggplot2::aes(elapsed, response_rate)) +
    ggplot2::geom_line(colour = "#3b7dd8") +
    ggplot2::geom_point(colour = "#3b7dd8") +
    ggplot2::geom_vline(xintercept = demo$interval, linetype = "dashed", colour = "darkgreen") +
    ggplot2::labs(x = "time since last reinforcer (steps)", y = "P(respond)", title = "Fixed-interval temporal control") +
    ggplot2::ylim(0, 1) +
    ggplot2::theme_minimal()
}

#' Differential-reinforcement (DRA/FCT) chamber
#'
#' Two responses share one maintaining reinforcer. Action 1 is the problem
#' response, action 2 the appropriate alternative. `set_reinforced()` switches
#' which response currently produces the reinforcer, so a baseline (problem
#' reinforced) can be followed by treatment (alternative reinforced, problem on
#' extinction) — the contingency engine under DRA and functional communication
#' training.
#'
#' @param magnitude Reinforcement magnitude.
#' @param response_cost Cost per response.
#' @return An environment object with `reset`, `step`, and `set_reinforced`.
#' @export
#' @examples
#' ch <- dra_chamber()
#' ch$reset(seed = 0)
#' ch$step(1)
dra_chamber <- function(magnitude = 1, response_cost = 0) {
  st <- new.env(parent = emptyenv())
  st$reinforced <- 1L
  reset <- function(seed = NULL) {
    if (!is.null(seed)) set.seed(seed)
    list(obs = 0)
  }
  step <- function(action) {
    r <- if (action == st$reinforced) magnitude else 0
    r <- r - response_cost
    list(obs = 0, reward = r, terminated = FALSE, truncated = FALSE)
  }
  set_reinforced <- function(which) st$reinforced <- as.integer(which)
  list(reset = reset, step = step, set_reinforced = set_reinforced)
}

#' DRA / FCT reallocation demonstration
#'
#' Trains a reward-driven agent on [dra_chamber()] through a baseline phase (the
#' problem response is reinforced) and a treatment phase (the problem response is
#' put on extinction and an alternative response is reinforced), then summarises
#' the proportion of each response over time. Behaviour reallocates from the
#' problem to the alternative — the mechanism behind differential reinforcement
#' of an alternative behaviour.
#'
#' @param baseline,treatment Steps per phase.
#' @param agent Registry key for the agent.
#' @param magnitude Reinforcement magnitude.
#' @param window Window length for the proportion summary.
#' @param seed Seed.
#' @return A tibble with `window_mid`, `response`, `rate`, `switch_step`.
#' @export
#' @examples
#' \donttest{
#' dra_fct_demo()
#' }
dra_fct_demo <- function(baseline = 4000L, treatment = 8000L, agent = "q_learning", magnitude = 1, window = 300L, seed = 0L) {
  set.seed(seed)
  ag <- make_agent(agent, n_actions = 2L, horizon = baseline + treatment)
  env <- dra_chamber(magnitude = magnitude)
  feat <- constant_featurizer()
  tbl <- make_table(2L)
  n <- baseline + treatment
  acts <- integer(n)
  r0 <- env$reset(seed = seed)
  s <- feat(r0$obs)
  env$set_reinforced(1L)
  for (i in seq_len(n)) {
    if (i == baseline + 1L) env$set_reinforced(2L)
    a <- ag$select(tbl, s)
    o <- env$step(a)
    s2 <- feat(o$obs)
    ag$update(tbl, s, a, o$reward, s2, FALSE)
    acts[i] <- a
    s <- s2
  }
  g <- (seq_len(n) - 1L) %/% as.integer(window)
  mid <- tapply(seq_len(n), g, mean)
  prob <- tapply(as.integer(acts == 1L), g, mean)
  alt <- tapply(as.integer(acts == 2L), g, mean)
  tibble::tibble(
    window_mid = rep(as.numeric(mid), 2),
    response = rep(c("problem", "alternative"), each = length(mid)),
    rate = c(as.numeric(prob), as.numeric(alt)),
    switch_step = baseline
  )
}

#' Plot DRA / FCT reallocation
#'
#' @param demo Output of [dra_fct_demo()].
#' @return A ggplot object.
#' @export
plot_dra_fct <- function(demo) {
  ggplot2::ggplot(demo, ggplot2::aes(window_mid, rate, colour = response)) +
    ggplot2::geom_line() +
    ggplot2::geom_point(size = 1) +
    ggplot2::geom_vline(xintercept = demo$switch_step[1], linetype = "dashed", colour = "darkgreen") +
    ggplot2::scale_colour_manual(values = c(problem = "firebrick", alternative = "#3b7dd8")) +
    ggplot2::labs(x = "step", y = "response proportion", colour = NULL, title = "DRA / FCT: reallocation from problem to alternative (dashed = treatment onset)") +
    ggplot2::ylim(0, 1) +
    ggplot2::theme_minimal()
}
