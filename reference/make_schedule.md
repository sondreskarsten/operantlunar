# Build a schedule by name

Build a schedule by name

## Usage

``` r
make_schedule(kind = "VR", param = 5)
```

## Arguments

- kind:

  One of "FR", "VR", "FI", "VI".

- param:

  Ratio or interval parameter.

## Value

A schedule object.

## Examples

``` r
make_schedule("VI", 30)
```
