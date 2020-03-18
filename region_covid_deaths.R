rm(list=ls())

library(tidyverse)
library(nls2)
library(mixtox)
library(Metrics)
library(MLmetrics)
library(easynls)
library(growthmodels)

#############################################################################################
##################### LOAD DATA 
############################################################################################
url = "https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-regioni/dpc-covid19-ita-regioni.csv"
df = read.csv(url, header = TRUE)
FMT = '%Y-%m-%d %H:%M:%S'
date = levels(df$data)
date = seq(as.Date("2020-02-24"), by=1, len=length(date))
df$data = as.POSIXlt(df$data,format = FMT)$yday

#############################################################################################
##################### EXTRACT REGION
############################################################################################

Marche = df[df$codice_regione==11,c("data","deceduti")]
Lombardia = df[df$codice_regione==3,c("data","deceduti")]
Piemonte = df[df$codice_regione==1,c("data","deceduti")]
ER = df[df$codice_regione==8,c("data","deceduti")]
Veneto = df[df$codice_regione==5,c("data","deceduti")]
Abruzzo = df[df$codice_regione==13,c("data","deceduti")]
Lazio = df[df$codice_regione==12,c("data","deceduti")]

N_reg = 7

#############################################################################################
##################### LOMBARIA 
############################################################################################
  
### Fit Logistic & Gompertz
gomp_Lombardia = nls(Lombardia$deceduti ~ SSgompertz(Lombardia$data, a, b, c), data = Lombardia)
logit_Lombardia = nls(Lombardia$deceduti ~ SSlogis(Lombardia$data, a, b, c), data = Lombardia)

### RMSE & goodness of fit 
pred_logi_Lom = predict(logit_Lombardia)
pred_gomp_Lom = predict(gomp_Lombardia)
rmse_logit_Lom = rmse(Lombardia$deceduti,pred_logi_Lom)
rmse_gomp_Lom = rmse(Lombardia$deceduti,pred_gomp_Lom)
r2_logit_Lom = R2_Score(pred_logi_Lom,Lombardia$deceduti)
r2_gomp_Lom = R2_Score(pred_gomp_Lom,Lombardia$deceduti)

### Choose between Logistic and Gompertz & Find the asymptotic value i.e. the peak
lastday = Lombardia$data[length(date)]
h = 100 # good for all 
newdate = (lastday+1):(lastday+h+1)

cn = NULL
if (rmse_logit_Lom < rmse_gomp_Lom & r2_logit_Lom > r2_gomp_Lom ) {
  coeff_Lombardia = coef(logit_Lombardia)
  predicted_Lombardia = coeff_Lombardia[1]/(1 + exp(-(newdate-coeff_Lombardia[2]))/coeff_Lombardia[3])
  cn[1] = "Logistic Lombardia"
} else{
  coeff_Lombardia = coef(gomp_Lombardia) 
  predicted_Lombardia = coeff_Lombardia[1]*exp(-coeff_Lombardia[2]*coeff_Lombardia[3]^(newdate))
  cn[1] = "Gompertz Lombardia"
}

pos_Lom = length(newdate) - length(predicted_Lombardia[round(predicted_Lombardia, digits = -3) == round(coeff_Lombardia[1], digits = -3)])
end_ep_Lom = newdate[pos_Lom]

### Calculate doubling time
gr_Lom = diff(Lombardia$deceduti)/Lombardia$deceduti[1:nrow(Lombardia)-1]
gr_mean_Lom = mean(gr_Lom)
dt_Lom = log(2,exp(1))/gr_mean_Lom
dt_Lom_today = (Lombardia$data[nrow(Lombardia)] - Lombardia$data[nrow(Lombardia)-1])*log(2)/(log(Lombardia$deceduti[nrow(Lombardia)]/Lombardia$deceduti[nrow(Lombardia)-1]))

### Approximated Flex Date 
appr_flex_date_Lom = seq(as.Date("2020-01-01"), by=1, len=end_ep_Lom)
appr_flex_date_Lom = appr_flex_date_Lom[length(appr_flex_date_Lom)]

#############################################################################################
##################### MARCHE
############################################################################################

### Calculate days of delay
Marche = Marche[Marche$deceduti>0,]
ritardo_Marche = nrow(Lombardia) - nrow(Marche)
Marche$data = Marche$data - ritardo_Marche

### Fit Logistic & Gompertz
gomp_Marche = nls(Marche$deceduti ~ SSgompertz(Marche$data, a, b, c), data = Marche)
logit_Marche = nls(Marche$deceduti ~ SSlogis(Marche$data, a, b, c), data = Marche)

### RMSE & goodness of fit 
pred_logi_Mar = predict(logit_Marche)
pred_gomp_Mar = predict(gomp_Marche)
rmse_logit_Mar = rmse(Marche$deceduti,pred_logi_Mar)
rmse_gomp_Mar = rmse(Marche$deceduti,pred_gomp_Mar)
r2_logit_Mar = R2_Score(pred_logi_Mar,Marche$deceduti)
r2_gomp_Mar = R2_Score(pred_gomp_Mar,Marche$deceduti)

### Choose between Logistic and Gompertz & find the asymptotic value i.e. the peak
lastday = Marche$data[nrow(Marche)]
h = 100 # good for all 
newdate = (lastday+1):(lastday+h+1)

if (rmse_logit_Mar < rmse_gomp_Mar & r2_logit_Mar > r2_gomp_Mar ) {
  coeff_Marche = coef(logit_Marche)
  predicted_Marche = coeff_Marche[1]/(1 + exp(-(newdate-coeff_Marche[2]))/coeff_Marche[3])
  cn[2] = "Logistic Marche"
} else{
  coeff_Marche = coef(gomp_Marche) 
  predicted_Marche = coeff_Marche[1]*exp(-coeff_Marche[2]*coeff_Marche[3]^(newdate))
  cn[2] = "Gompertz Marche"
}

pos_Mar = length(newdate) - length(predicted_Marche[round(predicted_Marche) > round(coeff_Marche[1], digits = 0)-2])
end_ep_Mar = newdate[pos_Mar]

### Calculate doubling time
gr_Mar = diff(Marche$deceduti)/Marche$deceduti[1:nrow(Marche)-1]
gr_mean_Mar = mean(gr_Mar)
dt_Mar = log(2,exp(1))/gr_mean_Mar
dt_Mar_today = (Marche$data[nrow(Marche)] - Marche$data[nrow(Marche)-1])*log(2)/(log(Marche$deceduti[nrow(Marche)]/Marche$deceduti[nrow(Marche)-1]))

### Approximated flex date
appr_flex_date_Mar = seq(as.Date("2020-01-01"), by=1, len=(end_ep_Mar+ritardo_Marche))
appr_flex_date_Mar = appr_flex_date_Mar[length(appr_flex_date_Mar)]

#############################################################################################
##################### EMILIA ROMAGNA
############################################################################################

### Calculate days of delay
ER = ER[ER$deceduti>0,]
ritardo_ER = nrow(Lombardia) - nrow(ER)
ER$data = ER$data - ritardo_ER

### Fit Logistic & Gompertz
gomp_ER = nls(ER$deceduti ~ SSgompertz(ER$data, a, b, c), data = ER)
logit_ER = nls(ER$deceduti ~ SSlogis(ER$data, a, b, c), data = ER)

### RMSE & goodness of fit 
pred_logi_ER = predict(logit_ER)
pred_gomp_ER = predict(gomp_ER)
rmse_logit_ER = rmse(ER$deceduti,pred_logi_ER)
rmse_gomp_ER = rmse(ER$deceduti,pred_gomp_ER)
r2_logit_ER = R2_Score(pred_logi_ER,ER$deceduti)
r2_gomp_ER = R2_Score(pred_gomp_ER,ER$deceduti)

### Choose between Logistic and Gompertz & find the asymptotic value i.e. the peak
lastday = ER$data[nrow(ER)]
h = 100 # good for all 
newdate = (lastday+1):(lastday+h+1)

if (rmse_logit_ER < rmse_gomp_ER & r2_logit_ER > r2_gomp_ER ) {
  coeff_ER = coef(logit_ER)
  predicted_ER = coeff_ER[1]/(1 + exp(-(newdate-coeff_ER[2]))/coeff_ER[3])
  cn[3] = "Logistic ER"
} else{
  coeff_ER = coef(gomp_ER) 
  predicted_ER = coeff_ER[1]*exp(-coeff_ER[2]*coeff_ER[3]^(newdate))
  cn[3] = "Gompertz ER"
}

pos_ER = length(newdate) - length(predicted_ER[round(predicted_ER) == round(coeff_ER[1], digits = 0)])
end_ep_ER = newdate[pos_ER]

### Calculate doubling time
gr_ER = diff(ER$deceduti)/ER$deceduti[1:nrow(ER)-1]
gr_mean_ER = mean(gr_ER)
dt_ER = log(2,exp(1))/gr_mean_ER
dt_ER_today = (ER$data[nrow(ER)] - ER$data[nrow(ER)-1])*log(2)/(log(ER$deceduti[nrow(ER)]/ER$deceduti[nrow(ER)-1]))

### Approximated flex date
appr_flex_date_ER = seq(as.Date("2020-01-01"), by=1, len=(end_ep_ER+ritardo_ER))
appr_flex_date_ER = appr_flex_date_ER[length(appr_flex_date_ER)]

#############################################################################################
##################### Veneto
############################################################################################

# ### Calculate days of delay
# Veneto = Veneto[Veneto$deceduti>0,]
# ritardo_Veneto = nrow(Lombardia) - nrow(Veneto)
# Veneto$data = Veneto$data - ritardo_Veneto
# 
# ### Fit Logistic & Gompertz
# gomp_Veneto = nls(Veneto$deceduti ~ SSgompertz(Veneto$data, a, b, c), data = Veneto)
# logit_Veneto = nls(Veneto$deceduti ~ SSlogis(Veneto$data, a, b, c), data = Veneto)
# 
# ### RMSE & goodness of fit 
# pred_logi_Veneto = predict(logit_Veneto)
# pred_gomp_Veneto = predict(gomp_Veneto)
# rmse_logit_Veneto = rmse(Veneto$deceduti,pred_logi_Veneto)
# rmse_gomp_Veneto = rmse(Veneto$deceduti,pred_gomp_Veneto)
# r2_logit_Veneto = R2_Score(pred_logi_Veneto,Veneto$deceduti)
# r2_gomp_Veneto = R2_Score(pred_gomp_Veneto,Veneto$deceduti)
# 
# ### Choose between Logistic and Gompertz & find the asymptotic value i.e. the peak
# lastday = Veneto$data[nrow(Veneto)]
# h = 100 # good for all 
# newdate = (lastday+1):(lastday+h+1)
# 
# if (rmse_logit_Veneto < rmse_gomp_Veneto & r2_logit_Veneto > r2_gomp_Veneto ) {
#   coeff_Veneto = coef(logit_Veneto)
#   predicted_Veneto = coeff_Veneto[1]/(1 + exp(-(newdate-coeff_Veneto[2]))/coeff_Veneto[3])
#   cn[4] = "Logistic Veneto"
# } else{
#   coeff_Veneto = coef(gomp_Veneto) 
#   predicted_Veneto = coeff_Veneto[1]*exp(-coeff_Veneto[2]*coeff_Veneto[3]^(newdate))
#   cn[4] = "Gompertz Veneto"
# }
# 
# pos_Veneto = length(newdate) - length(predicted_Veneto[round(predicted_Veneto) == round(coeff_Veneto[1], digits = 0)])
# end_ep_Veneto = newdate[pos_Veneto]
# 
# ### Calculate doubling time
# gr_Veneto = diff(Veneto$deceduti)/Veneto$deceduti[1:nrow(Veneto)-1]
# gr_mean_Veneto = mean(gr_Veneto)
# dt_Veneto = log(2,exp(1))/gr_mean_Veneto
# dt_Veneto_today = (Veneto$data[nrow(Veneto)] - Veneto$data[nrow(Veneto)-1])*log(2)/(log(Veneto$deceduti[nrow(Veneto)]/Veneto$deceduti[nrow(Veneto)-1]))
# 
# ### Approximated flex date
# appr_flex_date_Veneto = seq(as.Date("2020-01-01"), by=1, len=(end_ep_Veneto+ritardo_Veneto))
# appr_flex_date_Veneto = appr_flex_date_Veneto[length(appr_flex_date_Veneto)]
# 

#############################################################################################
##################### Piemonte
############################################################################################

### Calculate days of delay
Piemonte = Piemonte[Piemonte$deceduti>0,]
ritardo_Piemonte = nrow(Lombardia) - nrow(Piemonte)
Piemonte$data = Piemonte$data - ritardo_Piemonte

### Fit Logistic & Gompertz
gomp_Piemonte = nls(Piemonte$deceduti ~ SSgompertz(Piemonte$data, a, b, c), data = Piemonte)
logit_Piemonte = nls(Piemonte$deceduti ~ SSlogis(Piemonte$data, a, b, c), data = Piemonte)

### RMSE & goodness of fit 
pred_logi_Piemonte = predict(logit_Piemonte)
pred_gomp_Piemonte = predict(gomp_Piemonte)
rmse_logit_Piemonte = rmse(Piemonte$deceduti,pred_logi_Piemonte)
rmse_gomp_Piemonte = rmse(Piemonte$deceduti,pred_gomp_Piemonte)
r2_logit_Piemonte = R2_Score(pred_logi_Piemonte,Piemonte$deceduti)
r2_gomp_Piemonte = R2_Score(pred_gomp_Piemonte,Piemonte$deceduti)

### Choose between Logistic and Gompertz & find the asymptotic value i.e. the peak
lastday = Piemonte$data[nrow(Piemonte)]
h = 100 # good for all 
newdate = (lastday+1):(lastday+h+1)

if (rmse_logit_Piemonte < rmse_gomp_Piemonte & r2_logit_Piemonte > r2_gomp_Piemonte ) {
  coeff_Piemonte = coef(logit_Piemonte)
  predicted_Piemonte = coeff_Piemonte[1]/(1 + exp(-(newdate-coeff_Piemonte[2]))/coeff_Piemonte[3])
  cn[5] = "Logistic Piemonte"
} else{
  coeff_Piemonte = coef(gomp_Piemonte) 
  predicted_Piemonte = coeff_Piemonte[1]*exp(-coeff_Piemonte[2]*coeff_Piemonte[3]^(newdate))
  cn[5] = "Gompertz Piemonte"
}

pos_Piemonte = length(newdate) - length(predicted_Piemonte[round(predicted_Piemonte) == round(coeff_Piemonte[1], digits = 0)])
end_ep_Piemonte = newdate[pos_Piemonte]

### Calculate doubling time
gr_Piemonte = diff(Piemonte$deceduti)/Piemonte$deceduti[1:nrow(Piemonte)-1]
gr_mean_Piemonte = mean(gr_Piemonte)
dt_Piemonte = log(2,exp(1))/gr_mean_Piemonte
dt_Piemonte_today = (Piemonte$data[nrow(Piemonte)] - Piemonte$data[nrow(Piemonte)-1])*log(2)/(log(Piemonte$deceduti[nrow(Piemonte)]/Piemonte$deceduti[nrow(Piemonte)-1]))

### Approximated flex date
appr_flex_date_Piemonte = seq(as.Date("2020-01-01"), by=1, len=(end_ep_Piemonte+ritardo_Piemonte))
appr_flex_date_Piemonte = appr_flex_date_Piemonte[length(appr_flex_date_Piemonte)]

#############################################################################################
##################### Abruzzo
############################################################################################
# 
# ### Calculate days of delay
# Abruzzo = Abruzzo[Abruzzo$deceduti>0,]
# ritardo_Abruzzo = nrow(Lombardia) - nrow(Abruzzo)
# Abruzzo$data = Abruzzo$data - ritardo_Abruzzo
# 
# ### Fit Logistic & Gompertz
# gomp_Abruzzo = nls(Abruzzo$deceduti ~ SSgompertz(Abruzzo$data, a, b, c), data = Abruzzo)
# logit_Abruzzo = nls(Abruzzo$deceduti ~ SSlogis(Abruzzo$data, a, b, c), data = Abruzzo)
# 
# ### RMSE & goodness of fit 
# pred_logi_Abruzzo = predict(logit_Abruzzo)
# pred_gomp_Abruzzo = predict(gomp_Abruzzo)
# rmse_logit_Abruzzo = rmse(Abruzzo$deceduti,pred_logi_Abruzzo)
# rmse_gomp_Abruzzo = rmse(Abruzzo$deceduti,pred_gomp_Abruzzo)
# r2_logit_Abruzzo = R2_Score(pred_logi_Abruzzo,Abruzzo$deceduti)
# r2_gomp_Abruzzo = R2_Score(pred_gomp_Abruzzo,Abruzzo$deceduti)
# 
# ### Choose between Logistic and Gompertz & find the asymptotic value i.e. the peak
# lastday = Abruzzo$data[nrow(Abruzzo)]
# h = 100 # good for all 
# newdate = (lastday+1):(lastday+h+1)
# 
# if (rmse_logit_Abruzzo < rmse_gomp_Abruzzo & r2_logit_Abruzzo > r2_gomp_Abruzzo ) {
#   coeff_Abruzzo = coef(logit_Abruzzo)
#   predicted_Abruzzo = coeff_Abruzzo[1]/(1 + exp(-(newdate-coeff_Abruzzo[2]))/coeff_Abruzzo[3])
#   cn[3] = "Logistic Abruzzo"
# } else{
#   coeff_Abruzzo = coef(gomp_Abruzzo) 
#   predicted_Abruzzo = coeff_Abruzzo[1]*exp(-coeff_Abruzzo[2]*coeff_Abruzzo[3]^(newdate))
#   cn[3] = "Gompertz Abruzzo"
# }
# 
# pos_Abruzzo = length(newdate) - length(predicted_Abruzzo[round(predicted_Abruzzo) == round(coeff_Abruzzo[1], digits = 0)])
# end_ep_Abruzzo = newdate[pos_Abruzzo]
# 
# ### Calculate doubling time
# gr_Abruzzo = diff(Abruzzo$deceduti)/Abruzzo$deceduti[1:nrow(Abruzzo)-1]
# gr_mean_Abruzzo = mean(gr_Abruzzo)
# dt_Abruzzo = log(2,exp(1))/gr_mean_Abruzzo
# dt_Abruzzo_today = (Abruzzo$data[nrow(Abruzzo)] - Abruzzo$data[nrow(Abruzzo)-1])*log(2)/(log(Abruzzo$deceduti[nrow(Abruzzo)]/Abruzzo$deceduti[nrow(Abruzzo)-1]))
# 
# ### Approximated flex date
# appr_flex_date_Abruzzo = seq(as.Date("2020-01-01"), by=1, len=(end_ep_Abruzzo+ritardo_Abruzzo))
# appr_flex_date_Abruzzo = appr_flex_date_Abruzzo[length(appr_flex_date_Abruzzo)]

#############################################################################################
##################### Lazio
############################################################################################

# ### Calculate days of delay
# Lazio = Lazio[Lazio$deceduti>0,]
# ritardo_Lazio = nrow(Lombardia) - nrow(Lazio)
# Lazio$data = Lazio$data - ritardo_Lazio
# 
# ### Fit Logistic & Gompertz
# gomp_Lazio = nls(Lazio$deceduti ~ SSgompertz(Lazio$data, a, b, c), data = Lazio)
# logit_Lazio = nls(Lazio$deceduti ~ SSlogis(Lazio$data, a, b, c), data = Lazio)
# 
# ### RMSE & goodness of fit 
# pred_logi_Lazio = predict(logit_Lazio)
# pred_gomp_Lazio = predict(gomp_Lazio)
# rmse_logit_Lazio = rmse(Lazio$deceduti,pred_logi_Lazio)
# rmse_gomp_Lazio = rmse(Lazio$deceduti,pred_gomp_Lazio)
# r2_logit_Lazio = R2_Score(pred_logi_Lazio,Lazio$deceduti)
# r2_gomp_Lazio = R2_Score(pred_gomp_Lazio,Lazio$deceduti)
# 
# ### Choose between Logistic and Gompertz & find the asymptotic value i.e. the peak
# lastday = Lazio$data[nrow(Lazio)]
# h = 100 # good for all 
# newdate = (lastday+1):(lastday+h+1)
# 
# if (rmse_logit_Lazio < rmse_gomp_Lazio & r2_logit_Lazio > r2_gomp_Lazio ) {
#   coeff_Lazio = coef(logit_Lazio)
#   predicted_Lazio = coeff_Lazio[1]/(1 + exp(-(newdate-coeff_Lazio[2]))/coeff_Lazio[3])
#   cn[3] = "Logistic Lazio"
# } else{
#   coeff_Lazio = coef(gomp_Lazio) 
#   predicted_Lazio = coeff_Lazio[1]*exp(-coeff_Lazio[2]*coeff_Lazio[3]^(newdate))
#   cn[3] = "Gompertz Lazio"
# }
# 
# pos_Lazio = length(newdate) - length(predicted_Lazio[round(predicted_Lazio) == round(coeff_Lazio[1], digits = 0)])
# end_ep_Lazio = newdate[pos_Lazio]
# 
# ### Calculate doubling time
# gr_Lazio = diff(Lazio$deceduti)/Lazio$deceduti[1:nrow(Lazio)-1]
# gr_mean_Lazio = mean(gr_Lazio)
# dt_Lazio = log(2,exp(1))/gr_mean_Lazio
# dt_Lazio_today = (Lazio$data[nrow(Lazio)] - Lazio$data[nrow(Lazio)-1])*log(2)/(log(Lazio$deceduti[nrow(Lazio)]/Lazio$deceduti[nrow(Lazio)-1]))
# 
# ### Approximated flex date
# appr_flex_date_Lazio = seq(as.Date("2020-01-01"), by=1, len=(end_ep_Lazio+ritardo_Lazio))
# appr_flex_date_Lazio = appr_flex_date_Lazio[length(appr_flex_date_Lazio)]

#############################################################################################
##################### PLOTTING RESULTS
############################################################################################

### Outer bounds
end_ep = max(c(end_ep_Lom,end_ep_Mar,end_ep_ER))
lmt = max(c(coeff_Lombardia[1],coeff_Marche[1],coeff_ER[1]))

### Plot
pdf('./plot/plot_gomp_log_Marche_Lombardia.pdf',height=8, width=15)
plot(Lombardia, lwd = 4, log = "y", xlim = c(min(Lombardia$data), end_ep+10), ylim = c(min(Marche$deceduti),lmt),
     main = "Logistic & Gompertz growth for Deaths in Italina Regions (Logarithmic scale)",
     sub = "The algorithm automatically interpolates the data of the regions with the Gompertz and Logistic functions and plots the best fitting by evaluating RMSE and R square(carefully!)",
     xlab = "Days since 1st Jan",
     ylab = "Deaths")
lines(Marche,type = "p",col=2, lwd = 4) 
lines(ER,type = "p",col=3, lwd = 4) 
# lines(Veneto,type = "p",col=4) 
lines(Piemonte,type = "p",col=6, lwd = 4) 
# lines(Abruzzo,type = "p",col=10) 
#lines(Lazio, type = "p", col = 13)
#grid(col = 1)

legend(100,50, legend=c("Real data Lombardia","Real data Marche (7 days before)", "Real data ER (2 days before)","Real data Piemonte (10 days before)" ,cn[1],cn[2],cn[3], cn[5]),
       col=c(1,2,3,6,1,2,3,6), lty=c(NA,NA,NA,NA,1,1,1,1), pch= c(16,16,16,16,NA,NA,NA,NA), lwd = 2)

points(end_ep_Mar, coeff_Marche[1]/(1 + exp(-(end_ep_Mar - coeff_Marche[2])/coeff_Marche[3])) , pch = "X", cex = 1.3, col = 2)
points(end_ep_Lom, coeff_Lombardia[1]*exp(-coeff_Lombardia[2]*coeff_Lombardia[3]^(end_ep_Lom)) , pch = "X", cex = 1.3, col = 1)
points(end_ep_ER, coeff_ER[1]/(1 + exp(-(end_ep_ER - coeff_ER[2])/coeff_ER[3])) , pch = "X", cex = 1.3, col = 3)
points(end_ep_Piemonte, coeff_Piemonte[1]/(1 + exp(-(end_ep_Piemonte - coeff_Piemonte[2])/coeff_Piemonte[3])) , pch = "X", cex = 1.3, col = 6)
#points(end_ep_Abruzzo, coeff_Abruzzo[1]/(1 + exp(-(end_ep_Abruzzo - coeff_Abruzzo[2])/coeff_Abruzzo[3])) , pch = "X", cex = 1.3, col = 10)
#points(end_ep_Lazio, coeff_Lazio[1]/(1 + exp(-(end_ep_Lazio - coeff_Lazio[2])/coeff_Lazio[3])) , pch = "X", cex = 1.3, col = 13)

### Fit Lombardia
if (rmse_logit_Lom < rmse_gomp_Lom & r2_logit_Lom > r2_gomp_Lom ) {
  curve(coeff_Lombardia[1]/(1 + exp(-(x-coeff_Lombardia[2])/coeff_Lombardia[3])), add = T, col=1, lwd = 2)
} else{
  curve(coeff_Lombardia[1]*exp(-coeff_Lombardia[2]*coeff_Lombardia[3]^x), add = T, col = 1,lwd=2)
}

### Fit Marche
if (rmse_logit_Mar < rmse_gomp_Mar & r2_logit_Mar > r2_gomp_Mar ) {
 curve(coeff_Marche[1]/(1 + exp(-(x-coeff_Marche[2])/coeff_Marche[3])), add = T, col=2 , lwd = 2)
} else{
  curve(coeff_Marche[1]*exp(-coeff_Marche[2]*coeff_Marche[3]^x), add = T, col = 2,lwd=2)
}

### Fit ER
if (rmse_logit_ER < rmse_gomp_ER & r2_logit_ER > r2_gomp_ER ) {
  curve(coeff_ER[1]/(1 + exp(-(x-coeff_ER[2])/coeff_ER[3])), add = T, col=3 , lwd = 2)
} else{
  curve(coeff_ER[1]*exp(-coeff_ER[2]*coeff_ER[3]^x), add = T, col = 3,lwd=2)
}

# ### Fit Veneto
# if (rmse_logit_Veneto < rmse_gomp_Veneto & r2_logit_Veneto > r2_gomp_Veneto ) {
#   curve(coeff_Veneto[1]/(1 + exp(-(x-coeff_Veneto[2])/coeff_Veneto[3])), add = T, col=4 , lwd = 2)
# } else{
#   curve(coeff_Veneto[1]*exp(-coeff_Veneto[2]*coeff_Veneto[3]^x), add = T, col = 4,lwd=2)
# }


### Fit Piemonte
if (rmse_logit_Piemonte < rmse_gomp_Piemonte & r2_logit_Piemonte > r2_gomp_Piemonte ) {
  curve(coeff_Piemonte[1]/(1 + exp(-(x-coeff_Piemonte[2])/coeff_Piemonte[3])), add = T, col=6 , lwd = 2)
} else{
  curve(coeff_Piemonte[1]*exp(-coeff_Piemonte[2]*coeff_Piemonte[3]^x), add = T, col = 6,lwd=2)
}
# 
# ### Fit Abruzzo
# if (rmse_logit_Abruzzo < rmse_gomp_Abruzzo & r2_logit_Abruzzo > r2_gomp_Abruzzo ) {
#   curve(coeff_Abruzzo[1]/(1 + exp(-(x-coeff_Abruzzo[2])/coeff_Abruzzo[3])), add = T, col=10 , lwd = 2)
# } else{
#   curve(coeff_Abruzzo[1]*exp(-coeff_Abruzzo[2]*coeff_Abruzzo[3]^x), add = T, col = 10,lwd=2)
# } 

# ### Fit Lazio
# if (rmse_logit_Lazio < rmse_gomp_Lazio & r2_logit_Lazio > r2_gomp_Lazio ) {
#   curve(coeff_Lazio[1]/(1 + exp(-(x-coeff_Lazio[2])/coeff_Lazio[3])), add = T, col=13 , lwd = 2)
# } else{
#   curve(coeff_Lazio[1]*exp(-coeff_Lazio[2]*coeff_Lazio[3]^x), add = T, col = 13,lwd=2)
# }

text(80,100,sprintf("Appr. Flex Date Marche: %s \n AV. Doubling time Marche %g",appr_flex_date_Mar,round(dt_Mar,digits = 2)), col = 2, lwd = 2)
text(80,50,sprintf("Appr. Flex Date Lombardia: %s \n AV. Doubling time Lombardia %g",appr_flex_date_Lom,round(dt_Lom,digits = 2)), col = 1, lwd = 2)
text(80,20,sprintf("Appr. Flex Date ER: %s \n AV. Doubling time ER %g",appr_flex_date_ER,round(dt_ER,digits = 2)), col = 3, lwd = 2)
text(80,10,sprintf("Appr. Flex Date Piemonte: %s \n AV. Doubling time Piemonte %g",appr_flex_date_Piemonte,round(dt_Piemonte,digits = 2)), col = 6, lwd = 2)
#text(80,20,sprintf("Appr. Flex Date Veneto: %s \n AV. Doubling time Veneto %g",appr_flex_date_Veneto,round(dt_Veneto,digits = 2)), col = 4, lwd = 2)
#text(80,5,sprintf("Appr. Flex Date Abruzzo: %s \n AV. Doubling time Abruzzo %g",appr_flex_date_Abruzzo,round(dt_Abruzzo,digits = 2)), col = 10, lwd = 2)
#text(80,5,sprintf("Appr. Flex Date Lazio: %s \n AV. Doubling time Lazio %g",appr_flex_date_Lazio,round(dt_Lazio,digits = 2)), col = 3, lwd = 2)
text(end_ep,2,"Mario Marchetti")
dev.off()




