# Functional-analysis channel environment

One target response (action 1 = engage, 2 = withhold) on a single state.
Engaging emits reinforcement on the hidden `true_function` channel and
incurs a response cost; withholding does nothing. Combined with
[`contingency_env()`](https://sondreskarsten.github.io/operantlunar/reference/contingency_env.md),
engaging pays only when `true_function` is the active channel, so
differential responding across conditions reveals the function.

## Usage

``` r
fa_channel_env(
  true_function = "escape",
  arms = c("attention", "escape", "tangible", "goal"),
  magnitude = 1,
  response_cost = 0.1
)
```

## Arguments

- true_function:

  Hidden maintaining channel.

- arms:

  Channel names tested.

- magnitude:

  Reinforcement magnitude.

- response_cost:

  Cost per engage.

## Value

A channel environment with `reset`, `step`.
