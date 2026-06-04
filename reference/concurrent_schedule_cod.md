# Concurrent schedule with a changeover delay

Switching alternatives starts a lockout of `cod` steps during which no
reinforcer is delivered. Without a changeover delay, rapid alternation
harvests both schedules and undermatching results.

## Usage

``` r
concurrent_schedule_cod(schedules = NULL, magnitudes = c(1, 1), cod = 1L)
```

## Arguments

- schedules:

  List of two schedule objects.

- magnitudes:

  Reinforcement magnitudes.

- cod:

  Changeover-delay length in steps.

## Value

An environment object with `reset`, `step`.

## Examples

``` r
concurrent_schedule_cod(cod = 2)
```
