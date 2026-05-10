# Detect and return the indices of outliers in a dataset using the boxplot method

The function receives a dataset "data" and an "alpha" parameter (default
1.5), which controls the upper limit of the boxplot

## Usage

``` r
har_outliers_idx(data, alpha = 1.5)
```

## Arguments

- data:

  dataset

- alpha:

  Threshold for outliers

## Value

A boolean vector indicating whether each value in the data set is an
outlier or not and a vector of indices of the values considered to be
outliers

## Examples

``` r
detector <- harbinger()
```
