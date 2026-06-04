# Plot a two-pipelines convergence demonstration

Visualises the verdict distribution of each pipeline across the grid of
researcher choices. The ad hoc facet spreads across multiple verdicts;
the protocol facet concentrates on one. The asymmetry is the result.

## Usage

``` r
plot_convergence(demo)
```

## Arguments

- demo:

  The list returned by
  [`convergence_demo_gridworld()`](https://sondreskarsten.github.io/operantlunar/reference/convergence_demo_gridworld.md)
  or
  [`convergence_demo()`](https://sondreskarsten.github.io/operantlunar/reference/convergence_demo.md).

## Value

A ggplot object.
