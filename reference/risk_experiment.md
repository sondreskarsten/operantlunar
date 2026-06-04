# Risk-sensitivity experiment

Risk-sensitivity experiment

## Usage

``` r
risk_experiment(
  rules = c("q_learning", "melioration", "melioration_rate"),
  safe = 1,
  risky_high = 2,
  risky_p = 0.5,
  n_steps = 20000L,
  seed = 0L,
  tail = 0.2
)
```

## Arguments

- rules:

  Registry keys.

- safe, risky_high, risky_p:

  Payoff parameters.

- n_steps:

  Steps per rule.

- seed:

  Seed.

- tail:

  Fraction used for tail statistics.

## Value

A list with payoff constants and a tibble of risky-choice fractions.

## Examples

``` r
# \donttest{
risk_experiment(n_steps = 8000)
# }
```
