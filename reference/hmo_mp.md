# Motif discovery using Matrix Profile

Discovers repeated subsequences (motifs) using Matrix Profile methods as
implemented in the `tsmp` package <doi:10.32614/RJ-2020-021>.

## Usage

``` r
hmo_mp(mode = "stamp", w, qtd)
```

## Arguments

- mode:

  Character. Algorithm: one of "stomp", "stamp", "simple", "mstomp",
  "scrimp", "valmod", "pmp".

- w:

  Integer. Subsequence window size.

- qtd:

  Integer. Minimum number of occurrences to classify as a motif.

## Value

`hmo_mp` object.

## References

- Yeh CCM, et al. (2016). Matrix Profile I/II: All-pairs similarity
  joins and scalable time series motifs/discrod discovery. IEEE ICDM.

- Tavenard R, et al. tsmp: The Matrix Profile in R. The R Journal
  (2020). doi:10.32614/RJ-2020-021

## Examples

``` r
library(daltoolbox)

# Load motif example data
data(examples_motifs)

# Use a simple sequence example
dataset <- examples_motifs$simple
head(dataset)
#>       serie event
#> 1 1.0000000 FALSE
#> 2 0.9939124 FALSE
#> 3 0.9275826 FALSE
#> 4 0.8066889 FALSE
#> 5 0.6403023 FALSE
#> 6 0.4403224 FALSE

# Configure motif discovery via Matrix Profile
model <- hmo_mp("stamp", 4, 3)

# Fit the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)
#> Finished in 0.02 secs

# Show detected motifs
print(detection[(detection$event),])
#>    idx event  type seq seqlen
#> 6    6  TRUE motif   3      4
#> 19  19  TRUE motif   2      4
#> 25  25  TRUE motif   1      4
#> 31  31  TRUE motif   3      4
#> 44  44  TRUE motif   2      4
#> 56  56  TRUE motif   3      4
#> 69  69  TRUE motif   2      4
#> 75  75  TRUE motif   1      4
#> 81  81  TRUE motif   3      4
#> 94  94  TRUE motif   2      4
```
