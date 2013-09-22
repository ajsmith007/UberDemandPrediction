#!/usr/bin/env Rscript
##########################################################################
## Uber Demand Prediction
##########################################################################
#
# R script to analize Uber data from Washington DC in March and April of 2012
#
#
#
cat("\n\nStarting UBER Demand Prediction Script...\n")
cat(date(), "\n\n")
#source('local_functions.r')

##########################################################################
## Install R packages from Cloud CRAN if not already installed
##########################################################################
cat("Checking for package dependancies from CRAN Cloud Mirror...\n")
#Set default CRAN mirror
options(repos='http://cran.rstudio.com/') # Cloud Mirror
#options(repos='http://software.rc.fas.harvard.edu/mirrors/R/') # USA

if('rjson' %in% rownames(installed.packages()) == FALSE) 
{install.packages('rjson', dependencies=T)}
#if('RJSONIO' %in% rownames(installed.packages()) == FALSE) 
#{install.packages('RJSONIO', dependencies=T)}


##########################################################################
## Load packages and set environment vars
##########################################################################
cat("Loading libraries...\n")
library(rjson)    

## Set the working directory based on OS
cat("Setting the working directory...\n")
switch(Sys.info()[['sysname']],
       Windows= {setwd("C:\\Users\\ajsmith\\workspace\\demandPredictUber\\")},
       Linux  = {setwd("~/workspace/demandPredictUber/")},
       Darwin = {cat("I'm a Mac. Working Directory Not Set!\n")}
)


##########################################################################
## Read UBER json file
##########################################################################
cat("Reading JSON data...\n")
file <- 'static/data/uber_demand_prediction_challenge.json'
data <- fromJSON(file=file, method='C')

##########################################################################
## Append new data and analyze UBER json file
##########################################################################
# Convert UTC time to local Washington DC time
pb.txt <- "2009-06-03 19:30:00+00:00"
pb.date <- as.POSIXct(pb.txt, tz="UTC")
format(pb.date, tz="America/New_York",usetz=TRUE)

for (i in length(data)) { 
  tzCorrectedDateTime[i] <- format(as.POSIXct(gsub("(.*).(..)$","\\1\\2",data[i]), tz="UTC", format="%Y-%m-%d %H:%M:%S")), tz="America/New_York",usetz=TRUE)
}

# Define weekday funtion for numeric output [0=Sun, 1=Mon...etc]
wday <- function(x) as.POSIXlt(x)$wday
wday(Sys.time())

#Weekday as string
weekdays(Sys.time())
weekdays(2012-03-31T21:03:34+00:00)