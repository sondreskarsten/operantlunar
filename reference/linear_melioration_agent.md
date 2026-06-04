# Linear melioration agent (tile features)

Feature-based gradient bandit with a running-reward baseline and no
bootstrapping. Myopic by construction.

## Usage

``` r
linear_melioration_agent(coder, n_actions = 2L, alpha = 0.1, beta = 1)
```

## Arguments

- coder:

  A tile coder from
  [`tile_coder()`](https://sondreskarsten.github.io/operantlunar/reference/tile_coder.md).

- n_actions:

  Number of actions.

- alpha:

  Step size.

- beta:

  Inverse temperature.

## Value

A list with `select`, `update`, `greedy`, `state`.

## Examples

``` r
a <- linear_melioration_agent(tile_coder(c(-1, -1), c(1, 1)))
names(a)
```
