# Last-observation memory policy

Keeps only the most recent `n` observations in memory.

## Usage

``` r
har_memory_last_observations(n)
```

## Arguments

- n:

  Number of observations to retain.

## Value

A `har_memory_last_observations` object.

## Examples

``` r
memory <- har_memory_last_observations(100)
memory$n
#> [1] 100
```
