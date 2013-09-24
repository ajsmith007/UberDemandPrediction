#!/usr/bin/env Rscript
##########################################################################
## xkcd_examples.R
##########################################################################
#
# XKCD-style plots in R
#

library(xkcd)
vignette("xkcd-intro")

library(ggplot)
ggplot(mapping=aes(x=seq(1,10,.1), y=seq(1,10,.1))) + 
  geom_line(position="jitter", color="red", size=2) + theme_bw()
  
