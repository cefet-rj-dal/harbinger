# Load full dataset from mini data object

The mini datasets stored in `data/` include an `attr(url)` pointing to
the full dataset in `harbinger/`. This helper downloads and loads the
full data.

## Usage

``` r
loadfulldata(x, envir = parent.frame())
```

## Arguments

- x:

  Dataset object or its name (string or symbol).

- envir:

  Environment to load the full dataset into.

## Value

The full dataset object.

## Examples

``` r
data(A1Benchmark)
A1Benchmark <- loadfulldata(A1Benchmark)
```
