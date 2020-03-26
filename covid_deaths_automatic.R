rm(list=ls())

library(tidyverse)
library(nls2)
library(mixtox)
library(Metrics)
library(MLmetrics)
library(easynls)
library(growthmodels)
library(minpack.lm)
library(randomcoloR)
library(dplyr)

#############################################################################################
##################### LOAD DATA 
############################################################################################
url = "https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-regioni/dpc-covid19-ita-regioni.csv"
df = read.csv(url, header = TRUE)
FMT = '%Y-%m-%dT%H:%M:%S'
date = levels(df$data)
date = seq(as.Date("2020-02-24"), by=1, len=length(date))
df$data = as.POSIXlt(df$data,format = FMT)$yday

### select which series you want analyze
ser = c("data","deceduti")
N_regioni = 20

### Bolzano and Trento same codice regione but different denominazione 
for (w in as.POSIXlt(date,format = "%Y-%m-%d")$yday) {
  for (h in 5:(length(df)-2)) {
    df[df$codice_regione == 4 & df$data == w,h] = sum(df[df$codice_regione == 4 & df$data == w,h])*c(1,NA)
  }
}
df = na.omit(df)

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
gr_today = NULL
gr_today_text = NULL
nomi_regioni = NULL
ritardo = NULL
count = NULL
appr_flex_date = NULL
legend_data = NULL
legend_curve = NULL
lmt = NULL
color = NULL
DT_text = NULL
saturation_text = NULL
cont = nls.control(minFactor = 1e-10)

## Start calculation
for (i in 1:20) {
  ### Name region
  nomi_regioni[i] = as.character(df$denominazione_regione[df$codice_regione==i][1])
  nomi_regioni[4] = "Trentino A.A."
  
  ### Extract region
  Regioni[[i]] = df[df$codice_regione==i,ser]
  Regioni[[i]] = Regioni[[i]][Regioni[[i]]$deceduti>5,]
  ritardo[i] = nrow(df[df$codice_regione==3,]) - nrow(Regioni[[i]])
  Regioni[[i]]$data = Regioni[[i]]$data - ritardo[i]
  
  ### Last percentage growth 
  if (nrow(Regioni[[i]]) >= 2) {
    gr_today[i] = (Regioni[[i]]$deceduti[nrow(Regioni[[i]])] - Regioni[[i]]$deceduti[nrow(Regioni[[i]])-1])/(Regioni[[i]]$deceduti[nrow(Regioni[[i]])-1])*100
    gr_today_text[i] = sprintf("%s: +%g%%\n", nomi_regioni[i], round(gr_today[i], digits = 2))
  }
  
  ### Fit Logistic & Gompertz
  if (nrow(Regioni[[i]]) >= 13) {
    count[i] = i
    print(i)
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
      cn[i] = as.character(sprintf("Gompertz %s", nomi_regioni[i]))
    }
    
    pos[i] = length(newdate) - length(predicted[[i]][round(predicted[[i]]) > round(coeff[[i]][1], digits = 0)-2])
    if (pos[i] >=1) {
      end_ep[i] = newdate[pos[i]]  
    }else{
      end_ep[i] = newdate[1]
    }
    
    
    ### Calculate doubling time
    gr[[i]] = diff(Regioni[[i]]$deceduti)/Regioni[[i]]$deceduti[1:nrow(Regioni[[i]])-1]
    gr_mean[i] = mean(gr[[i]])
    dt[i] = log(2,exp(1))/gr_mean[i]
    dt_today[i] = (Regioni[[i]]$data[nrow(Regioni[[i]])] - Regioni[[i]]$data[nrow(Regioni[[i]])-1])*log(2)/(log(Regioni[[i]]$deceduti[nrow(Regioni[[i]])]/Regioni[[i]]$deceduti[nrow(Regioni[[i]])-1]))
    
    ### Approximated flex date
    appr_flex_date[[i]] = seq(as.Date("2020-01-01"), by=1, len=(end_ep[i]+ritardo[i]))
    appr_flex_date[[i]] = appr_flex_date[[i]][length(appr_flex_date[[i]])]
    
    ## Stuff for plot
    legend_data[i] = sprintf("Real Data %s (%g days before)",nomi_regioni[i],ritardo[i])
    legend_curve[i] = sprintf("%s",cn[i])
    lmt[i] = coeff[[i]][1]
    DT_text[i] = sprintf("Doubling Time (T) %s: %g\n",nomi_regioni[i],round(dt_today[i],digits = 2))
    saturation_text[i] = sprintf("%s: %g \n",nomi_regioni[i],round(coeff[[i]][1], digits = -2))
  }
}

## It is usefull to have Agggregated time series for Italy
aggr_it = NULL
gr_italy = NULL
gr_italy_text = NULL

for (t in as.POSIXlt(date,format = "%Y-%m-%d")$yday) {
  aggr_it[t-min(df$data)] = sum(df$deceduti[df$data == t]) 
  if (length(aggr_it) >= 2) {
    gr_italy = diff(aggr_it)/aggr_it[1:(length(aggr_it)-1)]*100
    gr_italy_text[t-min(df$data)] = sprintf("[%s] +%g%% \n", date[t-min(df$data)+1], round(gr_italy[t-min(df$data)-1], digits = 2))
  }
}

#############################################################################################
##################### PLOTTING RESULTS
############################################################################################

## What plot?
count = count[!is.na(count)]

## To compute legend automatically
legend = c(legend_data[!is.na(legend_data)],legend_curve[!is.na(legend_curve)])
len_leg = length(legend)
color[count] = 1:length(count) 
# color = c(count,count)
# color[count] = randomColor(length(count)) # nice function
color_ = c(color[!is.na(color)],color[!is.na(color)])
lty = rep(1,len_leg)
lty[1:length(count)] = NA
pch = rep(16,len_leg)
pch[length(count)+1:len_leg] = NA
DT_text = DT_text[!is.na(DT_text)]
gr_today = gr_today[!is.na(gr_today)]
gr_today_text = gr_today_text[!is.na(gr_today_text)]
gr_today_idx = sort(gr_today,decreasing = TRUE, index.return = TRUE)$ix[1:5]
top5gr = gr_today_text[gr_today_idx]
last5gr_it = gr_italy_text[length(gr_italy_text):(length(gr_italy_text)-5)]
saturation_text = saturation_text[!is.na(saturation_text)]

### Outer bounds out of cycle
end_ep = max(end_ep[!is.na(end_ep)])
lmt_ = max(lmt[!is.na(lmt)])

### Plot
pdf('./plot/plot_gomp_log_Region_auto.pdf',height=8, width=16)

par(xpd = T, mar = par()$mar + c(1,1,1,18))

plot(Regioni[[3]], lwd = 4, log = "y",
     xlim = c(min(Regioni[[3]]$data), end_ep/2),
     ylim = c(min(Regioni[[11]]$deceduti),max(Regioni[[3]]$deceduti)+mean(Regioni[[3]]$deceduti)),
     main = "Logistic & Gompertz growth for Deaths in Italian Regions (Logarithmic scale)",
     sub = "The algorithm automatically interpolates the data of the regions with the Gompertz and Logistic functions and plots the best fitting by evaluating RMSE and R square(carefully!)",
     xlab = "Days since 1st Jan",
     ylab = "Deaths")

legend(end_ep/2+2,max(Regioni[[3]]$deceduti)*5,
       legend = legend,
       col = color_, 
       lty = lty, 
       pch= pch, 
       lwd = 2,
       cex = 1,
       xpd = TRUE,
       horiz = FALSE,
       bty = "n")

for (j in count) {
  
  ## Plot Real Data 
  lines(Regioni[[j]],type = "p",col = color[j], lwd = 4)
  
  ### Fit Curves
  if (rmse_logit[j] < rmse_gomp[j] & r2_logit[j] > r2_gomp[j] ) {
    curve(coeff[[j]][1]/(1 + exp(-(x-coeff[[j]][2])/coeff[[j]][3])), add = T, col = color[j], lwd = 3, xpd = FALSE)
  } else{
    curve(coeff[[j]][1]*exp(-coeff[[j]][2]*coeff[[j]][3]^x), add = T, col = color[j],lwd=3, xpd = FALSE)
  }
}

## Show useful information on the figure
text(end_ep/2+2,max(Regioni[[3]]$deceduti)/exp(4.15), paste(DT_text, collapse = ""), col = 1, lwd = 2, pos = 4)

text(end_ep/2+2,max(Regioni[[3]]$deceduti)/exp(4.9), paste("Top 5 Perc. Growth ", date[length(date)]), col = 1, lwd = 2, pos = 4)
text(end_ep/2+2,max(Regioni[[3]]$deceduti)/exp(6), paste(top5gr, collapse = ""), col = 1, lwd = 2, pos = 4)

text(min(df$data),max(Regioni[[3]]$deceduti/0.8), "Last 5 days Perc. growth all over Italy",col = 1, lwd = 2, pos = 4)
text(min(df$data),max(Regioni[[3]]$deceduti/3), paste(last5gr_it, collapse = ""),col = 1, lwd = 2, pos = 4)

text(max(df$data)-8,max(Regioni[[3]]$deceduti)/exp(4.4), paste("Saturation Deaths (not a reliable forecast) ", date[length(date)]), col = 1, pos = 4)
text(max(df$data)-8,max(Regioni[[3]]$deceduti)/exp(6), paste(saturation_text, collapse = ""),col = 1, pos = 4)

text(end_ep/2.1,10,"Mario Marchetti", cex = 1.5)
par(mar=c(5, 4, 4, 2))
dev.off()

print(date[length(date)]) # to control updates