# MIT-BIH Arrhythmia Database – V5 Lead

Data collection with real-world time-series. MIT-BIH Arrhythmia Database
(MIT-BIH). See
[cefet-rj-dal/united](https://github.com/cefet-rj-dal/united) for
detailed guidance on using this package and the other datasets available
in it. Labels available? Yes

## Usage

``` r
data(mit_bih_V5)
```

## Format

A list of time series from the V5 sensor of the MIT-BIH Arrhythmia
Database.

## Source

[doi:10.1109/51.932724](https://doi.org/10.1109/51.932724)

## Details

This package ships a mini version of the dataset. Use loadfulldata() to
download and load the full dataset from the URL stored in attr(url).

## References

MIT-BIH Arrhythmia Database (MIT-BIH). See also: Moody, G. B., & Mark,
R. G. (2001). The impact of the MIT-BIH Arrhythmia Database. IEEE
Engineering in Medicine and Biology Magazine, 20(3), 45–50.

## Examples

``` r
data(mit_bih_V5)
data <- mit_bih_V5[[1]]
series <- data$value
```
