# Build a cumulative record

The canonical operant plot's data: cumulative responses against step,
with reinforced steps flagged.

## Usage

``` r
cumulative_record(actions, rewards = NULL)
```

## Arguments

- actions:

  Integer vector of actions (1 = respond).

- rewards:

  Optional reward vector; positive values flag reinforcers.

## Value

A tibble with `step`, `responses`, `reinforcer`.

## Examples

``` r
cumulative_record(c(1, 2, 1, 1), c(0, 0, 1, 0))
```
