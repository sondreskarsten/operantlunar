test_that("lunar_returns loads the bundled dataset", {
  r <- lunar_returns()
  expect_true(all(c("policy_seed", "terrain_seed", "ret") %in% names(r)))
  expect_identical(nrow(r), 800L)
  expect_setequal(unique(r$policy_seed), c(0L, 1L, 2L, 3L))
})

test_that("lunar_steady_state_return reads a settled estimate", {
  ss <- lunar_steady_state_return(policy_seed = 0L)
  expect_true(ss$stable)
  expect_gt(ss$estimate, 150)
  expect_lt(ss$estimate, 200)
  expect_lte(ss$n_episodes, 200L)
})

test_that("lunar_adhoc_solved returns a binary verdict", {
  a <- lunar_adhoc_solved(policy_seed = 0L, n_episodes = 10L, pool = 1L)
  expect_true(a$verdict %in% c("solved", "not solved"))
  expect_true(is.numeric(a$mean))
})

test_that("lunar_protocol_solved refuses the false solved claim with quantified confidence", {
  set.seed(1)
  pr <- lunar_protocol_solved(policy_seed = 0L, threshold = 200, n_boot = 500L)
  expect_identical(pr$verdict, "not solved")
  expect_lt(pr$estimate, 200)
  expect_lt(pr$bootstrap_solved_fraction, 0.2)
})

test_that("lunar_solved_convergence diverges ad hoc but not protocol", {
  d <- lunar_solved_convergence(policy_seed = 0L)
  expect_identical(d$adhoc_distinct, 2L)
  expect_identical(d$protocol_verdict, "not solved")
  expect_true(all(c("ad hoc", "protocol") %in% d$results$pipeline))
})

test_that("lunar_best_policy_convergence flips ad hoc, stable protocol", {
  b <- lunar_best_policy_convergence(policy_a = 0L, policy_b = 1L)
  expect_identical(b$protocol_verdict, "indistinguishable")
  expect_gte(b$adhoc_distinct, 1L)
})

test_that("lunar_training_reliability exposes the seed lottery", {
  r <- lunar_training_reliability(threshold = 200)
  expect_identical(r$n_total, 4L)
  expect_identical(r$n_solved, 0L)
  expect_identical(nrow(r$per_seed), 4L)
})
