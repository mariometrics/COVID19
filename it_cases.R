rm(list=ls())
library(tidyverse)
library(nls2)
library(mixtox)
library(Metrics)

url = "https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-andamento-nazionale/dpc-covid19-ita-andamento-nazionale.csv"

df = read.csv(url, header = TRUE)
FMT = '%Y-%m-%d %H:%M:%S'

df$data = as.POSIXlt(df$data,format = FMT)$yday
Casi = df[,c('data','totale_casi')]
date = df['data']

# Estimate the rest parameters using a linear model
model.0 <- lm(log(Casi$totale_casi) ~ Casi$data, data=Casi)  
a.0 <- exp(coef(model.0)[1])
b.0 <- coef(model.0)[2]
# Starting parameters
start <- list(a = a.0, b = b.0)

# Logit estimate
logit =  nls(Casi$totale_casi ~ SSlogis(Casi$data, c, b, a), data = Casi)
#logit =  nls(Casi$totale_casi ~ -exp(c-a*exp(- Casi$data/b)), data = Casi, start = st, nls.control(maxiter = 500))
coeff_logit = coef(logit)

lastday = Casi$data[nrow(date)]
h = 100
newdate = (lastday+1):(lastday+h+1)
predicted = coeff_logit[1]/(1 + exp(-(newdate-coeff_logit[2]))/coeff_logit[3])
pos = length(newdate) - length(predicted[round(predicted) == round(coeff_logit[1])])
end_ep = newdate[pos]

# Exponential estimate
exponential = nls(I(Casi$totale_casi ~ a * exp(b * Casi$data)), data = Casi, start = start)
coeff_exponential = coef(exponential)
appr_flex_date = seq(as.Date("2020-01-01"), by=1, len=end_ep)
appr_flex_date = appr_flex_date[length(appr_flex_date)]

pred_logi = predict(logit)
pred_exp = predict(exponential)
rmse_logit = rmse(Casi$totale_casi,pred_logi)
rmse_exp = rmse(Casi$totale_casi,pred_exp)
icu_capacity = 5090*0.25 # source: https://www.agi.it/fact-checking/news/2020-03-06/coronavirus-posti-letto-ospedali-7343251/
tau = log(2)/coeff_exponential["a"] # doubling time
gamma = exp(coeff_exponential[1]) # daily growth

# log = "y", for log scale

pdf('./plot/plot_logit_exp_Cases_it.pdf',height=8, width=15)
plot(Casi$totale_casi ~ Casi$data, data = Casi, type = "p", lwd = 4 , col = "red", main = "Logistic & Exponential Growth Model of COVID19 Deaths in Italy", 
     xlab = "Day since 1 Jan", ylab = "COVID19 Deaths", xlim = c(min(Casi$data), (end_ep+20)), ylim = c(min(Casi$totale_casi), coeff_logit[1]*1.1))  # Census data
curve(coeff_logit[1]/(1 + exp(-(x - coeff_logit[2])/coeff_logit[3])), add = T, col = "blue",lwd=2)  # Fitted model
curve(coeff_exponential[1]*exp(coeff_exponential[2]*x), add = T, col = "orange", lwd= 2)
#abline(h=icu_capacity)
legend(min(Casi$data), coeff_logit[1], legend=c("Real data","Logistic Model", "Exponential Model"),
       col=c("red","blue", "orange"), lty=c(NA,1,1), pch= c(16,NA,NA), lwd = 2)
points(end_ep, coeff_logit[1]/(1 + exp(-(end_ep - coeff_logit[2])/coeff_logit[3])) , pch = "X", cex = 1.3)
text(end_ep+10,20000,paste("RMSE Logit:",round(rmse_logit,digits = 2)))
text(end_ep+10,18000,paste("RMSE Exponential:",round(rmse_exp,digits = 2)))
text(end_ep+10,16000,paste("Approximated Flex Date (Logit, the abscissa of the X on blue line):",appr_flex_date))
text(end_ep+10,14000,paste("Approximated Flex Peak (Logit, the ordinate of the X on blue line):",round(coeff_logit[1]/(1 + exp(-(end_ep - coeff_logit[2])/coeff_logit[3])))))
text(end_ep+19,50,"Mario Marchetti")
dev.off()
