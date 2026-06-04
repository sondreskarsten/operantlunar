# Ad hoc "is it solved?" verdict from a short evaluation

Takes `n_episodes` from one contiguous terrain pool and declares the
policy solved if that short-sample mean clears `threshold`. The verdict
depends on how many episodes and which pool were chosen, which is the
researcher degree of freedom the protocol removes.

## Usage

``` r
lunar_adhoc_solved(
  returns = lunar_returns(),
  policy_seed = 0L,
  n_episodes = 10L,
  pool = 1L,
  n_pools = 10L,
  threshold = 200
)
```

## Arguments

- returns:

  Returns tibble.

- policy_seed:

  Policy to evaluate.

- n_episodes:

  Episodes sampled.

- pool:

  Which terrain pool (1-indexed).

- n_pools:

  Number of contiguous pools the terrains are split into.

- threshold:

  Solved threshold.

## Value

A list with `mean`, `verdict`.
