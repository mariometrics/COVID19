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
France_deaths = as.integer(as.numeric(t(Deaths[which(Deaths$Country.Region == "France"),])[5:ncol(Deaths),1]))
Spain_deaths = as.integer(as.numeric(t(Deaths[which(Deaths$Country.Region == "Spain"),])[5:ncol(Deaths),1]))

FMT = '%Y-%m-%d'
date = as.POSIXlt(Dates_aggregated,format = FMT)$yday

pos_it = which(Italy_deaths == 17)
pos_fr = which(France_deaths >= 19)[1]
pos_sp = which(Spain_deaths >=17)[1]
Italy_deaths = Italy_deaths[Italy_deaths > 16]
France_deaths = France_deaths[France_deaths > 16]
Italy_deaths = Italy_deaths[Italy_deaths > 16]
Spain_deaths = Spain_deaths[Spain_deaths > 10]
date_it = date[pos_it:nrow(Aggregated_deaths)] 
date_hubei = date + pos_it -1
date_france = date[pos_fr:nrow(Aggregated_deaths)] - (pos_fr - pos_it)
date_sp = date[pos_sp:nrow(Aggregated_deaths)] - (pos_sp - pos_it)

# Logit estimate
logit =  nls(Italy_deaths  ~ SSlogis(date_it, c, b, a))
gomp = nls(Italy_deaths ~ SSgompertz(date_it, c, b, a))
coeff_logit = coef(logit)
coeff_gomp = coef(gomp)

logit_fr =  nls(France_deaths  ~ SSlogis(date_france, c, b, a))
gomp_fr = nls(France_deaths ~ SSgompertz(date_france, c, b, a))
coeff_logit_fr = coef(logit_fr)
coeff_gomp_fr = coef(gomp_fr)

logit_sp =  nls(Spain_deaths  ~ SSlogis(date_sp, c, b, a))
#gomp_sp = nls(Spain_deaths ~ SSgompertz(date_sp, c, b, a))
coeff_logit_sp = coef(logit_sp)
#coeff_gomp_sp = coef(gomp_sp)


lastday = date[length(date)]
h = 100
newdate = (lastday+1):(lastday+h+1)
predicted = coeff_logit[1]/(1 + exp(-(newdate-coeff_logit[2]))/coeff_logit[3])
pos = length(newdate) - length(predicted[round(predicted) == round(coeff_logit[1])])
end_ep = newdate[pos]
st = list(a = 0.002)

pred_logi = predict(logit)
rmse_logit = rmse(Italy_deaths,pred_logi)
r2_logit = round(R2_Score(pred_logi,Italy_deaths), digits = 8)
pred_gomp = predict(gomp)
rmse_gomp = rmse(Italy_deaths,pred_gomp)
r2_gomp = round(R2_Score(pred_gomp,Italy_deaths), digits =  8)

Hubei_lockdown = as.POSIXlt("2020-01-23",format = FMT)$yday + pos_it-1
pos_LD = which(date_hubei == Hubei_lockdown)
Italy_lockdown = as.POSIXlt("2020-03-09",format = FMT)$yday
pos_LDit = which(date_it ==Italy_lockdown)
rit_res_it = Italy_lockdown - Hubei_lockdown

diff_date = end_ep - length(date_hubei) -1
dist_peak = coeff_logit[1]/(1 + exp(-(end_ep - coeff_logit[2])/coeff_logit[3])) - Hubei_deaths[diff_date]
dist_peak_c = coeff_logit[1]/(1 + exp(-(end_ep - coeff_logit[2])/coeff_logit[3])) - Hubei_deaths[28]

dt_Italy_today = (date_it[length(Italy_deaths)] - date_it[length(Italy_deaths)-1])*log(2)/(log(Italy_deaths[length(Italy_deaths)]/Italy_deaths[length(Italy_deaths)-1]))
#dt_France_today = (date_france[length(France_deaths)] - date_france[length(France_deaths)-1])*log(2)/(log(France_deaths[length(France_deaths)]/France_deaths[length(France_deaths)-1]))
gr = log((France_deaths[length(France_deaths)]/France_deaths[length(France_deaths)-2]),exp(1))/2 
dt_France_today =  log(2,exp(1))/gr 
dt_Spain_today = (date_sp[length(Spain_deaths)] - date_sp[length(Spain_deaths)-1])*log(2)/(log(Spain_deaths[length(Spain_deaths)]/Spain_deaths[length(Spain_deaths)-1]))

pdf('./plot/plot_logit_exp_Deaths_it_hu.pdf',height=8, width=15)
plot(Italy_deaths ~ date_it, type = "p", log = "y", lwd = 4 , cex = 1.9, pch = 16, col = "orange", main = "Logistic & Exponential Growth Model of COVID19 Deaths in Italy and Hubei (Logarithmic scale)", 
     xlab = "Day since 1 Jan", ylab = "COVID19 Deaths (log)", xlim = c(min(date_it), (end_ep+20)), ylim = c(min(Italy_deaths), coeff_logit[1]*2))  # Census data
curve(coeff_logit[1]/(1 + exp(-(x - coeff_logit[2])/coeff_logit[3])), add = T, col = "orange",lwd=2)  # Fitted model
curve(coeff_gomp[1]*exp(-coeff_gomp[2]*coeff_gomp[3]^x), add = T, col = "orange",lwd=2, lty = 4, type = "o",pch = 17)

curve(coeff_logit_fr[1]/(1 + exp(-(x - coeff_logit_fr[2])/coeff_logit_fr[3])), add = T, col = "purple",lwd=2)  # Fitted model
curve(coeff_gomp_fr[1]*exp(-coeff_gomp_fr[2]*coeff_gomp_fr[3]^x), add = T, col = "purple",lwd=2, type = "o",lty=4, pch =17)

curve(coeff_logit_sp[1]/(1 + exp(-(x - coeff_logit_sp[2])/coeff_logit_sp[3])), add = T, col = "red",lwd=2)  # Fitted model
#curve(coeff_gomp_sp[1]*exp(-coeff_gomp_sp[2]*coeff_gomp_sp[3]^x), add = T, col = "red",lwd=2, type = "o", lty=4, pch = 17)

lines(Hubei_deaths ~ date_hubei, type = "p", lwd = 4, col = "green", cex = 1.9, pch = 16)
lines(France_deaths ~ date_france, type = "p", lwd = 4, col = "purple", cex = 1.9, pch = 16)
lines(Spain_deaths ~ date_sp, type = "p", lwd = 4, col = "red", cex = 1.9, pch = 16 )
  
legend(end_ep+14, 200, legend=c("Real data Italy","Real data Hubei", "Real data France","Real data Spain", 
                                "Logistic Italy","Gompertz Italy","Logistic France","Gompertz France", "Logistic Spain","Gompertz Spain"),
       col=c("orange","green", "purple","red","orange", "orange", "purple","purple","red","red"), lty=c(NA,NA,NA,NA,1,1,1,1,1,1), 
       pch= c(16,16,16,16,NA,17,NA,17,NA,17), lwd = 2)

abline(v = Hubei_lockdown, col = "black")
abline(v = Hubei_lockdown+6, col = "black")
abline(v = Italy_lockdown, col = "black")
text(Hubei_lockdown,1000, "Hubei Lockdown")
points(Hubei_lockdown,Hubei_deaths[pos_LD], pch = "X", cex = 2.5, col = "black")
points(Hubei_lockdown+6,Hubei_deaths[pos_LD+6], pch = "X", cex = 2.5, col = "black")
points(Italy_lockdown,Italy_deaths[pos_LDit], pch = "X", cex = 2.5, col = "black")
text(Hubei_lockdown+6,3000, "1 week from Hubei Lockdown")
text(Hubei_lockdown+6,2500, "First positive signal")
text(Italy_lockdown, 2000, "Italy Lockdown")
text(77,185,TeX(sprintf("$R^2_{Logit,IT}: %g^*$   $R^2_{Gomp,IT}: %g^* $", r2_logit,r2_gomp)))
text(77,120,sprintf("Delay in the Italian lockdown: %g days \n Flex difference (Italy - Hubei) = %g deaths",rit_res_it,round(dist_peak, digits = 0)))
text(77,60,sprintf("Doubling Time Italy at time T: %g \n Doubling Time France at time T: %g \n Doubling Time Spain at time T: %g",round(dt_Italy_today, digits = 2),round(dt_France_today, digits = 2),round(dt_Spain_today, digits = 2)))
text(end_ep+15,10000,"Mario Marchetti")
text(end_ep+10,7,"*be careful to take seriously that indexin nonlinear correlations!\n Source: http://utenti.dises.univpm.it/palomba/Mat/Rsquared.pdf" )
points(end_ep, Hubei_deaths[diff_date] , pch = "X", cex = 2, col = 3)
points(end_ep, coeff_logit[1]/(1 + exp(-(end_ep - coeff_logit[2])/coeff_logit[3])) , pch = "X", cex = 2, col = 1)
dev.off()
