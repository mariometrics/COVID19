# COVID19 IN ITALY: MODELS AND PREDICTION 
### Logistic and Exponential Models: A comparison

Taking a cue from an article of Toward Science (available [here](https://towardsdatascience.com/covid-19-infection-in-italy-mathematical-models-and-predictions-7784b4d7dd8d)), I tried to replicate the analysis with the R software, and to extend it to the data of ICU patients, to the total number of hospitalized patients and to the deaths.

### Technical deatail

Instead of the exponential formula used in the article mentioned above, I used that simply version:

![f(x,a,b) = a\cdot e^{b\cdot x}](https://render.githubusercontent.com/render/math?math=f(x%2Ca%2Cb)%20%3D%20a%5Ccdot%20e%5E%7Bb%5Ccdot%20x%7D)

### Result 
<a href="figures/plot_logit_exp_Deaths_it.pdf" class="image fit"><img src="figures/plot_logit_exp_Deaths_it.pdf" alt=""></a>

