# Install Harbinger (if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 

# Instantiate utilities
hutils <- harutils()

# Generate synthetic residuals
values <- rnorm(30, mean = 0, sd = 1)

# L1 deviation measure over residual magnitude
v1 <- hutils$har_deviation_l1(values)
har_plot(harbinger(), v1)

# L2 deviation measure over residual magnitude
v2 <- hutils$har_deviation_l2(values)
har_plot(harbinger(), v2)
