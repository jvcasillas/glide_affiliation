---
title: "Glide affiliation"
output: 
  bookdown::word_document2: 
    reference_docx: "ref.docx"
    keep_md: true
bibliography: method_refs.bib
csl: apa.csl
---








# Filler
# Filler
# Filler

# Experiment

## Filler

## Filler

## Statistical analyses

We report four primary statistical analyses in order to address the aforementioned research questions.
To this end, we fit a series of Bayesian regression models, which are described in detail in the corresponding sections below and in the supplementary materials (LINK).
All analyses were conducted in R [@R-base, version 4.1.0].
The models were fit using `stan` [@stan] via the R package `brms`  [@R_brms_a].
All models included a maximal grouping-effects structure [@barr2013random], as well as regularizing, weakly informative priors [@Gelman_2017]. 
Additionally, models were fit with 2000 iterations (1000 warm-up) and  Hamiltonian Monte-Carlo sampling was carried out with 4 chains distributed between 4 processing cores.
We report point estimates (posterior medians) for each parameter of interest, along with the 95% highest density interval (HDI), and the maximum probability of effect (MPE).
A complete description of the models and output summaries in table format are available in the supplementary materials (LINK). 

## Results

### Syllable division task 

The first model analyzed the syllable division task data using hierarchical multinomial logistic regression. 
The participants responses to the critical CGVG sequences were classified as triphthong, hiatus, or simplification, i.e., [la.ka.ˈpi̯ai̯s.to], [la.ka.pi.ˈai̯s.to], or [la.ka.ˈpai̯s.to], respectively. 
Given that there were three response categorizations, the model likelihood was categorical and used a logit linking function. 
To simplify model interpretation, we report effects in the probability space.^[The complete model output in the original format is avaiable in the supplementary materials.]
The responses were modeled in a simple, intecept-only model, and as a function of the post-consonantal glide ([j], [w]). 
A "hiatus" response was set as the default and the model estimated intercepts for the the "simplification" and "triphthong" responses. 
Figure <a href="#fig:plot-syllabification-task">4.1</a> illustrates the overall posterior probabilities of a given response (panel A), and as a function of the glide (panels B and C). 



![Figure 4.1: Posterior probabilities of responding "hiatus", "triphthong", or "simplification". Each panel plots the posterior medians &pm; 66% and 95% credible intervals. Panels A shows overall responses, and panels B and C show responses as a function of glide type.](/Users/casillas/academia/research/in_progress/glide_affiliation/figs/manuscript/syllabification_all.png){width=100%}

With this model we aimed to shed light on how participants responded. 
Specifically, we were interested in knowing if GVG productions were possible and whether responses depended on the type of glide. 
We show that GVG responses are indeed possible. 
Triphthong realizations occurred approximately 39% of the time (0.39 [0.28, 0.51]) in the dataset. 
Aa production containing a hiatus made up roughly 35% (0.35 [0.24, 0.46]) of the data, followed by a simplification of some sort (0.26 [0.16, 0.37]).
Notably, responses were variable and the model does account for all of this variability when including the glide type, .
If we consider realizations as a function of glide type we see that triphthong realizations were possible in both environments, with more being produced with [w] (0.50 [0.31, 0.71]) than with [j] (0.33 [0.20, 0.47]). 
Overall, the task provides evidence supporting the hypothesis that pre-vocalic glides can be part of the onset in this variety of Spanish because the participants produced triphthongs at least some of the time. 










### Phrase reading task

For the phrase reading task data we fit models analyzing acoustic properties of the pre-vocalic glide [j]. 
Importantly, we expect co-occurrence restrictions such that pre-vocalic [j] will be disallowed if preceded by a palatal consonant. 
In the case that pre-vocalic [j] is indeed blocked after a palatal consonant (i.e., "lliape"), we may observe differences in overall duration of the segment, as well as formant trajectory differences related to height (F1) when compared with a pre-vocalic [j] that is not preceded by a palatal segment (i.e., "piano"). 
The justification for analyzing duration is due to the prediction that co-occurrence restrictions should result in an elided segment. 
Formant trajectory differences related to height (F1) are expected because in one case (i.e., "piano") a glide should be produced without restrictions and in the other case (i.e., "lliape") it should not. 
That is, in the non-palatal pre-glide items we expect formant movement from the high vocoid [j] to the low vowel [a]. 
If the pre-vocalic glide is blocked due to a palatal onset then we should not observe the same formant movement. 

#### Duration

The duration data were modeled using Bayesian hierarchical linear regression. 
The model analyzed participant-normalized segment duration as a function of whether the onset included a palatal consonant or not---henceforth *palatal*---, which was sum-to-zero coded (1, &minus;1, labelled as "palatal", "other"). 
The model included by-participant and by-item grouping variables, and the *palatal* predictor varied for participants. 
The model estimates suggest that the presence of a palatal onset is associated with an increase in glide duration (&beta; = 0.22 [&minus;0.20, 0.62]; MPE = 0.86), though the effect is small and the credible intervals of the posterior distribution are rather wide. 
Concretely, based on the model, the data, and our prior assumptions, we can conclude with 95% certainty that the effect falls somewhere between &minus;0.20 and 0.62, with an 86% chance that the effect is positive. 
Figure <a href="#fig:carrier-task-duration-all">4.2</a> plots the posterior distributions of pre-vocalic glides following [j] (and [w] for comparison) and Figure <a href="#fig:tab-carrier-task-duration">4.3</a> provides a forest plot of the parameter estimates, including all grouping variables. 
A traditional table summary of the model output is available in the supplementary materials (LINK). 



![Figure 4.2: Posterior distributions of pre-vocalic glide duration (panels A and C) following palatal and non-palatal onsets, as well as duration difference plots (panels B and D). Points represent posterior medians &pm;66% and 95% credible intervals.](/Users/casillas/academia/research/in_progress/glide_affiliation/figs/manuscript/duration_all.png){width=100%}



![Figure 4.3: Forest plot of posterior distributions of duration model estimates. Points represent posterior medians &pm;66% and 95% credible intervals.](/Users/casillas/academia/research/in_progress/glide_affiliation/figs/manuscript/duration_forest.png){width=100%}






#### Formant trajectories

The F1 trajectory data were analyzed using a Bayesian Generalized Additive Mixed Model [GAMM, @soskuthy2017generalised; @winter2016; @wood2006]. 
We modeled the participant-normalized F1 values as a function of pre-glide onset, *preceding consonant* ("palatal", "other"), and a non-linear function of the formant trajectory for the [j] productions. 
The *preceding consonant* parametric term was set as an ordered variable with *palatal* coded as 0. 
Cubic regression splines with three basis knots were applied (a) as a reference smooth to the time course, (b) as a difference smooth to the time course conditioned on the preceding consonant, and (c) as a random smooth for each participant conditioned on the time course. 
This specification uses the trajectory of the *palatal* condition as the baseline and compares it to the *other* trajectory. 



![Figure 4.4: Non-linear formant (F1) trajectories of [j] when preceded by *palatal* and *non-palatal* onsets (panel A), and estimated differences (palatal &minus; other) in standardized F1 over the time course (panel b). In both panels, the thin lines represent 300 draws of plausible lines from the posterior distribution. The thicker lines outlined in white represent the model average for the population estimate.](/Users/casillas/academia/research/in_progress/glide_affiliation/figs/manuscript/carrier_gam_f1.png){width=100%}

Panel A of Figure <a href="#fig:plot-carrier-task-f1">4.4</a> plots 300 posterior draws of plausible lines for the time course of the F1 trajectories in the palatal and other conditions. 
The thicker lines outlined in white represents the most plausible trajectories based on the data, the model, and our prior assumptions. 
One observes non-linear trajectories that are generally non-overlapping at the beginning of the time course and tend to converge on a single trajectory after approximately 50% of the time course. 
The estimates for the difference smooth suggest a small, negative effect with a moderate amount of uncertainty around the estimate (&beta; = &minus;0.15 [&minus;0.31, 0.00]; MPE = 0.98). 
There is approximately a .98 probability that the effect is negative. 
The uncertainty around the estimate is manifested in panels A and B of Figure <a href="#fig:plot-carrier-task-f1">4.4</a> by the overlapping colored lines. 
Panel B plots the estimated difference between the palatal and other conditions. 
The figure corroborates the estimates from the GAMM, as there appears to be a non-zero difference between trajectories during the first half of the time course, though some plausible estimates indicate that the difference may also be zero. 









#### [j] intensity time course

- Participants might be producing a longer segment in the palatal condition because of the fact that they cannot naturally produce both. 
- In other words, they might be trying to produce something, but because the target is illicit, they resort to lengthening.
- Prediction: intensity of the lengthened segment should be lower than that of a glide. 
- Why? More consonant-like productions have lower intensity than more vowel-like productions.
- Analysis 3
  - Generalized Additive Mixed Model
  - Model: Intensity ~ preceding_consonant + time


Summary
- Sonoran speakers used variable strategies when producing the CGVGC sequences
  - Importantly, they produced the GVG sequence at least some of the time (thus it is possible)
  - Acoustic analysis shows that pre-vocalic segments are longer after palatal consonants
  - Not shorter (i.e., elided because they are blocked)
  - Analysis of the time course suggests the duration increase could be due to lengthening of onset (Strategy to avoid illicit sequence)

Figure <a href="#fig:plot-carrier-task-int">4.5</a> shows the Intensity GAM stuff. 



![Figure 4.5: Non-linear intensity trajectories of [j] when preceded by *palatal* and *non-palatal* onsets (panel A), and estimated differences (palatal &minus; other) in standardized values over the time course (panel b). In both panels, the thin lines represent 300 draws of plausible lines from the posterior distribution. The thicker lines outlined in white represent the model average for the population estimate.](/Users/casillas/academia/research/in_progress/glide_affiliation/figs/manuscript/carrier_gam_int.png){width=100%}








Figure <a href="#fig:plot-carrier-task-forest">4.6</a> shows the GAM forest plot 



![Figure 4.6: This is a figure caption for the forest plot of the gams.](/Users/casillas/academia/research/in_progress/glide_affiliation/figs/manuscript/carrier_gam_forest.png){width=100%}





Answers to Research questions

- RQ1: Is a postconsonantal, prevocalic glide parsed as the second segment of a complex onset in Sonoran Spanish?
  - A1:Yes, at least some of the time.
- RQ2: In more general terms, the question is: are Spanish prevocalic glides always part of a complex nucleus (preceding a full vowel, in a diphthong) or can the glide be parsed in the onset in some dialects?
  - A2:The glide can be parsed in the onset in dialects like Sonoran Spanish, but it is not categorical





```{=openxml}
<w:p>
  <w:r>
    <w:br w:type="page"/>
  </w:r>
</w:p>
```


# Supplementary materials


## Bayesian Data Analysis

In all cases we used Bayesian Data Analysis (BDA, CITE) for statistical inferences. 


## Syllabification task

The first model analyzed the syllabification task data using multinomial logistic regression. 
The participants responses (triphthong, hiatus, simplification) were modeled in a simple, intecept-only model, and as a function of the post-consonantal glide ([j], [w]). 

Table <a href="#tab:syllabification-all-models-table">5.1</a> below.


Table: Table 5.1: Model summary for the syllabification task. The table reports 
    posterior medians, 95\% credible intervals, and probability of direction 
    to assess estimates, along with Rhat and Effective sample size to assess 
    model fit.

Model   Parameter                                             Estimate   P(direction)   Rhat       ESS           Prior
------  ----------------------------  --------------------------------  -------------  -----  --------  --------------
Main    μ Simplification: Intercept    &minus;0.30 [&minus;0.96, 0.29]           0.84   1.00   1724.03   Normal(0, 20)
Main    μ Triphthong: Intercept               0.12 [&minus;0.45, 0.66]           0.66   1.00   1974.05   Normal(0, 20)
[j]     μ Simplification: Intercept    &minus;0.29 [&minus;1.00, 0.47]           0.78   1.00   1576.48   Normal(0, 20)
[j]     μ Triphthong: Intercept        &minus;0.14 [&minus;0.89, 0.52]           0.65   1.00   1604.93   Normal(0, 20)
[w]     μ Simplification: Intercept    &minus;0.37 [&minus;1.61, 0.76]           0.73   1.00   1480.26   Normal(0, 20)
[w]     μ Triphthong: Intercept               0.54 [&minus;0.42, 1.55]           0.88   1.00   1238.82   Normal(0, 20)


## Carrier task

### GAMMs

GAMMs represent an extension to the linear model framework that allow non-linear functions called factor smooths to be applied to predictors. In this sense, the predictors can be classified into two types: parametric terms (equivalent to fixed effects in hierarchical model terminology) and smooth terms. 
Random smooths are conceptually similar to random slopes and intercepts in the mixed-effects regression framework [@winter2016].
Thus, they allow the by-subject trajectory shapes to vary as a function of a parametric effect and are essential in avoiding anti-conservative models.

### F1

Table <a href="#tab:carrier-dur">5.2</a> below.


Table: Table 5.2: Model summary for the duration analysis. The table reports 
    posterior medians, 95\% credible intervals, and probability of direction 
    to assess estimates, along with Rhat and Effective sample size to assess 
    model fit.

Parameter                           Estimate   P(direction)   Rhat       ESS            Prior
----------  --------------------------------  -------------  -----  --------  ---------------
Intercept    &minus;0.07 [&minus;0.41, 0.27]           0.65   1.00   2540.31   Normal(0, 0.2)
Palatal             0.22 [&minus;0.20, 0.62]           0.86   1.00   2091.63   Normal(0, 0.5)

Table <a href="#tab:carrier-f1-gam">5.3</a> below.


Table: Table 5.3: Model summary for the F1 GAMM. The table reports 
    posterior medians, 95\% credible intervals, and probability of direction 
    to assess estimates, along with Rhat and Effective sample size to assess 
    model fit.

Parameter                  Function                           Estimate   P(direction)   Rhat       ESS                Prior
-------------------------  ---------  --------------------------------  -------------  -----  --------  -------------------
Intercept                                     0.04 [&minus;0.30, 0.37]           0.62   1.00   1241.48       Normal(0, 0.5)
Not palatal                            &minus;0.15 [&minus;0.31, 0.00]           0.98   1.00   5632.28       Normal(0, 0.5)
Time course                Smooth             0.40 [&minus;0.15, 0.86]           0.93   1.00   1617.80   student_t(3, 0, 1)
Time course: Not palatal   Smooth             0.05 [&minus;0.17, 0.24]           0.67   1.00   5176.51   student_t(3, 0, 1)

Table <a href="#tab:carrier-int-gam">5.4</a> below.


Table: Table 5.4: Model summary for the F1 GAMM. The table reports 
    posterior medians, 95\% credible intervals, and probability of direction 
    to assess estimates, along with Rhat and Effective sample size to assess 
    model fit.

Parameter                  Function                           Estimate   P(direction)   Rhat       ESS                Prior
-------------------------  ---------  --------------------------------  -------------  -----  --------  -------------------
Intercept                              &minus;0.10 [&minus;0.48, 0.29]           0.72   1.00   1178.24       Normal(0, 0.5)
Not palatal                                          0.23 [0.10, 0.36]           1.00   1.00   5471.15       Normal(0, 0.5)
Time course                Smooth                    0.69 [0.32, 1.02]           1.00   1.00   1761.32   student_t(3, 0, 1)
Time course: Not palatal   Smooth                    0.37 [0.20, 0.56]           1.00   1.00   4063.34   student_t(3, 0, 1)





```{=openxml}
<w:p>
  <w:r>
    <w:br w:type="page"/>
  </w:r>
</w:p>
```

# References




