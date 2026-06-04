# Melioration-trap experiment

Trains Q-learning, expected-SARSA, and melioration on the trap and
reports tail allocation and reward rate against the analytic optimum and
matching point.

## Usage

``` r
melioration_trap_experiment(
  n_steps = 60000L,
  n_bins = 20L,
  gamma = 0.99,
  alpha_q = 0.2,
  alpha_mel = 0.1,
  seed = 0L,
  tail = 0.2
)
```

## Arguments

- n_steps:

  Steps per rule.

- n_bins:

  Bins for the allocation state.

- gamma:

  Discount for the maximizing rules.

- alpha_q, alpha_mel:

  Learning rates.

- seed:

  Seed.

- tail:

  Fraction of the run used for tail statistics.

## Value

A list with `optimum`, `matching_point`, and a tibble of `rules`.

## Examples

``` r
# \donttest{
melioration_trap_experiment(n_steps = 20000)
# }
```
