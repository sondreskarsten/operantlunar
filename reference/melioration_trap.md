# Melioration trap environment

Two alternatives; A's local reinforcement probability falls as A is
chosen more (`a - ca * x`), B's is `b - cb * (1 - x)`, with `x` a leaky
fraction of recent A-choices. Parameters can be chosen so the matching
point differs from the rate-maximizing optimum.

## Usage

``` r
melioration_trap(a = 0.8, b = 0.4, ca = 0.5, cb = 0, leak = 0.02)
```

## Arguments

- a, b:

  Intercepts of the two payoff functions.

- ca, cb:

  Slopes against allocation.

- leak:

  Leak rate of the allocation trace.

## Value

An environment object with `reset`, `step`, `optimum`, `matching_point`,
`rates`.

## Examples

``` r
tr <- melioration_trap()
tr$optimum()
tr$matching_point()
```
