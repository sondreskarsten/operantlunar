# Convergence demonstration for the "is it solved?" conclusion

Runs the ad hoc verdict across a grid of episode budgets and terrain
pools and the protocol verdict once. The ad hoc verdict flips between
solved and not solved depending on the budget and pool; the protocol
verdict is single-valued and accompanied by a bootstrap confidence.

## Usage

``` r
lunar_solved_convergence(
  returns = lunar_returns(),
  policy_seed = 0L,
  n_episodes_grid = c(5L, 10L, 20L),
  n_pools = 10L,
  threshold = 200
)
```

## Arguments

- returns:

  Returns tibble.

- policy_seed:

  Policy to evaluate.

- n_episodes_grid:

  Episode budgets for the ad hoc pipeline.

- n_pools:

  Terrain pools.

- threshold:

  Solved threshold.

## Value

A list with `results`, `adhoc_distinct`, `protocol_verdict`,
`protocol_estimate`, `bootstrap_solved_fraction`.
