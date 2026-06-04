# One Bush-Mosteller probability-space update

One Bush-Mosteller probability-space update

## Usage

``` r
bush_mosteller_step(p, action, reinforced, alpha = 0.1, scheme = "R-I")
```

## Arguments

- p:

  Probability vector.

- action:

  Index of the emitted response (1-based).

- reinforced:

  Logical, whether the response was reinforced.

- alpha:

  Learning rate.

- scheme:

  Either "R-I" (reward-inaction) or "R-P" (reward-penalty).

## Value

Updated probability vector.

## Examples

``` r
bush_mosteller_step(c(0.5, 0.5), 1, TRUE)
```
