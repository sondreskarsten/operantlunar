# Collect states from random rollouts

Collect states from random rollouts

## Usage

``` r
collect_states(
  env,
  featurize,
  n_actions = 4L,
  n_episodes = 20L,
  max_steps = 1000L,
  seed = 99999L
)
```

## Arguments

- env:

  An environment object.

- featurize:

  Observation-to-key function.

- n_actions:

  Number of actions.

- n_episodes:

  Number of rollouts.

- max_steps:

  Maximum steps per rollout.

- seed:

  Seed.

## Value

A character vector of unique state keys.
