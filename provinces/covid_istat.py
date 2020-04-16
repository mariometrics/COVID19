import pandas as pd 
import numpy as np
import matplotlib.pyplot as plt
import mplleaflet

df = pd.read_csv('comune_giorno.csv', usecols = ['REG','NOME_REGIONE', 'NOME_PROVINCIA',
                                                 'NOME_COMUNE', 'GE','TOTALE_15','TOTALE_16',
                                                 'TOTALE_17','TOTALE_18',
                                                 'TOTALE_19','TOTALE_20'])

PU = df.where(df['NOME_PROVINCIA'] == 'Pesaro e Urbino').dropna()
for i in  range(PU['TOTALE_20'].shape[0]):
    if PU['TOTALE_20'].iloc[i] == 9999:
        PU['TOTALE_20'].iloc[i] = np.nan
PU = PU.dropna()

# Cities PU considered 
Dettaglio_comuni_PU = PU.groupby('NOME_COMUNE').aggregate({'TOTALE_19':np.sum,'TOTALE_20':np.sum})
Dettaglio_comuni_PU = Dettaglio_comuni_PU.reset_index()
Dettaglio_comuni_PU.columns = ['City','2019','2020']
Dettaglio_comuni_PU['Variazione %'] = round((Dettaglio_comuni_PU['2020']/Dettaglio_comuni_PU['2019']-1)*100, 2)
Dettaglio_comuni_PU.to_csv('./../tables/Dettaglio_comuni_PU.csv ', header=True, index=False, sep=',')
comuni_PU = Dettaglio_comuni_PU['City']
n_comuni_PU = comuni_PU.shape[0]
n_comuni_PU_tot = 53 # source Wikipedia
perc_PU = round(n_comuni_PU/n_comuni_PU_tot*100,2)
max_var_PU = "Comune con il maggiore incremento di decessi tra '19 e '20: {} +{}%".format(Dettaglio_comuni_PU['City'].loc[Dettaglio_comuni_PU['Variazione %'].idxmax()],Dettaglio_comuni_PU['Variazione %'].max())

Lodi = df.where(df['NOME_PROVINCIA'] == 'Lodi').dropna()
for i in  range(Lodi['TOTALE_20'].shape[0]):
    if Lodi['TOTALE_20'].iloc[i] == 9999:
        Lodi['TOTALE_20'].iloc[i] = np.nan
Lodi = Lodi.dropna()

# Cities Lodi considered 
Dettaglio_comuni_Lodi = Lodi.groupby('NOME_COMUNE').aggregate({'TOTALE_19':np.sum,'TOTALE_20':np.sum})
Dettaglio_comuni_Lodi = Dettaglio_comuni_Lodi.reset_index()
Dettaglio_comuni_Lodi.columns = ['City','2019','2020']
Dettaglio_comuni_Lodi['Variazione %'] = round((Dettaglio_comuni_Lodi['2020']/Dettaglio_comuni_Lodi['2019']-1)*100, 2)
Dettaglio_comuni_Lodi.to_csv('./../tables/Dettaglio_comuni_Lodi.csv ', header=True, index=False, sep=',')
comuni_Lodi = Dettaglio_comuni_Lodi['City']
n_comuni_Lodi = comuni_Lodi.shape[0]
n_comuni_Lodi_tot = 60 # source Wikipedia
perc_Lodi = round(n_comuni_Lodi/n_comuni_Lodi_tot*100,2)
max_var_Lodi = "Comune con il maggiore incremento di decessi tra '19 e '20: {} +{}%".format(Dettaglio_comuni_Lodi['City'].loc[Dettaglio_comuni_Lodi['Variazione %'].idxmax()],Dettaglio_comuni_Lodi['Variazione %'].max())

Bergamo = df.where(df['NOME_PROVINCIA'] == 'Bergamo').dropna()
for i in  range(Bergamo['TOTALE_20'].shape[0]):
    if Bergamo['TOTALE_20'].iloc[i] == 9999:
        Bergamo['TOTALE_20'].iloc[i] = np.nan
Bergamo = Bergamo.dropna()

# Cities Bergamo considered 
Dettaglio_comuni_Bergamo = Bergamo.groupby('NOME_COMUNE').aggregate({'TOTALE_19':np.sum,'TOTALE_20':np.sum})
Dettaglio_comuni_Bergamo = Dettaglio_comuni_Bergamo.reset_index()
Dettaglio_comuni_Bergamo.columns = ['City','2019','2020']
Dettaglio_comuni_Bergamo['Variazione %'] = round((Dettaglio_comuni_Bergamo['2020']/Dettaglio_comuni_Bergamo['2019']-1)*100, 2)
Dettaglio_comuni_Bergamo.to_csv('./../tables/Dettaglio_comuni_Bergamo.csv ', header=True, index=False, sep=',')
comuni_Bergamo = Dettaglio_comuni_Bergamo['City']
n_comuni_Bergamo = comuni_Bergamo.shape[0]
n_comuni_Bergamo_tot = 243 # source Wikipedia
perc_Bergamo = round(n_comuni_Bergamo/n_comuni_Bergamo_tot*100,2)
max_var_Bergamo = "Comune con il maggiore incremento di decessi tra '19 e '20: {} +{}%".format(Dettaglio_comuni_Bergamo['City'].loc[Dettaglio_comuni_Bergamo['Variazione %'].idxmax()],Dettaglio_comuni_Bergamo['Variazione %'].max())

Piacenza = df.where(df['NOME_PROVINCIA'] == 'Piacenza').dropna()
for i in range(Piacenza['TOTALE_20'].shape[0]):
    if Piacenza['TOTALE_20'].iloc[i] == 9999:
        Piacenza['TOTALE_20'].iloc[i] = np.nan
Piacenza = Piacenza.dropna()

# Cities Piacenza considered 
Dettaglio_comuni_Piacenza = Piacenza.groupby('NOME_COMUNE').aggregate({'TOTALE_19':np.sum,'TOTALE_20':np.sum})
Dettaglio_comuni_Piacenza = Dettaglio_comuni_Piacenza.reset_index()
Dettaglio_comuni_Piacenza.columns = ['City','2019','2020']
Dettaglio_comuni_Piacenza['Variazione %'] = round((Dettaglio_comuni_Piacenza['2020']/Dettaglio_comuni_Piacenza['2019']-1)*100, 2)
Dettaglio_comuni_Piacenza.to_csv('./../tables/Dettaglio_comuni_Piacenza.csv ', header=True, index=False, sep=',')
comuni_Piacenza = Dettaglio_comuni_Piacenza['City']
n_comuni_Piacenza = comuni_Piacenza.shape[0]
n_comuni_Piacenza_tot = 46 # source Wikipedia
perc_Piacenza = round(n_comuni_Piacenza/n_comuni_Piacenza_tot*100,2)
max_var_Piacenza = "Comune con il maggiore incremento di decessi tra '19 e '20: {} +{}%".format(Dettaglio_comuni_Piacenza['City'].loc[Dettaglio_comuni_Piacenza['Variazione %'].idxmax()],Dettaglio_comuni_Piacenza['Variazione %'].max())

Milano = df.where(df['NOME_PROVINCIA'] == 'Milano').dropna()
for i in range(Milano['TOTALE_20'].shape[0]):
    if Milano['TOTALE_20'].iloc[i] == 9999:
        Milano['TOTALE_20'].iloc[i] = np.nan
Milano = Milano.dropna() 

# Cities Milano considered 
Dettaglio_comuni_Milano = Milano.groupby('NOME_COMUNE').aggregate({'TOTALE_19':np.sum,'TOTALE_20':np.sum})
Dettaglio_comuni_Milano = Dettaglio_comuni_Milano.reset_index()
Dettaglio_comuni_Milano.columns = ['City','2019','2020']
Dettaglio_comuni_Milano['Variazione %'] = round((Dettaglio_comuni_Milano['2020']/Dettaglio_comuni_Milano['2019']-1)*100, 2)
Dettaglio_comuni_Milano.to_csv('./../tables/Dettaglio_comuni_Milano.csv ', header=True, index=False, sep=',')
comuni_Milano = Dettaglio_comuni_Milano['City']
n_comuni_Milano = comuni_Milano.shape[0]
n_comuni_Milano_tot = 134 # source Wikipedia
perc_Milano = round(n_comuni_Milano/n_comuni_Milano_tot*100,2)
max_var_Milano = "Comune con il maggiore incremento di decessi tra '19 e '20: {} +{}%".format(Dettaglio_comuni_Milano['City'].loc[Dettaglio_comuni_Milano['Variazione %'].idxmax()],Dettaglio_comuni_Milano['Variazione %'].max())

PU  = PU.groupby('GE').aggregate({'TOTALE_15':np.sum, 'TOTALE_16':np.sum, 'TOTALE_17':np.sum, 'TOTALE_18':np.sum, 'TOTALE_19':np.sum, 'TOTALE_20':np.sum})
PU = PU.reset_index().drop('GE',axis=1)
PU['Day'] = list(pd.date_range('2020-01-01', periods=PU.shape[0], freq='D').to_series().dt.strftime('%m-%d'))
PU = PU.set_index(['Day'])
PU.columns = ['2015','2016','2017','2018','2019','2020']

### split dataset
max_PU = PU.drop('2020',axis=1).max(axis=1)
max_PU.loc['02-29'] = max_PU.loc['02-29'] + 5
min_PU = PU.drop('2020',axis=1).min(axis=1)
PU_2020 = PU['2020']
diff_max_PU = round(((PU_2020/max_PU -1)*100).max(),2)
data_diff_max_PU = ((PU_2020/max_PU -1)*100).idxmax()

diff_PU = (PU_2020/max_PU -1)*100
giorni_var_PU = []
for i in range(len(max_PU)):
    if diff_PU[i] >= 200.01:
        giorni_var_PU.append(PU.index[i])
n_giorni_var_PU = len(giorni_var_PU)

# outbreak date
first_cases = np.where(PU_2020.index == '02-21')[0]


### PLOT
plt.figure(figsize=(14,8))

# line plot 
plt.plot(min_PU.values, 'black')
plt.plot(max_PU.values, 'blue')
plt.plot(PU_2020.values, 'red', lw = 5, ls = '-')

plt.xlabel('Giorni')
plt.ylabel('Deceduti')
plt.title("Decessi Totali nella provincia di Pesaro-Urbino tra Gen-Mar 2015-19 \n Un confronto con i dati del 2020: effetto COVID19", fontsize=12)
plt.legend(['Min Decessi Giornalieri 15-19 PU', 'Max Decessi Giornalieri 15-19 PU', "Decessi 2020 PU"], frameon = False, fontsize=12, loc = 2)
plt.axvline(first_cases, c = 'green',lw = 2, ls=':')
plt.text(first_cases-0.5, 13, '21-02 primi casi di COVID19 confermati in Italia ', fontsize=9,
               rotation=90, rotation_mode='anchor')

plt.text(-3,21.5, max_var_PU, fontsize=10)
plt.text(-3,20.5, 'Comuni aderenti ANPR: {} su {} = {}%'.format(n_comuni_PU,n_comuni_PU_tot,perc_PU), fontsize=9)
plt.text(-3,19.5, 'Giorno con Max Var% tra Decessi 2020 e Max Decessi Giornalieri 15-19: {} +{}%'.format(data_diff_max_PU,diff_max_PU),fontsize=9)
plt.text(-3,18.5, 'N° giorni in cui i Decessi 2020 sono stati ALMENO il triplo dei Max Decessi Giornalieri 15-19: {}'.format(n_giorni_var_PU),fontsize=9)

# filling 
plt.gca().fill_between(range(len(min_PU)),
                       min_PU, 
                       max_PU, 
                       facecolor = "black",
                       alpha = 0.2)

# tick label 
plt.xticks(range(0, len(min_PU), 5), min_PU.index[range(0, len(min_PU), 5)], rotation = '45')

# removing the frame
plt.gca().spines['top'].set_visible(False)
plt.gca().spines['right'].set_visible(False)

#plt.show()
plt.savefig('./../plot/covid_PU.png')


Bergamo  = Bergamo.groupby('GE').aggregate({'TOTALE_15':np.sum, 'TOTALE_16':np.sum, 'TOTALE_17':np.sum, 'TOTALE_18':np.sum, 'TOTALE_19':np.sum, 'TOTALE_20':np.sum})
Bergamo = Bergamo.reset_index().drop('GE',axis=1)
Bergamo['Day'] = list(pd.date_range('2020-01-01', periods=PU.shape[0], freq='D').to_series().dt.strftime('%m-%d'))
Bergamo = Bergamo.set_index(['Day'])
Bergamo.columns = ['2015','2016','2017','2018','2019','2020']

### split dataset
max_Bergamo = Bergamo.drop('2020',axis=1).max(axis=1)
min_Bergamo = Bergamo.drop('2020',axis=1).min(axis=1)
Bergamo_2020 = Bergamo['2020']
diff_max_Bergamo = round(((Bergamo_2020/max_Bergamo -1)*100).max(),2)
data_diff_max_Bergamo = ((Bergamo_2020/max_Bergamo -1)*100).idxmax()

diff_Bergamo = (Bergamo_2020/max_Bergamo -1)*100
giorni_var_Bergamo = []
for i in range(len(max_Bergamo)):
    if diff_Bergamo[i] >= 200.01:
        giorni_var_Bergamo.append(Bergamo.index[i])
n_giorni_var_Bergamo = len(giorni_var_Bergamo)

# outbreak date
first_cases = np.where(Bergamo_2020.index == '02-21')[0]


### PLOT
plt.figure(figsize=(14,8))

# line plot 
plt.plot(min_Bergamo.values, 'black')
plt.plot(max_Bergamo.values, 'blue')
plt.plot(Bergamo_2020.values, 'red', lw = 5, ls = '-')

plt.xlabel('Giorni')
plt.ylabel('Deceduti')
plt.title("Decessi Totali nella provincia di Bergamo tra Gen-Mar 2015-19 \n Un confronto con i dati del 2020: effetto COVID19", fontsize=12)
plt.legend(['Min Decessi Giornalieri 15-19 Bergamo', 'Max Decessi Giornalieri 15-19 Bergamo', "Decessi 2020 Bergamo"], frameon = False, fontsize=12, loc = 2)
plt.axvline(first_cases, c = 'green',lw = 2, ls=':')
plt.text(first_cases-0.5, 50, '21-02 primi casi di COVID19 confermati in Italia ', fontsize=9,
               rotation=90, rotation_mode='anchor')

plt.text(-3,163, max_var_Bergamo, fontsize=11)
plt.text(-3,155, 'Comuni aderenti ANPR: {} su {} = {}%'.format(n_comuni_Bergamo,n_comuni_Bergamo_tot,perc_Bergamo), fontsize=11)
plt.text(-3,147, 'Giorno con Max Var% tra Decessi 2020 e Max Decessi Giornalieri 15-19: {} +{}%'.format(data_diff_max_Bergamo,diff_max_Bergamo),fontsize=9)
plt.text(-3,139, 'N° giorni in cui i Decessi 2020 sono stati ALMENO il triplo dei Max Decessi Giornalieri 15-19: {}'.format(n_giorni_var_Bergamo),fontsize=9)

# filling 
plt.gca().fill_between(range(len(min_Bergamo)),
                       min_Bergamo, 
                       max_Bergamo, 
                       facecolor = "black",
                       alpha = 0.2)

# tick label 
plt.xticks(range(0, len(min_Bergamo), 5), min_Bergamo.index[range(0, len(min_Bergamo), 5)], rotation = '45')

# removing the frame
plt.gca().spines['top'].set_visible(False)
plt.gca().spines['right'].set_visible(False)

#plt.show()
plt.savefig('./../plot/covid_Bergamo.png')


Piacenza  = Piacenza.groupby('GE').aggregate({'TOTALE_15':np.sum, 'TOTALE_16':np.sum, 'TOTALE_17':np.sum, 'TOTALE_18':np.sum, 'TOTALE_19':np.sum, 'TOTALE_20':np.sum})
Piacenza = Piacenza.reset_index().drop('GE',axis=1)
Piacenza['Day'] = list(pd.date_range('2020-01-01', periods=PU.shape[0], freq='D').to_series().dt.strftime('%m-%d'))
Piacenza = Piacenza.set_index(['Day'])
Piacenza.columns = ['2015','2016','2017','2018','2019','2020']

### split dataset
max_Piacenza = Piacenza.drop('2020',axis=1).max(axis=1)
min_Piacenza = Piacenza.drop('2020',axis=1).min(axis=1)
Piacenza_2020 = Piacenza['2020']
diff_max_Piacenza = round(((Piacenza_2020/max_Piacenza -1)*100).max(),2)
data_diff_max_Piacenza = ((Piacenza_2020/max_Piacenza -1)*100).idxmax()

diff_Piacenza = (Piacenza_2020/max_Piacenza -1)*100
giorni_var_Piacenza = []
for i in range(len(max_Piacenza)):
    if diff_Piacenza[i] >= 200.01:
        giorni_var_Piacenza.append(Piacenza.index[i])
n_giorni_var_Piacenza = len(giorni_var_Piacenza)

# outbreak date
first_cases = np.where(Piacenza_2020.index == '02-21')[0]


### PLOT
plt.figure(figsize=(14,8))

# line plot 
plt.plot(min_Piacenza.values, 'black')
plt.plot(max_Piacenza.values, 'blue')
plt.plot(Piacenza_2020.values, 'red', lw = 5, ls = '-')

plt.xlabel('Giorni')
plt.ylabel('Deceduti')
plt.title("Decessi Totali nella provincia di Piacenza tra Gen-Mar 2015-19 \n Un confronto con i dati del 2020: effetto COVID19", fontsize=12)
plt.legend(['Min Decessi Giornalieri 15-19 Piacenza', 'Max Decessi Giornalieri 15-19 Piacenza', "Decessi 2020 Piacenza"], frameon = False, fontsize=12, loc = 2)
plt.axvline(first_cases, c = 'green',lw = 2, ls=':')
plt.text(first_cases-0.5, 15, '21-02 primi casi di COVID19 confermati in Italia ', fontsize=9,
               rotation=90, rotation_mode='anchor')

plt.text(-3,36, max_var_Piacenza, fontsize=11)
plt.text(-3,34, 'Comuni aderenti ANPR: {} su {} = {}%'.format(n_comuni_Piacenza,n_comuni_Piacenza_tot,perc_Piacenza), fontsize=11)
plt.text(-3,32, 'Giorno con Max Var% tra Decessi 2020 e Max Decessi Giornalieri 15-19: {} +{}%'.format(data_diff_max_Piacenza,diff_max_Piacenza),fontsize=10)
plt.text(-3,30, 'N° giorni in cui i Decessi 2020 sono stati ALMENO il triplo dei Max Decessi Giornalieri 15-19: {}'.format(n_giorni_var_Piacenza),fontsize=9)

# filling 
plt.gca().fill_between(range(len(min_Piacenza)),
                       min_Piacenza, 
                       max_Piacenza, 
                       facecolor = "black",
                       alpha = 0.2)

# tick label 
plt.xticks(range(0, len(min_Piacenza), 5), min_Piacenza.index[range(0, len(min_Piacenza), 5)], rotation = '45')

# removing the frame
plt.gca().spines['top'].set_visible(False)
plt.gca().spines['right'].set_visible(False)

#plt.show()
plt.savefig('./../plot/covid_Piacenza.png')

Milano  = Milano.groupby('GE').aggregate({'TOTALE_15':np.sum, 'TOTALE_16':np.sum, 'TOTALE_17':np.sum, 'TOTALE_18':np.sum, 'TOTALE_19':np.sum, 'TOTALE_20':np.sum})
Milano = Milano.reset_index().drop('GE',axis=1)
Milano['Day'] = list(pd.date_range('2020-01-01', periods=PU.shape[0], freq='D').to_series().dt.strftime('%m-%d'))
Milano = Milano.set_index(['Day'])
Milano.columns = ['2015','2016','2017','2018','2019','2020']

### split dataset
max_Milano = Milano.drop('2020',axis=1).max(axis=1)
min_Milano = Milano.drop('2020',axis=1).min(axis=1)
min_Milano.loc['02-29'] = 55
Milano_2020 = Milano['2020']
diff_max_Milano = round(((Milano_2020/max_Milano -1)*100).max(),2)
data_diff_max_Milano = ((Milano_2020/max_Milano -1)*100).idxmax()

diff_Milano = (Milano_2020/max_Milano -1)*100
giorni_var_Milano = []
for i in range(len(max_Milano)):
    if diff_Milano[i] >= 200.01:
        giorni_var_Milano.append(Milano.index[i])
n_giorni_var_Milano = len(giorni_var_Milano)

# outbreak date
first_cases = np.where(Milano_2020.index == '02-21')[0]


### PLOT
plt.figure(figsize=(14,8))

# line plot 
plt.plot(min_Milano.values, 'black')
plt.plot(max_Milano.values, 'blue')
plt.plot(Milano_2020.values, 'red', lw = 5, ls = '-')

plt.xlabel('Giorni')
plt.ylabel('Deceduti')
plt.title("Decessi Totali nella provincia di Milano tra Gen-Mar 2015-19 \n Un confronto con i dati del 2020: effetto COVID19", fontsize=12)
plt.legend(['Min Decessi Giornalieri 15-19 Milano', 'Max Decessi Giornalieri 15-19 Milano', "Decessi 2020 Milano"], frameon = False, fontsize=12, loc = 2)
plt.axvline(first_cases, c = 'green',lw = 2, ls=':')
plt.text(first_cases-0.5, 102, '21-02 primi casi di COVID19 confermati in Italia ', fontsize=9,
               rotation=90, rotation_mode='anchor')

plt.text(-3,139, max_var_Milano, fontsize=10)
plt.text(-3,135, 'Comuni aderenti ANPR: {} su {} = {}%'.format(n_comuni_Milano,n_comuni_Milano_tot,perc_Milano), fontsize=9)
plt.text(-3,131, 'Giorno con Max Var% tra Decessi 2020 e Max Decessi Giornalieri 15-19: {} +{}%'.format(data_diff_max_Milano,diff_max_Milano),fontsize=9)
plt.text(-3,127, 'N° giorni in cui i Decessi 2020 sono stati ALMENO il triplo dei Max Decessi Giornalieri 15-19: {}'.format(n_giorni_var_Milano),fontsize=9)

# filling 
plt.gca().fill_between(range(len(min_Milano)),
                       min_Milano, 
                       max_Milano, 
                       facecolor = "black",
                       alpha = 0.2)

# tick label 
plt.xticks(range(0, len(min_Milano), 5), min_Milano.index[range(0, len(min_Milano), 5)], rotation = '45')

# removing the frame
plt.gca().spines['top'].set_visible(False)
plt.gca().spines['right'].set_visible(False)

#plt.show()
plt.savefig('./../plot/covid_Milano.png')

Lodi  = Lodi.groupby('GE').aggregate({'TOTALE_15':np.sum, 'TOTALE_16':np.sum, 'TOTALE_17':np.sum, 'TOTALE_18':np.sum, 'TOTALE_19':np.sum, 'TOTALE_20':np.sum})
Lodi = Lodi.reset_index().drop('GE',axis=1)
Lodi['Day'] = list(pd.date_range('2020-01-01', periods=PU.shape[0], freq='D').to_series().dt.strftime('%m-%d'))
Lodi = Lodi.set_index(['Day'])
Lodi.columns = ['2015','2016','2017','2018','2019','2020']

### split dataset
max_Lodi = Lodi.drop('2020',axis=1).max(axis=1)
min_Lodi = Lodi.drop('2020',axis=1).min(axis=1)
Lodi_2020 = Lodi['2020']
diff_max_Lodi = round(((Lodi_2020/max_Lodi -1)*100).max(),2)
data_diff_max_Lodi = ((Lodi_2020/max_Lodi -1)*100).idxmax()

diff_Lodi = (Lodi_2020/max_Lodi -1)*100
giorni_var_Lodi = []
for i in range(len(max_Lodi)):
    if diff_Lodi[i] >= 200.01:
        giorni_var_Lodi.append(Lodi.index[i])
n_giorni_var_Lodi = len(giorni_var_Lodi)

# outbreak date
first_cases = np.where(Lodi_2020.index == '02-21')[0]


### PLOT
plt.figure(figsize=(14,8))

# line plot 
plt.plot(min_Lodi.values, 'black')
plt.plot(max_Lodi.values, 'blue')
plt.plot(Lodi_2020.values, 'red', lw = 5, ls = '-')

plt.xlabel('Giorni')
plt.ylabel('Deceduti')
plt.title("Decessi Totali nella provincia di Lodi tra Gen-Mar 2015-19 \n Un confronto con i dati del 2020: effetto COVID19", fontsize=12)
plt.legend(['Min Decessi Giornalieri 15-19 Lodi', 'Max Decessi Giornalieri 15-19 Lodi', "Decessi 2020 Lodi"], frameon = False, fontsize=12, loc = 2)
plt.axvline(first_cases, c = 'green',lw = 2, ls=':')
plt.text(first_cases-0.5, 13, '21-02 primi casi di COVID19 confermati in Italia ', fontsize=9,
               rotation=90, rotation_mode='anchor')

plt.text(-3,35, max_var_Lodi, fontsize=10)
plt.text(-3,34, 'Comuni aderenti ANPR: {} su {} = {}%'.format(n_comuni_Lodi,n_comuni_Lodi_tot,perc_Lodi), fontsize=9)
plt.text(-3,33, 'Giorno con Max Var% tra Decessi 2020 e Max Decessi Giornalieri 15-19: {} +{}%'.format(data_diff_max_Lodi,diff_max_Lodi),fontsize=9)
plt.text(-3,32, 'N° giorni in cui i Decessi 2020 sono stati ALMENO il triplo dei Max Decessi Giornalieri 15-19: {}'.format(n_giorni_var_Lodi),fontsize=9)

# filling 
plt.gca().fill_between(range(len(min_Lodi)),
                       min_Lodi, 
                       max_Lodi, 
                       facecolor = "black",
                       alpha = 0.2)

# tick label 
plt.xticks(range(0, len(min_Lodi), 5), min_Lodi.index[range(0, len(min_Lodi), 5)], rotation = '45')

# removing the frame
plt.gca().spines['top'].set_visible(False)
plt.gca().spines['right'].set_visible(False)

#plt.show()
plt.savefig('./../plot/covid_Lodi.png')

