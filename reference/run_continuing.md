# Run an agent on a continuing (non-episodic) environment

Run an agent on a continuing (non-episodic) environment

## Usage

``` r
run_continuing(
  env,
  agent,
  featurize,
  n_steps = 50000L,
  seed = 0L,
  train = TRUE
)
```

## Arguments

- env:

  An environment object.

- agent:

  An agent.

- featurize:

  Observation-to-key function.

- n_steps:

  Number of steps.

- seed:

  Seed.

- train:

  Whether to update.

## Value

A list with `rewards`, `actions`, `xs`, and the `table`.
