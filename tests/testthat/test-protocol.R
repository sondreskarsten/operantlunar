test_that("criterion_line_verdict applies the Hagopian rule", {
  ctrl <- c(0.04, 0.05, 0.06, 0.05, 0.05)
  last_k <- tibble::tibble(
    session = rep(1:5, 5),
    condition = rep(c("attention", "escape", "tangible", "goal", "play"), each = 5),
    rate = c(rep(0.05, 5), rep(0.9, 5), rep(0.05, 5), rep(0.05, 5), ctrl)
  )
  cl <- criterion_line_verdict(last_k, control = "play")
  expect_identical(cl$verdict, "escape")
  expect_equal(cl$detail$D[cl$detail$condition == "escape"], 5)
  expect_equal(cl$detail$threshold[cl$detail$condition == "escape"], 3)
  flat <- tibble::tibble(
    session = rep(1:5, 5),
    condition = rep(c("attention", "escape", "tangible", "goal", "play"), each = 5),
    rate = c(rep(0.05, 5), rep(0.05, 5), rep(0.05, 5), rep(0.05, 5), ctrl)
  )
  expect_identical(criterion_line_verdict(flat, control = "play")$verdict, "undifferentiated")
})

test_that("stability_reached distinguishes stable from trending series", {
  stable <- tibble::tibble(session = 1:12, condition = "play", rate = c(rep(0.2, 6), 0.21, 0.19, 0.2, 0.2, 0.21, 0.2))
  expect_true(stability_reached(stable, k = 10L, tol_trend = 0.1, tol_bounce = 0.25))
  trending <- tibble::tibble(session = 1:12, condition = "play", rate = seq(0.1, 0.9, length.out = 12))
  expect_false(stability_reached(trending, k = 10L, tol_trend = 0.1, tol_bounce = 0.25))
  short <- tibble::tibble(session = 1:5, condition = "play", rate = rep(0.2, 5))
  expect_false(stability_reached(short, k = 10L))
})

test_that("fa_stochastic_env honours the engage/withhold contract", {
  env <- fa_stochastic_env(true_function = "escape", p_reinforce = 1, p_noise = 0, response_cost = 0.1)
  env$reset(seed = 1L)
  o_engage <- env$step(1L)
  expect_identical(unname(o_engage$channels["escape"]), 1)
  expect_equal(o_engage$reward, 0.9)
  o_withhold <- env$step(2L)
  expect_equal(sum(o_withhold$channels), 0)
  expect_equal(o_withhold$reward, 0)
  expect_identical(env$n_actions, 2L)
})

test_that("fa_subject recovers the planted function under a clean contingency", {
  s <- fa_subject(true_function = "escape", agent_seed = 1L, p_reinforce = 0.8,
                  session_len = 50L, min_sessions = 12L, max_sessions = 25L, k = 8L)
  expect_identical(s$verdict, "escape")
  expect_true(s$stable)
  expect_true(all(c("rates", "last_k", "detail") %in% names(s)))
})

test_that("functional_analysis_replicated returns an idiographic reliability summary", {
  r <- functional_analysis_replicated(true_function = "escape", p_reinforce = 0.8, n_subjects = 4L, min_subjects = 4L,
                                       session_len = 50L, min_sessions = 12L, max_sessions = 25L, k = 8L)
  expect_true(all(c("subjects", "summary", "distribution", "modal_verdict", "agreement") %in% names(r)))
  expect_identical(nrow(r$subjects), 4L)
  expect_identical(r$modal_verdict, "escape")
  expect_true(r$agreement <= 1 && r$agreement >= 0)
})

test_that("procedural_gridworld layout is seed-reproducible and stay is free", {
  g1 <- procedural_gridworld(env_seed = 7L, size = 4L, n_walls = 2L)
  g2 <- procedural_gridworld(env_seed = 7L, size = 4L, n_walls = 2L)
  expect_identical(g1$source_cell, g2$source_cell)
  g3 <- procedural_gridworld(env_seed = 8L, size = 4L, n_walls = 2L)
  expect_false(identical(g1$source_cell, g3$source_cell))
  expect_identical(g1$n_actions, 5L)
  expect_identical(names(g1$source_cell), g1$arms)
  r0 <- g1$reset(seed = 1L)
  o <- g1$step(5L)
  expect_equal(o$reward, 0)
  expect_false(o$terminated)
  expect_identical(o$obs, r0$obs)
})

test_that("fa_subject_gridworld recovers the planted function", {
  g <- fa_subject_gridworld(true_function = "escape", env_seed = 1L, agent_seed = 1L, size = 4L, n_walls = 2L,
                            episodes_per_session = 10L, min_sessions = 15L, max_sessions = 30L, k = 8L, max_steps = 20L)
  expect_identical(g$verdict, "escape")
})

test_that("reversal_probe shows behaviour tracking the contingency reversal", {
  rp <- reversal_probe(true_function = "escape", reversal_function = "attention", agent_seed = 1L, p_reinforce = 0.8,
                       session_len = 50L, train_sessions = 15L, probe_sessions = 10L, k = 8L)
  expect_true(rp$tracked)
  expect_gt(rp$summary$new_post, rp$summary$old_post)
})

test_that("convergence_demo returns both pipelines and a protocol verdict", {
  d <- convergence_demo(true_function = "escape", p_reinforce = 0.8, n_sessions_grid = c(20L), n_seeds_grid = c(1L),
                        keep_set = c("first"), seed_offsets = c(0L), n_protocol_subjects = 4L, session_len = 50L)
  expect_true(all(c("ad hoc", "protocol") %in% d$results$pipeline))
  expect_true(is.numeric(d$adhoc_distinct))
  expect_identical(d$protocol_verdict, "escape")
})
