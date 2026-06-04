# Classify behavior from a maximize score

Classify behavior from a maximize score

## Usage

``` r
classify_rule(score, max_cut = 0.8, mel_cut = 0.4)
```

## Arguments

- score:

  A value in the unit interval where 1 is reward-maximizing.

- max_cut, mel_cut:

  Thresholds.

## Value

One of "maximizing", "intermediate", "matching".

## Examples

``` r
classify_rule(0.95)
```
