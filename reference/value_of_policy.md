# Mean reward rate of a policy

Mean reward rate of a policy

## Usage

``` r
value_of_policy(
  env,
  agent,
  featurize,
  n_steps = 5000L,
  seed = 0L,
  greedy = TRUE
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

  Steps to evaluate.

- seed:

  Seed.

- greedy:

  Whether to follow the greedy policy.

## Value

The mean per-step reward.

## Examples

``` r
# \donttest{
value_of_policy(prob_matching_task(), make_agent("q_learning", 2L), constant_featurizer(), 2000)
# }
```
