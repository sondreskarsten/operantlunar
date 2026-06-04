# Reinforcer-devaluation environment

Pressing (action 1) yields the current outcome value; withholding
(action 2) yields nothing. The outcome can be devalued at test.

## Usage

``` r
devaluation_env(magnitude = 1, response_cost = 0.01)
```

## Arguments

- magnitude:

  Initial outcome value.

- response_cost:

  Cost per press.

## Value

An environment object with `reset`, `step`, `devalue`.

## Examples

``` r
env <- devaluation_env()
env$reset(seed = 0)
```
