# Sliding batch memory policy

Keeps only the most recent `batches` completed batches in memory.

## Usage

``` r
har_memory_sliding(batches)
```

## Arguments

- batches:

  Number of completed batches to retain.

## Value

A `har_memory_sliding` object.

## Examples

``` r
memory <- har_memory_sliding(3)
memory$batches
#> [1] 3
```
