#!/usr/bin/env Rscript
##########################################################################
## Uber Demand Prediction
##########################################################################
#
# R script to analize Uber data from Washington DC in March and April of 2012
#
#

cat("\n\nStarting UBER Demand Prediction Script...\n")
cat(date(), "\n\n")
source('local_functions.r') # local functions

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

if('plyr' %in% rownames(installed.packages()) == FALSE) 
{install.packages('plyr', dependencies=T)}

if('ggplot2' %in% rownames(installed.packages()) == FALSE) 
{install.packages('ggplot2', dependencies=T)}


##########################################################################
## Load packages and set environment vars
##########################################################################
cat("Loading libraries...\n")
library(rjson)
#library(RJSONIO)
library(plyr)
library(ggplot2)

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
data.json <- fromJSON(file=file, method='C')

##########################################################################
## Create new UBER data.frame for event times and append modified date/time vars
##########################################################################

# Initialize data frame with JSON data
uber.data <- data.frame(json=data.json)

# Convert JSON UTC times to ISO8601 and local Washington DC time
for (i in 1:length(uber.data$json)) {
	uber.data$iso_utc[i] = gsub("(.*).(..)$","\\1\\2",uber.data$json[i])
	uber.data$local[i] = format(as.POSIXct(strptime(uber.data$iso_utc[i], "%Y-%m-%dT%H:%M:%S%z", tz="UTC")), tz="America/New_York", usetz=TRUE)
}

# Append data.frame with info for Basic Histogram Analysis
for (i in 1:length(uber.data$json)) {
	uber.data$dow[i] = weekdays(as.POSIXlt(uber.data$local[i])) # Day of Week (dow)
	uber.data$hr[i] = strftime(uber.data$local[i], "%H")		# Hour
	# Top of the hour
	# Botom of the hour
}

# Save data.frame to csv
write.table(uber.data,file="analysis/UberData.csv",sep=",",row.names=F)

# Basic Histogram Analysis
#Generate Counts for each Hour reguardless of Day of the Week
hits.hour = count(uber.data, vars = "hr")
ggplot2(data = hits.hour) + geom_bar(aes(x = hr, y = freq, fill = uber.data$dow), stat="identity", position = "dodge")

print("Hit Enter to Continue...")
readline()

#Generate Counts for each Hour with Day of the Week (dow)
hits.hour_dow = count(uber.data, vars = c("hr","dow"))
ggplot(data = hits.hour_dow) + geom_bar(aes(x = hr, y = freq, fill = uber.data$dow), stat="identity", position = "dodge")


##########################################################################
## Generate a complete minute by minute based data.frame timeline of data and events 
##########################################################################
# Compute the number of minutes in the time line of the dataset
# first.day.minute = 
# last.day.minute =
#minutes = last.day.minute - first.day.minute
#for length(minutes) {
#	#Add one minute to first minute of the firts day and end on the last minute of the last day
#	timeline[m] = first.day.minute + m
#}
#uber.timeline <- data.frame(dt=timeline)
#
# 
# Append data.frame with relavent information 
#for (m in length(uber.events)) {
#	# Holiday (true/false) - National, Regional, Local
#	# Special Event	
#	# Top of the Hour
#	# Bottom of the Hour
#
#	# Weekday as numeric output [0=Sun, 1=Mon, ..., etc] -> easier for modulo
#	#wday(Sys.time())
#	wday(uber.data$local[i]))
#
#	#Weekday as string
#	 weekdays(as.POSIXlt(uber.data$local[i])))
#}

##########################################################################
## EOF
##########################################################################
