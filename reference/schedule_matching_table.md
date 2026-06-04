# Matching slopes across schedule types

Matching slopes across schedule types

## Usage

``` r
schedule_matching_table(n_steps = 20000L, seed = 0L)
```

## Arguments

- n_steps:

  Steps per condition.

- seed:

  Seed.

## Value

A tibble with one row per concurrent schedule type.

## Examples

``` r
# \donttest{
schedule_matching_table(n_steps = 8000)
# }
```
