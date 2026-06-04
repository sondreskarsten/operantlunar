# Stochastic functional-analysis channel environment

A single-state engage/withhold environment (action 1 = engage, 2 =
withhold) whose engage response emits reinforcement on a hidden
`true_function` channel only probabilistically (`p_reinforce`), with
occasional misfires onto a random channel (`p_noise`). The stochasticity
is deliberate: deterministic contingencies make replication across
subjects vacuous, so genuine subject-to-subject variation (and
occasional undifferentiated subjects) requires within-condition
randomness. Combine with
[`contingency_env()`](https://sondreskarsten.github.io/operantlunar/reference/contingency_env.md):
the active channel determines which condition is in force.

## Usage

``` r
fa_stochastic_env(
  true_function = "escape",
  arms = c("attention", "escape", "tangible", "goal"),
  p_reinforce = 0.8,
  p_noise = 0.05,
  magnitude = 1,
  response_cost = 0.1
)
```

## Arguments

- true_function:

  Hidden maintaining channel.

- arms:

  Channels tested.

- p_reinforce:

  Probability an engage delivers the true-channel reinforcer.

- p_noise:

  Probability an engage misfires onto a uniformly random channel.

- magnitude:

  Reinforcer magnitude.

- response_cost:

  Cost per engage (makes withholding the default).

## Value

A channel environment with `reset`, `step`, `n_actions`, `arms`.
