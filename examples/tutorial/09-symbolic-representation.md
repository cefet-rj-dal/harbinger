## Tutorial 09 - Symbolic Representation

Numeric series can also be studied through symbolic encodings. `trans_sax()` and `trans_xsax()` discretize the signal into symbols, which can simplify later motif and discord analysis.

This notebook compares the first symbolic values returned by both transformations on the same series.

The technique is symbolic discretization. Instead of preserving every numeric fluctuation, SAX and XSAX convert local behavior into symbols, making it easier to compare subsequences and search for repeated or unusual patterns at a higher level of abstraction.

Load the packages and a motif-oriented example series.

``` r
library(daltoolbox)
library(harbinger)

data(examples_motifs)
dataset <- examples_motifs$simple
```

Plot the original signal before transforming it.

``` r
har_plot(harbinger(), dataset$serie, event = dataset$event)
```

![plot of chunk unnamed-chunk-2](fig/09-symbolic-representation/unnamed-chunk-2-1.png)

Start with SAX, which uses a compact alphabet.

``` r
sax_model <- trans_sax(alpha = 8)
sax_model <- fit(sax_model, dataset$serie)
sax_series <- transform(sax_model, dataset$serie)
head(sax_series, 20)
```

```
##  [1] "D" "D" "D" "C" "C" "B" "B" "B" "A" "A" "A" "A" "A" "A" "A" "A" "A" "A" "B" "B"
```

Then apply XSAX, which allows a richer alphabet.

``` r
xsax_model <- trans_xsax(alpha = 16)
xsax_model <- fit(xsax_model, dataset$serie)
xsax_series <- transform(xsax_model, dataset$serie)
head(xsax_series, 20)
```

```
##  [1] "6" "6" "6" "5" "4" "3" "2" "2" "1" "0" "0" "0" "0" "0" "0" "0" "1" "1" "2" "3"
```

Compare the numeric and symbolic representations side by side.

``` r
head(
  data.frame(
    value = dataset$serie,
    sax = sax_series,
    xsax = xsax_series
  ),
  20
)
```

```
##           value sax xsax
## 1   1.000000000   D    6
## 2   0.993912422   D    6
## 3   0.927582562   D    6
## 4   0.806688869   C    5
## 5   0.640302306   C    4
## 6   0.440322362   B    3
## 7   0.220737202   B    2
## 8  -0.003246056   B    2
## 9  -0.216146837   A    1
## 10 -0.403173623   A    0
## 11 -0.551143616   A    0
## 12 -0.649302379   A    0
## 13 -0.689992497   A    0
## 14 -0.669129676   A    0
## 15 -0.586456687   A    0
## 16 -0.445559357   A    0
## 17 -0.253643621   A    1
## 18 -0.021087490   A    1
## 19  0.239204201   B    2
## 20  0.512602153   B    3
```

## References

- Lin, J., Keogh, E., Lonardi, S., Chiu, B. (2007). A symbolic representation of time series, with implications for streaming algorithms. Data Mining and Knowledge Discovery, 15, 107-144.
