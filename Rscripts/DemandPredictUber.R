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

if('car' %in% rownames(installed.packages()) == FALSE) 
{install.packages('car', dependencies=T)}

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
library(car)
library(extrafont)

## Set the working directory based on OS
cat("Setting the working directory...\n")
switch(Sys.info()[['sysname']],
       Windows= {setwd("C:\\Users\\ajsmith\\workspace\\demandPredictUber\\Rscripts\\")},
       Linux  = {setwd("~/workspace/demandPredictUber/Rscripts/")},
       Darwin = {cat("I'm a Mac. Working Directory Not Set!\n")}
)

#memory.limit(size=8000)	# set a higher memory limit (in MB)
source('local_functions.R') 	# local functions

##########################################################################
## Check to see if UberData.csv exists and not altered --> load csv to save time
##########################################################################
#csvFile = "../analysis/UberData.csv"
rdataFile = "DemandPredictUber.RData"
Altered = FALSE
#if (file.exists(csvFile) && (Altered == FALSE)){
#	cat("Reading data from CSV file...\n")
#	uber.data = read.csv("../analysis/UberDataNA.csv")
#} 
if (file.exists(rdataFile) && (Altered == FALSE)) {
	cat("Reading data from .Rdata file...\n")
	load(rdataFile)

} else { # Read json file from Uber and derive analysis vars 

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
	## Initialize data frame with JSON data
	uber.data <- data.frame(json=data.json)

	## Convert JSON UTC times to ISO8601 and local Washington DC time
	cat("Formatting UTC and computing localtime... [~3min]\n")
	tic()
	for (i in 1:length(uber.data$json)) {
		uber.data$iso_utc[i] = gsub("(.*).(..)$","\\1\\2",uber.data$json[i])
		uber.data$local[i] = format(as.POSIXct(strptime(uber.data$iso_utc[i], "%Y-%m-%dT%H:%M:%S%z", tz="UTC")), tz="America/New_York", usetz=TRUE)
	}
	toc()

	## Append data.frame with info for Basic Histogram and Regression Analysis 
	# [FIXME - might be faster as matrix instead of ~8-12mins for data.frame with ~90sec per variable computation]
	cat("Computing Day of the Week (dow) and Hourly Data...[very long process ~30min machine dependent]\n")
	tic()
	for (i in 1:length(uber.data$json)) {
		uber.data$doe[i] = as.integer(strptime(uber.data$local[i], "%Y-%m-%d") - strptime("1970-01-01", "%Y-%m-%d"))# Day of Epoch (~106.52 sec)
		uber.data$doy[i] = strptime(uber.data$local[i], "%Y-%m-%d %H:%M:%S")$yday+1	# Day of Year (~89.62 sec)
		# Days since Official Launch in this Market (Which? Uber: ~2011; UberX: ~2012)
		uber.data$mnthday[i] = strftime(uber.data$local[i], "%m-%d")	# Month and Day (~100.1 sec with warnings --> NA errors) 
		uber.data$mdh[i] = strftime(uber.data$local[i], "%m-%d %H00")	# Month, Day and Hour (~98.7 sec with warnings --> NA errors)
		uber.data$dow[i] = weekdays(as.POSIXlt(uber.data$local[i])) 	# Day of Week (dow) (~86.02 sec)
		uber.data$hr[i] = strftime(uber.data$local[i], "%H")			# Hour (~90.22 sec)
		# Top of the hour
		# Botom of the hour
		uber.data$min[i] = strftime(uber.data$local[i], "%M")			# Minute (~89.44 sec)
	}
	toc()

	## Add numeric to start of Day of Week for better display (n_dow = "n-dow") 
	# [FIXME - compute in previous loop using wday() in local_functions.R]
	cat("Adding numeric prefix to dow...\n")
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

	## Flag to resave uber.data as csv file if data.frame altered or appended in analysis
	# csvAltered = TRUE

	if (csvAltered == TRUE){
		# Save data.frame to csv for faster analysis next time
		cat("Saving data.frame to csv...\n")
		tic()
		write.table(uber.data,file="../analysis/UberDataNA.csv",sep=",",row.names=F)
		toc()
	}

} ## END file.exists

## Call browser() to pause script here
cat("Paused: Hit 'Q' to continue with regular prompt...") 
browser()

##########################################################################
# Basic Histogram Analysis
##########################################################################
cat("Beginning basic histogram analysis...\n")
## Generate Counts for each Hour reguardless of Day of the Week
hits.hour = count(uber.data, vars = "hr")
plot.hr = ggplot(data = hits.hour) + geom_bar(aes(x = hr, y = freq), stat="identity", position = "dodge")
print(plot.hr)
Pause()

## Generate Counts for each Hour with Day of the Week (dow)
hits.hour_dow = count(uber.data, vars = c("hr","dow"))
plot.hr_dow = ggplot(data = hits.hour_dow) + geom_bar(aes(x = hr, y = freq), stat="identity", position = "dodge")
print(plot.hr_dow)
Pause()

## Generate Counts for each Hour with Day of the Week (dow)
hits.hour_dow_n = count(uber.data, vars = c("hr","n_dow"))
plot.hr_dow_n = ggplot(data = hits.hour_dow_n) + 
	geom_bar(aes(x = hr, y = freq, fill=n_dow), stat="identity", position = "dodge") +
	scale_fill_brewer(palette="Blues")
print(plot.hr_dow_n)
Pause()

## Generate Counts for each Minute of the Day (reguardless of Day of the Week)
hits.min = count(uber.data, vars = "min")
plot.min = ggplot(data = hits.min) + 
	geom_bar(aes(x = min, y = freq), stat="identity", position = "dodge") +
	scale_fill_brewer(palette="Spectral")
print(plot.min)
Pause()

## Generate Counts for each Hour of the Day for the Whole Time Series
hits.mdh = count(uber.data, vars = c("mdh", "doy"))
plot.mdh = ggplot(data = hits.mdh) + 
	geom_bar(aes(x = mdh, y = freq), stat="identity", position = "dodge") +
	scale_x_discrete(hits.mdh$doy) +
	theme(axis.text.x=element_text(size=8, angle=90, vjust=1))
print(plot.mdh)
Pause()

## Generate Counts for each Month-Day combo
hits.mnthday = count(uber.data, vars = c("mnthday", "n_dow"))
plot.mnthday = ggplot(data = hits.mnthday ) + 
	geom_bar(aes(x = mnthday, y = freq), stat="identity", position = "dodge") +
	xlab("MM-DD") +
	theme_black() +
	theme(axis.text.x=element_text(size=8, angle=90, vjust=1))
	
print(plot.mnthday)
Pause()

cat("End of Basic Historam Analysis...\n")
Pause()

##########################################################################
# Basic Regression Analysis
##########################################################################
cat("Beginning basic regression analysis...\n")
## Simple Linear Model Day of Year vs Frequency
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

## Scatterplot with regression
ggplot(hits.mnthday, aes(x = mnthday, y = freq, group = 1)) +
	geom_point(shape=1) +
	xlab("MM-DD") +
	theme(axis.text.x=element_text(size=8, angle=90, vjust=1)) +
	geom_smooth(method=lm, formula = y ~ x, se = FALSE)

## Scatterplot with seperate n_dow regression 
ggplot(hits.mnthday, aes(x = mnthday, y = freq, group = n_dow, color=n_dow)) +
	geom_point() +
	geom_point(aes(shape=n_dow)) +
	xlab("MM-DD") +
	theme(axis.text.x=element_text(size=8, angle=90, vjust=1)) +
	stat_smooth(method=lm, formula = y ~ x ,
			se=FALSE,    	# Don't add shaded confidence region
                	fullrange=F) + 	# Extend regression lines
	scale_color_brewer(palette="GnBu")+theme_black()


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
## Study of Day of Epoch, Hour, and Day of Week for Demand Prediction
##########################################################################

## Generate Counts for each Day of Epoch, Hour, and Day of Week
hits.doe = count(uber.data, vars = c("doe", "n_dow", "dow", "hr"))
plot.doe = ggplot(data = hits.doedow ) + 
	geom_bar(aes(x = doe, y = freq), stat="identity", position = "dodge") +
	xlab("Day of Epoch") +
	theme(axis.text.x=element_text(size=8, angle=90, vjust=1))
print(plot.doe)
Pause()

## Scatterplot with seperate n_dow regression 
ggplot.doe = ggplot(hits.doe, aes(x = doe, y = freq, group = n_dow, color=n_dow)) +
	geom_point() +
	geom_point(aes(shape=n_dow)) +
	xlab("Day of Epoch") +
	theme(axis.text.x=element_text(size=8, angle=90, vjust=1)) +
	stat_smooth(method=lm, formula = y ~ x ,
			se=FALSE,    	# Don't add shaded confidence region
                	fullrange=FALSE) + 	# Extend regression lines
	scale_color_brewer(palette="Blues") +
	theme_black()

ggplot.doe  +
	scale_fill_discrete(name="Day of the Week")

## Scatterplot with regression
ggplot(hits.doe, aes(x = doe, y = freq, group = 1)) +
	geom_point(shape=1) +
	xlab("Day of Epoch") +
	theme(axis.text.x=element_text(size=8, angle=90, vjust=1)) +
	geom_smooth(method=lm, formula = y ~ x, se = FALSE)


## Linear Model Day of Epoch (doe), Hour of Day (hr) and Day of Week (dow) vs Frequency
freq = hits.doe$freq
doe = hits.doe$doe

# Linear Model
linear.mdl = lm(freq ~ doe)
summary(linear.mdl)
coef(linear.mdl)

par(mfrow = c(2, 2), pty = "s") # 2x2 square plots
plot(linear.mdl)

#predict()

# Polynomial Models
poly2.mdl = lm(freq ~ poly(doe, 2))
summary(poly2.mdl)
coef(poly2.mdl)

par(mfrow = c(2, 2), pty = "s") # 2x2 square plots
plot(poly2.mdl)

scatterplot(freq ~ doe, data=tue, 
  	xlab="Day of Epoch", ylab="Frequency", 
   	main="Demand Prediction")

scatterplotMatrix(~freq+doe+hr | n_dow, data=hits.doe,
	by.group=TRUE,
  	main="Demand Prediction") +
	scale_color_brewer(palette="Blues")


## Linear Model Day of Epoch (doe) and Day of Week (dow) vs Frequency
# Subset data by dow
sun = subset(hits.doe, dow == 'Sunday')
mon = subset(hits.doe, dow == 'Monday')
tue = subset(hits.doe, dow == 'Tuesday')
wed = subset(hits.doe, dow == 'Wednesday')
thu = subset(hits.doe, dow == 'Thursday')
fri = subset(hits.doe, dow == 'Friday')
sat = subset(hits.doe, dow == 'Saturday')

# Sunday
freq = sun$freq
doe = sun$doe

# Linear Model
linear.mdl = lm(freq ~ doe)
summary(linear.mdl)
coef(linear.mdl)

par(mfrow = c(2, 2), pty = "s") # 2x2 square plots
plot(linear.mdl)

par(mfrow = c(1, 1), pty = "s") # 1x1 square plots
plot(doe, freq)
abline(linear.mdl)

## Scatterplot with regression
ggplot(sun, aes(x = doe, y = freq, group = 1)) +
	geom_point(shape=1) +
	xlab("Day of Epoch") +
	theme(axis.text.x=element_text(size=8, angle=90, vjust=1)) +
	geom_smooth(method=lm, formula = y ~ x, se = TRUE)


#predict()

# Polynomial Models
poly2.mdl = lm(freq ~ poly(doe, 2))
summary(poly2.mdl)
coef(poly2.mdl)

par(mfrow = c(2, 2), pty = "s") # 2x2 square plots
plot(poly2.mdl)
