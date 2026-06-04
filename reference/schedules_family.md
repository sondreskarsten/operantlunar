# Reinforcement schedule primitives

Each returns a list with `tick()` (advance time) and `respond()`
(register a response, returning whether it is reinforced).

## Usage

``` r
sched_FR(n = 5)

sched_VR(n = 5)

sched_FI(t = 10)

sched_VI(t = 10)
```

## Arguments

- n:

  Ratio requirement (FR/VR).

- t:

  Interval in steps (FI/VI).

## Value

A schedule object.

## Examples

``` r
s <- sched_VR(5)
s$respond()
```
