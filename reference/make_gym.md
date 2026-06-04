# Generic Gymnasium environment adapter

Wraps any discrete-action Gymnasium environment behind the native
`reset`/`step` interface (R 1-based actions to Gymnasium 0-based).
Requires
[`lunar_setup()`](https://sondreskarsten.github.io/operantlunar/reference/lunar_setup.md)
(or `RETICULATE_PYTHON`) to be configured.

## Usage

``` r
make_gym(id = "CartPole-v1", ...)
```

## Arguments

- id:

  Gymnasium environment id.

- ...:

  Passed to `gymnasium.make`.

## Value

An environment object with `reset`, `step`, `py`, `n_actions`, `id`.

## Examples

``` r
if (FALSE) { # \dontrun{
lunar_setup("/usr/bin/python3")
env <- make_gym("CartPole-v1")
env$reset(seed = 0)
} # }
```
