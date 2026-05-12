source(url("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/examples/seed.R"))
# Install Harbinger (if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 

# Instantiate utilities
hutils <- harutils()

# Generate synthetic residuals
set_example_seed(123L)
values <- rnorm(30, mean = 0, sd = 1)

# L1 deviation.
# Objective: summarize residual magnitude in a simple and robust way.
# Property: linear growth treats all increases proportionally, so it is less
# dominated by a few very large residual peaks.
v1 <- hutils$har_deviation_l1(values)
har_plot(harbinger(), v1)

# L2 deviation.
# Objective: emphasize large residuals more strongly than moderate ones.
# Property: quadratic growth makes extreme values dominate the score more
# aggressively, which can help isolate sharp peaks but also increases
# sensitivity to large outliers.
v2 <- hutils$har_deviation_l2(values)
har_plot(harbinger(), v2)

# Huber deviation.
# Objective: preserve sensitivity to moderate residual growth while reducing
# the dominance of very large peaks.
# Property: Huber behaves quadratically near zero and linearly in the tails,
# making it a compromise between L2 sensitivity and L1 robustness.
vh <- hutils$har_deviation_huber(values)
har_plot(harbinger(), vh)
