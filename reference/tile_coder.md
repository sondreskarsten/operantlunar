# Hashed tile coder

Coarse coding with overlapping offset tilings, hashed into a fixed
feature space so memory stays bounded in higher dimensions.

## Usage

``` r
tile_coder(low, high, n_tilings = 8L, bins = 8L, table_size = 8192L)
```

## Arguments

- low, high:

  Observation bounds.

- n_tilings:

  Number of overlapping tilings.

- bins:

  Bins per dimension per tiling.

- table_size:

  Size of the hashed feature space.

## Value

A list with `encode` (observation to active indices), `n_features`,
`n_tilings`.

## Examples

``` r
tc <- tile_coder(c(-1, -1), c(1, 1))
tc$encode(c(0, 0))
```
