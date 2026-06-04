# Train a linear agent over episodes

Train a linear agent over episodes

## Usage

``` r
run_training_linear(env, agent, n_episodes = 300L, max_steps = 500L, seed = 0L)
```

## Arguments

- env:

  An environment object.

- agent:

  A linear agent.

- n_episodes:

  Number of episodes.

- max_steps:

  Step cap per episode.

- seed:

  Seed.

## Value

A numeric vector of episode returns.
