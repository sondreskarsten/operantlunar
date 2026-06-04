# Convergence demonstration for the "which policy is best?" conclusion

The concrete form of "the best policy is a seed artifact": across
episode budgets and terrain pools, the ad hoc head-to-head winner
between two policies flips, while the protocol compares steady-state
estimates with a difference band and returns a stable verdict (a winner
only when the settled gap exceeds the band, otherwise
indistinguishable).

## Usage

``` r
lunar_best_policy_convergence(
  returns = lunar_returns(),
  policy_a = 0L,
  policy_b = 1L,
  n_episodes_grid = c(5L, 10L, 20L),
  n_pools = 10L,
  band = 25
)
```

## Arguments

- returns:

  Returns tibble.

- policy_a, policy_b:

  Policies to compare.

- n_episodes_grid:

  Episode budgets.

- n_pools:

  Terrain pools.

- band:

  Minimum settled difference to declare a winner.

## Value

A list with `results`, `adhoc_distinct`, `protocol_verdict`,
`estimate_a`, `estimate_b`.
