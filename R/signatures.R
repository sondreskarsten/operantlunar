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
    ~signature, ~glossary_term, ~agent, ~paradigm, ~shows, ~status, ~note,
    "Matching law", "Matching law", "melioration", "single VI lever (Herrnstein)",
    "Response rate rises with reinforcement rate along a hyperbola (Herrnstein's law).", "reproduced",
    "Single-alternative form; on concurrent VI-VI the melioration agent also matches.",
    "Melioration vs maximisation", "Maximisation vs melioration", "melioration vs q_learning", "melioration trap",
    "Melioration settles at the matching allocation (~0.8) and earns less than the optimum (~0.4) that the maximiser reaches.", "reproduced",
    "The core dissociation the package was built to show.",
    "Extinction", "Extinction", "q_learning", "operant chamber, reinforcement withdrawn",
    "Responding declines once reinforcement stops; behaviour acquired on leaner schedules is more resistant.", "reproduced",
    "Partial-reinforcement extinction effect visible across acquisition schedules.",
    "DRL (low-rate spacing)", "Variable-interval (VI)", "q_learning", "DRL chamber (IRT state)",
    "The agent learns to space responses, holding rate near 1/threshold to earn reinforcement.", "reproduced",
    "Requires the inter-response-time observation.",
    "Self-control / delay discounting", "Operant conditioning", "q_learning vs melioration", "self-control env",
    "The far-sighted agent chooses the large-later reward; the myopic agent stays impulsive.", "reproduced",
    "Model-based and Q-learning are self-controlled; gradient-bandit melioration is impulsive.",
    "FI temporal control", "Fixed-interval (FI)", "boltzmann_td", "FI chamber (elapsed-time state)",
    "Responding is withheld early in the interval and concentrated near/after its end (break-and-run).", "reproduced",
    "The smoothly graded biological scallop needs temporal generalisation a tabular agent lacks.",
    "Cumulative record (steady rate)", "Variable-ratio (VR)", "melioration", "single VR / FR lever",
    "Steady high-rate responding gives a straight, steep cumulative record.", "reproduced",
    "Ratio schedules sustain near-maximal responding when reinforcement exceeds response cost.",
    "VR vs VI rate difference", "Variable-ratio (VR)", "melioration", "single VR vs VI lever",
    "Classically VR sustains higher rates than VI.", "not reproduced",
    "Depends on the molar feedback function; a single-state agent cannot represent it.",
    "FR post-reinforcement pause", "Fixed-ratio (FR)", "melioration", "single FR lever",
    "Classically a pause follows each reinforcer before the ratio is run.", "not reproduced",
    "Pausing delays reinforcement, so a reward-maximiser does not pause; the pause is a ratio-strain quirk.",
    "Undermatching / changeover delay", "Changeover delay (COD)", "melioration", "concurrent VI-VI with COD",
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
