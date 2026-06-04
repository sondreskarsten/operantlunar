# Progressive-ratio schedule

The ratio requirement increases by `step` after each reinforcer.

## Usage

``` r
progressive_ratio(start = 1, inc = 1, magnitude = 1, response_cost = 0.05)
```

## Arguments

- start:

  Initial ratio.

- inc:

  Ratio increment per reinforcer.

- magnitude:

  Reinforcement magnitude.

- response_cost:

  Cost per response.

## Value

An environment object with `reset`, `step`, `current_ratio`.

## Examples

``` r
env <- progressive_ratio()
env$reset(seed = 0)
```
