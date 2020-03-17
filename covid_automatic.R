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

### select which series you want analyze
ser = c("data","deceduti")
N_regioni = 20

### pre-allocation
Regioni = NULL
gomp = NULL
logit = NULL
pred_logi = NULL
pred_gomp = NULL
rmse_logit = NULL
rmse_gomp = NULL
r2_logit = NULL
r2_gomp = NULL
coeff = NULL
predicted = NULL
cn = NULL
pos = NULL 
end_ep = NULL
gr = NULL
gr_mean = NULL
dt = NULL
dt_today = NULL
nomi_regioni = NULL
ritardo = NULL
count = NULL
appr_flex_date = NULL

## Start calculation
for (i in 1:N_regioni) {
  ### Name region
  nomi_regioni[i] = as.character(df$denominazione_regione[df$codice_regione==i][1])
  
  ### Extract region
  Regioni[[i]] = df[df$codice_regione==i,ser]
  Regioni[[i]] = Regioni[[i]][Regioni[[i]]$deceduti>4,]
  ritardo[i] = nrow(df[df$codice_regione==3,]) - nrow(Regioni[[i]])
  Regioni[[i]]$data = Regioni[[i]]$data - ritardo[i]

  ### Fit Logistic & Gompertz
  if (nrow(Regioni[[i]]) > 10) {
    count[i] = i
    gomp[[i]] = nls(Regioni[[i]]$deceduti ~ SSgompertz(Regioni[[i]]$data, a, b, c), data = Regioni[[i]])
    logit[[i]] = nls(Regioni[[i]]$deceduti ~ SSlogis(Regioni[[i]]$data, a, b, c), data = Regioni[[i]])
    
    print(i)
    ### RMSE & goodness of fit 
    pred_logi[[i]] = predict(logit[[i]])
    pred_gomp[[i]] = predict(gomp[[i]])
    rmse_logit[i] = rmse(Regioni[[i]]$deceduti,pred_logi[[i]])
    rmse_gomp[i] = rmse(Regioni[[i]]$deceduti,pred_gomp[[i]])
    r2_logit[i] = R2_Score(pred_logi[[i]],Regioni[[i]]$deceduti)
    r2_gomp[i] = R2_Score(pred_gomp[[i]],Regioni[[i]]$deceduti)
    
    ### Choose between Logistic and Gompertz & find the asymptotic value i.e. the peak
    lastday = Regioni[[i]]$data[nrow(Regioni[[i]])]
    h = 100 # good for all 
    newdate = (lastday+1):(lastday+h+1)

    if (rmse_logit[i] < rmse_gomp[i] & r2_logit[i] > r2_gomp[i] ) {
      coeff[[i]] = coef(logit[[i]])
      predicted[[i]] = coeff[[i]][1]/(1 + exp(-(newdate-coeff[[i]][2]))/coeff[[i]][3])
      cn[i] = as.character(sprintf("Logistic %s", nomi_regioni[i]))
    } else{
      coeff[[i]] = coef(gomp[[i]])
      predicted[[i]] = coeff[[i]][1]*exp(-coeff[[i]][2]*coeff[[i]][3]^(newdate))
      cn[i] = as.character(sprintf("Logistic %s", nomi_regioni[i]))
    }

    pos[i] = length(newdate) - length(predicted[[i]][round(predicted[[i]]) > round(coeff[[i]][1], digits = 0)-2])
    end_ep[i] = newdate[pos[i]]

    ### Calculate doubling time
    gr[[i]] = diff(Regioni[[i]]$deceduti)/Regioni[[i]]$deceduti[1:nrow(Regioni[[i]])-1]
    gr_mean[i] = mean(gr[[i]])
    dt[i] = log(2,exp(1))/gr_mean[i]
    dt_today[i] = (Regioni[[i]]$data[nrow(Regioni[[i]])] - Regioni[[i]]$data[nrow(Regioni[[i]])-1])*log(2)/(log(Regioni[[i]]$deceduti[nrow(Regioni[[i]])]/Regioni[[i]]$deceduti[nrow(Regioni[[i]])-1]))

    ### Approximated flex date
    appr_flex_date[[i]] = seq(as.Date("2020-01-01"), by=1, len=(end_ep[i]+ritardo[i]))
    appr_flex_date[[i]] = appr_flex_date[[i]][length(appr_flex_date[[i]])]

  }
}