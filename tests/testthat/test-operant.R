test_that("concurrent VI delivers reinforcement", {
  set.seed(0)
  env <- concurrent_vi(c(5, 5))
  env$reset(seed = 0)
  got <- sum(vapply(seq_len(2000), function(i) env$step((i %% 2) + 1)$reward, numeric(1)))
  expect_gt(got, 0)
})

test_that("operant chamber extinction zeroes reinforcement", {
  set.seed(0)
  env <- operant_chamber(schedule = make_schedule("VR", 3))
  acq <- sum(vapply(seq_len(2000), function(i) env$step(1L)$reward, numeric(1)))
  env$set_extinction(TRUE)
  ext <- sum(vapply(seq_len(2000), function(i) env$step(1L)$reward, numeric(1)))
  expect_gt(acq, 0)
  expect_lte(ext, 0)
})

test_that("schedule factory returns the right kinds", {
  expect_true(is.list(make_schedule("FR", 2)))
  expect_true(is.list(make_schedule("VI", 2)))
})

test_that("melioration trap points differ", {
  tr <- melioration_trap()
  expect_gt(tr$matching_point()$x_match, tr$optimum()$x_opt)
  expect_gt(tr$optimum()$rate_opt, tr$matching_point()$rate_match)
})

test_that("maximizing escapes the trap, melioration is caught", {
  out <- melioration_trap_experiment(n_steps = 30000, seed = 0)
  mel <- out$rules$reward_rate_tail[out$rules$rule == "melioration"]
  esarsa <- out$rules$reward_rate_tail[out$rules$rule == "expected_sarsa"]
  expect_gt(esarsa, mel)
  expect_gt(out$rules$x_tail[out$rules$rule == "melioration"], 0.6)
})

test_that("interval schedules grade, ratio is exclusive", {
  t <- schedule_matching_table(n_steps = 10000, seed = 0)
  expect_gte(t$slope[t$schedule == "conc_VI_VI"], 0.6)
  expect_lte(t$slope[t$schedule == "conc_VI_VI"], 1.4)
  expect_gt(t$mean_exclusivity[t$schedule == "conc_VR_VR"], 0.85)
})

test_that("extinction acquires then extinguishes", {
  out <- extinction_experiment(acquire_steps = 6000, extinction_steps = 6000, seed = 0)
  expect_gt(out$acq_response_rate[out$schedule == "CRF"], 0.8)
  expect_lt(out$steps_to_extinction[out$schedule == "CRF"], 6000)
})
