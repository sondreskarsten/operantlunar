# Risk-sensitivity environment

A safe option pays a fixed amount; a risky option pays a larger amount
with some probability. Means can be matched to isolate variance
sensitivity.

## Usage

``` r
risk_env(safe = 1, risky_high = 2, risky_p = 0.5)
```

## Arguments

- safe:

  Safe payoff.

- risky_high:

  Risky payoff when it pays.

- risky_p:

  Probability the risky option pays.

## Value

An environment object with `reset`, `step`, `safe`, `risky_mean`.

## Examples

``` r
env <- risk_env()
env$risky_mean
```
