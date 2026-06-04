# Steady-state evaluation estimate for one policy

Accumulates episodes in terrain order, tracks the cumulative mean return
after each block, and applies the steady-state stability rule to the
cumulative-mean series: the estimate is read once the running mean has
settled (no trend and bounded range over the last `k` blocks), or
non-stabilisation is reported. A short evaluation is read off the
unsettled head of this same series and is therefore unreliable; the
settled estimate is what the protocol reports.

## Usage

``` r
lunar_steady_state_return(
  returns = lunar_returns(),
  policy_seed = 0L,
  block = 10L,
  min_blocks = 7L,
  k = 6L,
  tol_trend = 8,
  tol_bounce = 15
)
```

## Arguments

- returns:

  Returns tibble (defaults to the bundled dataset).

- policy_seed:

  Policy to evaluate.

- block:

  Episodes per block.

- min_blocks:

  Minimum blocks before the stability rule applies.

- k:

  Window length for stability and the read.

- tol_trend, tol_bounce:

  Stability tolerances on the return scale.

## Value

A list with `estimate`, `stable`, `n_blocks`, `n_episodes`, `series`.
