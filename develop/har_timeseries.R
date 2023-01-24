har_examples <- list()

{ # time series 1
  i <- seq(0, 25, 0.25)
  x <- cos(i)
  event <- rep(FALSE, length(x))

  event[50] <- TRUE
  x[50] <- x[50] + 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

  length(i)

  plot(i, x)
  lines(i, x)

  har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
}

{ # time series 2
  i <- seq(0, 25, 0.25)
  x <- cos(i)
  event <- rep(FALSE, length(x))

  event[50] <- TRUE
  x[50] <- x[50] - 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

  length(i)

  plot(i, x)
  lines(i, x)

  har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
}

{ # time series 3
  i <- seq(0, 25, 0.25)
  x <- cos(i)+i
  event <- rep(FALSE, length(x))

  event[50] <- TRUE
  x[50] <- x[50] + 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

  length(i)

  plot(i, x)
  lines(i, x)


  har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
}

{ # time series 4
  i <- seq(0, 25, 0.25)
  x <- i
  x[51:101] <- max(x[51:100]) - x[51:101]
  event <- rep(FALSE, length(x))

  event[50] <- TRUE
  x[50] <- x[50] + 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

  length(i)

  plot(i, x)
  lines(i, x)


  har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
}

{ # time series 5
  i <- seq(0, 25, 0.25)
  x <- i
  x[51:101] <- max(x[51:100]) - x[51:101]
  event <- rep(FALSE, length(x))

  event[50] <- TRUE
  x[50] <- x[50] - 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

  length(i)

  plot(i, x)
  lines(i, x)


  har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
}

{ # time series 6
  i <- seq(0, 25, 0.25)
  x <- cos(i)
  xt <- i
  xt[51:101] <- max(xt[51:100]) - xt[51:101]
  x <- x + xt

  event <- rep(FALSE, length(x))

  event[50] <- TRUE
  x[50] <- x[50] + 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

  length(i)

  plot(i, x)
  lines(i, x)


  har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
}


{ # time series 7
  i <- seq(0, 25, 0.25)
  x <- cos(i)
  xt <- i
  xt[51:101] <- max(xt[51:100]) - xt[51:101]
  x <- x + xt

  event <- rep(FALSE, length(x))

  event[50] <- TRUE
  x[50] <- x[50] - 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

  length(i)

  plot(i, x)
  lines(i, x)


  har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
}

save(har_examples, file="./data/har_examples.RData", compress = TRUE)




