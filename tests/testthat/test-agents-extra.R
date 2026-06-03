test_that("new agent constructors expose the agent interface", {
  for (ctor in list(sarsa_agent, double_q_agent, actor_critic_agent, melioration_rate_agent, model_based_agent)) {
    a <- ctor(n_actions = 2L)
    expect_true(all(c("select", "update", "greedy") %in% names(a)))
    expect_true(is.function(a$select))
    expect_true(is.function(a$update))
  }
  w <- win_stay_lose_shift_agent(n_actions = 2L)
  expect_true(all(c("select", "update", "greedy") %in% names(w)))
})

test_that("agent registry and make_agent build runnable agents", {
  reg <- agent_registry()
  expect_true(all(c("q_learning", "sarsa", "double_q", "actor_critic", "model_based", "melioration", "melioration_rate", "win_stay_lose_shift") %in% names(reg)))
  for (nm in names(reg)) {
    ag <- make_agent(nm, n_actions = 2L, horizon = 1000L)
    tbl <- make_table(2L)
    a <- ag$select(tbl, "S0")
    expect_true(a %in% c(1L, 2L))
    ag$update(tbl, "S0", a, 1, "S0", FALSE)
    expect_true(ag$greedy(tbl, "S0") %in% c(1L, 2L))
  }
})

test_that("agent_kind maps rules to behavioral classes", {
  expect_identical(agent_kind("q_learning"), "maximizer")
  expect_identical(agent_kind("model_based"), "maximizer")
  expect_identical(agent_kind("melioration"), "meliorator")
  expect_identical(agent_kind("melioration_rate"), "meliorator")
  expect_identical(agent_kind("win_stay_lose_shift"), "heuristic")
})

test_that("win-stay-lose-shift repeats after reward and shifts after none", {
  w <- win_stay_lose_shift_agent(n_actions = 2L)
  w$select(make_table(2L), "S0")
  w$update(NULL, "S0", 1L, 1, "S0", FALSE)
  expect_identical(w$greedy(NULL, "S0"), 1L)
  w$update(NULL, "S0", 1L, 0, "S0", FALSE)
  expect_identical(w$greedy(NULL, "S0"), 2L)
})
