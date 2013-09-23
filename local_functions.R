#!/usr/bin/env Rscript
##########################################################################
## Local Functions for Uber Demand Prediction
##########################################################################
#
# R script of Local Functions for Uber Demand Prediction
#

# Define weekday funtion for numeric output [0=Sun, 1=Mon...etc]
wday <- function(x) as.POSIXlt(x)$wday

##########################################################################
## Define Local Functions
##########################################################################
Pause <- function () { 
    cat("Hit <enter> to continue...")
    readline()
    invisible()
}

tic <- function(gcFirst = TRUE, type=c("elapsed", "user.self", "sys.self"))
{
   type <- match.arg(type)
   assign(".type", type, envir=baseenv())
   if(gcFirst) gc(FALSE)
   tic <- proc.time()[type]         
   assign(".tic", tic, envir=baseenv())
   invisible(tic)
}

toc <- function()
{
   type <- get(".type", envir=baseenv())
   toc <- proc.time()[type]
   tic <- get(".tic", envir=baseenv())
   print(toc - tic)
   invisible(toc)
}

beep <- function(n = 3){
    for(i in seq(n)){
        system("rundll32 user32.dll,MessageBeep -1")
        Sys.sleep(.5)
    }
}
