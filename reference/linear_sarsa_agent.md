# Linear semi-gradient SARSA agent (tile features)

Operates on raw observations, encoding them with a tile coder.
Bootstraps with an action sampled from the epsilon-greedy policy.

## Usage

``` r
linear_sarsa_agent(
  coder,
  n_actions = 2L,
  alpha = 0.1,
  gamma = 0.99,
  eps_start = 1,
  eps_end = 0.05,
  eps_decay_steps = NULL,
  horizon = 150000L
)
```

## Arguments

- coder:

  A tile coder from
  [`tile_coder()`](https://sondreskarsten.github.io/operantlunar/reference/tile_coder.md).

- n_actions:

  Number of actions.

- alpha:

  Step size (divided across tilings internally).

- gamma:

  Discount factor.

- eps_start, eps_end:

  Exploration schedule endpoints.

- eps_decay_steps:

  Steps over which to decay; derived from `horizon` if NULL.

- horizon:

  Expected number of steps.

## Value

A list with `select`, `update`, `greedy`, `state`.

## Examples

``` r
a <- linear_sarsa_agent(tile_coder(c(-1, -1), c(1, 1)))
names(a)
```
