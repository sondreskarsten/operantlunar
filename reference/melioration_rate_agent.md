# Rate-tracking melioration agent (Herrnstein-Vaughan)

Tracks an estimated local reinforcement rate per alternative and selects
in proportion to it, equalizing local rates. Reproduces matching by a
different mechanism than the gradient-bandit
[`melioration_agent()`](https://sondreskarsten.github.io/operantlunar/reference/melioration_agent.md).

## Usage

``` r
melioration_rate_agent(alpha = 0.05, n_actions = 2L, floor = 0.001)
```

## Arguments

- alpha:

  Learning rate for the local-rate estimate.

- n_actions:

  Number of actions.

- floor:

  Minimum rate to keep selection probabilities positive.

## Value

A list of agent callables.

## Examples

``` r
names(melioration_rate_agent())
```
