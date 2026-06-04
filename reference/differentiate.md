# Differentiate maximizing TD from melioration on LunarLander

Trains both rules on LunarLander-v3 and reports evaluation return and
policy divergence. Requires
[`lunar_setup()`](https://sondreskarsten.github.io/operantlunar/reference/lunar_setup.md)
first.

## Usage

``` r
differentiate(
  n_train = 300L,
  n_eval = 50L,
  n_bins = 7L,
  alpha_td = 0.1,
  gamma = 0.99,
  alpha_mel = 0.05,
  beta_mel = 1,
  seed = 0L
)
```

## Arguments

- n_train, n_eval:

  Episode counts.

- n_bins:

  Bins for the featurizer.

- alpha_td, gamma, alpha_mel, beta_mel:

  Hyperparameters.

- seed:

  Seed.

## Value

A list of metrics and training-return vectors.

## Examples

``` r
if (FALSE) { # \dontrun{
lunar_setup("/usr/bin/python3")
differentiate(n_train = 100, n_eval = 20)
} # }
```
