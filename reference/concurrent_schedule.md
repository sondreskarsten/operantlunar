# Concurrent two-operandum schedule

Concurrent two-operandum schedule

## Usage

``` r
concurrent_schedule(schedules = NULL, magnitudes = c(1, 1))
```

## Arguments

- schedules:

  List of two schedule objects.

- magnitudes:

  Reinforcement magnitudes.

## Value

An environment object with `reset` and `step`.

## Examples

``` r
concurrent_schedule(list(make_schedule("VI", 30), make_schedule("VI", 90)))
```
