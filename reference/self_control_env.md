# Self-control (delay-discounting) environment

A fixed-length trial offers a small-sooner versus a large-later reward.
Trial length is equalized across choices so reward rate favors the
larger reward; a discounting or myopic rule prefers the sooner one.

## Usage

``` r
self_control_env(ss_amount = 1, ss_delay = 0, ll_amount = 5, ll_delay = 10)
```

## Arguments

- ss_amount, ss_delay:

  Small-sooner amount and delay (steps).

- ll_amount, ll_delay:

  Large-later amount and delay (steps).

## Value

An environment object with `reset`, `step`, `trial_length`, `ss`, `ll`.

## Examples

``` r
env <- self_control_env()
env$trial_length
```
