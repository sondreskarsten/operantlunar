# Herrnstein single-alternative VI experiment

Runs a melioration agent on a single variable-interval lever across a
range of schedule values and records reinforcement and response rates.

## Usage

``` r
herrnstein_experiment(
  vi_values = c(5, 10, 20, 40, 80, 160),
  magnitude = 1,
  response_cost = 0.05,
  n_steps = 20000L,
  seed = 0L,
  tail = 0.3
)
```

## Arguments

- vi_values:

  Variable-interval means (steps).

- magnitude:

  Reinforcement magnitude.

- response_cost:

  Cost per response.

- n_steps:

  Steps per condition.

- seed:

  Seed.

- tail:

  Fraction used for tail statistics.

## Value

A tibble with one row per schedule value.

## Examples

``` r
# \donttest{
herrnstein_experiment(n_steps = 8000)
# }
```
