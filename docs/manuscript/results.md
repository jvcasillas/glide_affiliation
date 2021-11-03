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

We report three primary statistical analyses in order to address the aforementioned research questions.
To this end, we fit a series of Bayesian regression models, which are described in detail in the corresponding sections below and in the supplementary materials (https://osf.io/fyt4d/?view_only=1e5f867b1896417cbaa21a2872221cf8).
All analyses were conducted in R [@R-base, version 4.1.0].
The models were fit using `stan` [@stan] via the R package `brms`  [@R_brms_a].
All models included a maximal grouping-effects structure [@barr2013random], as well as regularizing, weakly informative priors [@Gelman_2017]. 
Additionally, models were fit with 2000 iterations (1000 warm-up) and  Hamiltonian Monte-Carlo sampling was carried out with 4 chains distributed between 4 processing cores.
We report point estimates (posterior medians) for each parameter of interest, along with the 95% highest density interval (HDI), and the maximum probability of effect (MPE).
A complete description of the models and output summaries in table format are available in the supplementary materials.

## Results

### Syllable division task 

The first model analyzed the syllable division task data using hierarchical multinomial logistic regression. 
The participants responses to the critical CGVG sequences were classified as triphthong, hiatus, or simplification, i.e., [la.ka.ˈpi̯ai̯s.to], [la.ka.pi.ˈai̯s.to], or [la.ka.ˈpai̯s.to], respectively. 
Given that there were three response categorizations, the model likelihood was categorical and used a logit linking function. 
To simplify model interpretation, we report effects in the probability space. 
The complete model output in the original format is available in the supplementary materials. 
The responses were modeled in a simple, intercept-only model, and as a function of the post-consonantal glide ([j], [w]). 
A "hiatus" response was set as the default and the model estimated intercepts for the "simplification" and "triphthong" responses. 
Figure <a href="#fig:plot-syllabification-task">4.1</a> illustrates the overall posterior probabilities of a given response (panel A), and as a function of the glide (panels B and C). 



![Figure 4.1: Posterior probabilities of responding "hiatus", "triphthong", or "simplification". Each panel plots the posterior medians &pm; 66% and 95% credible intervals. Panel A shows overall responses, and panels B and C show responses as a function of glide type.](/Users/casillas/academia/research/in_progress/glide_affiliation/figs/manuscript/syllabification_all.png){width=100%}

With this model we aimed to shed light on how participants responded. 
Specifically, we were interested in knowing if GVG productions were possible and whether responses depended on the type of glide. 
We show that GVG responses are indeed possible. 
Triphthong realizations occurred approximately 39% of the time (0.39 [0.28, 0.51]) in the data set. 
A production containing a hiatus made up roughly 35% of the data (0.35 [0.24, 0.46]), followed by a simplification of some sort (0.26 [0.16, 0.37]).
If we consider realizations as a function of glide type we see that triphthong realizations were possible in both environments, with more being produced with [w] (0.50 [0.31, 0.71]) than with [j] (0.33 [0.20, 0.47]). 
Overall, the task provides evidence supporting the hypothesis that pre-vocalic glides can be part of the onset in this variety of Spanish because the participants produced triphthongs at least some of the time. 










### Phrase reading task

For the phrase reading task data we fit models analyzing acoustic properties of the pre-vocalic glide [j]. 
Importantly, we expect co-occurrence restrictions such that pre-vocalic [j] will be disallowed if preceded by a palatal consonant. 
In the case that pre-vocalic [j] is indeed blocked after a palatal consonant (i.e., "lliape"), we may observe differences in overall duration of the segment, as well as formant trajectory differences related to height (F1) when compared with a pre-vocalic [j] that is not preceded by a palatal segment (i.e., "piano"). 
The justification for analyzing duration is due to the prediction that co-occurrence restrictions should disallow contiguous palatal consonant &plus; homorganic glide segments, possibly resulting in an elision. 
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
A traditional table summary of the model output is available in the supplementary materials:  
https://osf.io/fyt4d/?view_only=1e5f867b1896417cbaa21a2872221cf8. 



![Figure 4.2: Posterior distributions of pre-vocalic glide duration (panels A and C) following palatal and non-palatal onsets, as well as duration difference plots (panels B and D). Points represent posterior medians &pm;66% and 95% credible intervals.](/Users/casillas/academia/research/in_progress/glide_affiliation/figs/manuscript/duration_all.png){width=100%}



![Figure 4.3: Forest plot of posterior distributions of duration model estimates. Points represent posterior medians &pm;66% and 95% credible intervals.](/Users/casillas/academia/research/in_progress/glide_affiliation/figs/manuscript/duration_forest.png){width=100%}






#### Formant trajectories

The F1 trajectory data were analyzed using a Bayesian Generalized Additive Mixed Model [GAMM, @soskuthy2017generalised; @winter2016; @wood2006]. 
We modeled the participant-normalized F1 values as a function of pre-glide onset, *preceding consonant* ("palatal", "other"), and a non-linear function of the formant trajectory for the [j] productions. 
The *preceding consonant* parametric term was set as an ordered variable with *palatal* coded as 0. 
Cubic regression splines with three basis knots were applied (a) as a reference smooth to the time course, (b) as a difference smooth to the time course conditioned on the preceding consonant, and (c) as a random smooth for each participant conditioned on the time course. 
This specification uses the trajectory of the *palatal* condition as the baseline and compares it to the *other* trajectory. 



![Figure 4.4: Non-linear formant (F1) trajectories of [j] when preceded by *palatal* and *non-palatal* onsets (panel A), and estimated differences (palatal &minus; other) in standardized F1 over the time course (panel B). In both panels, the thin lines represent 300 draws of plausible lines from the posterior distribution. The thicker lines outlined in white represent the model average for the population estimate.](/Users/casillas/academia/research/in_progress/glide_affiliation/figs/manuscript/carrier_gam_f1.png){width=100%}

Panel A of Figure <a href="#fig:plot-carrier-task-f1">4.4</a> plots 300 posterior draws of plausible lines for the time course of the F1 trajectories in the palatal and other conditions. 
The thicker lines outlined in white represents the most plausible trajectories based on the data, the model, and our prior assumptions. 
One observes non-linear trajectories that are generally non-overlapping at the beginning of the time course and tend to converge on a single trajectory after approximately 50% of the time course. 
The estimates for the difference smooth suggest a small, negative effect with a moderate amount of uncertainty around the estimate (&beta; = &minus;0.15 [&minus;0.31, 0.00]; MPE = 0.98). 
The probability that the effect is negative is approximately .98. 
The uncertainty around the estimate is manifested in panels A and B of Figure <a href="#fig:plot-carrier-task-f1">4.4</a> by the overlapping colored lines. 
Panel B plots the estimated difference between the palatal and other conditions. 
The figure corroborates the estimates from the GAMM, as there appears to be a non-zero difference between trajectories during the first half of the time course, though some plausible estimates indicate that the difference may also be zero. 
Figure <a href="#fig:plot-carrier-task-forest">4.5</a> provides a forest plot of the model summary. 
A traditional table summary is provided in the supplementary materials:  
https://osf.io/fyt4d/?view_only=1e5f867b1896417cbaa21a2872221cf8.



![Figure 4.5: Forest plot of posterior distributions from the GAMM analyses of the F1 time course for [j]. Points represent posterior medians &pm;66% and 95% credible intervals for which numeric summaries are provided in the left margin. Vertical faceting distinguishes between parametric (top) and non-parametric population estimates, followed by grouping estimates for smooth terms and overall standard deviation.](/Users/casillas/academia/research/in_progress/glide_affiliation/figs/manuscript/carrier_gam_forest_f1.png){width=100%}


<!--
To consider this issue further we conducted an exploratory analysis of the intensity measurement of the time course of the lengthened segment. 
The should be lower than that of a glide. 
- Why? More consonant-like productions have lower intensity than more vowel-like productions.

#### [j] intensity time course


- Analysis 3
  - Generalized Additive Mixed Model
  - Model: Intensity ~ preceding_consonant + time

Figure <a href="#fig:plot-carrier-task-int"><strong>??</strong></a> shows the Intensity GAM stuff. 



![(\#fig:plot-carrier-task-int)Non-linear intensity trajectories of [j] when preceded by *palatal* and *non-palatal* onsets (panel A), and estimated differences (palatal &minus; other) in standardized values over the time course (panel b). In both panels, the thin lines represent 300 draws of plausible lines from the posterior distribution. The thicker lines outlined in white represent the model average for the population estimate.](/Users/casillas/academia/research/in_progress/glide_affiliation/figs/manuscript/carrier_gam_int.png){width=100%}


-->



# Discussion

The results of the production experiments suggest that Sonoran speakers used variable strategies when producing the CGVGC sequences. 
Importantly, they produced the GVG sequence at least some of the time in the syllabification task, indicating that this realization is indeed possible, though not categorical. 
An acoustic analysis of the production data from the phrase reading task indicates that pre-vocalic [j] may be realized with subtle differences after palatal consonants. 
Taken together, the duration and formant trajectory analyses suggest (1) that participants may be producing slightly *longer* pre-vocalic [j] when preceded by a &plus;palatal onset segment, and (2) that the starting point for the F1 transition from [j] to [a] is slightly lower when the onset contains a &plus;palatal segment. 
Concretely, [j] was not shortened or elided as hypothesized due to co-occurrence restrictions. 
On the contrary, we find evidence that the hypothesized co-occurrence restriction may result in lengthening of the onset segment. 
One possibility is that the participants may be producing a slightly longer segment, as opposed to eliding it, in the palatal condition because of the fact that they cannot naturally produce both.
That is, our exploratory analysis of the [j] time course suggests that the tendency to increase duration could be a strategy to avoid the illicit sequence. 

```{=openxml}
<w:p>
  <w:r>
    <w:br w:type="page"/>
  </w:r>
</w:p>
```


# Supplementary materials


## Bayesian Data Analysis

The present work uses Bayesian Data Analysis (BDA) for statistical inferences. 
This implies that we do not focus on a single point estimate for a given parameter &beta;, but rather we use Bayes Theorem to derive a posterior distribution of plausible estimates of &beta;. 
Importantly, we do not use p-values or any other decision rules for determining the importance of an effect. 
BDA allows us to quantify our uncertainty in a more straightforward way with regard to our statistical models and focus on estimation.

## Syllable division task

The first model analyzed the syllabification task data using multinomial logistic regression. 
The participants responses (triphthong, hiatus, simplification) were modeled in a simple, intecept-only model, and as a function of the post-consonantal glide ([j], [w]). 
Table <a href="#tab:syllabification-all-models-table">6.1</a> below provides the complete output summary of the model.


Table: Table 6.1: Model summary for the syllabification task. The table reports 
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


## Phrase reading task

### GAMMs

GAMMs represent an extension to the linear model framework that allow non-linear functions called factor smooths to be applied to predictors. 
In this sense, the predictors can be classified into two types: parametric terms (equivalent to fixed effects in hierarchical model terminology) and smooth terms. 
Random smooths are conceptually similar to random slopes and intercepts in the mixed-effects regression framework [@winter2016].
Thus, they allow the by-subject trajectory shapes to vary as a function of a parametric effect and are essential in avoiding anti-conservative models.

### F1

The model summary output of the duration model is available in Table <a href="#tab:carrier-dur">6.2</a> here: 


Table: Table 6.2: Model summary for the duration analysis. The table reports 
    posterior medians, 95\% credible intervals, and probability of direction 
    to assess estimates, along with Rhat and Effective sample size to assess 
    model fit.

Parameter                           Estimate   P(direction)   Rhat       ESS            Prior
----------  --------------------------------  -------------  -----  --------  ---------------
Intercept    &minus;0.07 [&minus;0.41, 0.27]           0.65   1.00   2540.31   Normal(0, 0.2)
Palatal             0.22 [&minus;0.20, 0.62]           0.86   1.00   2091.63   Normal(0, 0.5)


The full model specification used to fit the F1 GAMM is provided below, followed by the full output of the model summary in Table <a href="#tab:carrier-f1-gam">6.3</a>. 

```r
# Set priors
priors <- c(
  prior(normal(0, 0.5), class = Intercept), 
  prior(normal(0, 0.5), class = b), 
  prior(
    student_t(3, 0, 1), 
    class = sds, 
    coef = s(time_course_segment, bs = "cr", k = 3)), 
  prior(
    student_t(3, 0, 2.5), 
    class = sds, 
    coef = s(time_course_segment, by = is_palatal_ord, bs = "cr", k = 4)), 
  prior(
    student_t(3, 0, 2.5), 
    class = sds, 
    coef = s(time_course_segment, participant, bs = "fs", m = 1, k = 3)), 
  prior(cauchy(0, 2), class = sigma)
  )

# Model formula
mode_formula <- bf(
 f1norm ~ is_palatal_ord + 
  s(time_course_segment, bs = "cr", k = 3) + # ref smooth
  s(time_course_segment, by = is_palatal_ord, bs = "cr", k = 4) + # diff
  s(time_course_segment, participant, bs = "fs", m = 1, k = 3), # random 
)

# F1 GAM
b_gam_f1 <- brm(
  formula = model_formula
  family = gaussian(), 
  prior = priors, 
  backend = "cmdstanr", iter = 2000, warmup = 1000, cores = 4,
  control = list(adapt_delta = 0.999999, max_treedepth = 20), 
  data = carrier_tc_final_gamm, 
  )
```



Table: Table 6.3: Model summary for the F1 GAMM. The table reports 
    posterior medians, 95\% credible intervals, and probability of direction 
    to assess estimates, along with Rhat and Effective sample size to assess 
    model fit.

Parameter                  Function                           Estimate   P(direction)   Rhat       ESS                Prior
-------------------------  ---------  --------------------------------  -------------  -----  --------  -------------------
Intercept                                     0.04 [&minus;0.30, 0.37]           0.62   1.00   1241.48       Normal(0, 0.5)
Not palatal                            &minus;0.15 [&minus;0.31, 0.00]           0.98   1.00   5632.28       Normal(0, 0.5)
Time course                Smooth             0.40 [&minus;0.15, 0.86]           0.93   1.00   1617.80   student_t(3, 0, 1)
Time course: Not palatal   Smooth             0.05 [&minus;0.17, 0.24]           0.67   1.00   5176.51   student_t(3, 0, 1)

An exploratory model not reported on the time course of the intensity measurements is provided below in Table <a href="#tab:carrier-int-gam">6.4</a>. 


Table: Table 6.4: Model summary for the F1 GAMM. The table reports 
    posterior medians, 95\% credible intervals, and probability of direction 
    to assess estimates, along with Rhat and Effective sample size to assess 
    model fit.

Parameter                  Function                           Estimate   P(direction)   Rhat       ESS                Prior
-------------------------  ---------  --------------------------------  -------------  -----  --------  -------------------
Intercept                              &minus;0.10 [&minus;0.48, 0.29]           0.72   1.00   1178.24       Normal(0, 0.5)
Not palatal                                          0.23 [0.10, 0.36]           1.00   1.00   5471.15       Normal(0, 0.5)
Time course                Smooth                    0.69 [0.32, 1.02]           1.00   1.00   1761.32   student_t(3, 0, 1)
Time course: Not palatal   Smooth                    0.37 [0.20, 0.56]           1.00   1.00   4063.34   student_t(3, 0, 1)


## Reproducibility information

**About this document**  

This document was written in RMarkdown using `papaja` [@R-papaja].  

**Session info**  


```
 setting  value                       
 version  R version 4.1.0 (2021-05-18)
 os       macOS Big Sur 10.16         
 system   x86_64, darwin17.0          
 ui       X11                         
 language (EN)                        
 collate  en_US.UTF-8                 
 ctype    en_US.UTF-8                 
 tz       America/New_York            
 date     2021-11-02                  
```

```
               loadedversion       date
abind                  1.4-5 2016-07-21
arrayhelpers           1.1-0 2020-02-04
assertthat             0.2.1 2019-03-21
backports              1.2.1 2020-12-09
base64enc              0.1-3 2015-07-28
bayesplot              1.8.1 2021-06-14
bit                    4.0.4 2020-08-04
bit64                  4.0.5 2020-08-30
bookdown                0.24 2021-09-02
boot                  1.3-28 2021-05-03
bridgesampling         1.1-2 2021-04-16
brms                  2.16.1 2021-08-23
Brobdingnag            1.2-6 2018-08-13
broom                  0.7.9 2021-07-27
broom.mixed            0.2.7 2021-07-07
cachem                 1.0.6 2021-08-19
callr                  3.7.0 2021-04-20
cellranger             1.1.0 2016-07-27
checkmate              2.0.0 2020-02-06
cli                    3.0.1 2021-07-17
cmdstanr               0.4.0 2021-07-22
coda                  0.19-4 2020-09-30
codetools             0.2-18 2020-11-04
colorspace             2.0-2 2021-06-24
colourpicker           1.1.1 2021-10-04
crayon                 1.4.1 2021-02-08
crosstalk              1.1.1 2021-01-12
curl                   4.3.2 2021-06-23
DBI                    1.1.1 2021-01-15
dbplyr                 2.1.1 2021-04-06
desc                   1.4.0 2021-09-28
devtools               2.4.2 2021-06-07
digest                0.6.28 2021-09-23
distributional         0.2.2 2021-02-02
dplyr                  1.0.7 2021-06-18
DT                      0.19 2021-09-02
dygraphs             1.1.1.6 2018-07-11
ellipsis               0.3.2 2021-04-29
emmeans                1.7.0 2021-09-29
estimability             1.3 2018-02-11
evaluate                0.14 2019-05-28
fansi                  0.5.0 2021-05-25
farver                 2.1.0 2021-02-28
fastmap                1.1.0 2021-01-25
forcats                0.5.1 2021-01-27
fs                     1.5.0 2020-07-31
gamm4                  0.2-6 2020-04-03
generics               0.1.0 2020-10-31
ggdist                 3.0.0 2021-07-19
ggplot2                3.3.5 2021-06-25
ggridges               0.5.3 2021-01-08
glue                   1.4.2 2020-08-27
gridExtra                2.3 2017-09-09
gtable                 0.3.0 2019-03-25
gtools                 3.9.2 2021-06-06
haven                  2.4.3 2021-08-04
here                   1.0.1 2020-12-13
highr                    0.9 2021-04-16
hms                    1.1.1 2021-09-26
htmltools              0.5.2 2021-08-25
htmlwidgets            1.5.4 2021-09-08
httpuv                 1.6.3 2021-09-09
httr                   1.4.2 2020-07-20
igraph                 1.2.6 2020-10-06
inline                0.3.19 2021-05-31
jsonlite               1.7.2 2020-12-09
kableExtra             1.3.4 2021-02-20
knitr                   1.36 2021-09-29
later                  1.3.0 2021-08-18
lattice              0.20-45 2021-09-22
lifecycle              1.0.1 2021-09-24
lme4                1.1-27.1 2021-06-22
loo                    2.4.1 2020-12-09
lubridate              1.8.0 2021-10-07
magrittr               2.0.1 2020-11-17
markdown                 1.1 2019-08-07
MASS                  7.3-54 2021-05-03
Matrix                 1.3-4 2021-06-01
matrixStats           0.61.0 2021-09-17
memoise                2.0.0 2021-01-26
mgcv                  1.8-38 2021-10-06
mime                    0.12 2021-09-28
miniUI               0.1.1.1 2018-05-18
minqa                  1.2.4 2014-10-09
modelr                 0.1.8 2020-05-19
munsell                0.5.0 2018-06-12
mvtnorm                1.1-3 2021-10-08
nlme                 3.1-153 2021-09-07
nloptr               1.2.2.2 2020-07-02
patchwork              1.1.1 2020-12-17
pillar                 1.6.3 2021-09-26
pkgbuild               1.2.0 2020-12-15
pkgconfig              2.0.3 2019-09-22
pkgload                1.2.3 2021-10-13
plyr                   1.8.6 2020-03-03
posterior              1.1.0 2021-09-09
prettyunits            1.1.1 2020-01-24
processx               3.5.2 2021-04-30
projpred               2.0.2 2020-10-28
promises             1.2.0.1 2021-02-11
ps                     1.6.0 2021-02-28
purrr                  0.3.4 2020-04-17
R6                     2.5.1 2021-08-19
Rcpp                   1.0.7 2021-07-07
RcppParallel           5.1.4 2021-05-04
readr                  2.0.2 2021-09-27
readxl                 1.3.1 2019-03-13
remotes                2.4.1 2021-09-29
reprex                 2.0.1 2021-08-05
reshape2               1.4.4 2020-04-09
rlang                 0.4.11 2021-04-30
rmarkdown               2.11 2021-09-14
rprojroot              2.0.2 2020-11-15
rsconnect             0.8.24 2021-08-05
rstan                 2.21.2 2020-07-27
rstantools             2.1.1 2020-07-06
rstudioapi              0.13 2020-11-12
rvest                  1.0.1 2021-07-26
scales                 1.1.1 2020-05-11
sessioninfo            1.1.1 2018-11-05
shiny                  1.7.1 2021-10-02
shinyjs                2.0.0 2020-09-09
shinystan              2.5.0 2018-05-01
shinythemes            1.2.0 2021-01-25
StanHeaders         2.21.0-7 2020-12-17
stringi                1.7.5 2021-10-04
stringr                1.4.0 2019-02-10
svglite                2.0.0 2021-02-20
svUnit                 1.0.6 2021-04-19
systemfonts            1.0.3 2021-10-13
tensorA               0.36.2 2020-11-19
testthat               3.1.0 2021-10-04
threejs                0.3.3 2020-01-21
tibble                 3.1.5 2021-09-30
tidybayes              3.0.1 2021-08-22
tidyr                  1.1.4 2021-09-27
tidyselect             1.1.1 2021-04-30
tidyverse              1.3.1 2021-04-15
tzdb                   0.1.2 2021-07-20
usethis                2.0.1 2021-02-10
utf8                   1.2.2 2021-07-24
V8                     3.4.2 2021-05-01
vctrs                  0.3.8 2021-04-29
viridisLite            0.4.0 2021-04-13
vroom                  1.5.5 2021-09-14
webshot                0.5.2 2019-11-22
withr                  2.4.2 2021-04-18
xfun                    0.26 2021-09-14
xml2                   1.3.2 2020-04-23
xtable                 1.8-4 2019-04-21
xts                   0.12.1 2020-09-09
yaml                   2.2.1 2020-02-01
zoo                    1.8-9 2021-03-09
```


```{=openxml}
<w:p>
  <w:r>
    <w:br w:type="page"/>
  </w:r>
</w:p>
```

# References




