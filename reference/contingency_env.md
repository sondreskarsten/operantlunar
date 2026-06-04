# Contingency wrapper for any reinforcement environment

Wraps a base environment whose `step` returns a named numeric `channels`
vector (and optional `base_reward`) and recomputes scalar reward as
`base_reward + sum(channels[active])`. `set_active()` selects which
reinforcement contingencies are in force, which is how the ABA
instruments manipulate the contingency on a Gymnasium-style environment.

## Usage

``` r
contingency_env(base_env, active = NULL)
```

## Arguments

- base_env:

  An environment returning `channels` from `step`.

- active:

  Active channel names; `NULL` means all channels.

## Value

An environment object with `reset`, `step`, `set_active`,
`active_channels`.

## Examples

``` r
env <- contingency_env(fa_channel_env("escape"), active = "escape")
env$reset(seed = 0)
env$step(1)
```
