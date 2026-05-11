---
title: "KSWIN with `hcp_kswin()`"
output: rmarkdown::html_document
---



## Objective

This notebook demonstrates KSWIN change-point detection on a univariate time series. The detector compares an early sample with the most recent observations inside a sliding window and flags a changepoint when the two distributions differ significantly.

## Method at a glance

KSWIN is a window-based sequential detector for distributional change. In Harbinger it is restricted to one numeric series so that the output can be interpreted directly as virtual drift on the observed signal.

## Prepare the Example


``` r
data(examples_changepoints)
dataset <- examples_changepoints$complex
```

## Visualize the Raw Series


``` r
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-2](fig/18-kswin-hcp_kswin/unnamed-chunk-2-1.png)

## Configure the Method


``` r
model <- hcp_kswin(window_size = 100, stat_size = 30, alpha = 0.005)
model <- fit(model, dataset$serie)
```

## Run Detection


``` r
detection <- detect(model, dataset$serie)
print(detection[detection$event, ])
```

```
##     idx event        type
## 141 141  TRUE changepoint
## 213 213  TRUE changepoint
## 214 214  TRUE changepoint
## 215 215  TRUE changepoint
## 216 216  TRUE changepoint
## 217 217  TRUE changepoint
## 218 218  TRUE changepoint
## 219 219  TRUE changepoint
## 220 220  TRUE changepoint
## 221 221  TRUE changepoint
## 222 222  TRUE changepoint
## 223 223  TRUE changepoint
## 224 224  TRUE changepoint
## 225 225  TRUE changepoint
## 226 226  TRUE changepoint
## 227 227  TRUE changepoint
## 228 228  TRUE changepoint
## 229 229  TRUE changepoint
## 230 230  TRUE changepoint
## 231 231  TRUE changepoint
## 232 232  TRUE changepoint
## 233 233  TRUE changepoint
## 234 234  TRUE changepoint
## 235 235  TRUE changepoint
## 236 236  TRUE changepoint
## 237 237  TRUE changepoint
## 238 238  TRUE changepoint
## 239 239  TRUE changepoint
## 240 240  TRUE changepoint
## 241 241  TRUE changepoint
## 242 242  TRUE changepoint
## 243 243  TRUE changepoint
## 244 244  TRUE changepoint
## 245 245  TRUE changepoint
## 246 246  TRUE changepoint
## 247 247  TRUE changepoint
## 248 248  TRUE changepoint
## 249 249  TRUE changepoint
## 250 250  TRUE changepoint
## 251 251  TRUE changepoint
## 252 252  TRUE changepoint
## 253 253  TRUE changepoint
## 254 254  TRUE changepoint
## 255 255  TRUE changepoint
## 256 256  TRUE changepoint
## 257 257  TRUE changepoint
## 258 258  TRUE changepoint
## 259 259  TRUE changepoint
## 260 260  TRUE changepoint
## 261 261  TRUE changepoint
## 262 262  TRUE changepoint
## 263 263  TRUE changepoint
## 265 265  TRUE changepoint
## 270 270  TRUE changepoint
## 271 271  TRUE changepoint
## 318 318  TRUE changepoint
## 320 320  TRUE changepoint
## 321 321  TRUE changepoint
## 322 322  TRUE changepoint
## 323 323  TRUE changepoint
## 324 324  TRUE changepoint
## 325 325  TRUE changepoint
## 326 326  TRUE changepoint
## 327 327  TRUE changepoint
## 328 328  TRUE changepoint
## 329 329  TRUE changepoint
## 330 330  TRUE changepoint
## 331 331  TRUE changepoint
## 332 332  TRUE changepoint
## 333 333  TRUE changepoint
## 334 334  TRUE changepoint
## 335 335  TRUE changepoint
## 336 336  TRUE changepoint
## 337 337  TRUE changepoint
## 338 338  TRUE changepoint
## 339 339  TRUE changepoint
## 340 340  TRUE changepoint
## 341 341  TRUE changepoint
## 342 342  TRUE changepoint
## 343 343  TRUE changepoint
## 344 344  TRUE changepoint
## 345 345  TRUE changepoint
## 346 346  TRUE changepoint
## 347 347  TRUE changepoint
## 348 348  TRUE changepoint
## 349 349  TRUE changepoint
## 350 350  TRUE changepoint
## 351 351  TRUE changepoint
## 352 352  TRUE changepoint
## 353 353  TRUE changepoint
## 354 354  TRUE changepoint
## 355 355  TRUE changepoint
## 356 356  TRUE changepoint
## 357 357  TRUE changepoint
## 358 358  TRUE changepoint
## 359 359  TRUE changepoint
## 360 360  TRUE changepoint
## 361 361  TRUE changepoint
## 362 362  TRUE changepoint
## 363 363  TRUE changepoint
## 364 364  TRUE changepoint
## 365 365  TRUE changepoint
## 366 366  TRUE changepoint
## 367 367  TRUE changepoint
## 368 368  TRUE changepoint
## 369 369  TRUE changepoint
## 370 370  TRUE changepoint
## 371 371  TRUE changepoint
## 372 372  TRUE changepoint
## 373 373  TRUE changepoint
## 374 374  TRUE changepoint
## 375 375  TRUE changepoint
## 376 376  TRUE changepoint
## 377 377  TRUE changepoint
## 378 378  TRUE changepoint
## 379 379  TRUE changepoint
## 380 380  TRUE changepoint
## 381 381  TRUE changepoint
## 382 382  TRUE changepoint
## 383 383  TRUE changepoint
## 384 384  TRUE changepoint
## 385 385  TRUE changepoint
## 386 386  TRUE changepoint
## 387 387  TRUE changepoint
## 388 388  TRUE changepoint
## 389 389  TRUE changepoint
## 390 390  TRUE changepoint
## 391 391  TRUE changepoint
## 392 392  TRUE changepoint
## 393 393  TRUE changepoint
## 394 394  TRUE changepoint
## 395 395  TRUE changepoint
## 396 396  TRUE changepoint
## 397 397  TRUE changepoint
## 398 398  TRUE changepoint
## 399 399  TRUE changepoint
## 400 400  TRUE changepoint
## 401 401  TRUE changepoint
## 402 402  TRUE changepoint
## 403 403  TRUE changepoint
## 404 404  TRUE changepoint
## 405 405  TRUE changepoint
## 406 406  TRUE changepoint
## 407 407  TRUE changepoint
## 408 408  TRUE changepoint
## 409 409  TRUE changepoint
## 410 410  TRUE changepoint
## 411 411  TRUE changepoint
## 412 412  TRUE changepoint
## 413 413  TRUE changepoint
## 414 414  TRUE changepoint
## 415 415  TRUE changepoint
## 416 416  TRUE changepoint
## 417 417  TRUE changepoint
## 418 418  TRUE changepoint
## 419 419  TRUE changepoint
## 420 420  TRUE changepoint
## 421 421  TRUE changepoint
## 422 422  TRUE changepoint
## 423 423  TRUE changepoint
## 424 424  TRUE changepoint
## 425 425  TRUE changepoint
## 426 426  TRUE changepoint
## 427 427  TRUE changepoint
## 428 428  TRUE changepoint
## 429 429  TRUE changepoint
## 430 430  TRUE changepoint
## 431 431  TRUE changepoint
## 432 432  TRUE changepoint
## 433 433  TRUE changepoint
## 434 434  TRUE changepoint
## 435 435  TRUE changepoint
## 436 436  TRUE changepoint
## 437 437  TRUE changepoint
## 438 438  TRUE changepoint
## 439 439  TRUE changepoint
## 440 440  TRUE changepoint
## 441 441  TRUE changepoint
## 442 442  TRUE changepoint
## 443 443  TRUE changepoint
## 444 444  TRUE changepoint
## 445 445  TRUE changepoint
## 446 446  TRUE changepoint
## 447 447  TRUE changepoint
## 448 448  TRUE changepoint
## 449 449  TRUE changepoint
## 450 450  TRUE changepoint
## 451 451  TRUE changepoint
## 452 452  TRUE changepoint
## 453 453  TRUE changepoint
## 454 454  TRUE changepoint
## 455 455  TRUE changepoint
## 456 456  TRUE changepoint
## 457 457  TRUE changepoint
## 458 458  TRUE changepoint
## 459 459  TRUE changepoint
## 460 460  TRUE changepoint
## 461 461  TRUE changepoint
## 462 462  TRUE changepoint
## 463 463  TRUE changepoint
## 477 477  TRUE changepoint
## 480 480  TRUE changepoint
```

## Evaluate the Result


``` r
evaluation <- evaluate(har_eval(), detection$event, dataset$event)
print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      1     201  
## FALSE     3     295
```

## Plot the Detections


``` r
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-6](fig/18-kswin-hcp_kswin/unnamed-chunk-6-1.png)

## References

- Raab C, Heusinger M, Schleif FM (2020). Reactive Soft Prototype Computing for Concept Drift Streams. Neurocomputing.
- Bifet A, Gavaldà R (2007). Learning from time-changing data with adaptive windowing. SIAM International Conference on Data Mining.
