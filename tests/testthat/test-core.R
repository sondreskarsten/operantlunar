test_that("featurizer maps bounds correctly", {
  f <- lunar_featurizer(n_bins = 7)
  expect_equal(f(lunar_low), "0_0_0_0_0_0_0_0")
  expect_equal(f(lunar_high), "6_6_6_6_6_6_1_1")
})

test_that("softmax is a simplex", {
  p <- softmax(c(1, 2, 3, 0))
  expect_equal(sum(p), 1)
  expect_true(all(p > 0))
})

test_that("td update moves toward target", {
  a <- td_agent(alpha = 0.5, gamma = 0)
  tbl <- make_table(4L)
  a$update(tbl, "s", 2L, 10, "s", TRUE)
  expect_equal(table_get(tbl, "s", 4L)[2], 5)
})

test_that("melioration update raises chosen preference", {
  b <- melioration_agent(alpha = 0.5, beta = 1, baseline = FALSE)
  tbl <- make_table(4L)
  b$update(tbl, "s", 3L, 1, "s", FALSE)
  expect_gt(table_get(tbl, "s", 4L)[3], 0)
})

test_that("table_get defaults to zeros", {
  tbl <- make_table(4L)
  expect_equal(table_get(tbl, "missing", 4L), numeric(4))
})

test_that("selectors return valid actions", {
  set.seed(1)
  tbl <- make_table(4L)
  expect_true(td_agent()$select(tbl, "s") %in% 1:4)
  expect_true(melioration_agent()$select(tbl, "s") %in% 1:4)
})

test_that("bush mosteller stays on the simplex", {
  p <- bush_mosteller_step(c(0.5, 0.5), 1L, TRUE, alpha = 0.2)
  expect_equal(sum(p), 1)
  expect_gt(p[1], 0.5)
})

test_that("matching law holds on concurrent VI", {
  fit <- fit_generalized_matching(n_steps = 10000, seed = 0)
  expect_gte(fit$slope, 0.6)
  expect_lte(fit$slope, 1.4)
})
