# Fixed-interval chamber with an elapsed-time observation

A single-operandum FI schedule that exposes time since the last
reinforcer as the observation, so a value agent can bring responding
under temporal control. Actions: 1 = respond, 2 = withhold.

## Usage

``` r
fi_chamber(interval = 20, magnitude = 1, response_cost = 0.02, cap = NULL)
```

## Arguments

- interval:

  Fixed interval in steps.

- magnitude:

  Reinforcement magnitude.

- response_cost:

  Cost per response.

- cap:

  Maximum elapsed value exposed as the observation.

## Value

An environment object with `reset` and `step`.

## Examples

``` r
ch <- fi_chamber(20)
ch$reset(seed = 0)
ch$step(1)
```
