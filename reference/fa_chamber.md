# Functional-analysis chamber

One target response evaluated across analogue conditions. The response
produces the maintaining reinforcer only under the test condition whose
contingency matches a hidden `true_function`; the `play` control
delivers no contingent reinforcement. Conditions map to the categories
of maintaining reinforcement: attention (social positive), escape
(social negative), tangible (social positive, item), alone (automatic).
This is the operant contingency made diagnosable, not a clinical
apparatus.

## Usage

``` r
fa_chamber(true_function = "escape", magnitude = 1, response_cost = 0)
```

## Arguments

- true_function:

  One of "attention", "escape", "tangible", "automatic".

- magnitude:

  Reinforcement magnitude.

- response_cost:

  Cost per target response.

## Value

An environment object with `reset`, `step`, and `set_condition`.

## Examples

``` r
ch <- fa_chamber("escape")
ch$set_condition("escape")
ch$step(1)
```
