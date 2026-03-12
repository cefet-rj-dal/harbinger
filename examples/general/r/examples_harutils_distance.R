# Install Harbinger (if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 

# Instantiate utilities
hutils <- harutils()

# Generate synthetic residuals
values <- rnorm(30, mean = 0, sd = 1)

# L1 aggregation of residual magnitude
v1 <- hutils$har_distance_l1(values)
har_plot(harbinger(), v1)
# L2 aggregation of residual magnitude
v2 <- hutils$har_distance_l2(values)
har_plot(harbinger(), v2)
