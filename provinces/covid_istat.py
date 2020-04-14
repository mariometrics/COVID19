import pandas as pd 
import numpy as np
import matplotlib.pyplot as plt
import mplleaflet

df = pd.read_csv('comune_giorno.csv', usecols = ['REG','NOME_REGIONE', 'NOME_PROVINCIA',
                                                 'GE','TOTALE_15','TOTALE_16',
                                                 'TOTALE_17','TOTALE_18',
                                                 'TOTALE_19','TOTALE_20'])

PU = df.where(df['NOME_PROVINCIA'] == 'Pesaro e Urbino').dropna()
for i in  range(PU['TOTALE_20'].shape[0]):
    if PU['TOTALE_20'].iloc[i] == 9999:
        PU['TOTALE_20'].iloc[i] = np.nan
PU = PU.dropna()

Bergamo = df.where(df['NOME_PROVINCIA'] == 'Bergamo').dropna()
for i in  range(Bergamo['TOTALE_20'].shape[0]):
    if Bergamo['TOTALE_20'].iloc[i] == 9999:
        Bergamo['TOTALE_20'].iloc[i] = np.nan
Bergamo = Bergamo.dropna()

Piacenza = df.where(df['NOME_PROVINCIA'] == 'Piacenza').dropna()
for i in range(Piacenza['TOTALE_20'].shape[0]):
    if Piacenza['TOTALE_20'].iloc[i] == 9999:
        Piacenza['TOTALE_20'].iloc[i] = np.nan
Piacenza = Piacenza.dropna() 

Milano = df.where(df['NOME_PROVINCIA'] == 'Milano').dropna()
for i in range(Milano['TOTALE_20'].shape[0]):
    if Milano['TOTALE_20'].iloc[i] == 9999:
        Milano['TOTALE_20'].iloc[i] = np.nan
Milano = Milano.dropna() 


PU  = PU.groupby('GE').aggregate({'TOTALE_15':np.sum, 'TOTALE_16':np.sum, 'TOTALE_17':np.sum, 'TOTALE_18':np.sum, 'TOTALE_19':np.sum, 'TOTALE_20':np.sum})
PU = PU.reset_index().drop('GE',axis=1)
PU['Day'] = list(pd.date_range('2020-01-01', periods=81, freq='D').to_series().dt.strftime('%m-%d'))
PU = PU.set_index(['Day'])
PU.columns = ['2015','2016','2017','2018','2019','2020']

### split dataset
max_PU = PU.drop('2020',axis=1).max(axis=1)
min_PU = PU.drop('2020',axis=1).min(axis=1)
PU_2020 = PU['2020']

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
Bergamo['Day'] = list(pd.date_range('2020-01-01', periods=81, freq='D').to_series().dt.strftime('%m-%d'))
Bergamo = Bergamo.set_index(['Day'])
Bergamo.columns = ['2015','2016','2017','2018','2019','2020']

### split dataset
max_Bergamo = Bergamo.drop('2020',axis=1).max(axis=1)
min_Bergamo = Bergamo.drop('2020',axis=1).min(axis=1)
Bergamo_2020 = Bergamo['2020']

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
Piacenza['Day'] = list(pd.date_range('2020-01-01', periods=81, freq='D').to_series().dt.strftime('%m-%d'))
Piacenza = Piacenza.set_index(['Day'])
Piacenza.columns = ['2015','2016','2017','2018','2019','2020']

### split dataset
max_Piacenza = Piacenza.drop('2020',axis=1).max(axis=1)
min_Piacenza = Piacenza.drop('2020',axis=1).min(axis=1)
Piacenza_2020 = Piacenza['2020']

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
Milano['Day'] = list(pd.date_range('2020-01-01', periods=81, freq='D').to_series().dt.strftime('%m-%d'))
Milano = Milano.set_index(['Day'])
Milano.columns = ['2015','2016','2017','2018','2019','2020']

### split dataset
max_Milano = Milano.drop('2020',axis=1).max(axis=1)
min_Milano = Milano.drop('2020',axis=1).min(axis=1)
min_Milano.loc['02-29'] = 55
Milano_2020 = Milano['2020']

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






