#' Plot probability-matching results
#'
#' @param res Output of [prob_matching_experiment()].
#' @return A ggplot object.
#' @export
plot_prob_matching <- function(res) {
  ggplot2::ggplot(res$rules, ggplot2::aes(stats::reorder(rule, frac_optimal), frac_optimal)) +
    ggplot2::geom_col(fill = "#3b7dd8") +
    ggplot2::geom_hline(yintercept = 1, linetype = "dashed", colour = "darkgreen") +
    ggplot2::geom_hline(yintercept = res$matching_p_richer, linetype = "dotted", colour = "firebrick") +
    ggplot2::coord_flip() +
    ggplot2::labs(x = NULL, y = "fraction choosing richer option", title = "Probability matching: optimal (1) vs matching") +
    ggplot2::ylim(0, 1) +
    ggplot2::theme_minimal()
}

#' Plot self-control results
#'
#' @param res Output of [self_control_experiment()].
#' @return A ggplot object.
#' @export
plot_self_control <- function(res) {
  ggplot2::ggplot(res$rules, ggplot2::aes(stats::reorder(rule, frac_LL), frac_LL)) +
    ggplot2::geom_col(fill = "#3b7dd8") +
    ggplot2::geom_hline(yintercept = 0.5, linetype = "dotted") +
    ggplot2::coord_flip() +
    ggplot2::labs(x = NULL, y = "fraction choosing large-later", title = "Self-control (1 = self-controlled, 0 = impulsive)") +
    ggplot2::ylim(0, 1) +
    ggplot2::theme_minimal()
}

#' Plot DRL results
#'
#' @param res Output of [drl_experiment()].
#' @return A ggplot object.
#' @export
plot_drl <- function(res) {
  ggplot2::ggplot(res$rules, ggplot2::aes(stats::reorder(rule, -response_rate), response_rate)) +
    ggplot2::geom_col(fill = "#3b7dd8") +
    ggplot2::geom_hline(yintercept = res$optimal_rate, linetype = "dashed", colour = "darkgreen") +
    ggplot2::coord_flip() +
    ggplot2::labs(x = NULL, y = "response rate", title = sprintf("DRL %d: optimal rate = 1/%d", as.integer(res$threshold), as.integer(res$threshold))) +
    ggplot2::theme_minimal()
}

#' Plot progressive-ratio breakpoints
#'
#' @param df Output of [progressive_ratio_experiment()].
#' @return A ggplot object.
#' @export
plot_progressive_ratio <- function(df) {
  ggplot2::ggplot(df, ggplot2::aes(stats::reorder(rule, breakpoint), breakpoint)) +
    ggplot2::geom_col(fill = "#3b7dd8") +
    ggplot2::coord_flip() +
    ggplot2::labs(x = NULL, y = "breakpoint (highest completed ratio)", title = "Progressive ratio") +
    ggplot2::theme_minimal()
}

#' Plot risk-sensitivity results
#'
#' @param res Output of [risk_experiment()].
#' @return A ggplot object.
#' @export
plot_risk <- function(res) {
  ggplot2::ggplot(res$rules, ggplot2::aes(stats::reorder(rule, frac_risky), frac_risky)) +
    ggplot2::geom_col(fill = "#3b7dd8") +
    ggplot2::geom_hline(yintercept = 0.5, linetype = "dotted") +
    ggplot2::coord_flip() +
    ggplot2::labs(x = NULL, y = "fraction choosing risky option", title = "Risk sensitivity (means matched)") +
    ggplot2::ylim(0, 1) +
    ggplot2::theme_minimal()
}

#' Plot the differentiation matrix as a heatmap
#'
#' @param dm Output of [differentiation_matrix()].
#' @return A ggplot object.
#' @export
plot_differentiation_matrix <- function(dm) {
  ggplot2::ggplot(dm$long, ggplot2::aes(paradigm, rule, fill = score)) +
    ggplot2::geom_tile(colour = "white") +
    ggplot2::geom_text(ggplot2::aes(label = sprintf("%.2f", score)), size = 3) +
    ggplot2::scale_fill_gradient2(low = "#b2182b", mid = "#f7f7f7", high = "#2166ac", midpoint = 0.5, limits = c(0, 1)) +
    ggplot2::labs(x = NULL, y = NULL, fill = "maximize\nscore", title = "Maximize vs meliorate across paradigms") +
    ggplot2::theme_minimal() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 30, hjust = 1))
}

#' Plot a discounting fit
#'
#' @param delays Delays.
#' @param indiff Indifference amounts.
#' @param fit Output of [fit_discounting()].
#' @return A ggplot object.
#' @export
plot_discounting <- function(delays, indiff, fit) {
  grid <- seq(min(delays), max(delays), length.out = 100)
  pred <- if (fit$model == "hyperbolic") fit$A / (1 + fit$k * grid) else fit$A * exp(-fit$k * grid)
  ggplot2::ggplot(data.frame(delay = delays, v = indiff), ggplot2::aes(delay, v)) +
    ggplot2::geom_point(size = 2) +
    ggplot2::geom_line(data = data.frame(delay = grid, v = pred), colour = "#3b7dd8") +
    ggplot2::labs(x = "delay", y = "subjective value", title = sprintf("%s discounting (k = %.3f)", fit$model, fit$k)) +
    ggplot2::theme_minimal()
}

#' Plot a Herrnstein hyperbola fit
#'
#' @param df Output of [herrnstein_experiment()].
#' @param fit Output of [fit_herrnstein_hyperbola()].
#' @return A ggplot object.
#' @export
plot_herrnstein <- function(df, fit) {
  grid <- seq(min(df$reinforcement_rate), max(df$reinforcement_rate), length.out = 100)
  pred <- fit$k * grid / (grid + fit$r0)
  ggplot2::ggplot(df, ggplot2::aes(reinforcement_rate, response_rate)) +
    ggplot2::geom_point(size = 2) +
    ggplot2::geom_line(data = data.frame(reinforcement_rate = grid, response_rate = pred), colour = "#3b7dd8") +
    ggplot2::labs(x = "reinforcement rate", y = "response rate", title = sprintf("Herrnstein hyperbola (k = %.2f, r0 = %.3f)", fit$k, fit$r0)) +
    ggplot2::theme_minimal()
}

#' Plot linear-agent learning curves
#'
#' @param curves Named list of episode-return vectors.
#' @param window Smoothing window.
#' @return A ggplot object.
#' @export
plot_gym_training <- function(curves, window = 20L) {
  smooth <- function(x) as.numeric(stats::filter(x, rep(1 / window, window), sides = 1))
  df <- dplyr::bind_rows(lapply(names(curves), function(nm) {
    tibble::tibble(episode = seq_along(curves[[nm]]), value = smooth(curves[[nm]]), name = nm)
  }))
  ggplot2::ggplot(df, ggplot2::aes(episode, value, colour = name)) +
    ggplot2::geom_line() +
    ggplot2::labs(x = "episode", y = "return (smoothed)", colour = NULL, title = "Function-approximation learning curves") +
    ggplot2::theme_minimal()
}
