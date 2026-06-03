#' Contingency wrapper for any reinforcement environment
#'
#' Wraps a base environment whose `step` returns a named numeric `channels`
#' vector (and optional `base_reward`) and recomputes scalar reward as
#' `base_reward + sum(channels[active])`. `set_active()` selects which
#' reinforcement contingencies are in force, which is how the ABA instruments
#' manipulate the contingency on a Gymnasium-style environment.
#'
#' @param base_env An environment returning `channels` from `step`.
#' @param active Active channel names; `NULL` means all channels.
#' @return An environment object with `reset`, `step`, `set_active`, `active_channels`.
#' @export
#' @examples
#' env <- contingency_env(fa_channel_env("escape"), active = "escape")
#' env$reset(seed = 0)
#' env$step(1)
contingency_env <- function(base_env, active = NULL) {
  st <- new.env(parent = emptyenv())
  st$active <- active
  reset <- function(seed = NULL) base_env$reset(seed = seed)
  step <- function(action) {
    o <- base_env$step(action)
    ch <- o$channels
    if (is.null(ch)) stop("contingency_env requires the base env's step() to return `channels`")
    act <- if (is.null(st$active)) names(ch) else st$active
    base_r <- if (is.null(o$base_reward)) 0 else o$base_reward
    r <- base_r + sum(ch[intersect(names(ch), act)])
    list(obs = o$obs, reward = r, terminated = o$terminated, truncated = o$truncated, channels = ch)
  }
  set_active <- function(active) st$active <- active
  active_channels <- function() st$active
  c(list(reset = reset, step = step, set_active = set_active, active_channels = active_channels),
    base_env[setdiff(names(base_env), c("reset", "step"))])
}

#' Expose a single-reward environment as a one-channel environment
#'
#' Wraps a plain `reward`-returning environment (e.g. [make_gym()]) so its scalar
#' reward becomes a single named channel, making it usable with
#' [contingency_env()] (and therefore with the gym instruments).
#'
#' @param env A `reset`/`step` environment returning scalar `reward`.
#' @param channel Channel name.
#' @return An environment whose `step` returns `channels` and `base_reward`.
#' @export
as_channel_env <- function(env, channel = "task") {
  step <- function(action) {
    o <- env$step(action)
    list(obs = o$obs, reward = o$reward, terminated = o$terminated, truncated = o$truncated,
         base_reward = 0, channels = stats::setNames(o$reward, channel))
  }
  c(list(reset = env$reset, step = step), env[setdiff(names(env), c("reset", "step"))])
}

#' Functional-analysis channel environment
#'
#' One target response (action 1 = engage, 2 = withhold) on a single state.
#' Engaging emits reinforcement on the hidden `true_function` channel and incurs
#' a response cost; withholding does nothing. Combined with [contingency_env()],
#' engaging pays only when `true_function` is the active channel, so differential
#' responding across conditions reveals the function.
#'
#' @param true_function Hidden maintaining channel.
#' @param arms Channel names tested.
#' @param magnitude Reinforcement magnitude.
#' @param response_cost Cost per engage.
#' @return A channel environment with `reset`, `step`.
#' @export
fa_channel_env <- function(true_function = "escape", arms = c("attention", "escape", "tangible", "goal"), magnitude = 1, response_cost = 0.1) {
  reset <- function(seed = NULL) {
    if (!is.null(seed)) set.seed(seed)
    list(obs = 0L)
  }
  step <- function(action) {
    engage <- action == 1L
    ch <- stats::setNames(rep(0, length(arms)), arms)
    if (engage) ch[true_function] <- magnitude
    base_r <- if (engage) -response_cost else 0
    list(obs = 0L, reward = base_r + sum(ch), terminated = FALSE, truncated = FALSE, base_reward = base_r, channels = ch)
  }
  list(reset = reset, step = step, n_actions = 2L, arms = arms)
}

#' Composite-reward gridworld (Gymnasium-style)
#'
#' A hub-and-spoke navigation task: from the hub, each action commits toward one
#' arm; staying on an arm advances to its end, choosing another arm retreats.
#' Reaching an arm's end terminates the episode and emits that arm's
#' reinforcement channel; every step costs `step_cost`. With [contingency_env()]
#' the active channel determines which arm pays, so the agent navigates to the
#' reinforced arm.
#'
#' @param arms Channel names, one per arm.
#' @param corridor Steps from hub to an arm end.
#' @param magnitude Terminal reinforcement magnitude.
#' @param step_cost Per-step cost (always applied).
#' @return A channel environment with `reset`, `step`, `n_actions`, `arms`, `n_states`.
#' @export
gridworld_env <- function(arms = c("attention", "escape", "tangible", "goal"), corridor = 3L, magnitude = 1, step_cost = 0.02) {
  K <- length(arms)
  corridor <- as.integer(corridor)
  st <- new.env(parent = emptyenv())
  encode <- function(arm, dist) if (dist == 0L) 0L else (arm - 1L) * corridor + dist
  reset <- function(seed = NULL) {
    if (!is.null(seed)) set.seed(seed)
    st$arm <- 0L
    st$dist <- 0L
    list(obs = 0L)
  }
  step <- function(action) {
    a <- as.integer(action)
    if (st$dist == 0L) {
      st$arm <- a
      st$dist <- 1L
    } else if (a == st$arm) {
      st$dist <- st$dist + 1L
    } else {
      st$dist <- st$dist - 1L
    }
    if (st$dist == 0L) st$arm <- 0L
    term <- st$dist >= corridor
    ch <- stats::setNames(rep(0, K), arms)
    if (term) ch[arms[st$arm]] <- magnitude
    list(obs = encode(st$arm, st$dist), reward = -step_cost + sum(ch), terminated = term, truncated = FALSE, base_reward = -step_cost, channels = ch)
  }
  list(reset = reset, step = step, n_actions = K, arms = arms, n_states = 1L + K * corridor)
}

gw_rollout <- function(env, table, select, update, featurize, max_steps = 20L, train = TRUE, seed = NULL) {
  r0 <- env$reset(seed = seed)
  s <- featurize(r0$obs)
  total <- 0
  steps <- 0L
  arm <- NA_integer_
  repeat {
    a <- select(table, s)
    o <- env$step(a)
    s2 <- featurize(o$obs)
    if (train) update(table, s, a, o$reward, s2, o$terminated)
    total <- total + o$reward
    steps <- steps + 1L
    s <- s2
    if (isTRUE(o$terminated)) {
      hit <- which(o$channels > 0)
      if (length(hit) == 1) arm <- hit
      break
    }
    if (isTRUE(o$truncated) || steps >= max_steps) break
  }
  list(total = total, steps = steps, arm = arm)
}

#' Functional analysis on a Gymnasium-style environment
#'
#' The functional-analysis instrument mapped to gym: train a reinforcement-driven
#' agent under each single-channel condition (and a no-channel play control) via
#' [contingency_env()], measure the target response rate, and identify the
#' maintaining channel as the condition elevated over control. Recovers a planted
#' `true_function`. This is reward-channel ablation: which reinforcement
#' contingency maintains the behaviour.
#'
#' @param true_function Planted maintaining channel.
#' @param arms Channels tested.
#' @param agent Registry key for the agent.
#' @param n_steps Trials per condition.
#' @param margin Rate elevation over control to call a channel.
#' @param response_cost Engage cost.
#' @param seed Seed.
#' @return A list with `by_condition`, `identified_channel`, `true_function`, `correct`.
#' @export
#' @examples
#' \donttest{
#' gym_functional_analysis("attention")
#' }
gym_functional_analysis <- function(true_function = "escape", arms = c("attention", "escape", "tangible", "goal"),
                                     agent = "q_learning", n_steps = 20000L, margin = 0.3, response_cost = 0.1, seed = 0L) {
  conds <- c(arms, "play")
  feat <- discrete_featurizer()
  rate <- stats::setNames(numeric(length(conds)), conds)
  for (cc in conds) {
    base <- fa_channel_env(true_function = true_function, arms = arms, response_cost = response_cost)
    env <- contingency_env(base, active = if (cc == "play") character(0) else cc)
    ag <- make_agent(agent, n_actions = 2L, horizon = as.integer(n_steps))
    tbl <- make_table(2L)
    env$reset(seed = seed)
    acts <- integer(n_steps)
    for (i in seq_len(n_steps)) {
      a <- ag$select(tbl, "0")
      o <- env$step(a)
      ag$update(tbl, "0", a, o$reward, "0", TRUE)
      acts[i] <- a
    }
    keep <- seq.int(as.integer(n_steps / 2) + 1L, n_steps)
    rate[cc] <- mean(acts[keep] == 1L)
  }
  play <- rate[["play"]]
  elevated <- arms[rate[arms] - play > margin]
  identified <- if (length(elevated) == 0) "undifferentiated" else if (length(elevated) == 1) elevated else paste("multiple:", paste(elevated, collapse = "/"))
  list(
    by_condition = tibble::tibble(condition = conds, target_rate = unname(rate[conds]), is_control = conds == "play"),
    identified_channel = identified,
    true_function = true_function,
    correct = identical(identified, true_function)
  )
}

#' Differential reinforcement (DRA) on a Gymnasium-style gridworld
#'
#' Trains the agent to navigate to a problem arm (baseline), then switches the
#' active channel so the problem arm is on extinction and an alternative arm is
#' reinforced (treatment). Behaviour reallocates from the problem arm to the
#' alternative: the contingency engine behind DRA/FCT on a multi-state navigation
#' task.
#'
#' @param arms Two channel names, `c(problem, alternative)`.
#' @param corridor Arm length.
#' @param agent Registry key for the agent.
#' @param n_baseline,n_treatment Episodes per phase.
#' @param window Episodes per summary window.
#' @param max_steps Step cap per episode.
#' @param seed Seed.
#' @return A tibble with `window_mid`, `arm`, `reach_rate`, `switch_ep`.
#' @export
#' @examples
#' \donttest{
#' gym_dra()
#' }
gym_dra <- function(arms = c("problem", "alternative"), corridor = 3L, agent = "q_learning",
                    n_baseline = 400L, n_treatment = 600L, window = 50L, max_steps = 20L, seed = 0L) {
  feat <- discrete_featurizer()
  base <- gridworld_env(arms = arms, corridor = corridor)
  env <- contingency_env(base, active = arms[1])
  n <- n_baseline + n_treatment
  ag <- make_agent(agent, n_actions = length(arms), horizon = as.integer(n * max_steps))
  tbl <- make_table(length(arms))
  reached <- integer(n)
  for (ep in seq_len(n)) {
    if (ep == n_baseline + 1L) env$set_active(arms[2])
    set.seed(seed + ep)
    r <- gw_rollout(env, tbl, ag$select, ag$update, feat, max_steps = max_steps, train = TRUE, seed = seed + ep)
    reached[ep] <- if (is.na(r$arm)) 0L else r$arm
  }
  g <- (seq_len(n) - 1L) %/% as.integer(window)
  mid <- tapply(seq_len(n), g, mean)
  p_rate <- tapply(as.integer(reached == 1L), g, mean)
  a_rate <- tapply(as.integer(reached == 2L), g, mean)
  tibble::tibble(
    window_mid = rep(as.numeric(mid), 2),
    arm = rep(arms, each = length(mid)),
    reach_rate = c(as.numeric(p_rate), as.numeric(a_rate)),
    switch_ep = n_baseline
  )
}

#' Extinction on a Gymnasium environment
#'
#' Acquires a policy with the maintaining channel active, then withdraws
#' reinforcement (channel inactive) while continuing to train, probing retained
#' behaviour by evaluating with the channel restored. Evaluation success declines
#' as reinforcement is withheld: extinction on a real gym task.
#'
#' @param builder A zero-argument function returning a channel environment.
#' @param channel The maintaining channel to withdraw.
#' @param n_acquire,n_extinction Episodes per phase.
#' @param eval_every,n_eval Evaluation cadence and size during extinction.
#' @param max_steps Step cap per episode.
#' @param seed Seed.
#' @return A tibble with `episode`, `eval_success`.
#' @export
#' @examples
#' \dontrun{
#' lunar_setup("/usr/bin/python3")
#' gym_extinction(function() as_channel_env(make_gym("FrozenLake-v1", is_slippery = FALSE), "goal"))
#' }
gym_extinction <- function(builder, channel = "goal", n_acquire = 1200L, n_extinction = 150L,
                           eval_every = 10L, n_eval = 40L, max_steps = 100L, seed = 0L) {
  feat <- discrete_featurizer()
  env <- contingency_env(builder())
  ag <- make_agent("q_learning", n_actions = env$n_actions, horizon = as.integer((n_acquire + n_extinction) * 5L))
  tbl <- make_table(env$n_actions)
  noop <- function(...) invisible(NULL)
  env$set_active(channel)
  for (ep in seq_len(n_acquire)) {
    set.seed(seed + ep)
    run_episode(env, tbl, ag$select, ag$update, feat, max_steps = max_steps, train = TRUE, seed = seed + ep)
  }
  base_succ <- mean(vapply(seq_len(n_eval), function(j) {
    set.seed(seed + 400000L + j)
    run_episode(env, tbl, ag$greedy, noop, feat, max_steps = max_steps, train = FALSE, seed = seed + 400000L + j)$total
  }, numeric(1)) > 0)
  blocks <- as.integer(n_extinction / eval_every)
  ep_at <- integer(blocks)
  succ <- numeric(blocks)
  done <- n_acquire
  for (b in seq_len(blocks)) {
    env$set_active(character(0))
    for (k in seq_len(eval_every)) {
      done <- done + 1L
      set.seed(seed + done)
      run_episode(env, tbl, ag$select, ag$update, feat, max_steps = max_steps, train = TRUE, seed = seed + done)
    }
    env$set_active(channel)
    rets <- vapply(seq_len(n_eval), function(j) {
      set.seed(seed + 500000L + done + j)
      run_episode(env, tbl, ag$greedy, noop, feat, max_steps = max_steps, train = FALSE, seed = seed + 500000L + done + j)$total
    }, numeric(1))
    ep_at[b] <- done
    succ[b] <- mean(rets > 0)
  }
  tibble::tibble(episode = c(n_acquire, ep_at), eval_success = c(base_succ, succ))
}

#' ABA-to-gym mapping
#'
#' How each toolkit instrument reframes a reinforcement-learning problem: the ABA
#' theory as an alternative analytic framework for gym environments.
#'
#' @return A tibble with `instrument`, `rl_problem`, `gym_mechanism`, `diagnoses_or_changes`.
#' @export
#' @examples
#' aba_gym_mapping()
aba_gym_mapping <- function() {
  tibble::tribble(
    ~instrument, ~rl_problem, ~gym_mechanism, ~diagnoses_or_changes,
    "Functional analysis", "What reward component drives a learned behaviour?", "Reward-channel ablation across conditions via contingency_env", "Diagnoses which reinforcement contingency maintains a target behaviour.",
    "Extinction", "How robust is a policy to reward removal?", "Disable the maintaining channel and keep training", "Diagnoses persistence; behaviour weakens as reinforcement is withheld.",
    "Differential reinforcement (DRA/FCT)", "Redirect a policy to an alternative behaviour", "Extinguish one channel while reinforcing an alternative", "Changes behaviour by reallocating it to a functionally equivalent alternative.",
    "DRL", "Shape low-rate or paced responding", "Reinforce the response only after an inter-response time", "Changes the temporal structure of responding.",
    "Matching (phenomenon)", "Characterise an agent's allocation under concurrent reward", "Concurrent reward channels", "Diagnoses choice allocation; descriptive, not prescriptive."
  )
}

#' Plot a gym functional analysis
#'
#' @param fa Output of [gym_functional_analysis()].
#' @return A ggplot object.
#' @export
plot_gym_functional_analysis <- function(fa) {
  d <- fa$by_condition
  ggplot2::ggplot(d, ggplot2::aes(stats::reorder(condition, -target_rate), target_rate, fill = is_control)) +
    ggplot2::geom_col() +
    ggplot2::scale_fill_manual(values = c(`FALSE` = "#3b7dd8", `TRUE` = "grey60"), guide = "none") +
    ggplot2::labs(x = "condition (active channel)", y = "target-response rate",
                  title = paste0("Gym functional analysis: identified = ", fa$identified_channel, " (true = ", fa$true_function, ")")) +
    ggplot2::ylim(0, 1) +
    ggplot2::theme_minimal()
}

#' Plot a gym DRA reallocation
#'
#' @param demo Output of [gym_dra()].
#' @return A ggplot object.
#' @export
plot_gym_dra <- function(demo) {
  ggplot2::ggplot(demo, ggplot2::aes(window_mid, reach_rate, colour = arm)) +
    ggplot2::geom_line() +
    ggplot2::geom_point(size = 1) +
    ggplot2::geom_vline(xintercept = demo$switch_ep[1], linetype = "dashed", colour = "darkgreen") +
    ggplot2::labs(x = "episode", y = "arm-reach rate", colour = NULL,
                  title = "Gym DRA: reallocation from problem to alternative arm (dashed = treatment)") +
    ggplot2::ylim(0, 1) +
    ggplot2::theme_minimal()
}
