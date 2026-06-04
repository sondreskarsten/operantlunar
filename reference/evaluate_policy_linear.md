# Evaluate a linear agent's policy

Evaluate a linear agent's policy

## Usage

``` r
evaluate_policy_linear(
  env,
  agent,
  policy = c("greedy", "select"),
  n_episodes = 20L,
  max_steps = 500L,
  seed = 10000L
)
```

## Arguments

- env:

  An environment object.

- agent:

  A linear agent.

- policy:

  "greedy" or "select".

- n_episodes:

  Number of episodes.

- max_steps:

  Step cap per episode.

- seed:

  Seed.

## Value

A numeric vector of episode returns.
