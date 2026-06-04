# Generalized-matching sensitivity and bias

Fits log response ratio on log reinforcement ratio. Sensitivity is the
slope, bias the exponentiated intercept. Optional bootstrap resamples
conditions.

## Usage

``` r
matching_sensitivity_bias(log_r, log_b, n_boot = 0, seed = 0L)
```

## Arguments

- log_r:

  Log reinforcement ratios.

- log_b:

  Log behavior ratios.

- n_boot:

  Bootstrap replicates (0 to skip).

- seed:

  Seed for the bootstrap.

## Value

A list with `sensitivity`, `bias`, `r_squared`, and optional CIs.

## Examples

``` r
matching_sensitivity_bias(log(c(0.3, 1, 3)), log(c(0.28, 1.02, 2.9)))
```
