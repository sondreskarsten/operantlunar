# Observation bounds for known environments

Effective clipping bounds used to build tile coders. Fails loudly for an
unknown id rather than guessing.

## Usage

``` r
gym_bounds(id = "CartPole-v1")
```

## Arguments

- id:

  Gymnasium environment id.

## Value

A list with numeric `low` and `high` vectors.

## Examples

``` r
gym_bounds("CartPole-v1")
```
