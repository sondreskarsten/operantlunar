# Construct an agent by name

Exploration for the value-bootstrapping rules is scaled to `horizon`.

## Usage

``` r
make_agent(name = "q_learning", n_actions = 2L, horizon = 20000L, ...)
```

## Arguments

- name:

  Registry key.

- n_actions:

  Number of actions.

- horizon:

  Number of steps the agent will run (sets epsilon decay).

- ...:

  Passed to the underlying constructor.

## Value

A list of agent callables.

## Examples

``` r
names(make_agent("sarsa", n_actions = 2L, horizon = 5000L))
```
