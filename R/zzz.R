utils::globalVariables(c("log_r", "log_b", "rule", "reward_rate_tail", "schedule", "steps_to_extinction", "episode", "return_val", "series"))

#' Launch the bundled Shiny app
#'
#' @param ... Passed to [shiny::runApp()].
#' @return Invisibly, the result of [shiny::runApp()].
#' @export
#' @examples
#' \dontrun{
#' run_app()
#' }
run_app <- function(...) {
  app_dir <- system.file("shiny", package = "operantlunar")
  shiny::runApp(app_dir, ...)
}
