##########################################################################
## Study of Day of Epoch, Hour, and Day of Week for Demand Prediction
##########################################################################
#
# Run DemandPredictUber.R up to Browser() break, hit 'Q' before running this
#
## Additional libraries
library(car)
library(MASS)

## Generate Counts for each Day of Epoch, Day of Week and Hour
hits.doe = count(uber.data, vars = c("doe", "dow", "hr"))

cat("Adding numeric prefix to dow for cleaner plotting...\n")
tic()
for (d in 1:length(hits.doe$dow)){
	if(hits.doe$dow[d] == "Sunday"){ 
		hits.doe$n_dow[d] = "0-Sunday" 
	} else if(hits.doe$dow[d] == "Monday"){
		hits.doe$n_dow[d] = "1-Monday" 
	} else if(hits.doe$dow[d] == "Tuesday"){ 
		hits.doe$n_dow[d] = "2-Tuesday" 
	} else if(hits.doe$dow[d] == "Wednesday"){ 
		hits.doe$n_dow[d] = "3-Wednesday" 
	} else if(hits.doe$dow[d] == "Thursday"){ 
		hits.doe$n_dow[d] = "4-Thursday" 
	} else if(hits.doe$dow[d] == "Friday"){ 
		hits.doe$n_dow[d] = "5-Friday" 
	} else if (hits.doe$dow[d] == "Saturday"){ 
		hits.doe$n_dow[d] = "6-Saturday" 
	}
}
toc()

##########################################################################
## Bar Chart of Frequency for each Month-Day combo
hits.mnthday = count(uber.data, vars = c("mnthday", "n_dow"))
plot.mnthday = ggplot(data = hits.mnthday) + 
	geom_bar(aes(x = mnthday, y = freq), stat="identity", position = "dodge") +
	xlab("MM-DD") +
	theme_black() +
	theme(axis.text.x=element_text(size=8, angle=90, vjust=1))
plot.mnthday


# Bar Chart of Freqency vs Day of Epoch
ggplot.doebar = ggplot(data = hits.doe) + 
	geom_bar(aes(x = doe, y = freq), stat="identity", position = "dodge") +
	xlab("Day of Epoch") +
	theme_black() +
	theme(axis.text.x=element_text(size=8, angle=90, vjust=1))
ggplot.doebar

## Generate Counts for each Hour with Day of the Week (dow)
hits.hour_dow_n = count(uber.data, vars = c("hr","n_dow"))
plot.hr_dow_n = ggplot(data = hits.hour_dow_n) + 
	geom_bar(aes(x = hr, y = freq, fill=n_dow), stat="identity", position = "dodge") +
	theme_black() +
	scale_fill_brewer(palette="Blues")
print(plot.hr_dow_n)


## Scatterplot with seperate n_dow regression 
ggplot.doe = ggplot(hits.doe, aes(x = doe, y = freq, group = n_dow, color=n_dow)) +
	geom_point() +
	geom_point(aes(shape=n_dow)) +
	xlab("Day of Epoch") +
	theme(axis.text.x=element_text(size=8, angle=90, vjust=1)) +
	stat_smooth(method=rlm, formula = y ~ x ,
			se=FALSE,    	# Don't add shaded confidence region
                	fullrange=FALSE) + 	# Extend regression lines
	scale_color_brewer(palette="Blues") +
	theme_black()
ggplot.doe

##########################################################################
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

scatterplotMatrix(~freq+hr | n_dow, data=hits.doe,
	by.group=TRUE,
  	main="Demand Prediction")




## Linear Model Day of Epoch (doe) and Day of Week (dow) vs Frequency
# Add hour as string for regression over the day
cat("Adding hour as string...\n")
tic()
for (h in 1:length(hits.doe$hr)){ 
	hits.doe$hour[h] = toString(hits.doe$hr[h])
}
toc()

##########################################################################
# Subset data by dow and certain hours
sun = subset(hits.doe, dow == 'Sunday' & hr == 0)
mon = subset(hits.doe, dow == 'Monday' & hr == 2 | hr == 8 | hr == 14 | hr == 20)
tue = subset(hits.doe, dow == 'Tuesday' & hr == 0)
wed = subset(hits.doe, dow == 'Wednesday' & hr == 0 | hr == 6 | hr == 12 | hr == 18)
thu = subset(hits.doe, dow == 'Thursday' & hr == 0 | hr == 6 | hr == 12 | hr == 18)
fri = subset(hits.doe, dow == 'Friday' & hr == 0 | hr == 6 | hr == 12 | hr == 18)
sat = subset(hits.doe, dow == 'Saturday' & hr == 0 | hr == 6 | hr == 12 | hr == 18)

Sun0000.mean <- mean(hits.doe$freq[which(hits.doe$dow == 'Sunday' & hits.doe$hr == 0)])
mean(sun$freq)

##########################################################################
##########################################################################
# Sub in any day
sub = subset(hits.doe, dow == 'Wednesday' & hr == 14)
freq = sub$freq
doe = sub$doe

# Linear Model
linear.mdl = rlm(freq ~ doe)
summary(linear.mdl)
coef(linear.mdl)


##########################################################################
##########################################################################
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

ggplot.mon = ggplot(mon, aes(x = doe, y = freq, group = hour, color=hour)) +
	geom_point() +
	geom_point(aes(shape=hour)) +
	xlab("Day of Epoch") +
	theme(axis.text.x=element_text(size=8, angle=90, vjust=1)) +
	stat_smooth(method=rlm, formula = y ~ poly(x, 1),
			se=F,    		# Don't add shaded confidence region
                	fullrange=FALSE) + 	# Extend regression lines
	scale_color_brewer(palette="Blues") +
	theme_black()
ggplot.mon

#predict()

# Polynomial Models
poly2.mdl = lm(freq ~ poly(doe, 2))
summary(poly2.mdl)
coef(poly2.mdl)

par(mfrow = c(2, 2), pty = "s") # 2x2 square plots
plot(poly2.mdl)



##########################################################################
##Hour of Day

hod = subset(hits.doe), hr == 0)
ggplot.hod = ggplot(hod, aes(x = doe, y = freq, group = n_dow, color=n_dow)) +
	geom_point() +
	geom_point(aes(shape=n_dow)) +
	scale_y_continuous(limits=c(0,120)) +
	ggtitle("Time: 0000") +
	xlab("Day of Epoch") +
	theme(axis.text.x=element_text(size=8, angle=90, vjust=1)) +
	stat_smooth(method=rlm, formula = y ~ poly(x, 1),
			se=FALSE,    		# Don't add shaded confidence region
                	fullrange=TRUE) + 	# Extend regression lines
	scale_color_brewer(palette="Blues") +
	theme_black()
#ggsave("regression_2300_day_of_epoch_by_dow_black.png", width=11.11, height=7.2, dpi=100)
ggplot.hod

##########################################################################
##Model Demand Prediction by Hour of Day and Day of Epoch

days = c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")

slope <- matrix(ncol = 24, nrow = length(days))
intercept <- matrix(ncol = 24, nrow = length(days))

colnames(slope) <- seq(0,23) 
colnames(intercept) <-seq(0,23)

rownames(slope) <- days 
rownames(intercept) <- days

d = 0
for (dd in days){
	for (h in seq(0,23,1)){
		# Get subset of data by doe and hr
		sub = subset(hits.doe, dow == dd & hr == h)
		freq = sub$freq
		doe = sub$doe

		# Linear Model
		linear.mdl = rlm(freq ~ doe)
		c = coef(linear.mdl)
		intercept[d+1, h+1] = as.numeric(c[1]) 	
		slope[d+1, h+1] = as.numeric(c[2])		

	}
	d = d +1
}

write.table(intercept, file = "../static/data/intercept.csv", row.names = F, col.names = F, sep = ",")
write.table(slope, file = "../static/data/slope.csv", row.names = F, col.names = F, sep = ",")

sink("../static/data/slope.json")
toJSON(dput(slope))
sink()

sink("../static/data/intercept.json")
toJSON(dput(intercept))
sink()


##########################################################################
##########################################################################
# Make predictions for May 1 2012 00:00:00 UTC through May 15 2012 23:00:00 UTC
#Copy hits.doe
hits.doed = hits.doe
hits.doed$hrs = as.numeric(hits.doed$hr) # make hr numeric
# Corrrect Time from UTC to Eastern Time Zone
startDate$json = "2012-05-01T00:00:00+00:00"
startDate$iso_utc = gsub("(.*).(..)$","\\1\\2",startDate$json)
startDate$utc = as.POSIXct(startDate$iso_utc, "%Y-%m-%dT%H:%M:%S", tz="UTC")
#startDate$local = format(as.POSIXct(strptime(startDate$iso_utc, "%Y-%m-%dT%H:%M:%S%z", tz="UTC")), tz="America/New_York", usetz=TRUE)
startDate$local = format(startDate$utc, tz="America/New_York", usetz=TRUE)

# Cycle through evry hour for the first two weeks in May 2012
for (dd in seq(0,14,1)) {
	for (hh in seq(0,23,1)){ 
		# Add multiple of hours (3600sec) to  
		newDate$local = as.POSIXct(as.POSIXlt(startDate$local, tz="America/New_York", usetz=TRUE) + (dd * 86400) + (hh * 3600))
		newDate$doe = as.integer(strptime(newDate$local, "%Y-%m-%d") - strptime("1970-01-01", "%Y-%m-%d"))# Day of Epoch
		# Extract weekday and hour from datetime
		w = weekdays(newDate$local)
		h = as.POSIXlt(newDate$local)$hour
		
		sub = subset(hits.doed, dow == w & hrs == h)
		freq = sub$freq
		doe = sub$doe
		linear.mdl = lm(freq ~ doe) # Linear Model

		c = coef(linear.mdl)
		intercept = as.numeric(c[1]) 	
		slope = as.numeric(c[2])			
		predict.it = newDate$doe*slope + intercept

		newDate$utc = format(newDate$local, tz='UTC', usetz=TRUE)
		newDate$iso_utc =  format(as.POSIXct(newDate$utc), '%Y-%m-%dT%H:%M:%S')
		
		if (dd == 0 & hh == 0){
			prediction <- data.frame(datetime_utc=toString(newDate$iso_utc), prediction=as.numeric(predict.it))		
		} else {
			prediction <- rbind(prediction, data.frame(datetime_utc=toString(newDate$iso_utc), prediction=as.numeric(predict.it)))		
		}
	}
}

# Write answers for first two weeks May 2012 to CSV 
write.table(prediction, file="../static/data/DemandPredictionMay2012.csv", sep = ", ", row.names=FALSE, col.names=TRUE)

#,append=FALSE, 

##########################################################################


