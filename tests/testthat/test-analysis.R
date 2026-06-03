test_that("Herrnstein hyperbola recovers generating parameters", {
  r <- c(0.005, 0.01, 0.02, 0.05, 0.1, 0.2)
  B <- 0.8 * r / (r + 0.03)
  fit <- fit_herrnstein_hyperbola(r, B)
  expect_gt(fit$k, 0.5)
  expect_lt(fit$k, 1.2)
  expect_gt(fit$r0, 0.01)
  expect_lt(fit$r0, 0.06)
})

test_that("discounting fit recovers k", {
  delays <- c(1, 2, 5, 10, 20, 40)
  v <- 5 / (1 + 0.1 * delays)
  fit <- fit_discounting(delays, v, model = "hyperbolic")
  expect_gt(fit$k, 0.05)
  expect_lt(fit$k, 0.2)
})

test_that("matching sensitivity recovers the slope", {
  log_r <- log(c(0.25, 0.5, 1, 2, 4))
  log_b <- 0.9 * log_r + 0.05 + c(0.012, -0.009, 0.004, -0.006, 0.001)
  out <- matching_sensitivity_bias(log_r, log_b)
  expect_gt(out$sensitivity, 0.8)
  expect_lt(out$sensitivity, 1.0)
})

test_that("classify_rule and regret behave", {
  expect_identical(classify_rule(0.95), "maximizing")
  expect_identical(classify_rule(0.6), "intermediate")
  expect_identical(classify_rule(0.2), "matching")
  expect_equal(regret(0.4, 0.48), 0.08)
  expect_equal(regret(0.5, 0.48), 0)
})

test_that("differentiation matrix returns long, wide, and classification", {
  dm <- differentiation_matrix(rules = c("q_learning", "melioration"), paradigms = c("prob_matching", "trap"), n_steps = 4000L)
  expect_true(all(c("long", "wide", "classification") %in% names(dm)))
  expect_setequal(colnames(dm$wide), c("rule", "prob_matching", "trap"))
  expect_identical(nrow(dm$wide), 2L)
  expect_true(all(c("rule", "kind", "mean_score", "label") %in% names(dm$classification)))
})
