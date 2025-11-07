# Harbinger

Base class for time series event detection in the Harbinger framework.
It provides common state handling and helper methods used by anomaly,
change point, and motif detectors. Concrete detectors extend this class
and implement their own
[`fit()`](https://rdrr.io/pkg/daltoolbox/man/fit.html) and/or
[`detect()`](https://cefet-rj-dal.github.io/harbinger/reference/detect.md)
S3 methods.

## Usage

``` r
harbinger()
```

## Value

A `harbinger` object that can be extended by detectors.

## Details

Internally, this class stores references to the original series, indices
of non-missing observations, and helper structures to restore detection
results in the original series index space. It also exposes utility
hooks for distance computation and outlier post-processing provided by
[`harutils()`](https://cefet-rj-dal.github.io/harbinger/reference/harutils.md).

## References

- Harbinger documentation: https://cefet-rj-dal.github.io/harbinger

- Salles, R., Escobar, L., Baroni, L., Zorrilla, R., Ziviani, A.,
  Kreischer, V., Delicato, F., Pires, P. F., Maia, L., Coutinho, R.,
  Assis, L., Ogasawara, E. Harbinger: Um framework para integração e
  análise de métodos de detecção de eventos em séries temporais. Anais
  do Simpósio Brasileiro de Banco de Dados (SBBD). In: Anais do XXXV
  Simpósio Brasileiro de Bancos de Dados. SBC, 28 Sep. 2020.
  doi:10.5753/sbbd.2020.13626

## Examples

``` r
# See the specific detector examples for anomalies, change points, and motifs
# at https://cefet-rj-dal.github.io/harbinger
```
