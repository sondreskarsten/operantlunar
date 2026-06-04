# Fit the generalized matching law on concurrent VI schedules

Runs a melioration agent across VI ratio conditions and fits
`log(B1/B2) = a log(R1/R2) + log b`.

## Usage

``` r
fit_generalized_matching(
  conditions = list(c(20, 60), c(30, 90), c(45, 45), c(60, 30), c(90, 30), c(40, 120),
    c(120, 40)),
  alpha = 0.1,
  beta = 1,
  n_steps = 20000L,
  seed = 0L
)
```

## Arguments

- conditions:

  List of VI mean pairs.

- alpha, beta:

  Melioration hyperparameters.

- n_steps:

  Steps per condition.

- seed:

  Seed.

## Value

A list with `slope`, `bias`, and a tibble of `log_r`/`log_b`.

## Examples

``` r
# \donttest{
fit_generalized_matching(n_steps = 8000)
# }
```
