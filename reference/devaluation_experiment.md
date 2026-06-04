# Reinforcer-devaluation experiment (habit vs goal-directed)

Acquires pressing, then devalues the outcome and tests in extinction
with learning frozen. A model-based rule revalues from its model and
stops; cached value rules (model-free, melioration) persist.

## Usage

``` r
devaluation_experiment(
  rules = c("q_learning", "model_based", "melioration"),
  magnitude = 1,
  response_cost = 0.01,
  acquire_steps = 8000L,
  test_steps = 500L,
  seed = 0L
)
```

## Arguments

- rules:

  Registry keys.

- magnitude:

  Outcome value during acquisition.

- response_cost:

  Cost per press (survives devaluation).

- acquire_steps:

  Acquisition length.

- test_steps:

  Test length.

- seed:

  Seed.

## Value

A list with a tibble of acquired and post-devaluation press fractions.

## Examples

``` r
# \donttest{
devaluation_experiment(acquire_steps = 4000)
# }
```
