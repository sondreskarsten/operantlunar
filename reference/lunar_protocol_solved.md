# Protocol "is it solved?" verdict with quantified reliability

Reads the steady-state estimate over all terrains, applies the frozen
solved threshold, and quantifies the residual uncertainty by
bootstrapping the terrain sample: the fraction of resampled means that
clear the threshold is a direct confidence readout. The verdict does not
depend on an episode budget or a terrain pool.

## Usage

``` r
lunar_protocol_solved(
  returns = lunar_returns(),
  policy_seed = 0L,
  threshold = 200,
  n_boot = 1000L,
  block = 10L,
  min_blocks = 7L,
  k = 6L,
  tol_trend = 8,
  tol_bounce = 15
)
```

## Arguments

- returns:

  Returns tibble.

- policy_seed:

  Policy to evaluate.

- threshold:

  Solved threshold.

- n_boot:

  Bootstrap resamples.

- block, min_blocks, k, tol_trend, tol_bounce:

  Steady-state parameters.

## Value

A list with `verdict`, `estimate`, `stable`, `n_episodes`,
`bootstrap_solved_fraction`.
