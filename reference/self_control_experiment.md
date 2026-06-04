# Self-control experiment

Self-control experiment

## Usage

``` r
self_control_experiment(
  rules = c("q_learning", "melioration", "model_based"),
  ss_amount = 1,
  ss_delay = 0,
  ll_amount = 5,
  ll_delay = 10,
  n_steps = 40000L,
  seed = 0L,
  tail_choices = 200L
)
```

## Arguments

- rules:

  Registry keys.

- ss_amount, ss_delay, ll_amount, ll_delay:

  Trial parameters.

- n_steps:

  Steps per rule.

- seed:

  Seed.

- tail_choices:

  Number of trailing choices used for the statistic.

## Value

A list with trial parameters and a tibble of large-later fractions.

## Examples

``` r
# \donttest{
self_control_experiment(n_steps = 20000)
# }
```
