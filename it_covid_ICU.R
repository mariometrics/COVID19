rm(list=ls())
library(tidyverse)
library(nls2)
library(mixtox)
library(Metrics)

url = "https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-andamento-nazionale/dpc-covid19-ita-andamento-nazionale.csv"

df = read.csv(url, header = TRUE)
FMT = '%Y-%m-%d %H:%M:%S'

df$data = as.POSIXlt(df$data,format = FMT)$yday
Totale_TI = df[,c('data','terapia_intensiva')]
date = df['data']

# Logit estimate
logit =  nls(Totale_TI$terapia_intensiva ~ SSlogis(Totale_TI$data, c, b, a), data = Totale_TI)
coeff_logit = coef(logit)
lastday = Totale_TI$data[nrow(date)]
h = 100
newdate = (lastday+1):(lastday+h+1)
predicted = coeff_logit[1]/(1 + exp(-(newdate-coeff_logit[2]))/coeff_logit[3])
pos = length(newdate) - length(predicted[round(predicted) == round(coeff_logit[1])])
end_ep = newdate[pos]

# Exponential estimate

# Select an approximate $\theta$, since theta must be lower than min(y), and greater than zero

# Estimate the rest parameters using a linear model
model.0 <- lm(log(Totale_TI$terapia_intensiva) ~ Totale_TI$data, data=Totale_TI)  
a.0 <- exp(coef(model.0)[1])
b.0 <- coef(model.0)[2]

# Starting parameters
start <- list(a = a.0, b = b.0)
exponential = nls(I(Totale_TI$terapia_intensiva ~ a * exp(b * Totale_TI$data)), data = Totale_TI, start = start)
coeff_exponential = coef(exponential)
appr_flex_date = seq(as.Date("2020-01-01"), by=1, len=end_ep)
appr_flex_date = appr_flex_date[length(appr_flex_date)]
appr_flex_peak = coeff_logit[1]/(1 + exp(-(end_ep - coeff_logit[2])/coeff_logit[3]))

pred_logi = predict(logit)
pred_exp = predict(exponential)
rmse_logit = rmse(Totale_TI$terapia_intensiva,pred_logi)
rmse_exp = rmse(Totale_TI$terapia_intensiva,pred_exp)
icu_capacity = 5090*0.35 # source: https://www.agi.it/fact-checking/news/2020-03-06/coronavirus-posti-letto-ospedali-7343251/

pdf('./plot/plot_logit_exp_ICU_it.pdf',height=8, width=15)
plot(Totale_TI$terapia_intensiva ~ Totale_TI$data, data = Totale_TI, type = "p", lwd = 4 , col = "red", main = "Logistic & Exponential Growth Model of COVID19 ICU patients in Italy", 
     xlab = "Day since 1 Jan", ylab = "COVID19 ICU patients", xlim = c(min(Totale_TI$data), (end_ep+20)), ylim = c(min(Totale_TI$terapia_intensiva), coeff_logit[1]*1.1))  # Census data
curve(coeff_logit[1]/(1 + exp(-(x - coeff_logit[2])/coeff_logit[3])), add = T, col = "blue",lwd=2)  # Fitted model
curve(coeff_exponential[1]*exp(coeff_exponential[2]*x), add = T, col = "orange", lwd= 2)
abline(h=icu_capacity)
legend(end_ep+10, 500, legend=c("Real data","Logistic Model", "Exponential Model","ICU Capacity"),
       col=c("red","blue", "orange","black"), lty=c(NA,1,1,1), pch= c(16,NA,NA,NA), lwd = 2)
points(end_ep, coeff_logit[1]/(1 + exp(-(end_ep - coeff_logit[2])/coeff_logit[3])) , pch = "X", cex = 1.3)
text(end_ep+10,950,paste("RMSE Logit:",round(rmse_logit,digits = 2)))
text(end_ep+10,850,paste("RMSE Exponential:",round(rmse_exp,digits = 2)))
text(end_ep+10,750,paste("Approximated Flex Date (Logit, the abscissa of the X on blue line):",appr_flex_date))
text(end_ep+10,650,paste("Approximated Flex Peak (Logit, the ordinate of the X on blue line):",round(appr_flex_peak)))
text(end_ep+19,50,"Mario Marchetti")
dev.off()



