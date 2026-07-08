# Get the next observation from a source

Generic used by Harbinger online sessions to request one observation in
pull mode.

## Usage

``` r
next_observation(obj, ...)
```

## Arguments

- obj:

  Source object.

- ...:

  Additional arguments passed to methods.

## Value

A list with fields:

- `source`: the updated source object;

- `observation`: a normalized observation or `NULL`;

- `available`: logical flag indicating whether a new observation was
  returned.
