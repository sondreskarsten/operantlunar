# Extinction on a Gymnasium environment

Acquires a policy with the maintaining channel active, then withdraws
reinforcement (channel inactive) while continuing to train, probing
retained behaviour by evaluating with the channel restored. Evaluation
success declines as reinforcement is withheld: extinction on a real gym
task.

## Usage

``` r
gym_extinction(
  builder,
  channel = "goal",
  n_acquire = 1200L,
  n_extinction = 150L,
  eval_every = 10L,
  n_eval = 40L,
  max_steps = 100L,
  seed = 0L
)
```

## Arguments

- builder:

  A zero-argument function returning a channel environment.

- channel:

  The maintaining channel to withdraw.

- n_acquire, n_extinction:

  Episodes per phase.

- eval_every, n_eval:

  Evaluation cadence and size during extinction.

- max_steps:

  Step cap per episode.

- seed:

  Seed.

## Value

A tibble with `episode`, `eval_success`.

## Examples

``` r
if (FALSE) { # \dontrun{
lunar_setup("/usr/bin/python3")
gym_extinction(function() as_channel_env(make_gym("FrozenLake-v1", is_slippery = FALSE), "goal"))
} # }
```
