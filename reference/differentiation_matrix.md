# Differentiation matrix across rules and paradigms

Runs each rule on each paradigm and scores it in the unit interval,
where 1 is reward-maximizing and lower values indicate matching or
suboptimal behavior. The capstone instrument: it reads out where each
learning rule sits on the maximize-vs-meliorate axis.

## Usage

``` r
differentiation_matrix(
  rules = c("q_learning", "expected_sarsa", "double_q", "actor_critic", "melioration",
    "melioration_rate", "win_stay_lose_shift"),
  paradigms = c("prob_matching", "trap", "drl", "self_control"),
  n_steps = 30000L,
  seed = 0L
)
```

## Arguments

- rules:

  Registry keys.

- paradigms:

  Any of "prob_matching", "trap", "drl", "self_control".

- n_steps:

  Steps per (rule, paradigm) cell.

- seed:

  Seed.

## Value

A list with `long`, `wide`, and `classification` tibbles.

## Examples

``` r
# \donttest{
differentiation_matrix(rules = c("q_learning", "melioration"), n_steps = 8000)
# }
```
