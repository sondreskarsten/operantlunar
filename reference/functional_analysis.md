# Functional analysis: identify a maintaining function

Runs a reinforcement-driven agent across the standard analogue
conditions (attention, escape, tangible, alone) against a play control,
in rapid alternation (multielement), and identifies the function as the
test condition whose target-response rate is elevated over the control.
Recovers a planted `true_function`, validating the functional-analysis
logic: differential responding across analogue conditions reveals the
operative reinforcement contingency. The agent stands in for the
organism; this validates the logic, not a clinical FA.

## Usage

``` r
functional_analysis(
  true_function = "escape",
  agent = "q_learning",
  n_steps = 20000L,
  margin = 0.3,
  response_cost = 0.1,
  seed = 0L
)
```

## Arguments

- true_function:

  Planted maintaining function.

- agent:

  Registry key for the agent.

- n_steps:

  Total trials across all conditions.

- margin:

  Rate elevation over control required to call a function.

- response_cost:

  Cost per target response, so withholding is the default where
  responding does not pay.

- seed:

  Seed.

## Value

A list with `by_condition` (tibble), `identified_function`,
`true_function`, `correct`.

## Examples

``` r
# \donttest{
functional_analysis("attention")
# }
```
