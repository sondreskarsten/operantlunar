#' Load the bundled LunarLander evaluation returns
#'
#' Returns the per-policy, per-terrain episode returns produced by evaluating
#' four DQN policies (training seeds 0-3) on LunarLander-v3 across 200 distinct
#' terrains (reset seeds). Seeds 0 and 1 are near-solved (true 100+ episode means
#' of roughly 182 and 167); seeds 2 and 3 fail at the same training budget. Policy
#' seed 99 is a PPO policy trained to a verified solve (true mean about 243, above
#' the 200 threshold, with low variance). The dataset is the substrate for
#' demonstrating that conclusions about a policy are invariant under the protocol
#' but not under ad hoc evaluation.
#'
#' @param path Optional path to a returns CSV; defaults to the bundled dataset.
#' @return A tibble with `policy_seed`, `terrain_seed`, `ret`.
#' @export
lunar_returns <- function(path = NULL) {
  if (is.null(path)) path <- system.file("extdata", "lunar_returns.csv", package = "operantlunar")
  tibble::as_tibble(utils::read.csv(path))
}

#' Steady-state evaluation estimate for one policy
#'
#' Accumulates episodes in terrain order, tracks the cumulative mean return after
#' each block, and applies the steady-state stability rule to the cumulative-mean
#' series: the estimate is read once the running mean has settled (no trend and
#' bounded range over the last `k` blocks), or non-stabilisation is reported. A
#' short evaluation is read off the unsettled head of this same series and is
#' therefore unreliable; the settled estimate is what the protocol reports.
#'
#' @param returns Returns tibble (defaults to the bundled dataset).
#' @param policy_seed Policy to evaluate.
#' @param block Episodes per block.
#' @param min_blocks Minimum blocks before the stability rule applies.
#' @param k Window length for stability and the read.
#' @param tol_trend,tol_bounce Stability tolerances on the return scale.
#' @return A list with `estimate`, `stable`, `n_blocks`, `n_episodes`, `series`.
#' @export
lunar_steady_state_return <- function(returns = lunar_returns(), policy_seed = 0L, block = 10L,
                                      min_blocks = 7L, k = 6L, tol_trend = 8, tol_bounce = 15) {
  d <- returns[returns$policy_seed == policy_seed, ]
  v <- d$ret[order(d$terrain_seed)]
  nb <- length(v) %/% block
  cum <- vapply(seq_len(nb), function(b) mean(v[seq_len(b * block)]), numeric(1))
  series <- tibble::tibble(session = seq_len(nb), condition = "p", rate = cum)
  stable <- FALSE
  n_used <- nb
  for (b in seq.int(min_blocks, nb)) {
    if (stability_reached(series[seq_len(b), ], k = k, tol_trend = tol_trend, tol_bounce = tol_bounce)) {
      stable <- TRUE
      n_used <- b
      break
    }
  }
  list(estimate = cum[n_used], stable = stable, n_blocks = n_used, n_episodes = n_used * block, series = cum)
}

#' Ad hoc "is it solved?" verdict from a short evaluation
#'
#' Takes `n_episodes` from one contiguous terrain pool and declares the policy
#' solved if that short-sample mean clears `threshold`. The verdict depends on
#' how many episodes and which pool were chosen, which is the researcher degree
#' of freedom the protocol removes.
#'
#' @param returns Returns tibble.
#' @param policy_seed Policy to evaluate.
#' @param n_episodes Episodes sampled.
#' @param pool Which terrain pool (1-indexed).
#' @param n_pools Number of contiguous pools the terrains are split into.
#' @param threshold Solved threshold.
#' @return A list with `mean`, `verdict`.
#' @export
lunar_adhoc_solved <- function(returns = lunar_returns(), policy_seed = 0L, n_episodes = 10L,
                               pool = 1L, n_pools = 10L, threshold = 200) {
  d <- returns[returns$policy_seed == policy_seed, ]
  v <- d$ret[order(d$terrain_seed)]
  psize <- length(v) %/% n_pools
  chunk <- v[((pool - 1L) * psize + 1L):(pool * psize)]
  m <- mean(chunk[seq_len(min(n_episodes, length(chunk)))])
  list(mean = m, verdict = if (m >= threshold) "solved" else "not solved")
}

#' Protocol "is it solved?" verdict with quantified reliability
#'
#' Reads the steady-state estimate over all terrains, applies the frozen solved
#' threshold, and quantifies the residual uncertainty by bootstrapping the
#' terrain sample: the fraction of resampled means that clear the threshold is a
#' direct confidence readout. The verdict does not depend on an episode budget or
#' a terrain pool.
#'
#' @param returns Returns tibble.
#' @param policy_seed Policy to evaluate.
#' @param threshold Solved threshold.
#' @param n_boot Bootstrap resamples.
#' @param block,min_blocks,k,tol_trend,tol_bounce Steady-state parameters.
#' @return A list with `verdict`, `estimate`, `stable`, `n_episodes`, `bootstrap_solved_fraction`.
#' @export
lunar_protocol_solved <- function(returns = lunar_returns(), policy_seed = 0L, threshold = 200, n_boot = 1000L,
                                  block = 10L, min_blocks = 7L, k = 6L, tol_trend = 8, tol_bounce = 15) {
  ss <- lunar_steady_state_return(returns, policy_seed = policy_seed, block = block, min_blocks = min_blocks, k = k, tol_trend = tol_trend, tol_bounce = tol_bounce)
  d <- returns[returns$policy_seed == policy_seed, ]
  v <- d$ret
  boot <- vapply(seq_len(n_boot), function(i) mean(sample(v, length(v), replace = TRUE)), numeric(1))
  list(verdict = if (ss$estimate >= threshold) "solved" else "not solved",
       estimate = ss$estimate, stable = ss$stable, n_episodes = ss$n_episodes,
       bootstrap_solved_fraction = mean(boot >= threshold))
}

#' Convergence demonstration for the "is it solved?" conclusion
#'
#' Runs the ad hoc verdict across a grid of episode budgets and terrain pools and
#' the protocol verdict once. The ad hoc verdict flips between solved and not
#' solved depending on the budget and pool; the protocol verdict is single-valued
#' and accompanied by a bootstrap confidence.
#'
#' @param returns Returns tibble.
#' @param policy_seed Policy to evaluate.
#' @param n_episodes_grid Episode budgets for the ad hoc pipeline.
#' @param n_pools Terrain pools.
#' @param threshold Solved threshold.
#' @return A list with `results`, `adhoc_distinct`, `protocol_verdict`, `protocol_estimate`, `bootstrap_solved_fraction`.
#' @export
lunar_solved_convergence <- function(returns = lunar_returns(), policy_seed = 0L,
                                     n_episodes_grid = c(5L, 10L, 20L), n_pools = 10L, threshold = 200) {
  ah <- list()
  for (ne in n_episodes_grid) for (p in seq_len(n_pools)) {
    a <- lunar_adhoc_solved(returns, policy_seed = policy_seed, n_episodes = ne, pool = p, n_pools = n_pools, threshold = threshold)
    ah[[length(ah) + 1L]] <- data.frame(pipeline = "ad hoc", n_episodes = ne, pool = p, verdict = a$verdict, stringsAsFactors = FALSE)
  }
  pr <- lunar_protocol_solved(returns, policy_seed = policy_seed, threshold = threshold)
  prow <- data.frame(pipeline = "protocol", n_episodes = pr$n_episodes, pool = NA_integer_, verdict = pr$verdict, stringsAsFactors = FALSE)
  results <- tibble::as_tibble(rbind(do.call(rbind, ah), prow))
  list(results = results,
       adhoc_distinct = length(unique(results$verdict[results$pipeline == "ad hoc"])),
       protocol_verdict = pr$verdict, protocol_estimate = pr$estimate,
       bootstrap_solved_fraction = pr$bootstrap_solved_fraction)
}

#' Convergence demonstration for the "which policy is best?" conclusion
#'
#' The concrete form of "the best policy is a seed artifact": across episode
#' budgets and terrain pools, the ad hoc head-to-head winner between two policies
#' flips, while the protocol compares steady-state estimates with a difference
#' band and returns a stable verdict (a winner only when the settled gap exceeds
#' the band, otherwise indistinguishable).
#'
#' @param returns Returns tibble.
#' @param policy_a,policy_b Policies to compare.
#' @param n_episodes_grid Episode budgets.
#' @param n_pools Terrain pools.
#' @param band Minimum settled difference to declare a winner.
#' @return A list with `results`, `adhoc_distinct`, `protocol_verdict`, `estimate_a`, `estimate_b`.
#' @export
lunar_best_policy_convergence <- function(returns = lunar_returns(), policy_a = 0L, policy_b = 1L,
                                          n_episodes_grid = c(5L, 10L, 20L), n_pools = 10L, band = 25) {
  ah <- list()
  for (ne in n_episodes_grid) for (p in seq_len(n_pools)) {
    ma <- lunar_adhoc_solved(returns, policy_seed = policy_a, n_episodes = ne, pool = p, n_pools = n_pools)$mean
    mb <- lunar_adhoc_solved(returns, policy_seed = policy_b, n_episodes = ne, pool = p, n_pools = n_pools)$mean
    w <- if (ma >= mb) paste0("seed", policy_a) else paste0("seed", policy_b)
    ah[[length(ah) + 1L]] <- data.frame(pipeline = "ad hoc", n_episodes = ne, pool = p, verdict = w, stringsAsFactors = FALSE)
  }
  ea <- lunar_steady_state_return(returns, policy_seed = policy_a)$estimate
  eb <- lunar_steady_state_return(returns, policy_seed = policy_b)$estimate
  pv <- if (abs(ea - eb) < band) "indistinguishable" else if (ea > eb) paste0("seed", policy_a) else paste0("seed", policy_b)
  prow <- data.frame(pipeline = "protocol", n_episodes = NA_integer_, pool = NA_integer_, verdict = pv, stringsAsFactors = FALSE)
  results <- tibble::as_tibble(rbind(do.call(rbind, ah), prow))
  list(results = results,
       adhoc_distinct = length(unique(results$verdict[results$pipeline == "ad hoc"])),
       protocol_verdict = pv, estimate_a = ea, estimate_b = eb)
}

#' Training-seed reliability of the solved conclusion
#'
#' Applies the protocol verdict to every policy and reports how many training
#' seeds actually meet the solved criterion. This exposes the training-seed
#' lottery: at a fixed budget some seeds reach the criterion and some do not, so
#' a claim resting on a single trained seed is not reproducible.
#'
#' @param returns Returns tibble.
#' @param threshold Solved threshold.
#' @return A list with `per_seed` (tibble) and `n_solved`, `n_total`.
#' @export
lunar_training_reliability <- function(returns = lunar_returns(), threshold = 200) {
  seeds <- sort(unique(returns$policy_seed))
  rows <- lapply(seeds, function(s) {
    pr <- lunar_protocol_solved(returns, policy_seed = s, threshold = threshold)
    data.frame(policy_seed = s, estimate = round(pr$estimate, 1), stable = pr$stable, verdict = pr$verdict, stringsAsFactors = FALSE)
  })
  per_seed <- tibble::as_tibble(do.call(rbind, rows))
  list(per_seed = per_seed, n_solved = sum(per_seed$verdict == "solved"), n_total = length(seeds))
}

#' Plot a LunarLander convergence demonstration
#'
#' @param demo The list returned by [lunar_solved_convergence()] or [lunar_best_policy_convergence()].
#' @return A ggplot object.
#' @export
plot_lunar_convergence <- function(demo) {
  ggplot2::ggplot(demo$results, ggplot2::aes(x = verdict, fill = pipeline)) +
    ggplot2::geom_bar() +
    ggplot2::facet_wrap(~pipeline, ncol = 1, scales = "free_y") +
    ggplot2::coord_flip() +
    ggplot2::labs(title = "LunarLander: conclusion stability under ad hoc vs protocol evaluation",
                  subtitle = sprintf("ad hoc distinct verdicts: %d; protocol: 1", demo$adhoc_distinct),
                  x = "verdict", y = "evaluations") +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "none")
}
