# Fit Herrnstein's single-alternative hyperbola

Response rate B = k r / (r + r0) against reinforcement rate r.

## Usage

``` r
fit_herrnstein_hyperbola(reinforcement_rate, response_rate)
```

## Arguments

- reinforcement_rate:

  Reinforcement rates.

- response_rate:

  Response rates.

## Value

A list with `k`, `r0`, and fitted values.

## Examples

``` r
fit_herrnstein_hyperbola(c(0.02, 0.05, 0.1, 0.2), c(0.3, 0.5, 0.65, 0.78))
```
