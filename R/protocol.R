#' Stochastic functional-analysis channel environment
#'
#' A single-state engage/withhold environment (action 1 = engage, 2 = withhold)
#' whose engage response emits reinforcement on a hidden `true_function` channel
#' only probabilistically (`p_reinforce`), with occasional misfires onto a random
#' channel (`p_noise`). The stochasticity is deliberate: deterministic
#' contingencies make replication across subjects vacuous, so genuine
#' subject-to-subject variation (and occasional undifferentiated subjects)
#' requires within-condition randomness. Combine with [contingency_env()]: the
#' active channel determines which condition is in force.
#'
#' @param true_function Hidden maintaining channel.
#' @param arms Channels tested.
#' @param p_reinforce Probability an engage delivers the true-channel reinforcer.
#' @param p_noise Probability an engage misfires onto a uniformly random channel.
#' @param magnitude Reinforcer magnitude.
#' @param response_cost Cost per engage (makes withholding the default).
#' @return A channel environment with `reset`, `step`, `n_actions`, `arms`.
#' @export
fa_stochastic_env <- function(true_function = "escape", arms = c("attention", "escape", "tangible", "goal"),
                              p_reinforce = 0.8, p_noise = 0.05, magnitude = 1, response_cost = 0.1) {
  reset <- function(seed = NULL) {
    if (!is.null(seed)) set.seed(seed)
    list(obs = 0L)
  }
  step <- function(action) {
    engage <- action == 1L
    ch <- stats::setNames(rep(0, length(arms)), arms)
    if (engage) {
      if (stats::runif(1) < p_noise) ch[sample(arms, 1)] <- magnitude
      else if (stats::runif(1) < p_reinforce) ch[true_function] <- magnitude
    }
    base_r <- if (engage) -response_cost else 0
    list(obs = 0L, reward = base_r + sum(ch), terminated = FALSE, truncated = FALSE, base_reward = base_r, channels = ch)
  }
  list(reset = reset, step = step, n_actions = 2L, arms = arms)
}

#' Steady-state stability of a per-condition rate series
#'
#' A Sidman-tradition stability criterion applied to the last `k` sessions of
#' each condition's response-rate series: stable when there is no trend (the
#' first-half and second-half means of the window differ by at most `tol_trend`)
#' and bounce is bounded (the window range is at most `tol_bounce`), for every
#' condition. This is the endogenous stopping rule that replaces an arbitrary
#' fixed number of sessions.
#'
#' @param rates A tibble with `session`, `condition`, `rate`.
#' @param k Window length (most recent sessions).
#' @param tol_trend Maximum allowed half-split mean difference within the window.
#' @param tol_bounce Maximum allowed range within the window.
#' @return `TRUE` if every condition is stable over the last `k` sessions.
#' @export
stability_reached <- function(rates, k = 10L, tol_trend = 0.1, tol_bounce = 0.25) {
  conds <- unique(rates$condition)
  ok <- vapply(conds, function(cc) {
    v <- rates$rate[rates$condition == cc]
    if (length(v) < k) return(FALSE)
    w <- utils::tail(v, k)
    h <- as.integer(k / 2)
    trend <- abs(mean(utils::tail(w, h)) - mean(utils::head(w, h)))
    bounce <- diff(range(w))
    trend <= tol_trend && bounce <= tol_bounce
  }, logical(1))
  all(ok)
}

#' Criterion-line functional-analysis verdict (Hagopian et al., 1997)
#'
#' Applies the structured, reproducible interpretation rule from Hagopian et al.
#' (1997) (as described in Fisher et al., 2021): draw an upper and lower criterion
#' line one standard deviation above and below the control-condition mean; for
#' each test condition, count session points above the upper line minus points
#' below the lower line; the condition is differentiated when that difference is
#' at least half the number of data points. This replaces subjective visual
#' analysis with a fixed quantitative decision so the verdict is not a researcher
#' degree of freedom.
#'
#' @param last_k A tibble with `session`, `condition`, `rate` (the stabilised window).
#' @param arms Test channels.
#' @param control Control condition name.
#' @return A list with `verdict`, `differentiated`, `detail` (per-condition D and threshold).
#' @export
criterion_line_verdict <- function(last_k, arms = c("attention", "escape", "tangible", "goal"), control = "play") {
  ctrl <- last_k$rate[last_k$condition == control]
  m <- mean(ctrl)
  s <- stats::sd(ctrl)
  if (is.na(s)) s <- 0
  ucl <- m + s
  lcl <- m - s
  detail <- lapply(arms, function(cc) {
    v <- last_k$rate[last_k$condition == cc]
    n <- length(v)
    d <- sum(v > ucl) - sum(v < lcl)
    data.frame(condition = cc, n = n, D = d, threshold = ceiling(n / 2), differentiated = d >= ceiling(n / 2))
  })
  detail <- do.call(rbind, detail)
  diff_conds <- detail$condition[detail$differentiated]
  verdict <- if (length(diff_conds) == 0) "undifferentiated" else if (length(diff_conds) == 1) diff_conds else paste("multiple:", paste(diff_conds, collapse = "/"))
  list(verdict = verdict, differentiated = diff_conds, detail = tibble::as_tibble(detail), ucl = ucl, lcl = lcl)
}

#' One functional-analysis subject (multielement, trained to steady state)
#'
#' Runs a single synthetic subject (one `agent_seed`) through a multielement
#' functional analysis: conditions (the test channels plus a play control) are
#' presented in randomised order each session, each session yields one
#' response-rate data point per condition, and the agent learns condition-specific
#' responding across sessions. Sessions are added until the steady-state stability
#' criterion is met or `max_sessions` is reached; the verdict is read from the
#' stabilised window with the criterion-line rule. Non-stabilisation is reported
#' rather than forced into a reading.
#'
#' @param true_function Hidden maintaining channel.
#' @param arms Test channels.
#' @param agent Registry key for the agent.
#' @param agent_seed The subject's random seed (its identity).
#' @param session_len Trials per condition per session.
#' @param min_sessions,max_sessions Session bounds.
#' @param k Stabilised-window length read for the verdict.
#' @param tol_trend,tol_bounce Stability tolerances.
#' @param p_reinforce,p_noise,response_cost Environment stochasticity.
#' @return A list with `verdict`, `stable`, `n_sessions`, `rates`, `last_k`, `detail`.
#' @export
fa_subject <- function(true_function = "escape", arms = c("attention", "escape", "tangible", "goal"),
                       agent = "q_learning", agent_seed = 1L, session_len = 100L,
                       min_sessions = 20L, max_sessions = 60L, k = 10L, tol_trend = 0.1, tol_bounce = 0.25,
                       p_reinforce = 0.8, p_noise = 0.05, response_cost = 0.1) {
  set.seed(agent_seed)
  conds <- c(arms, "play")
  base <- fa_stochastic_env(true_function = true_function, arms = arms, p_reinforce = p_reinforce, p_noise = p_noise, response_cost = response_cost)
  env <- contingency_env(base, active = NULL)
  horizon <- as.integer(max_sessions * length(conds) * session_len / 2)
  ag <- make_agent(agent, n_actions = 2L, horizon = horizon)
  tbl <- make_table(2L)
  env$reset(seed = agent_seed)
  recs <- vector("list", max_sessions * length(conds))
  idx <- 0L
  n_sessions <- 0L
  stable <- FALSE
  for (sess in seq_len(max_sessions)) {
    n_sessions <- sess
    order <- sample(conds)
    for (cc in order) {
      env$set_active(if (cc == "play") character(0) else cc)
      eng <- 0L
      for (t in seq_len(session_len)) {
        a <- ag$select(tbl, cc)
        o <- env$step(a)
        ag$update(tbl, cc, a, o$reward, cc, TRUE)
        eng <- eng + (a == 1L)
      }
      idx <- idx + 1L
      recs[[idx]] <- data.frame(session = sess, condition = cc, rate = eng / session_len)
    }
    if (sess >= min_sessions) {
      rates_so_far <- tibble::as_tibble(do.call(rbind, recs[seq_len(idx)]))
      if (stability_reached(rates_so_far, k = k, tol_trend = tol_trend, tol_bounce = tol_bounce)) {
        stable <- TRUE
        break
      }
    }
  }
  rates <- tibble::as_tibble(do.call(rbind, recs[seq_len(idx)]))
  last_k <- do.call(rbind, lapply(conds, function(cc) {
    v <- rates[rates$condition == cc, ]
    utils::tail(v, k)
  }))
  last_k <- tibble::as_tibble(last_k)
  cl <- criterion_line_verdict(last_k, arms = arms, control = "play")
  list(verdict = cl$verdict, stable = stable, n_sessions = n_sessions, rates = rates, last_k = last_k, detail = cl$detail)
}

#' Replicated functional analysis to a reliability conclusion (no pooling)
#'
#' Runs many synthetic subjects (one per `agent_seed`), each individually
#' trained to steady state and given a criterion-line verdict, and adds subjects
#' until the reliability of the conclusion stabilises (the modal-verdict agreement
#' among stabilised subjects changes by at most `reliability_tol` over the last
#' `reliability_window` subjects) or `n_subjects` is reached. The conclusion is
#' the reliability summary, computed at read time from the per-subject verdicts:
#' response rates are never pooled across subjects, because averaging subjects who
#' differ manufactures a group function that no subject has. This is the
#' idiographic replication logic that replaces a single seed or best-of-K.
#'
#' @param true_function Hidden maintaining channel.
#' @param arms Test channels.
#' @param agent Registry key for the agent.
#' @param n_subjects Maximum subjects.
#' @param min_subjects Minimum before the reliability stopping rule applies.
#' @param reliability_window,reliability_tol Endogenous meta-stopping parameters.
#' @param seed0 Offset added to subject indices (so disjoint subject pools are possible).
#' @param session_len,min_sessions,max_sessions,k,tol_trend,tol_bounce Per-subject parameters.
#' @param p_reinforce,p_noise,response_cost Environment stochasticity.
#' @return A list with `subjects` (tibble), `summary` (tibble), `modal_verdict`, `agreement`.
#' @export
functional_analysis_replicated <- function(true_function = "escape", arms = c("attention", "escape", "tangible", "goal"),
                                            agent = "q_learning", n_subjects = 20L, min_subjects = 10L,
                                            reliability_window = 5L, reliability_tol = 0.1, seed0 = 0L,
                                            session_len = 100L, min_sessions = 20L, max_sessions = 50L, k = 10L,
                                            tol_trend = 0.1, tol_bounce = 0.25, p_reinforce = 0.3, p_noise = 0.05, response_cost = 0.1) {
  sf <- bandit_subject(true_function = true_function, arms = arms, agent = agent, session_len = session_len,
                       min_sessions = min_sessions, max_sessions = max_sessions, k = k, tol_trend = tol_trend, tol_bounce = tol_bounce,
                       p_reinforce = p_reinforce, p_noise = p_noise, response_cost = response_cost)
  replicate_to_reliability(sf, n_subjects = n_subjects, min_subjects = min_subjects,
                           reliability_window = reliability_window, reliability_tol = reliability_tol, seed0 = seed0)
}

#' Ad hoc functional analysis (the undisciplined pipeline)
#'
#' Deliberately reproduces the researcher degrees of freedom the protocol removes:
#' a fixed (often too small) number of sessions with no steady-state check
#' (exogenous stopping), a handful of seeds, and an arbitrary rule for collapsing
#' them to one verdict (`first` seed, `best` of K by differentiation magnitude,
#' `majority` vote without a reliability check, or `pool` which averages rates
#' across subjects). Its verdict is sensitive to these knobs; that sensitivity is
#' the point of comparison.
#'
#' @param true_function,arms,session_len,p_reinforce,p_noise,response_cost As elsewhere.
#' @param n_sessions Fixed session count (exogenous stopping).
#' @param n_seeds Seeds run.
#' @param keep Collapse rule: "first", "best", "majority", or "pool".
#' @param seed0 Seed offset.
#' @param k Verdict window (capped at `n_sessions`).
#' @return A single verdict string.
#' @export
adhoc_fa <- function(true_function = "escape", arms = c("attention", "escape", "tangible", "goal"),
                     n_sessions = 8L, n_seeds = 3L, keep = "first", seed0 = 0L, session_len = 100L, k = 10L,
                     p_reinforce = 0.3, p_noise = 0.05, response_cost = 0.1) {
  sf <- bandit_subject(true_function = true_function, arms = arms, session_len = session_len, k = k,
                       p_reinforce = p_reinforce, p_noise = p_noise, response_cost = response_cost)
  adhoc_collapse(sf, n_sessions = n_sessions, n_seeds = n_seeds, keep = keep, seed0 = seed0, arms = arms)
}

#' Two-pipelines convergence demonstration
#'
#' The headline validation of the protocol-as-method. It runs the undisciplined
#' [adhoc_fa()] across a grid of researcher choices (session count, seed count,
#' collapse rule, seed offset) and the disciplined [functional_analysis_replicated()]
#' across the same seed offsets, and reports the verdict each yields. The ad hoc
#' verdict varies with the knobs; the protocol verdict does not. The residual
#' variability of each is quantified as the number of distinct verdicts produced.
#'
#' @param true_function,arms Environment.
#' @param n_sessions_grid Session counts for the ad hoc pipeline.
#' @param n_seeds_grid Seed counts for the ad hoc pipeline.
#' @param keep_set Collapse rules for the ad hoc pipeline.
#' @param seed_offsets Seed offsets applied to both pipelines (subject-pool choice).
#' @param n_protocol_subjects Subject cap for the protocol pipeline.
#' @param p_reinforce,p_noise,response_cost,session_len Environment/run parameters.
#' @return A list with `results` (tibble), `adhoc_distinct`, `protocol_distinct`, `protocol_verdict`.
#' @export
convergence_demo <- function(true_function = "escape", arms = c("attention", "escape", "tangible", "goal"),
                             n_sessions_grid = c(6L, 10L, 20L), n_seeds_grid = c(1L, 3L), keep_set = c("first", "best", "pool"),
                             seed_offsets = c(0L, 100L, 200L), n_protocol_subjects = 16L,
                             p_reinforce = 0.3, p_noise = 0.05, response_cost = 0.1, session_len = 100L) {
  sf <- bandit_subject(true_function = true_function, arms = arms, session_len = session_len,
                       p_reinforce = p_reinforce, p_noise = p_noise, response_cost = response_cost)
  convergence_grid(sf, arms = arms, n_sessions_grid = n_sessions_grid, n_seeds_grid = n_seeds_grid,
                   keep_set = keep_set, seed_offsets = seed_offsets, n_protocol_subjects = n_protocol_subjects)
}

replicate_to_reliability <- function(subject_fn, n_subjects = 20L, min_subjects = 10L,
                                     reliability_window = 5L, reliability_tol = 0.1, seed0 = 0L) {
  rows <- vector("list", n_subjects)
  agree_series <- numeric(0)
  used <- 0L
  for (i in seq_len(n_subjects)) {
    used <- i
    s <- subject_fn(seed0 + i, NULL)
    rows[[i]] <- data.frame(subject = i, verdict = s$verdict, stable = s$stable, n_sessions = s$n_sessions, stringsAsFactors = FALSE)
    if (i >= min_subjects) {
      sofar <- do.call(rbind, rows[seq_len(i)])
      st <- sofar[sofar$stable, ]
      a <- if (nrow(st) == 0) 0 else max(table(st$verdict)) / nrow(st)
      agree_series <- c(agree_series, a)
      if (length(agree_series) >= reliability_window && diff(range(utils::tail(agree_series, reliability_window))) <= reliability_tol) break
    }
  }
  subjects <- tibble::as_tibble(do.call(rbind, rows[seq_len(used)]))
  st <- subjects[subjects$stable, ]
  dist <- as.data.frame(table(st$verdict), stringsAsFactors = FALSE)
  names(dist) <- c("verdict", "n")
  dist$proportion <- if (nrow(st) == 0) numeric(0) else dist$n / nrow(st)
  modal <- if (nrow(st) == 0) "non-stabilization" else dist$verdict[which.max(dist$n)]
  agreement <- if (nrow(st) == 0) 0 else max(dist$n) / nrow(st)
  summary <- tibble::tibble(
    n_subjects = used, n_stable = nrow(st),
    non_stabilization_rate = mean(!subjects$stable),
    modal_verdict = modal, agreement = agreement,
    undifferentiated_rate = if (nrow(st) == 0) NA_real_ else mean(st$verdict == "undifferentiated")
  )
  list(subjects = subjects, summary = summary, distribution = tibble::as_tibble(dist), modal_verdict = modal, agreement = agreement)
}

adhoc_collapse <- function(subject_fn, n_sessions = 8L, n_seeds = 3L, keep = "first", seed0 = 0L,
                           arms = c("attention", "escape", "tangible", "goal")) {
  subs <- lapply(seq_len(n_seeds), function(i) subject_fn(seed0 + i, n_sessions))
  if (keep == "first") return(subs[[1]]$verdict)
  if (keep == "best") return(subs[[which.max(vapply(subs, function(s) max(s$detail$D), numeric(1)))]]$verdict)
  if (keep == "majority") {
    v <- vapply(subs, function(s) s$verdict, character(1))
    return(names(which.max(table(v))))
  }
  lk <- do.call(rbind, lapply(subs, function(s) {
    s$last_k$rank <- stats::ave(s$last_k$session, s$last_k$condition, FUN = seq_along)
    s$last_k
  }))
  pooled <- stats::aggregate(rate ~ condition + rank, data = lk, FUN = mean)
  pooled$session <- pooled$rank
  criterion_line_verdict(tibble::as_tibble(pooled[, c("session", "condition", "rate")]), arms = arms, control = "play")$verdict
}

convergence_grid <- function(subject_fn, arms = c("attention", "escape", "tangible", "goal"),
                             n_sessions_grid = c(6L, 10L, 20L), n_seeds_grid = c(1L, 3L), keep_set = c("first", "best", "pool"),
                             seed_offsets = c(0L, 100L, 200L), n_protocol_subjects = 16L) {
  ah <- list()
  for (ns in n_sessions_grid) for (nse in n_seeds_grid) for (kp in keep_set) for (so in seed_offsets) {
    v <- adhoc_collapse(subject_fn, n_sessions = ns, n_seeds = nse, keep = kp, seed0 = so, arms = arms)
    ah[[length(ah) + 1L]] <- data.frame(pipeline = "ad hoc", n_sessions = ns, n_seeds = nse, keep = kp, seed_offset = so, verdict = v, stringsAsFactors = FALSE)
  }
  pr <- list()
  for (so in seed_offsets) {
    r <- replicate_to_reliability(subject_fn, n_subjects = n_protocol_subjects, seed0 = so)
    pr[[length(pr) + 1L]] <- data.frame(pipeline = "protocol", n_sessions = NA_integer_, n_seeds = r$summary$n_subjects, keep = "replicate", seed_offset = so, verdict = r$modal_verdict, stringsAsFactors = FALSE)
  }
  results <- tibble::as_tibble(rbind(do.call(rbind, ah), do.call(rbind, pr)))
  list(
    results = results,
    adhoc_distinct = length(unique(results$verdict[results$pipeline == "ad hoc"])),
    protocol_distinct = length(unique(results$verdict[results$pipeline == "protocol"])),
    protocol_verdict = unique(results$verdict[results$pipeline == "protocol"])
  )
}

bandit_subject <- function(true_function = "escape", arms = c("attention", "escape", "tangible", "goal"),
                           agent = "q_learning", session_len = 100L, min_sessions = 20L, max_sessions = 50L, k = 10L,
                           tol_trend = 0.1, tol_bounce = 0.25, p_reinforce = 0.3, p_noise = 0.05, response_cost = 0.1) {
  function(agent_seed, n_sessions = NULL) {
    if (is.null(n_sessions)) {
      fa_subject(true_function = true_function, arms = arms, agent = agent, agent_seed = agent_seed,
                 session_len = session_len, min_sessions = min_sessions, max_sessions = max_sessions, k = k,
                 tol_trend = tol_trend, tol_bounce = tol_bounce, p_reinforce = p_reinforce, p_noise = p_noise, response_cost = response_cost)
    } else {
      fa_subject(true_function = true_function, arms = arms, agent = agent, agent_seed = agent_seed,
                 session_len = session_len, min_sessions = n_sessions, max_sessions = n_sessions, k = min(k, n_sessions),
                 tol_trend = tol_trend, tol_bounce = tol_bounce, p_reinforce = p_reinforce, p_noise = p_noise, response_cost = response_cost)
    }
  }
}

gridworld_subject <- function(true_function = "escape", arms = c("attention", "escape", "tangible", "goal"),
                              env_seed = 1L, episodes_per_session = 20L, min_sessions = 25L, max_sessions = 70L, k = 10L,
                              tol_trend = 0.12, tol_bounce = 0.3, max_steps = 40L, size = 5L, n_walls = 4L, slip = 0.05, step_cost = 0.04) {
  function(agent_seed, n_sessions = NULL) {
    fa_subject_gridworld(true_function = true_function, arms = arms, env_seed = env_seed, agent_seed = agent_seed,
                         n_sessions = n_sessions, episodes_per_session = episodes_per_session, min_sessions = min_sessions,
                         max_sessions = max_sessions, k = k, tol_trend = tol_trend, tol_bounce = tol_bounce,
                         max_steps = max_steps, size = size, n_walls = n_walls, slip = slip, step_cost = step_cost)
  }
}

#' Replicated gridworld functional analysis to a reliability conclusion
#'
#' [functional_analysis_replicated()] on the procedural gridworld: a fixed
#' apparatus (`env_seed`) with subjects (`agent_seed`s) replicated to a reliability
#' conclusion, each trained to steady state. Navigation makes the per-subject
#' identification genuinely effortful, so the reliability summary is informative
#' rather than trivially unanimous.
#'
#' @param true_function,arms,env_seed,episodes_per_session,min_sessions,max_sessions,k,max_steps,size,n_walls,slip,step_cost Gridworld subject parameters.
#' @param n_subjects,min_subjects,reliability_window,reliability_tol,seed0 Replication parameters.
#' @return The list returned by [functional_analysis_replicated()].
#' @export
functional_analysis_replicated_gridworld <- function(true_function = "escape", arms = c("attention", "escape", "tangible", "goal"),
                                                      env_seed = 1L, episodes_per_session = 20L, min_sessions = 25L, max_sessions = 45L, k = 10L,
                                                      max_steps = 40L, size = 6L, n_walls = 6L, slip = 0.05, step_cost = 0.04,
                                                      n_subjects = 16L, min_subjects = 8L, reliability_window = 4L, reliability_tol = 0.1, seed0 = 0L) {
  sf <- gridworld_subject(true_function = true_function, arms = arms, env_seed = env_seed, episodes_per_session = episodes_per_session,
                          min_sessions = min_sessions, max_sessions = max_sessions, k = k, max_steps = max_steps,
                          size = size, n_walls = n_walls, slip = slip, step_cost = step_cost)
  replicate_to_reliability(sf, n_subjects = n_subjects, min_subjects = min_subjects, reliability_window = reliability_window, reliability_tol = reliability_tol, seed0 = seed0)
}

#' Two-pipelines convergence demonstration on the procedural gridworld
#'
#' The headline demonstration on the navigation substrate. Because navigation is
#' slow to learn, an ad hoc pipeline with an arbitrary session budget reaches a
#' conclusion that depends on that budget (under-trained subjects look
#' undifferentiated), while the protocol's steady-state stopping detects
#' non-convergence and keeps training, so its verdict is invariant to the budget
#' and seed pool. The apparatus (`env_seed`) is held constant across both.
#'
#' @param true_function,arms,env_seed,episodes_per_session,max_steps,size,n_walls,slip,step_cost Gridworld parameters.
#' @param n_sessions_grid,n_seeds_grid,keep_set,seed_offsets,n_protocol_subjects Grid of researcher choices.
#' @param min_sessions,max_sessions,k Protocol steady-state parameters.
#' @return The list returned by the internal grid runner: `results`, `adhoc_distinct`, `protocol_distinct`, `protocol_verdict`.
#' @export
convergence_demo_gridworld <- function(true_function = "escape", arms = c("attention", "escape", "tangible", "goal"),
                                       env_seed = 1L, episodes_per_session = 15L, max_steps = 40L, size = 6L, n_walls = 6L, slip = 0.05, step_cost = 0.04,
                                       n_sessions_grid = c(12L, 28L), n_seeds_grid = c(1L, 3L), keep_set = c("first", "pool"),
                                       seed_offsets = c(0L, 50L, 100L), n_protocol_subjects = 12L,
                                       min_sessions = 22L, max_sessions = 45L, k = 10L) {
  sf <- gridworld_subject(true_function = true_function, arms = arms, env_seed = env_seed, episodes_per_session = episodes_per_session,
                          min_sessions = min_sessions, max_sessions = max_sessions, k = k, max_steps = max_steps,
                          size = size, n_walls = n_walls, slip = slip, step_cost = step_cost)
  convergence_grid(sf, arms = arms, n_sessions_grid = n_sessions_grid, n_seeds_grid = n_seeds_grid, keep_set = keep_set,
                   seed_offsets = seed_offsets, n_protocol_subjects = n_protocol_subjects)
}

#' Contingency-sensitivity (reversal) probe
#'
#' Trains one subject to steady state under a baseline contingency (engage
#' reinforced under the `true_function` discriminative stimulus), then reverses
#' the contingency so engage is reinforced under the `reversal_function`
#' stimulus instead, and measures whether behaviour tracks the change while
#' learning continues. Behaviour that re-allocates to the new contingency is
#' contingency-sensitive; behaviour that perseveres on the old stimulus is
#' insensitive, the signature of a policy that no longer tracks its environment
#' (off-distribution brittleness). This is the ABAB reversal logic applied to a
#' synthetic subject.
#'
#' @param true_function Baseline maintaining stimulus.
#' @param reversal_function Post-reversal maintaining stimulus.
#' @param arms Channels.
#' @param agent_seed Subject seed.
#' @param session_len Trials per condition per session.
#' @param train_sessions,probe_sessions Baseline and reversal session counts.
#' @param k Window read for post-reversal rates.
#' @param p_reinforce,p_noise,response_cost Environment stochasticity.
#' @return A list with `rates` (tibble with `phase`), `tracked`, `summary`.
#' @export
reversal_probe <- function(true_function = "escape", reversal_function = "attention", arms = c("attention", "escape", "tangible", "goal"),
                           agent_seed = 1L, session_len = 100L, train_sessions = 25L, probe_sessions = 15L, k = 10L,
                           p_reinforce = 0.8, p_noise = 0.05, response_cost = 0.1) {
  set.seed(agent_seed)
  conds <- c(arms, "play")
  horizon <- as.integer((train_sessions + probe_sessions) * length(conds) * session_len / 2)
  ag <- make_agent("q_learning", n_actions = 2L, horizon = horizon)
  tbl <- make_table(2L)
  run_phase <- function(env, n_sessions, start_sess) {
    recs <- vector("list", n_sessions * length(conds))
    idx <- 0L
    for (s in seq_len(n_sessions)) {
      for (cc in sample(conds)) {
        env$set_active(if (cc == "play") character(0) else cc)
        eng <- 0L
        for (t in seq_len(session_len)) {
          a <- ag$select(tbl, cc)
          o <- env$step(a)
          ag$update(tbl, cc, a, o$reward, cc, TRUE)
          eng <- eng + (a == 1L)
        }
        idx <- idx + 1L
        recs[[idx]] <- data.frame(session = start_sess + s, condition = cc, rate = eng / session_len)
      }
    }
    do.call(rbind, recs[seq_len(idx)])
  }
  envA <- contingency_env(fa_stochastic_env(true_function = true_function, arms = arms, p_reinforce = p_reinforce, p_noise = p_noise, response_cost = response_cost), active = NULL)
  pa <- run_phase(envA, train_sessions, 0L)
  envB <- contingency_env(fa_stochastic_env(true_function = reversal_function, arms = arms, p_reinforce = p_reinforce, p_noise = p_noise, response_cost = response_cost), active = NULL)
  pb <- run_phase(envB, probe_sessions, train_sessions)
  rates <- tibble::as_tibble(rbind(cbind(phase = "A:baseline", pa), cbind(phase = "B:reversal", pb)))
  old_post <- mean(utils::tail(pb$rate[pb$condition == true_function], k))
  new_post <- mean(utils::tail(pb$rate[pb$condition == reversal_function], k))
  tracked <- new_post > 0.5 && old_post < 0.5
  summary <- tibble::tibble(
    condition_old = true_function, condition_new = reversal_function,
    old_pre = mean(pa$rate[pa$condition == true_function]), old_post = old_post,
    new_pre = mean(pa$rate[pa$condition == reversal_function]), new_post = new_post, tracked = tracked
  )
  list(rates = rates, tracked = tracked, summary = summary)
}

#' Apparatus (env_seed) versus subject (agent_seed) demonstration
#'
#' Crosses several layout seeds with several agent seeds on the procedural
#' gridworld and reports each subject's verdict, stability, and sessions to
#' steady state. The env_seed is a setting variable: it changes the apparatus
#' (path lengths, wall placement) and therefore systematically shifts difficulty
#' (sessions to stability), whereas the agent_seed indexes interchangeable
#' subjects within an apparatus. Holding these on separate grains is what keeps
#' a non-influential seed out of scope and prevents pooling subjects who differ.
#'
#' @param true_function,arms Environment.
#' @param env_seeds Layout seeds (apparatus).
#' @param agent_seeds Subject seeds.
#' @param episodes_per_session,min_sessions,max_sessions,k,max_steps,size,n_walls,slip,step_cost Gridworld parameters.
#' @return A tibble with `env_seed`, `agent_seed`, `verdict`, `stable`, `n_sessions`.
#' @export
env_vs_agent_demo <- function(true_function = "escape", arms = c("attention", "escape", "tangible", "goal"),
                              env_seeds = 1:4, agent_seeds = 1:4, episodes_per_session = 15L, min_sessions = 22L, max_sessions = 50L,
                              k = 10L, max_steps = 40L, size = 6L, n_walls = 6L, slip = 0.05, step_cost = 0.04) {
  grid <- expand.grid(env_seed = env_seeds, agent_seed = agent_seeds)
  res <- lapply(seq_len(nrow(grid)), function(i) {
    s <- fa_subject_gridworld(true_function = true_function, arms = arms, env_seed = grid$env_seed[i], agent_seed = grid$agent_seed[i],
                              episodes_per_session = episodes_per_session, min_sessions = min_sessions, max_sessions = max_sessions, k = k,
                              max_steps = max_steps, size = size, n_walls = n_walls, slip = slip, step_cost = step_cost)
    data.frame(env_seed = grid$env_seed[i], agent_seed = grid$agent_seed[i], verdict = s$verdict, stable = s$stable, n_sessions = s$n_sessions)
  })
  tibble::as_tibble(do.call(rbind, res))
}

#' Plot a two-pipelines convergence demonstration
#'
#' Visualises the verdict distribution of each pipeline across the grid of
#' researcher choices. The ad hoc facet spreads across multiple verdicts; the
#' protocol facet concentrates on one. The asymmetry is the result.
#'
#' @param demo The list returned by [convergence_demo_gridworld()] or [convergence_demo()].
#' @return A ggplot object.
#' @export
plot_convergence <- function(demo) {
  ggplot2::ggplot(demo$results, ggplot2::aes(x = verdict, fill = pipeline)) +
    ggplot2::geom_bar() +
    ggplot2::facet_wrap(~pipeline, ncol = 1, scales = "free_y") +
    ggplot2::coord_flip() +
    ggplot2::labs(
      title = "Conclusion stability: ad hoc versus protocol",
      subtitle = sprintf("ad hoc: %d distinct verdicts across knobs; protocol: %d", demo$adhoc_distinct, demo$protocol_distinct),
      x = "verdict", y = "runs"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "none")
}
