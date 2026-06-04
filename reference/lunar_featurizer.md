# LunarLander state featurizer

Bins the 8-dimensional observation into a character state key.
Leg-contact dimensions (7, 8) are rounded rather than binned.

## Usage

``` r
lunar_featurizer(edges = NULL, n_bins = 7, binary_dims = c(7L, 8L))
```

## Arguments

- edges:

  Edge list from
  [`make_bin_edges()`](https://sondreskarsten.github.io/operantlunar/reference/make_bin_edges.md);
  built if `NULL`.

- n_bins:

  Number of bins per continuous dimension.

- binary_dims:

  Indices treated as binary.

## Value

A function mapping an observation vector to a character key.

## Examples

``` r
f <- lunar_featurizer()
f(lunar_low)
f(lunar_high)
```
