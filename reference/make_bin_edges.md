# Bin edges for the LunarLander observation

Bin edges for the LunarLander observation

## Usage

``` r
make_bin_edges(low = lunar_low, high = lunar_high, n_bins = 7)
```

## Arguments

- low, high:

  Numeric bounds (length 8).

- n_bins:

  Number of bins per continuous dimension.

## Value

A list of interior edge vectors.

## Examples

``` r
make_bin_edges()
```
