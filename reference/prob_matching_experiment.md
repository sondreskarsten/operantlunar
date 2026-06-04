# Probability-matching experiment

Probability-matching experiment

## Usage

``` r
prob_matching_experiment(
  probs = c(0.75, 0.25),
  rules = c("q_learning", "melioration", "melioration_rate"),
  n_steps = 20000L,
  seed = 0L,
  tail = 0.2
)
```

## Arguments

- probs:

  Reinforcement probabilities.

- rules:

  Registry keys.

- n_steps:

  Steps per rule.

- seed:

  Seed.

- tail:

  Fraction used for tail statistics.

## Value

A list with task constants and a tibble of per-rule results.

## Examples

``` r
# \donttest{
prob_matching_experiment(n_steps = 8000)
# }
```
