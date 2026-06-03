#' Functional-analysis chamber
#'
#' One target response evaluated across analogue conditions. The response
#' produces the maintaining reinforcer only under the test condition whose
#' contingency matches a hidden `true_function`; the `play` control delivers no
#' contingent reinforcement. Conditions map to the categories of maintaining
#' reinforcement: attention (social positive), escape (social negative),
#' tangible (social positive, item), alone (automatic). This is the operant
#' contingency made diagnosable, not a clinical apparatus.
#'
#' @param true_function One of "attention", "escape", "tangible", "automatic".
#' @param magnitude Reinforcement magnitude.
#' @param response_cost Cost per target response.
#' @return An environment object with `reset`, `step`, and `set_condition`.
#' @export
#' @examples
#' ch <- fa_chamber("escape")
#' ch$set_condition("escape")
#' ch$step(1)
fa_chamber <- function(true_function = "escape", magnitude = 1, response_cost = 0) {
  match.arg(true_function, c("attention", "escape", "tangible", "automatic"))
  st <- new.env(parent = emptyenv())
  st$condition <- "play"
  contingent <- c(attention = "attention", escape = "escape", tangible = "tangible", alone = "automatic", play = "control")
  reset <- function(seed = NULL) {
    if (!is.null(seed)) set.seed(seed)
    list(obs = st$condition)
  }
  step <- function(action) {
    pays <- action == 1L && unname(contingent[st$condition]) == true_function
    r <- (if (pays) magnitude else 0) - (if (action == 1L) response_cost else 0)
    list(obs = st$condition, reward = r, terminated = FALSE, truncated = FALSE)
  }
  set_condition <- function(condition) st$condition <- condition
  list(reset = reset, step = step, set_condition = set_condition)
}

#' Functional analysis: identify a maintaining function
#'
#' Runs a reinforcement-driven agent across the standard analogue conditions
#' (attention, escape, tangible, alone) against a play control, in rapid
#' alternation (multielement), and identifies the function as the test condition
#' whose target-response rate is elevated over the control. Recovers a planted
#' `true_function`, validating the functional-analysis logic: differential
#' responding across analogue conditions reveals the operative reinforcement
#' contingency. The agent stands in for the organism; this validates the logic,
#' not a clinical FA.
#'
#' @param true_function Planted maintaining function.
#' @param agent Registry key for the agent.
#' @param n_steps Total trials across all conditions.
#' @param margin Rate elevation over control required to call a function.
#' @param response_cost Cost per target response, so withholding is the default where responding does not pay.
#' @param seed Seed.
#' @return A list with `by_condition` (tibble), `identified_function`, `true_function`, `correct`.
#' @export
#' @examples
#' \donttest{
#' functional_analysis("attention")
#' }
functional_analysis <- function(true_function = "escape", agent = "q_learning", n_steps = 20000L, margin = 0.3, response_cost = 0.1, seed = 0L) {
  set.seed(seed)
  conds <- c("attention", "escape", "tangible", "alone", "play")
  fn_of <- c(attention = "attention", escape = "escape", tangible = "tangible", alone = "automatic")
  ag <- make_agent(agent, n_actions = 2L, horizon = n_steps)
  env <- fa_chamber(true_function = true_function, response_cost = response_cost)
  tbl <- make_table(2L)
  n <- as.integer(n_steps)
  acts <- integer(n)
  cvec <- sample(conds, n, replace = TRUE)
  env$reset(seed = seed)
  for (i in seq_len(n)) {
    cc <- cvec[i]
    env$set_condition(cc)
    a <- ag$select(tbl, cc)
    o <- env$step(a)
    ag$update(tbl, cc, a, o$reward, cc, TRUE)
    acts[i] <- a
  }
  keep <- seq.int(as.integer(n / 2) + 1L, n)
  rate <- vapply(conds, function(cc) {
    sel <- keep[cvec[keep] == cc]
    if (length(sel) == 0) NA_real_ else mean(acts[sel] == 1L)
  }, numeric(1))
  play_rate <- rate[["play"]]
  tests <- setdiff(conds, "play")
  elevated <- tests[rate[tests] - play_rate > margin]
  identified <- if (length(elevated) == 0) "undifferentiated" else if (length(elevated) == 1) unname(fn_of[elevated]) else paste("multiple:", paste(unname(fn_of[elevated]), collapse = "/"))
  list(
    by_condition = tibble::tibble(condition = conds, response_rate = unname(rate[conds]), is_control = conds == "play"),
    identified_function = identified,
    true_function = true_function,
    correct = identical(identified, true_function)
  )
}

#' Plot a functional analysis
#'
#' @param fa Output of [functional_analysis()].
#' @return A ggplot object.
#' @export
plot_functional_analysis <- function(fa) {
  d <- fa$by_condition
  d$condition <- factor(d$condition, levels = c("attention", "escape", "tangible", "alone", "play"))
  ggplot2::ggplot(d, ggplot2::aes(condition, response_rate, fill = is_control)) +
    ggplot2::geom_col() +
    ggplot2::scale_fill_manual(values = c(`FALSE` = "#3b7dd8", `TRUE` = "grey60"), guide = "none") +
    ggplot2::labs(x = "condition", y = "target-response rate", title = paste0("Functional analysis: identified = ", fa$identified_function, " (true = ", fa$true_function, ")")) +
    ggplot2::ylim(0, 1) +
    ggplot2::theme_minimal()
}
