# Detect outliers in a dataset using the boxplot method

The function receives a dataset "data" and an "alpha" parameter (default
1.5), which controls the upper limit of the boxplot

## Usage

``` r
har_outliers(data, alpha = 1.5)
```

## Arguments

- data:

  dataset

- alpha:

  Threshold for outliers

## Value

The function returns a boolean array with true values for values
considered to be outliers

## Examples

``` r
detector <- harbinger()
```
