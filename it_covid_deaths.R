rm(list=ls())
library(tidyverse)
library(nls2)
library(mixtox)
library(Metrics)

url = "https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-andamento-nazionale/dpc-covid19-ita-andamento-nazionale.csv"

df = read.csv(url, header = TRUE)
FMT = '%Y-%m-%d %H:%M:%S'

df$data = as.POSIXlt(df$data,format = FMT)$yday
Totale_deceduti = df[,c('data','deceduti')]
date = df['data']

# Logit estimate
logit =  nls(Totale_deceduti$deceduti ~ SSlogis(Totale_deceduti$data, c, b, a), data = Totale_deceduti)
coeff_logit = coef(logit)
lastday = Totale_deceduti$data[nrow(date)]
h = 100
newdate = (lastday+1):(lastday+h+1)
predicted = coeff_logit[1]/(1 + exp(-(newdate-coeff_logit[2]))/coeff_logit[3])
pos = length(newdate) - length(predicted[round(predicted) == round(coeff_logit[1])])
end_ep = newdate[pos]

# Exponential estimate

# Select an approximate $\theta$, since theta must be lower than min(y), and greater than zero

# Estimate the rest parameters using a linear model
model.0 <- lm(log(Totale_deceduti$deceduti) ~ Totale_deceduti$data, data=Totale_deceduti)  
a.0 <- exp(coef(model.0)[1])
b.0 <- coef(model.0)[2]

# Starting parameters
start <- list(a = a.0, b = b.0)
exponential = nls(I(Totale_deceduti$deceduti ~ a * exp(b * Totale_deceduti$data)), data = Totale_deceduti, start = start)
coeff_exponential = coef(exponential)
appr_flex_date = seq(as.Date("2020-01-01"), by=1, len=end_ep)
appr_flex_date = appr_flex_date[length(appr_flex_date)]

pred_logi = predict(logit)
pred_exp = predict(exponential)
rmse_logit = rmse(Totale_deceduti$deceduti,pred_logi)
rmse_exp = rmse(Totale_deceduti$deceduti,pred_exp)
icu_capacity = 5090*0.25 # source: https://www.agi.it/fact-checking/news/2020-03-06/coronavirus-posti-letto-ospedali-7343251/
# gr = NULL
# for (i in 1:(nrow(date)-1)) {
#   gr[i] = (Totale_deceduti$deceduti[i+1] - Totale_deceduti$deceduti[i])/(Totale_deceduti$deceduti[i])
# }
# T_d = (70/gr) + 0.03

pdf('./plot/plot_logit_exp_Deaths_it.pdf',height=8, width=15)
plot(Totale_deceduti$deceduti ~ Totale_deceduti$data, data = Totale_deceduti, type = "p", lwd = 4 , col = "red", main = "Logistic & Exponential Growth Model of COVID19 Deaths in Italy", 
     xlab = "Day since 1 Jan", ylab = "COVID19 Deaths", xlim = c(min(Totale_deceduti$data), (end_ep+20)), ylim = c(min(Totale_deceduti$deceduti), coeff_logit[1]*1.1))  # Census data
curve(coeff_logit[1]/(1 + exp(-(x - coeff_logit[2])/coeff_logit[3])), add = T, col = "blue",lwd=2)  # Fitted model
curve(coeff_exponential[1]*exp(coeff_exponential[2]*x), add = T, col = "orange", lwd= 2)
#abline(h=icu_capacity)
legend(min(Totale_deceduti$data), coeff_logit[1], legend=c("Real data","Logistic Model", "Exponential Model"),
       col=c("red","blue", "orange"), lty=c(NA,1,1), pch= c(16,NA,NA), lwd = 2)
points(end_ep, coeff_logit[1]/(1 + exp(-(end_ep - coeff_logit[2])/coeff_logit[3])) , pch = "X", cex = 1.3)
text(end_ep+10,6000,paste("RMSE Logit:",round(rmse_logit,digits = 2)))
text(end_ep+10,5600,paste("RMSE Exponential:",round(rmse_exp,digits = 2)))
text(end_ep+10,5200,paste("Approximated Flex Date (Logit, the X on blue line):",appr_flex_date))
text(end_ep+19,50,"Mario Marchetti")
dev.off()
