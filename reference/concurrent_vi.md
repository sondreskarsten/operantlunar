# Concurrent variable-interval environment

Two alternatives on independent VI schedules; one response per step.

## Usage

``` r
concurrent_vi(vi_means = c(30, 90), magnitudes = c(1, 1))
```

## Arguments

- vi_means:

  Mean inter-arming intervals.

- magnitudes:

  Reinforcement magnitudes per alternative.

## Value

An environment object with `reset` and `step`.

## Examples

``` r
env <- concurrent_vi()
env$reset(seed = 0)
env$step(1)
```
