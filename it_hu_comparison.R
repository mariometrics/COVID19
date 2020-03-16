rm(list=ls())

# Import libraries
library(forecast)
library(ggplot2)
library(ggthemes)
library(dplyr)
library(lmtest)
library(scales)
library(zoo)
library(RColorBrewer)
library(xts)
library(plotly)
library(tidyverse)
library(nls2)
library(mixtox)
library(Metrics)
library(MLmetrics)
library(latex2exp)
library(xml2)
library(rvest)
library(tikzDevice)


## Create a daily Date object - helps my work on dates
# Load dataset from github
Deaths = read.csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv"), header=T)
Time = ncol(Deaths)-4
Dates_aggregated = seq( as.Date("2020-01-22"), by=1, len=Time)

# Preallocate matrices to compute aggergate time series
Aggregated_deaths = matrix(nrow = Time , ncol = 1)

# Preallocate matrices to compute aggergate time series
Aggregated_deaths = matrix(nrow = Time , ncol = 1)

for (i in 1:Time) {
  Aggregated_deaths[i,]    = sum(Deaths[,i+4])
}

# Start the analysis for Italy
Italy_deaths = as.integer(t(Deaths[which(Deaths$Country.Region == "Italy"),])[5:ncol(Deaths),1])
Hubei_deaths = as.integer(as.numeric(t(Deaths[which(Deaths$Province.State == "Hubei"),])[5:ncol(Deaths),1]))
FMT = '%Y-%m-%d'
date = as.POSIXlt(Dates_aggregated,format = FMT)$yday

pos_it = which(Italy_deaths == 17)
Italy_deaths = Italy_deaths[Italy_deaths > 16]
date_it = date[pos_it:nrow(Aggregated_deaths)] 
date_hubei = date + pos_it -1

# Logit estimate
logit =  nls(Italy_deaths  ~ SSlogis(date_it, c, b, a))
coeff_logit = coef(logit)

lastday = date[length(date)]
h = 100
newdate = (lastday+1):(lastday+h+1)
predicted = coeff_logit[1]/(1 + exp(-(newdate-coeff_logit[2]))/coeff_logit[3])
pos = length(newdate) - length(predicted[round(predicted) == round(coeff_logit[1])])
end_ep = newdate[pos]
st = list(a = 0.002)

pred_logi = predict(logit)
rmse_logit = rmse(Italy_deaths,pred_logi)
r2_logit = round(R2_Score(pred_logi,Italy_deaths), digits = 6)
Hubei_lockdown = as.POSIXlt("2020-01-23",format = FMT)$yday + pos_it-1
pos_LD = which(date_hubei == Hubei_lockdown)
Italy_lockdown = as.POSIXlt("2020-03-09",format = FMT)$yday
pos_LDit = which(date_it ==Italy_lockdown)
rit_res_it = Italy_lockdown - Hubei_lockdown


pg =TeX("\\href{http://utenti.dises.univpm.it/palomba/Mat/Rsquared.pdf}{G. Palomba (2013)}")



pdf('./plot/plot_logit_exp_Deaths_it_hu.pdf',height=8, width=15)
  plot(Italy_deaths ~ date_it, type = "p", log = "y", lwd = 4 , col = "red", main = "Logistic & Exponential Growth Model of COVID19 Deaths in Italy and Hubei (Logarithmic scale)", 
     xlab = "Day since 1 Jan", ylab = "COVID19 Deaths (log)", xlim = c(min(date_it), (end_ep+20)), ylim = c(min(Italy_deaths), coeff_logit[1]*1.1))  # Census data
curve(coeff_logit[1]/(1 + exp(-(x - coeff_logit[2])/coeff_logit[3])), add = T, col = "blue",lwd=2)  # Fitted model
lines(Hubei_deaths ~ date_hubei, type = "p", lwd = 4, col = "green")
legend(end_ep+10, 100, legend=c("Real data Italy","Real data Hubei", "Logistic Model"),
       col=c("red","green", "blue"), lty=c(NA,NA,1), pch= c(16,16,NA), lwd = 2)
abline(v = Hubei_lockdown, col = "black")
abline(v = Hubei_lockdown+6, col = "black")
abline(v = Italy_lockdown, col = "black")
text(Hubei_lockdown,1000, "Hubei Lockdown")
points(Hubei_lockdown,Hubei_deaths[pos_LD], pch = "X", cex = 2.5, col = "purple")
points(Hubei_lockdown+6,Hubei_deaths[pos_LD+6], pch = "X", cex = 2.5, col = "orange")
points(Italy_lockdown,Italy_deaths[pos_LDit], pch = "X", cex = 2.5, col = "purple")
text(Hubei_lockdown+6,3000, "1 week from Hubei Lockdown")
text(Hubei_lockdown+6,2500, "First positive signal")
text(Italy_lockdown, 2000, "Italy Lockdown")
text(90,700,TeX(sprintf("$R^2_{Logit}: %g^* $", r2_logit)))
text(90,500,paste("days of delay in the Italian lockdown: ",rit_res_it))
text(end_ep+15,30,"Mario Marchetti")
text(end_ep+10,20,"*be careful to take this index seriously in nonlinear correlations!\n Source: http://utenti.dises.univpm.it/palomba/Mat/Rsquared.pdf" )
dev.off()
