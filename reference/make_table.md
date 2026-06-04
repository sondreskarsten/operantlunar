# Create a state-action value table

The table is an environment mapping character state keys to numeric
vectors of length `n_actions` (interpreted as Q-values or preferences
depending on the rule).

## Usage

``` r
make_table(n_actions = 4L)
```

## Arguments

- n_actions:

  Number of actions (unused at construction; kept for clarity).

## Value

An environment used as a mutable table.

## Examples

``` r
make_table()
```
