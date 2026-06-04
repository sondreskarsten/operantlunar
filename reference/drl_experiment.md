# DRL experiment

DRL experiment

## Usage

``` r
drl_experiment(
  rules = c("q_learning", "expected_sarsa", "melioration", "win_stay_lose_shift"),
  threshold = 15L,
  n_steps = 40000L,
  seed = 0L,
  tail = 0.2
)
```

## Arguments

- rules:

  Registry keys.

- threshold:

  Minimum inter-response time.

- n_steps:

  Steps per rule.

- seed:

  Seed.

- tail:

  Fraction used for tail statistics.

## Value

A list with the threshold, optimal response rate, and a tibble.

## Examples

``` r
# \donttest{
drl_experiment(n_steps = 20000)
# }
```
