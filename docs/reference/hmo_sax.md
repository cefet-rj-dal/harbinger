# Motif discovery using SAX

Discovers repeated subsequences (motifs) using a Symbolic Aggregate
approXimation (SAX) representation <doi:10.1007/s10618-007-0064-z>.
Subsequences are discretized and grouped by symbolic words; frequently
occurring words indicate motifs.

## Usage

``` r
hmo_sax(a, w, qtd = 2)
```

## Arguments

- a:

  Integer. Alphabet size.

- w:

  Integer. Word/window size.

- qtd:

  Integer. Minimum number of occurrences to classify as a motif.

## Value

`hmo_sax` object.

## References

- Lin J, Keogh E, Lonardi S, Chiu B (2007). A symbolic representation of
  time series, with implications for streaming algorithms. Data Mining
  and Knowledge Discovery 15, 107–144.

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

# Configure SAX-based motif discovery
model <- hmo_sax(26, 3, 3)

# Fit the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected motifs
print(detection[(detection$event),])
#>    idx event  type seq seqlen
#> 25  25  TRUE motif QST      3
#> 50  50  TRUE motif QST      3
#> 75  75  TRUE motif QST      3
```
