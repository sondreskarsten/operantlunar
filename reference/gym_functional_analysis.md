# Functional analysis on a Gymnasium-style environment

The functional-analysis instrument mapped to gym: train a
reinforcement-driven agent under each single-channel condition (and a
no-channel play control) via
[`contingency_env()`](https://sondreskarsten.github.io/operantlunar/reference/contingency_env.md),
measure the target response rate, and identify the maintaining channel
as the condition elevated over control. Recovers a planted
`true_function`. This is reward-channel ablation: which reinforcement
contingency maintains the behaviour.

## Usage

``` r
gym_functional_analysis(
  true_function = "escape",
  arms = c("attention", "escape", "tangible", "goal"),
  agent = "q_learning",
  n_steps = 20000L,
  margin = 0.3,
  response_cost = 0.1,
  seed = 0L
)
```

## Arguments

- true_function:

  Planted maintaining channel.

- arms:

  Channels tested.

- agent:

  Registry key for the agent.

- n_steps:

  Trials per condition.

- margin:

  Rate elevation over control to call a channel.

- response_cost:

  Engage cost.

- seed:

  Seed.

## Value

A list with `by_condition`, `identified_channel`, `true_function`,
`correct`.

## Examples

``` r
# \donttest{
gym_functional_analysis("attention")
# }
```
