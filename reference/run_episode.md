# Run a single episode

Run a single episode

## Usage

``` r
run_episode(
  env,
  table,
  select,
  update,
  featurize,
  max_steps = 1000L,
  train = TRUE,
  seed = NULL
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

- max_steps:

  Maximum steps.

- train:

  Whether to call `update`.

- seed:

  Optional seed.

## Value

A list with `total`, `steps`, and `visited`.
