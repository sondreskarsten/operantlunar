# Differential-reinforcement-of-low-rate chamber

A response is reinforced only if at least `threshold` steps have elapsed
since the previous response.

## Usage

``` r
drl_chamber(threshold = 15, magnitude = 1, response_cost = 0.02, cap = NULL)
```

## Arguments

- threshold:

  Minimum inter-response time.

- magnitude:

  Reinforcement magnitude.

- response_cost:

  Cost per response.

- cap:

  Maximum inter-response time exposed as the observation.

## Value

An environment object with `reset`, `step`, `threshold`.

## Examples

``` r
env <- drl_chamber(15)
env$reset(seed = 0)
```
