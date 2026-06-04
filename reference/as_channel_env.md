# Expose a single-reward environment as a one-channel environment

Wraps a plain `reward`-returning environment (e.g.
[`make_gym()`](https://sondreskarsten.github.io/operantlunar/reference/make_gym.md))
so its scalar reward becomes a single named channel, making it usable
with
[`contingency_env()`](https://sondreskarsten.github.io/operantlunar/reference/contingency_env.md)
(and therefore with the gym instruments).

## Usage

``` r
as_channel_env(env, channel = "task")
```

## Arguments

- env:

  A `reset`/`step` environment returning scalar `reward`.

- channel:

  Channel name.

## Value

An environment whose `step` returns `channels` and `base_reward`.
