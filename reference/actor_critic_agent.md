# Actor-critic agent (policy gradient with a TD critic)

Maximizes via a bootstrapped critic, but selects from an explicit
softmax policy like melioration does.

## Usage

``` r
actor_critic_agent(
  alpha_theta = 0.1,
  alpha_v = 0.1,
  gamma = 0.99,
  beta = 1,
  n_actions = 4L
)
```

## Arguments

- alpha_theta:

  Policy learning rate.

- alpha_v:

  Critic learning rate.

- gamma:

  Discount factor.

- beta:

  Inverse temperature.

- n_actions:

  Number of actions.

## Value

A list of agent callables.

## Examples

``` r
names(actor_critic_agent())
```
