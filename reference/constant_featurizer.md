# Constant single-state featurizer

Constant single-state featurizer

## Usage

``` r
constant_featurizer(state = "S0")
```

## Arguments

- state:

  Character key returned for every observation.

## Value

A function mapping any observation to `state`.

## Examples

``` r
constant_featurizer()(runif(8))
```
