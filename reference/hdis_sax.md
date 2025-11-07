# Discord discovery using SAX

Discord discovery using SAX <doi:10.1007/s10618-007-0064-z>

## Usage

``` r
hdis_sax(a, w, qtd = 2)
```

## Arguments

- a:

  alphabet size

- w:

  word size

- qtd:

  number of occurrences to be classified as discords

## Value

`hdis_sax` object

## References

- Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in
  Time Series. 1st ed. Cham: Springer Nature Switzerland, 2025.
  doi:10.1007/978-3-031-75941-3

## Examples

``` r
library(daltoolbox)

# Load motif/discord example data
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

# Configure discord discovery via SAX
model <- hdis_sax(26, 3, 3)

# Fit the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected discords
print(detection[(detection$event),])
#>    idx event  type seq seqlen
#> 17  17  TRUE motif BCE      3
#> 21  21  TRUE motif IKM      3
#> 39  39  TRUE motif CDE      3
#> 43  43  TRUE motif GJL      3
#> 64  64  TRUE motif GHI      3
#> 68  68  TRUE motif LOS      3
#> 86  86  TRUE motif ONM      3
#> 90  90  TRUE motif MOP      3
#> 94  94  TRUE motif VXX      3
```
