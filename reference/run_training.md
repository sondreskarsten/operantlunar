# Train an agent for several episodes

Train an agent for several episodes

## Usage

``` r
run_training(
  env,
  table,
  select,
  update,
  featurize,
  n_episodes = 500L,
  max_steps = 1000L,
  seed = 0L
)
```

## Arguments

- env:

  An environment object exposing `reset(seed)` and `step(action)`.

- table:

  A table from
  [`make_table()`](https://sondreskarsten.github.io/operantlunar/reference/make_table.md).

- select:

  Action-selection callable.

- update:

  Learning-update callable.

- featurize:

  Observation-to-key function.

- n_episodes:

  Number of episodes.

- max_steps:

  Maximum steps.

- seed:

  Optional seed.

## Value

Numeric vector of episode returns.
