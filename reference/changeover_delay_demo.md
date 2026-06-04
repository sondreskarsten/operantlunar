# Changeover-delay demonstration

Fits matching slopes for a melioration agent at two changeover delays.

## Usage

``` r
changeover_delay_demo(
  cods = c(0L, 4L),
  conditions = list(c(20, 60), c(30, 90), c(45, 45), c(60, 30), c(90, 30)),
  n_steps = 20000L,
  seed = 0L
)
```

## Arguments

- cods:

  Changeover delays to compare.

- conditions:

  VI mean pairs.

- n_steps:

  Steps per condition.

- seed:

  Seed.

## Value

A tibble with one row per changeover delay.

## Examples

``` r
# \donttest{
changeover_delay_demo(n_steps = 8000)
# }
```
