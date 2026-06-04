# Extinction experiment

Acquires responding under three schedules, then withholds reinforcement
and measures resistance to extinction.

## Usage

``` r
extinction_experiment(
  acquire_steps = 8000L,
  extinction_steps = 8000L,
  alpha = 0.02,
  response_cost = 0.02,
  q0 = 1,
  seed = 0L,
  window = 300L,
  threshold = 0.2
)
```

## Arguments

- acquire_steps, extinction_steps:

  Phase lengths.

- alpha:

  Learning rate.

- response_cost:

  Cost per response.

- q0:

  Optimistic initial value.

- seed:

  Seed.

- window:

  Rolling window for the rate.

- threshold:

  Extinction rate threshold.

## Value

A tibble with one row per acquisition schedule.

## Examples

``` r
# \donttest{
extinction_experiment(acquire_steps = 4000, extinction_steps = 4000)
# }
```
