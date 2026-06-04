# Fit a delay-discounting function

Fit a delay-discounting function

## Usage

``` r
fit_discounting(delays, indiff, model = c("hyperbolic", "exponential"))
```

## Arguments

- delays:

  Delays.

- indiff:

  Indifference amounts (subjective value of the larger reward).

- model:

  "hyperbolic" (A/(1+k d)) or "exponential" (A exp(-k d)).

## Value

A list with `k`, `A`, `model`, and fitted values.

## Examples

``` r
fit_discounting(c(2, 5, 10, 20), c(4.5, 3.5, 2.4, 1.4))
```
