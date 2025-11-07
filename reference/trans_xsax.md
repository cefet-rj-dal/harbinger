# XSAX transformation

Extended SAX (XSAX) discretization using a larger alphanumeric alphabet
for finer symbolic resolution.

## Usage

``` r
trans_xsax(alpha)
```

## Arguments

- alpha:

  Integer. Alphabet size (2–36).

## Value

A `trans_xsax` transformer object.

## References

- Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in
  Time Series. 1st ed. Cham: Springer Nature Switzerland, 2025.
  doi:10.1007/978-3-031-75941-3

## See also

trans_sax

## Examples

``` r
library(daltoolbox)
vector <- 1:52
model <- trans_xsax(alpha = 36)
model <- fit(model, vector)
xvector <- transform(model, vector)
print(xvector)
#>  [1] "0" "0" "1" "2" "2" "3" "4" "4" "5" "6" "7" "7" "8" "9" "9" "A" "B" "B" "C"
#> [20] "D" "E" "E" "F" "G" "G" "H" "I" "J" "J" "K" "L" "L" "M" "N" "N" "O" "P" "Q"
#> [39] "Q" "R" "S" "S" "T" "U" "V" "V" "W" "X" "X" "Y" "Z" "Z"
```
