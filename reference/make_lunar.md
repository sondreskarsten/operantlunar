# LunarLander-v3 environment adapter

Wraps the Python Gymnasium environment behind the same `reset`/`step`
interface as the native-R environments. Actions are 1-based on the R
side and translated to Gymnasium's 0-based discrete actions.

## Usage

``` r
make_lunar()
```

## Value

An environment object with `reset`, `step`, `py`, `n_actions`.

## Examples

``` r
if (FALSE) { # \dontrun{
lunar_setup("/usr/bin/python3")
env <- make_lunar()
env$reset(seed = 0)
env$step(1)
} # }
```
