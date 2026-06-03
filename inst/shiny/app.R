library(shiny)
library(operantlunar)

all_rules <- c("q_learning", "sarsa", "expected_sarsa", "double_q", "actor_critic",
               "model_based", "melioration", "melioration_rate", "win_stay_lose_shift")

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
      "Probability matching",
      sidebarLayout(
        sidebarPanel(
          checkboxGroupInput("pm_rules", "Rules", choices = all_rules,
                             selected = c("q_learning", "melioration", "melioration_rate")),
          sliderInput("pm_p1", "P(reward | richer)", min = 0.55, max = 0.95, value = 0.75, step = 0.05),
          sliderInput("pm_steps", "Steps per rule", min = 4000, max = 30000, value = 12000, step = 2000),
          numericInput("pm_seed", "Seed", value = 0),
          actionButton("pm_run", "Run", class = "btn-primary"),
          downloadButton("pm_csv", "Download CSV"),
          helpText("A maximizer goes exclusive; rate-tracking melioration matches the probabilities.")
        ),
        mainPanel(plotOutput("pm_plot"), tableOutput("pm_table"))
      )
    ),
    tabPanel(
      "Self-control",
      sidebarLayout(
        sidebarPanel(
          sliderInput("sc_lldelay", "Large-later delay", min = 4, max = 20, value = 10, step = 1),
          sliderInput("sc_llamt", "Large-later amount", min = 2, max = 10, value = 5, step = 1),
          sliderInput("sc_steps", "Steps per rule", min = 10000, max = 50000, value = 24000, step = 2000),
          numericInput("sc_seed", "Seed", value = 0),
          actionButton("sc_run", "Run", class = "btn-primary"),
          helpText("Trial length is equalized so large-later is better. Melioration stays impulsive.")
        ),
        mainPanel(plotOutput("sc_plot"), tableOutput("sc_table"))
      )
    ),
    tabPanel(
      "DRL",
      sidebarLayout(
        sidebarPanel(
          sliderInput("drl_thresh", "IRT threshold", min = 5, max = 30, value = 15, step = 1),
          sliderInput("drl_steps", "Steps per rule", min = 8000, max = 40000, value = 20000, step = 2000),
          numericInput("drl_seed", "Seed", value = 0),
          actionButton("drl_run", "Run", class = "btn-primary"),
          helpText("Reinforced only above the IRT threshold. Annealed-exploration value rules learn to space.")
        ),
        mainPanel(plotOutput("drl_plot"), tableOutput("drl_table"))
      )
    ),
    tabPanel(
      "Differentiation matrix",
      sidebarLayout(
        sidebarPanel(
          checkboxGroupInput("dm_rules", "Rules", choices = all_rules,
                             selected = c("q_learning", "double_q", "actor_critic", "melioration", "melioration_rate", "win_stay_lose_shift")),
          checkboxGroupInput("dm_paradigms", "Paradigms",
                             choices = c("prob_matching", "trap", "drl", "self_control"),
                             selected = c("prob_matching", "trap", "drl", "self_control")),
          sliderInput("dm_steps", "Steps per cell", min = 8000, max = 40000, value = 24000, step = 2000),
          numericInput("dm_seed", "Seed", value = 0),
          actionButton("dm_run", "Run", class = "btn-primary"),
          downloadButton("dm_csv", "Download CSV"),
          helpText("Maximize score per rule per paradigm: 1 = maximizing, low = matching. Self-control needs ~24k+ steps.")
        ),
        mainPanel(plotOutput("dm_plot"), tableOutput("dm_table"), tableOutput("dm_class"))
      )
    ),
    tabPanel(
      "Operant primer",
      sidebarLayout(
        sidebarPanel(
          selectInput("primer_cat", "Category", choices = c("All", sort(unique(operant_glossary()$category))), selected = "All"),
          textInput("primer_search", "Search term / definition", ""),
          downloadButton("primer_csv", "Download glossary CSV"),
          helpText("A verified operant-conditioning glossary plus the bundled handbook corpus. Every definition was checked against the literature; full sources are in the bibliography.")
        ),
        mainPanel(
          h4("Glossary"),
          tableOutput("primer_glossary"),
          h4("Bibliography (handbook corpus + primary sources)"),
          tableOutput("primer_biblio")
        )
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

  pm_res <- eventReactive(input$pm_run, {
    prob_matching_experiment(probs = c(input$pm_p1, 1 - input$pm_p1), rules = input$pm_rules,
                             n_steps = as.integer(input$pm_steps), seed = as.integer(input$pm_seed))
  })
  output$pm_plot <- renderPlot(plot_prob_matching(pm_res()))
  output$pm_table <- renderTable(pm_res()$rules)
  output$pm_csv <- downloadHandler(
    filename = function() "prob_matching.csv",
    content = function(file) utils::write.csv(pm_res()$rules, file, row.names = FALSE)
  )

  sc_res <- eventReactive(input$sc_run, {
    self_control_experiment(rules = c("q_learning", "melioration", "model_based"),
                            ll_amount = input$sc_llamt, ll_delay = as.integer(input$sc_lldelay),
                            n_steps = as.integer(input$sc_steps), seed = as.integer(input$sc_seed))
  })
  output$sc_plot <- renderPlot(plot_self_control(sc_res()))
  output$sc_table <- renderTable(sc_res()$rules)

  drl_res <- eventReactive(input$drl_run, {
    drl_experiment(threshold = as.integer(input$drl_thresh), n_steps = as.integer(input$drl_steps), seed = as.integer(input$drl_seed))
  })
  output$drl_plot <- renderPlot(plot_drl(drl_res()))
  output$drl_table <- renderTable(drl_res()$rules)

  dm_res <- eventReactive(input$dm_run, {
    differentiation_matrix(rules = input$dm_rules, paradigms = input$dm_paradigms,
                           n_steps = as.integer(input$dm_steps), seed = as.integer(input$dm_seed))
  })
  output$dm_plot <- renderPlot(plot_differentiation_matrix(dm_res()))
  output$dm_table <- renderTable(dm_res()$wide)
  output$dm_class <- renderTable(dm_res()$classification)
  output$dm_csv <- downloadHandler(
    filename = function() "differentiation_matrix.csv",
    content = function(file) utils::write.csv(dm_res()$long, file, row.names = FALSE)
  )

  primer_data <- reactive({
    g <- operant_glossary()
    if (!is.null(input$primer_cat) && input$primer_cat != "All") g <- g[g$category == input$primer_cat, ]
    q <- input$primer_search
    if (is.null(q)) q <- ""
    q <- trimws(tolower(q))
    if (nzchar(q)) g <- g[grepl(q, tolower(paste(g$term, g$definition)), fixed = TRUE), ]
    g
  })
  output$primer_glossary <- renderTable(primer_data()[, c("term", "category", "definition", "primary_source", "handbook")])
  output$primer_biblio <- renderTable(operant_bibliography()[, c("key", "type", "citation")])
  output$primer_csv <- downloadHandler(
    filename = function() "operant_glossary.csv",
    content = function(file) utils::write.csv(operant_glossary(), file, row.names = FALSE)
  )

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
