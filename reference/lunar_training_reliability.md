# Training-seed reliability of the solved conclusion

Applies the protocol verdict to every policy and reports how many
training seeds actually meet the solved criterion. This exposes the
training-seed lottery: at a fixed budget some seeds reach the criterion
and some do not, so a claim resting on a single trained seed is not
reproducible.

## Usage

``` r
lunar_training_reliability(returns = lunar_returns(), threshold = 200)
```

## Arguments

- returns:

  Returns tibble.

- threshold:

  Solved threshold.

## Value

A list with `per_seed` (tibble) and `n_solved`, `n_total`.
