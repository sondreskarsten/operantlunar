#' Plot the generalized matching law fit
#'
#' @param fit Output of [fit_generalized_matching()].
#' @return A ggplot.
#' @export
plot_matching <- function(fit) {
  ggplot2::ggplot(fit$data, ggplot2::aes(log_r, log_b)) +
    ggplot2::geom_abline(slope = 1, intercept = 0, linetype = 2, colour = "grey60") +
    ggplot2::geom_smooth(method = "lm", se = FALSE, colour = "#2c7fb8", formula = y ~ x) +
    ggplot2::geom_point(size = 3) +
    ggplot2::labs(
      title = sprintf("Matching law: slope = %.2f, bias = %.2f", fit$slope, fit$bias),
      x = "log reinforcer ratio", y = "log response ratio"
    ) +
    ggplot2::theme_minimal(base_size = 13)
}

#' Plot the melioration-trap result
#'
#' @param exp Output of [melioration_trap_experiment()].
#' @return A ggplot.
#' @export
plot_trap <- function(exp) {
  ggplot2::ggplot(exp$rules, ggplot2::aes(stats::reorder(rule, reward_rate_tail), reward_rate_tail)) +
    ggplot2::geom_col(fill = "#2c7fb8", width = 0.6) +
    ggplot2::geom_hline(yintercept = exp$optimum$rate_opt, linetype = 2, colour = "forestgreen") +
    ggplot2::geom_hline(yintercept = exp$matching_point$rate_match, linetype = 3, colour = "firebrick") +
    ggplot2::annotate("text", x = 0.7, y = exp$optimum$rate_opt, label = "optimum", vjust = -0.5, hjust = 0, colour = "forestgreen", size = 3.5) +
    ggplot2::annotate("text", x = 0.7, y = exp$matching_point$rate_match, label = "matching point", vjust = 1.4, hjust = 0, colour = "firebrick", size = 3.5) +
    ggplot2::labs(title = "Melioration trap: reward rate by rule", x = NULL, y = "tail reward rate") +
    ggplot2::coord_flip() +
    ggplot2::theme_minimal(base_size = 13)
}

#' Plot the extinction result
#'
#' @param df Output of [extinction_experiment()].
#' @return A ggplot.
#' @export
plot_extinction <- function(df) {
  ggplot2::ggplot(df, ggplot2::aes(stats::reorder(schedule, -steps_to_extinction), steps_to_extinction)) +
    ggplot2::geom_col(fill = "#756bb1", width = 0.6) +
    ggplot2::labs(title = "Resistance to extinction by acquisition schedule", x = NULL, y = "steps to extinction") +
    ggplot2::theme_minimal(base_size = 13)
}

#' Plot LunarLander training returns
#'
#' @param res Output of [differentiate()].
#' @return A ggplot.
#' @export
plot_training <- function(res) {
  df <- dplyr::bind_rows(
    tibble::tibble(episode = seq_along(res$train_a), return_val = res$train_a, series = "Q-learning"),
    tibble::tibble(episode = seq_along(res$train_b), return_val = res$train_b, series = "melioration")
  )
  ggplot2::ggplot(df, ggplot2::aes(episode, return_val, colour = series)) +
    ggplot2::geom_line(alpha = 0.8) +
    ggplot2::labs(title = "LunarLander training returns", x = "episode", y = "return", colour = NULL) +
    ggplot2::theme_minimal(base_size = 13)
}
