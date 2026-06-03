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

test_that("behavioral_signatures has the expected structure and honest statuses", {
  s <- behavioral_signatures()
  expect_true(all(c("signature", "glossary_term", "agent", "paradigm", "shows", "status", "note") %in% names(s)))
  expect_true(all(c("reproduced", "not reproduced", "partial") %in% s$status))
  expect_true(all(s$glossary_term %in% operant_glossary()$term))
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

test_that("behavioral_signatures has group column with both strata and DRA/FCT in the core", {
  s <- behavioral_signatures()
  expect_true("group" %in% names(s))
  expect_true(all(c("Applied-robust core", "Basic-science (not applied-robust)") %in% s$group))
  expect_true("DRA / FCT reallocation" %in% s$signature[s$group == "Applied-robust core"])
})
