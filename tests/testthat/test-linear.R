test_that("tile coder is deterministic and bounded", {
  coder <- tile_coder(c(-1, -1), c(1, 1), n_tilings = 4L, bins = 4L, table_size = 256L)
  e1 <- coder$encode(c(0.1, -0.2))
  e2 <- coder$encode(c(0.1, -0.2))
  expect_identical(e1, e2)
  expect_length(e1, 4L)
  expect_true(all(e1 >= 1 & e1 <= 256))
  expect_equal(coder$n_features, 256)
  expect_identical(coder$n_tilings, 4L)
})

test_that("tile coder clips out-of-range observations", {
  coder <- tile_coder(c(0, 0), c(1, 1), n_tilings = 2L, bins = 4L, table_size = 64L)
  expect_length(coder$encode(c(5, -5)), 2L)
})

test_that("linear SARSA updates weights on a transition", {
  coder <- tile_coder(c(-1, -1), c(1, 1), n_tilings = 4L, bins = 4L, table_size = 128L)
  ag <- linear_sarsa_agent(coder, n_actions = 2L, horizon = 100L)
  before <- sum(abs(ag$state$W))
  ag$update(c(0, 0), 1L, 1, c(0.1, 0.1), FALSE)
  expect_gt(sum(abs(ag$state$W)), before)
  expect_true(ag$greedy(c(0, 0)) %in% c(1L, 2L))
})

test_that("linear melioration updates preferences on a transition", {
  coder <- tile_coder(c(-1, -1), c(1, 1), n_tilings = 4L, bins = 4L, table_size = 128L)
  ag <- linear_melioration_agent(coder, n_actions = 2L)
  ag$update(c(0, 0), 1L, 1, c(0.1, 0.1), FALSE)
  ag$update(c(0, 0), 1L, 0, c(0.1, 0.1), FALSE)
  expect_gt(sum(abs(ag$state$H)), 0)
})

test_that("gym bounds known ids and fails loudly otherwise", {
  expect_type(gym_bounds("CartPole-v1"), "list")
  expect_length(gym_bounds("MountainCar-v0")$low, 2L)
  expect_error(gym_bounds("Nonexistent-v9"))
})
