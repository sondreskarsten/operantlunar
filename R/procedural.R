#' Procedural-layout gridworld (env_seed sets the apparatus)
#'
#' A navigation environment whose layout — start cell, the location of each
#' channel's reward source, and the walls — is fixed by `env_seed`. This makes
#' the env_seed a genuine setting variable (the apparatus / contours), distinct
#' from an agent's exploration seed (the subject). Reaching a source terminates
#' the episode and emits that source's channel (gated by [contingency_env()]);
#' moving costs `step_cost`; a stay action costs nothing, so under a no-channel
#' control the agent's best policy is to stay and reach no source. Navigation is
#' slow to learn, which is the point: it makes "trained too little" a real
#' source of unreliable conclusions. The channels are the candidate functions —
#' the agent's own reward sources, not an imported four-function taxonomy.
#'
#' @param env_seed Seed fixing the layout (the apparatus).
#' @param size Grid side length.
#' @param arms Channel names, one source each.
#' @param n_walls Number of wall cells.
#' @param slip Probability an action is replaced by a random one.
#' @param magnitude Source reinforcement magnitude.
#' @param step_cost Cost per executed move (stay is free).
#' @return A channel environment with `reset`, `step`, `n_actions`, `arms`, `n_states`, `source_cell`, `start`, `walls`, `size`.
#' @export
procedural_gridworld <- function(env_seed = 1L, size = 5L, arms = c("attention", "escape", "tangible", "goal"),
                                 n_walls = 4L, slip = 0.05, magnitude = 1, step_cost = 0.04) {
  set.seed(env_seed)
  K <- length(arms)
  ncell <- size * size
  picks <- sample(ncell, K + 1L + n_walls)
  start <- picks[1]
  src <- picks[1L + seq_len(K)]
  names(src) <- arms
  walls <- if (n_walls > 0) picks[(K + 2L):(K + 1L + n_walls)] else integer(0)
  st <- new.env(parent = emptyenv())
  reset <- function(seed = NULL) {
    if (!is.null(seed)) set.seed(seed)
    st$cell <- start
    list(obs = start)
  }
  step <- function(action) {
    a <- as.integer(action)
    if (stats::runif(1) < slip) a <- sample.int(5L, 1L)
    r <- ((st$cell - 1L) %/% size) + 1L
    co <- ((st$cell - 1L) %% size) + 1L
    nr <- r
    nco <- co
    moved <- TRUE
    if (a == 1L) nr <- r - 1L else if (a == 2L) nr <- r + 1L else if (a == 3L) nco <- co - 1L else if (a == 4L) nco <- co + 1L else moved <- FALSE
    if (nr < 1L || nr > size || nco < 1L || nco > size) {
      nr <- r
      nco <- co
      moved <- FALSE
    }
    nidx <- (nr - 1L) * size + nco
    if (nidx %in% walls) {
      nidx <- st$cell
      moved <- FALSE
    }
    st$cell <- nidx
    ch <- stats::setNames(rep(0, K), arms)
    hit <- which(src == nidx)
    term <- length(hit) == 1L
    if (term) ch[arms[hit]] <- magnitude
    base_r <- if (moved) -step_cost else 0
    list(obs = nidx, reward = base_r + sum(ch), terminated = term, truncated = FALSE, base_reward = base_r, channels = ch)
  }
  list(reset = reset, step = step, n_actions = 5L, arms = arms, n_states = ncell, source_cell = src, start = start, walls = walls, size = size)
}

gridworld_session_rate <- function(env, ag, tbl, target_arm, cond, episodes, max_steps, base_seed) {
  reached <- 0L
  for (ep in seq_len(episodes)) {
    set.seed(base_seed + ep)
    r0 <- env$reset(seed = base_seed + ep)
    s <- paste0(cond, ":", r0$obs)
    steps <- 0L
    repeat {
      a <- ag$select(tbl, s)
      o <- env$step(a)
      s2 <- paste0(cond, ":", o$obs)
      ag$update(tbl, s, a, o$reward, s2, o$terminated)
      s <- s2
      steps <- steps + 1L
      if (isTRUE(o$terminated)) {
        hit <- which(o$channels > 0)
        if (length(hit) == 1L && env$arms[hit] == target_arm) reached <- reached + 1L
        break
      }
      if (steps >= max_steps) break
    }
  }
  reached / episodes
}

#' One functional-analysis subject on the procedural gridworld
#'
#' The gridworld analogue of [fa_subject()]: a single subject (one `agent_seed`)
#' at a fixed `env_seed` (the apparatus held constant, as a real functional
#' analysis holds the chamber constant across replications). Conditions (each
#' channel active, plus a play control) alternate by session; each session's data
#' point is the proportion of episodes that reach the target source (the source
#' tied to `true_function`). Reaching the target is reinforced only when its
#' channel is active, so the target-reach rate is elevated only under the
#' maintaining condition. Sessions are added until steady state or `max_sessions`;
#' the verdict uses the criterion-line rule.
#'
#' @param true_function Hidden maintaining channel.
#' @param arms Channels.
#' @param env_seed Layout seed (apparatus).
#' @param agent_seed Subject seed.
#' @param n_sessions If non-NULL, run exactly this many sessions (exogenous stopping); else steady-state.
#' @param episodes_per_session Episodes per condition per session.
#' @param min_sessions,max_sessions Session bounds for steady-state mode.
#' @param k Stabilised-window length.
#' @param tol_trend,tol_bounce Stability tolerances.
#' @param max_steps Step cap per episode.
#' @param size,n_walls,slip,step_cost Environment parameters.
#' @return A list with `verdict`, `stable`, `n_sessions`, `rates`, `last_k`, `detail`.
#' @export
fa_subject_gridworld <- function(true_function = "escape", arms = c("attention", "escape", "tangible", "goal"),
                                 env_seed = 1L, agent_seed = 1L, n_sessions = NULL, episodes_per_session = 20L,
                                 min_sessions = 25L, max_sessions = 70L, k = 10L, tol_trend = 0.12, tol_bounce = 0.3,
                                 max_steps = 40L, size = 5L, n_walls = 4L, slip = 0.05, step_cost = 0.04) {
  set.seed(agent_seed)
  conds <- c(arms, "play")
  base <- procedural_gridworld(env_seed = env_seed, size = size, arms = arms, n_walls = n_walls, slip = slip, step_cost = step_cost)
  env <- contingency_env(base, active = NULL)
  fixed <- !is.null(n_sessions)
  cap <- if (fixed) as.integer(n_sessions) else max_sessions
  kk <- if (fixed) min(k, as.integer(n_sessions)) else k
  horizon <- as.integer(cap * length(conds) * episodes_per_session * max_steps / 2)
  ag <- make_agent("q_learning", n_actions = 5L, horizon = horizon)
  tbl <- make_table(5L)
  recs <- vector("list", cap * length(conds))
  idx <- 0L
  n_done <- 0L
  stable <- FALSE
  for (sess in seq_len(cap)) {
    n_done <- sess
    for (cc in sample(conds)) {
      env$set_active(if (cc == "play") character(0) else cc)
      rate <- gridworld_session_rate(env, ag, tbl, target_arm = true_function, cond = cc,
                                      episodes = episodes_per_session, max_steps = max_steps, base_seed = agent_seed * 100000L + sess * 100L)
      idx <- idx + 1L
      recs[[idx]] <- data.frame(session = sess, condition = cc, rate = rate)
    }
    if (!fixed && sess >= min_sessions) {
      rsf <- tibble::as_tibble(do.call(rbind, recs[seq_len(idx)]))
      if (stability_reached(rsf, k = k, tol_trend = tol_trend, tol_bounce = tol_bounce)) {
        stable <- TRUE
        break
      }
    }
  }
  rates <- tibble::as_tibble(do.call(rbind, recs[seq_len(idx)]))
  if (fixed) stable <- TRUE
  last_k <- tibble::as_tibble(do.call(rbind, lapply(conds, function(cc) utils::tail(rates[rates$condition == cc, ], kk))))
  cl <- criterion_line_verdict(last_k, arms = arms, control = "play")
  list(verdict = cl$verdict, stable = stable, n_sessions = n_done, rates = rates, last_k = last_k, detail = cl$detail)
}
