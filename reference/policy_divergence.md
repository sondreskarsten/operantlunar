# Total-variation policy divergence between two agents

Total-variation policy divergence between two agents

## Usage

``` r
policy_divergence(table_a, dist_a, table_b, dist_b, states)
```

## Arguments

- table_a, table_b:

  Tables.

- dist_a, dist_b:

  Action-distribution callables.

- states:

  Character state keys.

## Value

A list with `mean_tv` and `argmax_agreement`.
