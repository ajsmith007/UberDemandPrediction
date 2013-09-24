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

if('extrafont' %in% rownames(installed.packages()) == FALSE) 
{install.packages('extrafont', dependencies=T)}

##########################################################################
## Load packages and set environment vars
##########################################################################
cat("Loading libraries...\n")
library(rjson)
#library(RJSONIO)
library(plyr)
library(ggplot2)
library(extrafont)

## Set the working directory based on OS
cat("Setting the working directory...\n")
switch(Sys.info()[['sysname']],
       Windows= {setwd("C:\\Users\\ajsmith\\workspace\\demandPredictUber\\Rscripts\\")},
       Linux  = {setwd("~/workspace/demandPredictUber/Rscripts/")},
       Darwin = {cat("I'm a Mac. Working Directory Not Set!\n")}
)

source('local_functions.R') # local functions

##########################################################################
## Read UBER json file
##########################################################################
cat("Reading JSON data...\n")
file <- '../static/data/uber_demand_prediction_challenge.json'
data.json <- fromJSON(file=file, method='C')

##########################################################################
## Create new UBER data.frame for event times and append modified date/time vars
##########################################################################
cat("Initializing data frame...\n")
# Initialize data frame with JSON data
uber.data <- data.frame(json=data.json)

# Convert JSON UTC times to ISO8601 and local Washington DC time
cat("Formatting UTC and computing localtime...\n")
tic()
for (i in 1:length(uber.data$json)) {
	uber.data$iso_utc[i] = gsub("(.*).(..)$","\\1\\2",uber.data$json[i])
	uber.data$local[i] = format(as.POSIXct(strptime(uber.data$iso_utc[i], "%Y-%m-%dT%H:%M:%S%z", tz="UTC")), tz="America/New_York", usetz=TRUE)
}
toc()

# Append data.frame with info for Basic Histogram Analysis
cat("Computing Day of the Week (dow) and Hourly Data...\n")
tic()
for (i in 1:length(uber.data$json)) {
	uber.data$doy[i] = strptime(uber.data$local[i], "%Y-%m-%d %H:%M:%S")$yday+1	# Day of Year
	# Days since official launch in this market
	uber.data$mnthday[i] = strftime(uber.data$local[i], "%m-%d")	# Month and Day
	uber.data$mdh[i] = strftime(uber.data$local[i], "%m-%d %H00")	# Month, Day and Hour
	uber.data$dow[i] = weekdays(as.POSIXlt(uber.data$local[i])) 	# Day of Week (dow)
	uber.data$hr[i] = strftime(uber.data$local[i], "%H")			# Hour
	# Top of the hour
	# Botom of the hour
	uber.data$min[i] = strftime(uber.data$local[i], "%M")			# Minute
}
toc()

# Add numeric to start of Day of Week for better display (n_dow = "n-dow")
tic()
for (d in 1:length(uber.data$json)){
	if(uber.data$dow[d] == "Sunday"){ 
		uber.data$n_dow[d] = "0-Sunday" 
	} else if(uber.data$dow[d] == "Monday"){
		uber.data$n_dow[d] = "1-Monday" 
	} else if(uber.data$dow[d] == "Tuesday"){ 
		uber.data$n_dow[d] = "2-Tuesday" 
	} else if(uber.data$dow[d] == "Wednesday"){ 
		uber.data$n_dow[d] = "3-Wednesday" 
	} else if(uber.data$dow[d] == "Thursday"){ 
		uber.data$n_dow[d] = "4-Thursday" 
	} else if(uber.data$dow[d] == "Friday"){ 
		uber.data$n_dow[d] = "5-Friday" 
	} else if (uber.data$dow[d] == "Saturday"){ 
		uber.data$n_dow[d] = "6-Saturday" 
	}
}
toc()

# Save data.frame to csv
write.table(uber.data,file="analysis/UberData.csv",sep=",",row.names=F)

##########################################################################
# Basic Histogram Analysis
##########################################################################
cat("Beginning basic histogram analysis...\n")
# Generate Counts for each Hour reguardless of Day of the Week
hits.hour = count(uber.data, vars = "hr")
plot.hr = ggplot(data = hits.hour) + geom_bar(aes(x = hr, y = freq), stat="identity", position = "dodge")
print(plot.hr)
Pause()

# Generate Counts for each Hour with Day of the Week (dow)
hits.hour_dow = count(uber.data, vars = c("hr","dow"))
plot.hr_dow = ggplot(data = hits.hour_dow) + geom_bar(aes(x = hr, y = freq), stat="identity", position = "dodge")
print(plot.hr_dow)
Pause()

# Generate Counts for each Hour with Day of the Week (dow)
hits.hour_dow_n = count(uber.data, vars = c("hr","n_dow"))
plot.hr_dow_n = ggplot(data = hits.hour_dow_n) + 
	geom_bar(aes(x = hr, y = freq, fill=n_dow), stat="identity", position = "dodge") +
	scale_fill_brewer(palette="GnBu")
print(plot.hr_dow_n)
Pause()

# Generate Counts for each Minute of the Day (reguardless of Day of the Week)
hits.min = count(uber.data, vars = "min")
plot.min = ggplot(data = hits.min) + 
	geom_bar(aes(x = min, y = freq), stat="identity", position = "dodge") +
	scale_fill_brewer(palette="Spectral")
print(plot.min)
Pause()

# Generate Counts for each Hour of the Day for the Whole Time Series
hits.mdh = count(uber.data, vars = c("mdh", "doy"))
plot.mdh = ggplot(data = hits.mdh) + 
	geom_bar(aes(x = mdh, y = freq), stat="identity", position = "dodge") +
	scale_x_discrete(hits.mdh$doy) +
	theme(axis.text.x=element_text(size=8, angle=90, vjust=1))
print(plot.mdh)
Pause()

# Generate Counts for each Month-Day combo
hits.mnthday = count(uber.data, vars = c("mnthday", "n_dow"))
plot.mnthday = ggplot(data = hits.mnthday ) + 
	geom_bar(aes(x = mnthday, y = freq), stat="identity", position = "dodge") +
	xlab("MM-DD") +
	theme(axis.text.x=element_text(size=8, angle=90, vjust=1))
print(plot.mnthday)
Pause()

cat("End of Basic Historam Analysis...\n")
Pause()

##########################################################################
# Basic Regression Analysis
##########################################################################
cat("Beginning basic regression analysis...\n")
# Simple Linear Model
x = hits.mdh$doy
y = hits.mdh$freq
new <- data.frame(x = seq(1, 365, 1))
linear.mdl = predict(lm(y ~ x), new, se.fit = TRUE)

pred.w.plim <- predict(lm(y ~ x), new, interval = "prediction")
pred.w.clim <- predict(lm(y ~ x), new, interval = "confidence")
require(graphics)
matplot(new$x, cbind(pred.w.clim, pred.w.plim[,-1]),
        lty = c(1,2,2,3,3), type = "l", ylab = "predicted y")

linear.mdl$fit[122:130]

# Scatterplot with regression
ggplot(hits.mnthday, aes(x = mnthday, y = freq, group = 1)) +
	geom_point(shape=1) +
	xlab("MM-DD") +
	theme(axis.text.x=element_text(size=8, angle=90, vjust=1)) +
	geom_smooth(method=lm, formula = y ~ x, se = FALSE)

# Scatterplot with seperate n_dow regression 
ggplot(hits.mnthday, aes(x = mnthday, y = freq, group = n_dow, color=n_dow)) +
	geom_point() +
	geom_point(aes(shape=n_dow)) +
	xlab("MM-DD") +
	theme(axis.text.x=element_text(size=8, angle=90, vjust=1)) +
	stat_smooth(method=lm, formula = y ~ x ,
			se=FALSE,    	# Don't add shaded confidence region
                	fullrange=F) + 	# Extend regression lines
	scale_color_brewer(palette="GnBu")

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
