test_that("probability matching: value maximizes, rate-tracking matches", {
  res <- prob_matching_experiment(probs = c(0.75, 0.25), rules = c("q_learning", "melioration_rate"), n_steps = 8000L, seed = 1L)
  q <- res$rules$frac_optimal[res$rules$rule == "q_learning"]
  mr <- res$rules$p_richer[res$rules$rule == "melioration_rate"]
  expect_gt(q, 0.9)
  expect_lt(mr, 0.9)
})

test_that("self-control: value/model-based choose large-later, melioration is impulsive", {
  res <- self_control_experiment(rules = c("q_learning", "melioration"), n_steps = 20000L, seed = 0L)
  expect_gt(res$rules$frac_LL[res$rules$rule == "q_learning"], 0.8)
  expect_lt(res$rules$frac_LL[res$rules$rule == "melioration"], 0.2)
})

test_that("DRL: a value maximizer spaces responses and earns reward", {
  res <- drl_experiment(rules = c("q_learning", "melioration"), threshold = 15L, n_steps = 16000L, seed = 0L)
  q <- res$rules[res$rules$rule == "q_learning", ]
  expect_lt(q$response_rate, 0.25)
  expect_gt(q$reward_rate, 0.01)
})

test_that("devaluation: model-based revalues, model-free and melioration persist", {
  res <- devaluation_experiment(rules = c("q_learning", "model_based"), acquire_steps = 5000L, seed = 0L)
  expect_gt(res$rules$test_press_rate[res$rules$rule == "q_learning"], 0.8)
  expect_lt(res$rules$test_press_rate[res$rules$rule == "model_based"], 0.2)
})

test_that("self-control environment equalizes trial length", {
  env <- self_control_env(ss_amount = 1, ss_delay = 0, ll_amount = 5, ll_delay = 10)
  expect_equal(env$trial_length, 11)
  env$reset(seed = 0)
  o <- env$step(2L)
  expect_equal(o$reward, 0)
})

test_that("DRL chamber tracks inter-response time and reinforces only above threshold", {
  env <- drl_chamber(threshold = 5, magnitude = 1, response_cost = 0)
  env$reset(seed = 0)
  for (i in 1:5) o <- env$step(2L)
  expect_equal(o$obs, 5)
  rewarded <- env$step(1L)
  expect_equal(rewarded$reward, 1)
  env$step(2L)
  early <- env$step(1L)
  expect_equal(early$reward, 0)
})
