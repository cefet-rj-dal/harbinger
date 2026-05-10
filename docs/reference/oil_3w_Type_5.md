# Oil Wells Dataset – Type 5

First realistic dataset with real events in oil well drilling. The data
available in this package consist of time series already analyzed and
applied in research experiments by the DAL group (Data Analytics Lab).
The series are divided into 7 groups (Type_0, Type_1, Type_2, Type_4,
Type_5, Type_6, Type_7 and Type_8). Creation date: 2019. See
[cefet-rj-dal/united](https://github.com/cefet-rj-dal/united) for
detailed guidance on using this package and the other datasets available
in it. Labels available? Yes

## Usage

``` r
data(oil_3w_Type_5)
```

## Format

A list of time series.

## Source

[UCI Machine Learning
Repository](https://archive.ics.uci.edu/ml/datasets/3W+dataset)

## Details

This package ships a mini version of the dataset. Use loadfulldata() to
download and load the full dataset from the URL stored in attr(url).

## References

3W dataset (UCI repository). See also: Truong, C., Oudre, L., & Vayatis,
N. (2020). Selective review of change point detection methods. Signal
Processing, 167, 107299.

## Examples

``` r
data(oil_3w_Type_5)
serie <- oil_3w_Type_5[[1]]
```
