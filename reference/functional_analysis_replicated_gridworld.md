# Replicated gridworld functional analysis to a reliability conclusion

[`functional_analysis_replicated()`](https://sondreskarsten.github.io/operantlunar/reference/functional_analysis_replicated.md)
on the procedural gridworld: a fixed apparatus (`env_seed`) with
subjects (`agent_seed`s) replicated to a reliability conclusion, each
trained to steady state. Navigation makes the per-subject identification
genuinely effortful, so the reliability summary is informative rather
than trivially unanimous.

## Usage

``` r
functional_analysis_replicated_gridworld(
  true_function = "escape",
  arms = c("attention", "escape", "tangible", "goal"),
  env_seed = 1L,
  episodes_per_session = 20L,
  min_sessions = 25L,
  max_sessions = 45L,
  k = 10L,
  max_steps = 40L,
  size = 6L,
  n_walls = 6L,
  slip = 0.05,
  step_cost = 0.04,
  n_subjects = 16L,
  min_subjects = 8L,
  reliability_window = 4L,
  reliability_tol = 0.1,
  seed0 = 0L
)
```

## Arguments

- true_function, arms, env_seed, episodes_per_session, min_sessions,
  max_sessions, k, max_steps, size, n_walls, slip, step_cost:

  Gridworld subject parameters.

- n_subjects, min_subjects, reliability_window, reliability_tol, seed0:

  Replication parameters.

## Value

The list returned by
[`functional_analysis_replicated()`](https://sondreskarsten.github.io/operantlunar/reference/functional_analysis_replicated.md).
