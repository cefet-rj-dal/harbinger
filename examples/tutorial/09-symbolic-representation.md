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
```

```
## Warning: restarting interrupted promise evaluation
```

```
## Error:
## ! cannot allocate vector of size 3.5 Gb
```

``` r
sax_model <- fit(sax_model, dataset$serie)
```

```
## Error:
## ! object 'sax_model' not found
```

``` r
sax_series <- transform(sax_model, dataset$serie)
```

```
## Error:
## ! object 'sax_model' not found
```

``` r
head(sax_series, 20)
```

```
## Error:
## ! object 'sax_series' not found
```

Then apply XSAX, which allows a richer alphabet.

``` r
xsax_model <- trans_xsax(alpha = 16)
```

```
## Warning: restarting interrupted promise evaluation
```

```
## Warning: internal error 1 in R_decompress1 with libdeflate
```

```
## Error:
## ! lazy-load database 'C:/R/R-4.5.0/library/harbinger/R/harbinger.rdb' is corrupt
```

``` r
xsax_model <- fit(xsax_model, dataset$serie)
```

```
## Error:
## ! object 'xsax_model' not found
```

``` r
xsax_series <- transform(xsax_model, dataset$serie)
```

```
## Error:
## ! object 'xsax_model' not found
```

``` r
head(xsax_series, 20)
```

```
## Error:
## ! object 'xsax_series' not found
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
## Error:
## ! object 'sax_series' not found
```

## References

- Lin, J., Keogh, E., Lonardi, S., Chiu, B. (2007). A symbolic representation of time series, with implications for streaming algorithms. Data Mining and Knowledge Discovery, 15, 107-144.
