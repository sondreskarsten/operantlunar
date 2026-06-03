#' Concurrent variable-interval environment
#'
#' Two alternatives on independent VI schedules; one response per step.
#'
#' @param vi_means Mean inter-arming intervals.
#' @param magnitudes Reinforcement magnitudes per alternative.
#' @return An environment object with `reset` and `step`.
#' @export
#' @examples
#' env <- concurrent_vi()
#' env$reset(seed = 0)
#' env$step(1)
concurrent_vi <- function(vi_means = c(30, 90), magnitudes = c(1, 1)) {
  st <- new.env(parent = emptyenv())
  n <- length(vi_means)
  st$armed <- rep(FALSE, n)
  reset <- function(seed = NULL) {
    if (!is.null(seed)) set.seed(seed)
    st$armed <- rep(FALSE, n)
    list(obs = 0)
  }
  step <- function(action) {
    for (i in seq_len(n)) if (!st$armed[i] && stats::runif(1) < 1 / vi_means[i]) st$armed[i] <- TRUE
    r <- 0
    if (st$armed[action]) {
      r <- magnitudes[action]
      st$armed[action] <- FALSE
    }
    list(obs = 0, reward = r, terminated = FALSE, truncated = FALSE)
  }
  list(reset = reset, step = step)
}

#' Run a melioration agent on a concurrent VI schedule
#'
#' @param agent An agent (see [melioration_agent()]).
#' @param vi_means Mean intervals.
#' @param n_steps Number of responses.
#' @param seed Seed.
#' @return A list with response counts `B` and reinforcer counts `R`.
#' @export
run_matching <- function(agent, vi_means = c(30, 90), n_steps = 20000L, seed = 0L) {
  set.seed(seed)
  env <- concurrent_vi(vi_means = vi_means)
  tbl <- make_table(2L)
  env$reset(seed = seed)
  s <- "S0"
  B <- c(0, 0)
  R <- c(0, 0)
  for (i in seq_len(n_steps)) {
    a <- agent$select(tbl, s)
    o <- env$step(a)
    agent$update(tbl, s, a, o$reward, s, FALSE)
    B[a] <- B[a] + 1
    if (o$reward > 0) R[a] <- R[a] + 1
  }
  list(B = B, R = R)
}

#' Fit the generalized matching law on concurrent VI schedules
#'
#' Runs a melioration agent across VI ratio conditions and fits
#' `log(B1/B2) = a log(R1/R2) + log b`.
#'
#' @param conditions List of VI mean pairs.
#' @param alpha,beta Melioration hyperparameters.
#' @param n_steps Steps per condition.
#' @param seed Seed.
#' @return A list with `slope`, `bias`, and a tibble of `log_r`/`log_b`.
#' @export
#' @examples
#' \donttest{
#' fit_generalized_matching(n_steps = 8000)
#' }
fit_generalized_matching <- function(conditions = list(c(20, 60), c(30, 90), c(45, 45), c(60, 30), c(90, 30), c(40, 120), c(120, 40)),
                                     alpha = 0.1, beta = 1, n_steps = 20000L, seed = 0L) {
  n <- length(conditions)
  log_b <- numeric(n)
  log_r <- numeric(n)
  for (k in seq_len(n)) {
    ag <- melioration_agent(alpha = alpha, beta = beta, n_actions = 2L)
    cnt <- run_matching(ag, vi_means = conditions[[k]], n_steps = n_steps, seed = seed + k)
    log_b[k] <- log(cnt$B[1] / cnt$B[2])
    log_r[k] <- log(cnt$R[1] / cnt$R[2])
  }
  fit <- stats::lm(log_b ~ log_r)
  list(slope = unname(stats::coef(fit)[2]),
       bias = unname(exp(stats::coef(fit)[1])),
       data = tibble::tibble(log_r = log_r, log_b = log_b))
}
