# Two-pipelines convergence demonstration on the procedural gridworld

The headline demonstration on the navigation substrate. Because
navigation is slow to learn, an ad hoc pipeline with an arbitrary
session budget reaches a conclusion that depends on that budget
(under-trained subjects look undifferentiated), while the protocol's
steady-state stopping detects non-convergence and keeps training, so its
verdict is invariant to the budget and seed pool. The apparatus
(`env_seed`) is held constant across both.

## Usage

``` r
convergence_demo_gridworld(
  true_function = "escape",
  arms = c("attention", "escape", "tangible", "goal"),
  env_seed = 1L,
  episodes_per_session = 15L,
  max_steps = 40L,
  size = 6L,
  n_walls = 6L,
  slip = 0.05,
  step_cost = 0.04,
  n_sessions_grid = c(12L, 28L),
  n_seeds_grid = c(1L, 3L),
  keep_set = c("first", "pool"),
  seed_offsets = c(0L, 50L, 100L),
  n_protocol_subjects = 12L,
  min_sessions = 22L,
  max_sessions = 45L,
  k = 10L
)
```

## Arguments

- true_function, arms, env_seed, episodes_per_session, max_steps, size,
  n_walls, slip, step_cost:

  Gridworld parameters.

- n_sessions_grid, n_seeds_grid, keep_set, seed_offsets,
  n_protocol_subjects:

  Grid of researcher choices.

- min_sessions, max_sessions, k:

  Protocol steady-state parameters.

## Value

The list returned by the internal grid runner: `results`,
`adhoc_distinct`, `protocol_distinct`, `protocol_verdict`.
