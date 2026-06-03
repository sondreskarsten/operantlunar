library(shiny)
library(operantlunar)

ui <- fluidPage(
  titlePanel("operantlunar — maximizing vs meliorating"),
  tabsetPanel(
    tabPanel(
      "Melioration trap",
      sidebarLayout(
        sidebarPanel(
          sliderInput("trap_steps", "Steps per rule", min = 10000, max = 80000, value = 40000, step = 10000),
          numericInput("trap_seed", "Seed", value = 0),
          actionButton("trap_run", "Run", class = "btn-primary"),
          helpText("Q-learning and expected-SARSA escape the trap via foresight; melioration is caught.")
        ),
        mainPanel(plotOutput("trap_plot"), tableOutput("trap_table"))
      )
    ),
    tabPanel(
      "Schedule matching",
      sidebarLayout(
        sidebarPanel(
          sliderInput("sched_steps", "Steps per condition", min = 5000, max = 30000, value = 15000, step = 5000),
          numericInput("sched_seed", "Seed", value = 0),
          actionButton("sched_run", "Run", class = "btn-primary"),
          helpText("Interval schedules give graded matching (slope approx 1); ratio gives exclusive choice.")
        ),
        mainPanel(tableOutput("sched_table"))
      )
    ),
    tabPanel(
      "Extinction",
      sidebarLayout(
        sidebarPanel(
          sliderInput("ext_acq", "Acquisition steps", min = 2000, max = 12000, value = 8000, step = 2000),
          sliderInput("ext_ext", "Extinction steps", min = 2000, max = 12000, value = 8000, step = 2000),
          numericInput("ext_seed", "Seed", value = 0),
          actionButton("ext_run", "Run", class = "btn-primary"),
          helpText("Acquired-value-magnitude effect: CRF is most resistant (anti-PREE).")
        ),
        mainPanel(plotOutput("ext_plot"), tableOutput("ext_table"))
      )
    ),
    tabPanel(
      "LunarLander (Python)",
      sidebarLayout(
        sidebarPanel(
          numericInput("ll_train", "Training episodes", value = 100, min = 20, max = 1000),
          numericInput("ll_eval", "Eval episodes", value = 20, min = 5, max = 200),
          numericInput("ll_bins", "Bins", value = 7, min = 3, max = 12),
          numericInput("ll_seed", "Seed", value = 0),
          actionButton("ll_run", "Run", class = "btn-primary"),
          helpText("Requires reticulate + gymnasium[box2d]; provisioned on first run via lunar_setup().")
        ),
        mainPanel(plotOutput("ll_plot"), verbatimTextOutput("ll_text"))
      )
    )
  )
)

server <- function(input, output, session) {
  trap_res <- eventReactive(input$trap_run, {
    melioration_trap_experiment(n_steps = as.integer(input$trap_steps), seed = as.integer(input$trap_seed))
  })
  output$trap_plot <- renderPlot(plot_trap(trap_res()))
  output$trap_table <- renderTable({
    r <- trap_res()
    tab <- r$rules
    tab$optimum_rate <- r$optimum$rate_opt
    tab$matching_rate <- r$matching_point$rate_match
    tab
  })

  sched_res <- eventReactive(input$sched_run, {
    schedule_matching_table(n_steps = as.integer(input$sched_steps), seed = as.integer(input$sched_seed))
  })
  output$sched_table <- renderTable(sched_res())

  ext_res <- eventReactive(input$ext_run, {
    extinction_experiment(acquire_steps = as.integer(input$ext_acq), extinction_steps = as.integer(input$ext_ext), seed = as.integer(input$ext_seed))
  })
  output$ext_plot <- renderPlot(plot_extinction(ext_res()))
  output$ext_table <- renderTable(ext_res())

  ll_res <- eventReactive(input$ll_run, {
    lunar_setup()
    differentiate(n_train = as.integer(input$ll_train), n_eval = as.integer(input$ll_eval), n_bins = as.integer(input$ll_bins), seed = as.integer(input$ll_seed))
  })
  output$ll_plot <- renderPlot(plot_training(ll_res()))
  output$ll_text <- renderPrint({
    r <- ll_res()
    cat(sprintf("TD eval:          %.1f +/- %.1f\n", r$td_eval_mean, r$td_eval_sd))
    cat(sprintf("Melioration eval: %.1f +/- %.1f\n", r$melioration_eval_mean, r$melioration_eval_sd))
    cat(sprintf("Policy divergence (mean TV): %.2f\n", r$policy_divergence$mean_tv))
    cat(sprintf("Argmax agreement: %.2f\n", r$policy_divergence$argmax_agreement))
    cat(sprintf("States compared: %d\n", r$n_states_compared))
  })
}

shinyApp(ui, server)
