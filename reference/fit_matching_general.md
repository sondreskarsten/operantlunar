# Fit the generalized matching law for an arbitrary schedule pair

Fit the generalized matching law for an arbitrary schedule pair

## Usage

``` r
fit_matching_general(
  make_pair,
  params,
  alpha_mel = 0.1,
  beta = 1,
  n_steps = 20000L,
  seed = 0L
)
```

## Arguments

- make_pair:

  Function mapping a parameter to a list of two schedules.

- params:

  List of parameter pairs.

- alpha_mel, beta:

  Melioration hyperparameters.

- n_steps:

  Steps per condition.

- seed:

  Seed.

## Value

A list with `slope`, `bias`, `mean_exclusivity`, `n_graded`.
