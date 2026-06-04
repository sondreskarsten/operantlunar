# Scalar (1-D) featurizer

Scalar (1-D) featurizer

## Usage

``` r
interval_featurizer(n_bins = 20, lo = 0, hi = 1, dim = 1L)
```

## Arguments

- n_bins:

  Number of bins.

- lo, hi:

  Range of the scalar.

- dim:

  Index of the scalar within the observation.

## Value

A function mapping an observation to a character key.

## Examples

``` r
interval_featurizer()(0.5)
```
