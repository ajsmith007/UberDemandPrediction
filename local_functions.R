#!/usr/bin/env Rscript
##########################################################################
## Local Functions for Uber Demand Prediction
##########################################################################
#
# R script of Local Functions for Uber Demand Prediction
#

# Define weekday funtion for numeric output [0=Sun, 1=Mon...etc]
wday <- function(x) as.POSIXlt(x)$wday