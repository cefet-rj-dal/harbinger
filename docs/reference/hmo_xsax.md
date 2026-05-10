# Motif discovery using XSAX

Discovers repeated subsequences (motifs) using an extended SAX (XSAX)
representation that supports a larger alphanumeric alphabet.

## Usage

``` r
hmo_xsax(a, w, qtd)
```

## Arguments

- a:

  Integer. Alphabet size.

- w:

  Integer. Word/window size.

- qtd:

  Integer. Minimum number of occurrences to be classified as motifs.

## Value

`hmo_xsax` object.

## References

- Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in
  Time Series. 1st ed. Cham: Springer Nature Switzerland, 2025.
  doi:10.1007/978-3-031-75941-3

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

# Configure XSAX-based motif discovery
model <- hmo_xsax(37, 3, 3)

# Fit the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected motifs
print(detection[(detection$event),])
#>    idx event  type    seq seqlen
#> 25  25  TRUE motif 0N0P0R      3
#> 50  50  TRUE motif 0N0P0R      3
#> 75  75  TRUE motif 0N0P0R      3
```
