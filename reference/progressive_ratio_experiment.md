# Progressive-ratio experiment

Progressive-ratio experiment

## Usage

``` r
progressive_ratio_experiment(
  rules = c("q_learning", "melioration", "win_stay_lose_shift"),
  inc = 1,
  magnitude = 1,
  response_cost = 0.05,
  n_steps = 40000L,
  seed = 0L
)
```

## Arguments

- rules:

  Registry keys.

- inc:

  Ratio increment.

- magnitude:

  Reinforcement magnitude.

- response_cost:

  Cost per response.

- n_steps:

  Steps per rule.

- seed:

  Seed.

## Value

A tibble of breakpoints (highest completed ratio).

## Examples

``` r
# \donttest{
progressive_ratio_experiment(n_steps = 20000)
# }
```
