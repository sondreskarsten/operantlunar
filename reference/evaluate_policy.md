# Evaluate a fixed policy

Evaluate a fixed policy

## Usage

``` r
evaluate_policy(
  env,
  table,
  select,
  featurize,
  n_episodes = 50L,
  max_steps = 1000L,
  seed = 10000L
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

- featurize:

  Observation-to-key function.

- n_episodes:

  Number of evaluation episodes.

- max_steps:

  Maximum steps.

- seed:

  Optional seed.

## Value

Numeric vector of episode returns.
