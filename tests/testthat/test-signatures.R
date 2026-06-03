test_that("fi_chamber reinforces only at or after the interval", {
  ch <- fi_chamber(interval = 5, magnitude = 1, response_cost = 0.02)
  ch$reset(seed = 0)
  o1 <- ch$step(1)
  expect_lt(o1$reward, 0)
  ch$step(2)
  ch$step(2)
  ch$step(2)
  o5 <- ch$step(1)
  expect_gt(o5$reward, 0)
})

test_that("cumulative_record accumulates responses and flags reinforcers", {
  cr <- cumulative_record(c(1, 2, 1, 1), c(0, 0, 1, 0))
  expect_equal(cr$responses, c(1, 1, 2, 3))
  expect_equal(cr$reinforcer, c(FALSE, FALSE, TRUE, FALSE))
})

test_that("schedule_record_demo returns a monotone record of the tail window", {
  cr <- schedule_record_demo("VR", 10, n_steps = 2000L, window = 200L, seed = 1L)
  expect_equal(nrow(cr), 200L)
  expect_true(all(diff(cr$responses) >= 0))
})

test_that("fi_temporal_demo shows responding concentrated at the interval boundary", {
  d <- fi_temporal_demo(interval = 20, n_steps = 16000L, window = 5000L, seed = 1L)
  bt <- d$by_time
  early <- mean(bt$response_rate[bt$elapsed < d$interval - 1])
  late <- mean(bt$response_rate[bt$elapsed >= d$interval - 1])
  expect_gt(late - early, 0.2)
})

test_that("aba_toolkit has the expected structure and functional analysis is an assessment", {
  tk <- aba_toolkit()
  expect_true(all(c("tool", "type", "env", "what_it_does", "validation", "note") %in% names(tk)))
  expect_true(all(tk$type %in% c("assessment", "intervention")))
  expect_equal(tk$type[tk$tool == "Functional analysis"], "assessment")
  expect_true(any(grepl("Differential reinforcement", tk$tool) & tk$type == "intervention"))
})

test_that("signature plots return ggplot objects", {
  cr <- cumulative_record(c(1, 1, 2, 1), c(1, 0, 0, 1))
  expect_s3_class(plot_cumulative_record(cr), "ggplot")
})

test_that("dra_fct_demo reallocates from problem to alternative after treatment onset", {
  d <- dra_fct_demo(baseline = 3000L, treatment = 6000L, window = 300L, seed = 1L)
  sw <- d$switch_step[1]
  alt <- d[d$response == "alternative", ]
  base_alt <- mean(alt$rate[alt$window_mid <= sw])
  treat_alt_end <- tail(alt$rate[alt$window_mid > sw], 1)
  expect_gt(treat_alt_end - base_alt, 0.5)
})

test_that("basic_phenomena holds reproduced and not-reproduced phenomena", {
  ph <- basic_phenomena()
  expect_true(all(c("phenomenon", "status", "env", "shows", "note") %in% names(ph)))
  expect_true(all(c("reproduced", "not reproduced", "partial") %in% ph$status))
  expect_true("Matching law" %in% ph$phenomenon)
})

test_that("functional_analysis recovers a planted maintaining function", {
  for (f in c("attention", "escape", "tangible", "automatic")) {
    fa <- functional_analysis(true_function = f, n_steps = 12000L, seed = 1L)
    expect_identical(fa$identified_function, f)
    expect_true(fa$correct)
  }
})
