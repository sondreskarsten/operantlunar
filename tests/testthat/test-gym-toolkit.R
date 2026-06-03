test_that("contingency_env gates reward by active channel", {
  base <- fa_channel_env("escape", arms = c("escape", "goal"), response_cost = 0)
  on <- contingency_env(base, active = "escape")
  on$reset(seed = 0)
  off <- contingency_env(base, active = "goal")
  off$reset(seed = 0)
  expect_gt(on$step(1)$reward, 0)
  expect_equal(off$step(1)$reward, 0)
})

test_that("gridworld_env terminates at an arm end with that channel reinforced", {
  env <- gridworld_env(arms = c("a", "b"), corridor = 2L)
  env$reset(seed = 0)
  o1 <- env$step(1)
  expect_false(o1$terminated)
  o2 <- env$step(1)
  expect_true(o2$terminated)
  expect_gt(o2$channels[["a"]], 0)
})

test_that("gym_functional_analysis recovers a planted maintaining channel", {
  for (f in c("escape", "tangible")) {
    fa <- gym_functional_analysis(f, n_steps = 12000L, seed = 1L)
    expect_identical(fa$identified_channel, f)
    expect_true(fa$correct)
  }
})

test_that("gym_dra reallocates from problem to alternative arm", {
  d <- gym_dra(n_baseline = 300L, n_treatment = 500L, window = 50L, seed = 1L)
  sw <- d$switch_ep[1]
  al <- d[d$arm == "alternative", ]
  base_alt <- mean(al$reach_rate[al$window_mid <= sw])
  treat_alt <- tail(al$reach_rate[al$window_mid > sw], 1)
  expect_gt(treat_alt - base_alt, 0.4)
})

test_that("aba_gym_mapping documents instruments as RL framing", {
  m <- aba_gym_mapping()
  expect_true(all(c("instrument", "rl_problem", "gym_mechanism", "diagnoses_or_changes") %in% names(m)))
  expect_true("Functional analysis" %in% m$instrument)
})

test_that("gym_extinction shows acquired behaviour weaken when reinforcement is withdrawn", {
  skip_if_not(reticulate::py_module_available("gymnasium"))
  builder <- function() as_channel_env(make_gym("FrozenLake-v1", is_slippery = FALSE), "goal")
  d <- gym_extinction(builder, n_acquire = 600L, n_extinction = 30L, eval_every = 10L, n_eval = 15L, max_steps = 40L, seed = 1L)
  expect_true(all(c("episode", "eval_success") %in% names(d)))
  expect_lte(tail(d$eval_success, 1), d$eval_success[1] + 0.01)
})

test_that("gym toolkit plots return ggplot objects", {
  fa <- gym_functional_analysis("escape", n_steps = 6000L, seed = 1L)
  expect_s3_class(plot_gym_functional_analysis(fa), "ggplot")
  d <- gym_dra(n_baseline = 200L, n_treatment = 300L, seed = 1L)
  expect_s3_class(plot_gym_dra(d), "ggplot")
})
