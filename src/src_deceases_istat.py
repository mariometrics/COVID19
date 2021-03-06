import pandas as pd 
pd.options.mode.chained_assignment = None  # default='warn'
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime
import mplleaflet
import os

#============================================= LOAD DATA =====================================================
df = pd.read_csv('comuni_giornaliero.csv', usecols = ['REG','NOME_REGIONE', 'NOME_PROVINCIA',
                                                 'NOME_COMUNE', 'GE','T_15','T_16',
                                                 'T_17','T_18',
                                                 'T_19','T_20'])

n_comuni_prov = pd.read_csv('com_prov.csv', index_col = 'Provincia') # source: https://www.tuttitalia.it/province/numero-comuni/ len=107
n_comuni_reg = pd.read_csv('com_reg.csv', index_col = 'Regione') # source: https://www.tuttitalia.it/regioni/numero-comuni/

df.loc[df['NOME_PROVINCIA'] == 'Bolzano/Bozen','NOME_PROVINCIA'] = 'Bolzano' 
df.loc[df['NOME_PROVINCIA'] == "Valle d'Aosta/Valle d'Aoste",'NOME_PROVINCIA'] = 'Aosta'
df.loc[df['NOME_REGIONE'] == "Valle d'Aosta/Valle d'Aoste",'NOME_REGIONE'] = "Valle d'Aosta"
df.loc[df['NOME_REGIONE'] == "Trentino-Alto Adige/Sdtirol",'NOME_REGIONE'] = "Trentino-Alto Adige"

# ISTAT use '9999' instead of NaN so change and delete
#df = df[df.T_20 != 9999]
df = df[df.T_20 != "n.d."]
df.T_20 = df.T_20.astype("int64")

# 6866 municipalities but only for the first quarter of 2020, 4433 until Apr 15
# coiche what you want analyze: 
# if the string until is set on 'Apr 15' --> you will see the analysis of the municipalities until Apr 15
# set 'Mar 31' for the analysis until March 31 but for more municipalities:
print("Which analysis do you want to see?")
print("You have two options:\n-- Type 1 and analyze 4243/7904 municipalities from Jan, 1 to Apr, 15.\n-- Type 2 and analyze 6854/7904 municipalities... but from Jan, 1 to March, 31.")
choice = int(input("Make your choice (i.e. enter 1 or 2): "))
if choice == 1:
    until = 'Apr 15'     
    com_latest = df[df.GE > 331] 
    com_latest_name = com_latest['NOME_COMUNE'].unique()
    df = df[df['NOME_COMUNE'].isin(com_latest_name)]
else:
    until = 'March 31' 
    df = df[df.GE <= 331]

reg = df['NOME_REGIONE'].unique()
n_reg = 20
prov = df['NOME_PROVINCIA'].unique() # prov name
n_prov = len(prov) #103 (match with n_comuni_prov)
n_comuni_anpr_tot = df.groupby('NOME_COMUNE').aggregate(np.sum).shape[0]
n_comuni_tot = 7904 # sources https://www.tuttitalia.it/regioni/numero-comuni/

#####################################
##### ITALY AS A WHOLE ANALYSIS #####
#####################################
print('Start to analyze aggregated ANPR data.')
print("We have: {} Cities, {} Provinces and, obviously, {} Regions".format(n_comuni_anpr_tot,n_prov,n_reg))
### implement comuni, provinces and regions variation
it = df.groupby('GE').aggregate(np.sum).drop('REG',axis = 1)
it = it.reset_index()

date = []
for i in range(len(it['GE'])):
    date.append('0{}-{}'.format(str(it['GE'].iloc[i])[0],str(it['GE'].iloc[i])[1:]))


it['Giorni'] = date
it = it.set_index(['Giorni']).drop('GE',axis=1) 
it.columns = ['2015','2016','2017','2018','2019','2020']

it.drop('02-29',inplace=True)

### split dataset
max_dd_it = it.drop('2020',axis=1).max(axis=1)
min_dd_it = it.drop('2020',axis=1).min(axis=1)
it_2020 = it['2020']
it_2019 = it['2019']
diff_max_it = round(((it_2020/max_dd_it -1)*100).max(),2)
data_diff_max_it = ((it_2020/max_dd_it -1)*100).idxmax()

diff_it = (it_2020/max_dd_it -1)*100
n_giorni_var_it = 0
for i in range(len(max_dd_it)):
    if diff_it.iloc[i] >= 100:
        n_giorni_var_it += 1
t = '02-21'        

first_cases = np.where(it.index == t)[0]

# region variation
var_tot_it = (it_2020.loc[t:].sum()-max_dd_it.loc[t:].sum())/max_dd_it.loc[t:].sum() * 100
var_tot_it_19_20 = (it_2020.loc[t:].sum()-it_2019.loc[t:].sum())/it_2019.loc[t:].sum() * 100

## stuff for plot 
legend_it = ['Min Daily Deceases 15-19 Italy', 'Max Daily Deceases 15-19 Italy', "Deceases 2020 Italy", "Firsts Confirmed Cases Italy"]
note_it = "Notes:\nANPR Municipalities: {} over {} = {:6.2f}% \nApproximated Peak: {} \nN° of  days in which '20 Deceases are at least double of Max Daily Deceases 15-19   : {} \nDeceases % Change 19-20 from Feb 21 to {}: {:+6.2f}% \nDeceases % Change '20 - Max Deceases 15-19 from Feb 21 to {}: {:+6.2f}%".format(n_comuni_anpr_tot,n_comuni_tot,(n_comuni_anpr_tot/n_comuni_tot)*100,data_diff_max_it,n_giorni_var_it,until,var_tot_it_19_20,until,var_tot_it)

#### PLOT ####

plt.figure(figsize=(14,8))

# line plot 
plt.plot(min_dd_it.values, 'black')
plt.plot(max_dd_it.values, 'blue')
plt.plot(it_2020.values, 'red', lw = 5, ls = '-')
plt.axvline(first_cases, c = 'green',lw = 2, ls=':')

plt.xlabel('Days')
plt.ylabel('Deceases')
plt.title(" Total Deceases in Italy Gen-Mar 2015-19 \n A comparison with 2020 data: COVID19 effect", fontsize=14)
plt.legend(legend_it, frameon = False, fontsize=12, loc = 2)


#plt.subplots_adjust(bottom=0.2)
plt.suptitle(note_it, y=0.01,x = 0.01, fontsize=11, ha = 'left', va = 'bottom')

# filling 
plt.gca().fill_between(range(len(min_dd_it)),
                       min_dd_it, 
                       max_dd_it, 
                       facecolor = "black",
                       alpha = 0.2)

# tick label 
plt.xticks(range(0, len(min_dd_it), 5), min_dd_it.index[range(0, len(min_dd_it), 5)], rotation = '45')

# removing the frame
plt.gca().spines['top'].set_visible(False)
plt.gca().spines['right'].set_visible(False)
plt.tight_layout(pad = 5.1)

# save plots
plt.savefig('./../plot/covid_italy.png')
plt.close()
print('Aggregated ANPR done.')

##############################
##### REGIONS ANALYSIS #####
##############################
print('\nStart to analyze regions.\n')

# preallocation
regions = {}
Dettaglio_comuni = {}
comuni = {}
n_comuni = {}
comune_max_var = {}
perc = {}
max_dd = {}    
min_dd = {}
diff_max = {}    
data_diff_max = {}
regions_2020 = {}
regions_2019 = {}
diff = {}
giorni_var = {}
n_giorni_var = {}
idx = {}
date_idx = {}
legend = {}
var_tot_reg_max_2020 = {}
var_tot_19_20 = {}
note = {}

for r in reg:
    print('Processing {}'.format(r))    
    regions["{}".format(r)] = df.loc[df['NOME_REGIONE'] == r] # select regions
    
    # Analyze cities in regions
    Dettaglio_comuni[r] = regions[r].groupby('NOME_COMUNE').aggregate({'T_19':np.sum,'T_20':np.sum})
    Dettaglio_comuni[r] = Dettaglio_comuni[r].reset_index()
    Dettaglio_comuni[r].columns = ['Comune','2019','2020']
    Dettaglio_comuni[r]['Variazione %'] = round((Dettaglio_comuni[r]['2020']/Dettaglio_comuni[r]['2019']-1)*100, 2)
    comuni[r] = Dettaglio_comuni[r]['Comune']
    n_comuni[r] = comuni[r].shape[0]
    perc[r] = round(n_comuni[r]/n_comuni_reg['N_comuni'].loc[r]*100,2) 

    if regions[r].shape[0] >= 1:
        comune_max_var[r] = [Dettaglio_comuni[r]['Comune'].loc[Dettaglio_comuni[r]['Variazione %'].idxmax()],Dettaglio_comuni[r]['Variazione %'].max()]
        
        # store in csv files
        filepath = './../tables/{}/Dettaglio_comuni_{}_total.csv '.format(r,r)
        plotpath = './../plot/{}/covid_{}.png'.format(r,r) # a fantastic tool that we will use later
        os.makedirs(os.path.dirname(filepath), exist_ok=True)    
        Dettaglio_comuni[r].to_csv(filepath, header=True, index=False, sep=',')    
        
        # now start to analyze regions 
        regions[r] = regions[r].groupby('GE').aggregate({'T_15':np.sum, 'T_16':np.sum, 'T_17':np.sum, 'T_18':np.sum, 'T_19':np.sum, 'T_20':np.sum})
        regions[r] = regions[r].reset_index()#.drop('GE',axis=1)

        # create index
        date_idx[r] = []
        for i in range(len(regions[r]['GE'])):
            date_idx[r].append('0{}-{}'.format(str(regions[r]['GE'].iloc[i])[0],str(regions[r]['GE'].iloc[i])[1:]))       
        
        regions[r]['Giorni'] = date_idx[r] #list(pd.date_range('2020-01-01', periods=provinces[p].shape[0], freq='D').to_series().dt.strftime('%m-%d'))
        #provinces[p] = provinces[p].reset_index().drop('GE',axis=1)
        regions[r] = regions[r].set_index(['Giorni']).drop('GE',axis=1)        
        regions[r].columns = ['2015','2016','2017','2018','2019','2020']
        
        if '02-29' in date_idx[r]:
            regions[r].drop('02-29',inplace=True)
        
        ### split dataset
        max_dd[r] = regions[r].drop('2020',axis=1).max(axis=1)
        min_dd[r] = regions[r].drop('2020',axis=1).min(axis=1)
        regions_2020[r] = regions[r]['2020']
        regions_2019[r] = regions[r]['2019']
        diff_max[r] = round(((regions_2020[r]/max_dd[r] -1)*100).max(),2)
        data_diff_max[r] = ((regions_2020[r]/max_dd[r] -1)*100).idxmax()
        
        diff[r] = (regions_2020[r]/max_dd[r] -1)*100
        n_giorni_var[r] = 0
        for i in range(len(max_dd[r])):
            if diff[r].iloc[i] >= 100:
                n_giorni_var[r] += 1
        
        # outbreak date
        if '02-21' in date_idx[r]:
            first_cases = np.where(regions_2020[r].index == '02-21')[0]
            tt = '02-21'
        else:
            first_cases = np.where(regions_2020[r].index == '02-20')[0]
            tt = '02-20'        
        
        # region variation
        var_tot_reg_max_2020[r] = (regions_2020[r].loc[tt:].sum()-max_dd[r].loc[tt:].sum())/max_dd[r].loc[tt:].sum() * 100
        var_tot_19_20[r] = (regions_2020[r].loc[tt:].sum()-regions_2019[r].loc[tt:].sum())/regions_2019[r].loc[tt:].sum() * 100

        ## stuff for plot 
        legend[r] = ['Min Daily Deceases 15-19 {}'.format(r), 'Max Daily Deceases 15-19 {}'.format(r), "Deceases 2020 {}".format(r), "Firsts Confirmed Cases Italy"]
        note[r] = "Notes:\nANPR Municipalities: {} over {} = {}% \nApproximated Peak: {} \nN° of  days in which '20 Deceases are at least double of Max Daily Deceases 15-19   : {} \nDeceases % Change 19-20 from Feb 21 to {}: {:+6.2f}% \nDeceases % Change '20 - Max Deceases 15-19 from Feb 21 to {}: {:+6.2f}%".format(n_comuni[r],n_comuni_reg['N_comuni'].loc[r],perc[r],data_diff_max[r],n_giorni_var[r],until,var_tot_19_20[r],until,var_tot_reg_max_2020[r])

        #### PLOT ####
        
        plt.figure(figsize=(14,8))

        # line plot 
        plt.plot(min_dd[r].values, 'black')
        plt.plot(max_dd[r].values, 'blue')
        plt.plot(regions_2020[r].values, 'red', lw = 5, ls = '-')
        plt.axvline(first_cases, c = 'green',lw = 2, ls=':')
        
        plt.xlabel('Days')
        plt.ylabel('Deceases')
        plt.title(" Total Deceases in {} Gen-Mar 2015-19 \n A comparison with 2020 data: COVID19 effect".format(r), fontsize=14)
        plt.legend(legend[r], frameon = False, fontsize=12, loc = 2)
        

        #plt.subplots_adjust(bottom=0.2)
        plt.suptitle(note[r], y=0.01,x = 0.01, fontsize=11, ha = 'left', va = 'bottom')

        # filling 
        plt.gca().fill_between(range(len(min_dd[r])),
                               min_dd[r], 
                               max_dd[r], 
                               facecolor = "black",
                               alpha = 0.2)

        # tick label 
        plt.xticks(range(0, len(min_dd[r]), 5), min_dd[r].index[range(0, len(min_dd[r]), 5)], rotation = '45')

        # removing the frame
        plt.gca().spines['top'].set_visible(False)
        plt.gca().spines['right'].set_visible(False)
        plt.tight_layout(pad = 5.1)
        
        # save plots
        os.makedirs(os.path.dirname(plotpath), exist_ok=True)        
        plt.savefig(plotpath)
        plt.close()
    print('{} done.'.format(r))

##############################
##### PROVINCES ANALYSIS #####
##############################
print('\nStart to analyze provinces.\n')

# preallocation
provinces = {}
Dettaglio_comuni = {}
comuni = {}
n_comuni = {}
comune_max_var = {}
perc = {}
max_dd = {}    
min_dd = {}
diff_max = {}    
data_diff_max = {}
provinces_2020 = {}
provinces_2019 = {}
diff = {}
giorni_var = {}
n_giorni_var = {}
idx = {}
date_idx = {}
legend = {}
var_tot_prov_max_2020 = {}
var_tot_19_20 = {}
note = {}

for p in prov:
    print('Processing {}'.format(p))    
    provinces["{}".format(p)] = df.loc[df['NOME_PROVINCIA'] == p] # select provinces
    
    # Analyze cities in provinces
    Dettaglio_comuni[p] = provinces[p].groupby('NOME_COMUNE').aggregate({'T_19':np.sum,'T_20':np.sum})
    Dettaglio_comuni[p] = Dettaglio_comuni[p].reset_index()
    Dettaglio_comuni[p].columns = ['Comune','2019','2020']
    Dettaglio_comuni[p]['Variazione %'] = round((Dettaglio_comuni[p]['2020']/Dettaglio_comuni[p]['2019']-1)*100, 2)
    comuni[p] = Dettaglio_comuni[p]['Comune']
    n_comuni[p] = comuni[p].shape[0]
    perc[p] = round(n_comuni[p]/n_comuni_prov['N_comuni'].loc[p]*100,2) 

    if provinces[p].shape[0] >= 1:
        comune_max_var[p] = [Dettaglio_comuni[p]['Comune'].loc[Dettaglio_comuni[p]['Variazione %'].idxmax()],Dettaglio_comuni[p]['Variazione %'].max()]
        
        # store in csv files
        filepath = './../tables/{}/Dettaglio_comuni_{}.csv '.format(provinces[p]['NOME_REGIONE'].iloc[0],p)
        plotpath = './../plot/{}/covid_{}.png'.format(provinces[p]['NOME_REGIONE'].iloc[0],p) # a fantastic tool that we will use later
        os.makedirs(os.path.dirname(filepath), exist_ok=True)    
        Dettaglio_comuni[p].to_csv(filepath, header=True, index=False, sep=',')    
        
        # now start to analyze provices 
        provinces[p] = provinces[p].groupby('GE').aggregate({'T_15':np.sum, 'T_16':np.sum, 'T_17':np.sum, 'T_18':np.sum, 'T_19':np.sum, 'T_20':np.sum})
        provinces[p] = provinces[p].reset_index()#.drop('GE',axis=1)

        # create index
        date_idx[p] = []
        for i in range(len(provinces[p]['GE'])):
            date_idx[p].append('0{}-{}'.format(str(provinces[p]['GE'].iloc[i])[0],str(provinces[p]['GE'].iloc[i])[1:]))       
        
        provinces[p]['Giorni'] = date_idx[p] #list(pd.date_range('2020-01-01', periods=provinces[p].shape[0], freq='D').to_series().dt.strftime('%m-%d'))
        #provinces[p] = provinces[p].reset_index().drop('GE',axis=1)
        provinces[p] = provinces[p].set_index(['Giorni']).drop('GE',axis=1)        
        provinces[p].columns = ['2015','2016','2017','2018','2019','2020']
        
        if '02-29' in date_idx[p]:
            provinces[p].drop('02-29',inplace=True)
        
        ### split dataset
        max_dd[p] = provinces[p].drop('2020',axis=1).max(axis=1)
        min_dd[p] = provinces[p].drop('2020',axis=1).min(axis=1)
        provinces_2020[p] = provinces[p]['2020']
        provinces_2019[p] = provinces[p]['2019']
        diff_max[p] = round(((provinces_2020[p]/max_dd[p] -1)*100).max(),2)
        data_diff_max[p] = ((provinces_2020[p]/max_dd[p] -1)*100).idxmax()
        
        diff[p] = (provinces_2020[p]/max_dd[p] -1)*100
        n_giorni_var[p] = 0
        for i in range(len(max_dd[p])):
            if diff[p].iloc[i] >= 100:
                n_giorni_var[p] += 1

        # province variation
        var_tot_prov_max_2020[p] = (provinces_2020[p].loc[tt:].sum()-max_dd[p].loc[tt:].sum())/max_dd[p].loc[tt:].sum() * 100
        var_tot_19_20[p] = (provinces_2020[p].loc[tt:].sum()-provinces_2019[p].loc[tt:].sum())/provinces_2019[p].loc[tt:].sum() * 100
 
        # outbreak date
        if '02-21' in date_idx[p]:
            first_cases = np.where(provinces_2020[p].index == '02-21')[0]
        else:
            first_cases = np.where(provinces_2020[p].index == '02-20')[0]

        ## stuff for plot 
        legend[p] = ['Min Daily Deceases 15-19 {}'.format(p), 'Max Daily Deceases 15-19 {}'.format(p), "Deceases 2020 {}".format(p), "Firsts Confirmed Cases Italy"]
        note[p] = "Note:\nANPR Municipalities: {} over {} = {}% \nApproximated Peak: {} \nN° of  days in which '20 Deceases are at least double of Max Daily Deceases 15-19   : {} \nDeceases % Change 19-20 from Feb 21 to {}: {:+6.2f}% \nDeceases % Change '20 - Max Deceases 15-19 from Feb 21 to {}: {:+6.2f}%".format(n_comuni[p],n_comuni_prov['N_comuni'].loc[p],perc[p],data_diff_max[p],n_giorni_var[p],until,var_tot_19_20[p],until,var_tot_prov_max_2020[p])

        #### PLOT ####
        
        plt.figure(figsize=(14,8))

        # line plot 
        plt.plot(min_dd[p].values, 'black')
        plt.plot(max_dd[p].values, 'blue')
        plt.plot(provinces_2020[p].values, 'red', lw = 5, ls = '-')
        plt.axvline(first_cases, c = 'green',lw = 2, ls=':')
        
        plt.xlabel('Days')
        plt.ylabel('Deceases')
        plt.title("Total Deceases in {} province Gen-Mar 2015-19 \n A comparison with 2020 data: COVID19 effect".format(p), fontsize=14)
        plt.legend(legend[p], frameon = False, fontsize=12, loc = 2)
        

        #plt.subplots_adjust(bottom=0.2)
        plt.suptitle(note[p], y=0.01,x = 0.01, fontsize=11, ha = 'left', va = 'bottom')

        # filling 
        plt.gca().fill_between(range(len(min_dd[p])),
                               min_dd[p], 
                               max_dd[p], 
                               facecolor = "black",
                               alpha = 0.2)

        # tick label 
        plt.xticks(range(0, len(min_dd[p]), 5), min_dd[p].index[range(0, len(min_dd[p]), 5)], rotation = '45')

        # removing the frame
        plt.gca().spines['top'].set_visible(False)
        plt.gca().spines['right'].set_visible(False)
        plt.tight_layout(pad = 5.1)
        
        # save plots
        os.makedirs(os.path.dirname(plotpath), exist_ok=True)        
        plt.savefig(plotpath)
        plt.close()
    print('{} done.'.format(p))
print('Mario, you have finished the analysis! Enjoy!')
