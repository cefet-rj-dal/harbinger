
``` r
# Installing Harbinger
install.packages("harbinger")
```

```

```


``` r
# Loading Harbinger
library(daltoolbox)
library(harbinger) 
```


``` r
# class harutils
  hutils <- harutils()
```


``` r
values <- rnorm(30, mean = 0, sd = 1)
```


``` r
v1 <- hutils$har_distance_l1(values)
har_plot(harbinger(), v1)
```

![plot of chunk unnamed-chunk-5](fig/examples_harutils_distance/unnamed-chunk-5-1.png)

``` r
v2 <- hutils$har_distance_l2(values)
har_plot(harbinger(), v2)
```

![plot of chunk unnamed-chunk-6](fig/examples_harutils_distance/unnamed-chunk-6-1.png)
