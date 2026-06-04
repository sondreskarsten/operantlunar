# Run one episode with a linear agent

Run one episode with a linear agent

## Usage

``` r
run_episode_linear(
  env,
  agent,
  max_steps = 500L,
  train = TRUE,
  seed = NULL,
  policy = c("learn", "greedy", "select")
)
```

## Arguments

- env:

  An environment object.

- agent:

  A linear agent.

- max_steps:

  Step cap.

- train:

  Whether to update weights.

- seed:

  Reset seed.

- policy:

  "learn", "greedy", or "select".

## Value

The episode return.
