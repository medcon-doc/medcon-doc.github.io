****MedCon: Human Ratings of Topics Generated from Topic Models for Coherence & Relevance

* Author: [blinded]
* This Version: 1 August 2018

/*
Note 1: Input xlsx files are based on individual human coding in individual Excel files,
	manually merged and preformatted for analysis in Stata. 
	
Note 2: Topic models based on news & blog documents from Australia, Switzerland, Germany, Turkey, and US

Note 3: Three topic models estimated for each country: 100, 500, and 1000 topics
	
Objectives:
1. Prepare single combined human topic ratings dataset
2. Identify optimal (most reliable) coding approach
3. Identify optimal topic model for each country
4. Identify relevant topics (by majority decision, optimal coding approach), by topic model
5. Create plots of mean topic coherence, by topic model (dot plots)
*/

version 15
set more off
capture log close

	
* Change to work directory to folder containing raw data
* cd [my data directory]

**************Step 1: Prepare Single Dataset**************

* Generate AU_100 .dta dataset 
import excel "AU_top0.2-(C22-C24-C97)_manprep.xlsx", ///
sheet("AU_100") cellrange(A1:J21) firstrow allstring   // import codings only
save TM_AU_C22-C24-C97_100.dta, replace
clear

* Generate AU_500 .dta dataset 
import excel "AU_top0.2-(C22-C24-C97)_manprep.xlsx", ///
sheet("AU_500") cellrange(A1:J101) firstrow allstring   // import codings only
save TM_AU_C22-C24-C97_500.dta, replace
clear

* Generate AU_1000 .dta dataset 
import excel "AU_top0.2-(C22-C24-C97)_manprep.xlsx", ///
sheet("AU_1000") cellrange(A1:J201) firstrow allstring   // import codings only
save TM_AU_C22-C24-C97_1000.dta, replace
clear

* Generate CH_100 .dta dataset 
import excel "CH_top0.2-(C22-C24-C97)_manprep.xlsx", ///
sheet("CH_100") cellrange(A1:J21) firstrow allstring   // import codings only
save TM_CH_C22-C24-C97_100.dta, replace
clear

* Generate CH_500 .dta dataset 
import excel "CH_top0.2-(C22-C24-C97)_manprep.xlsx", ///
sheet("CH_500") cellrange(A1:J101) firstrow allstring   // import codings only
save TM_CH_C22-C24-C97_500.dta, replace
clear

* Generate CH_1000 .dta dataset 
import excel "CH_top0.2-(C22-C24-C97)_manprep.xlsx", ///
sheet("CH_1000") cellrange(A1:J201) firstrow allstring   // import codings only
save TM_CH_C22-C24-C97_1000.dta, replace
clear

* Generate DE_100 .dta dataset 
import excel "DE_top0.2-(C09-C22-C24-C97)_manprep.xlsx", ///
sheet("DE_100") cellrange(A1:J21) firstrow allstring   // import codings only
save TM_DE_C09-C22-C24-C97_100.dta, replace
clear

* Generate DE_500 .dta dataset 
import excel "DE_top0.2-(C09-C22-C24-C97)_manprep.xlsx", ///
sheet("DE_500") cellrange(A1:J101) firstrow allstring   // import codings only
save TM_DE_C09-C22-C24-C97_500.dta, replace
clear

* Generate DE_1000 .dta dataset 
import excel "DE_top0.2-(C09-C22-C24-C97)_manprep.xlsx", ///
sheet("DE_1000") cellrange(A1:J201) firstrow allstring   // import codings only
save TM_DE_C09-C22-C24-C97_1000.dta, replace
clear

* Generate TR_100 .dta dataset 
import excel "TR_top0.2-(C16-C17-C18)_manprep.xlsx", ///
sheet("TR_100") cellrange(A1:J21) firstrow allstring   // import codings only
save TM_TR_C16-C17-C18_100.dta, replace
clear

* Generate TR_500 .dta dataset 
import excel "TR_top0.2-(C16-C17-C18)_manprep.xlsx", ///
sheet("TR_500") cellrange(A1:J101) firstrow allstring   // import codings only
save TM_TR_C16-C17-C18_500.dta, replace
clear

* Generate TR_1000 .dta dataset 
import excel "TR_top0.2-(C16-C17-C18)_manprep.xlsx", ///
sheet("TR_1000") cellrange(A1:J201) firstrow allstring   // import codings only
save TM_TR_C16-C17-C18_1000.dta, replace
clear

* Generate US_100 .dta dataset 
import excel "US_top0.2-(C22-C24-C97)_manprep.xlsx", ///
sheet("US_100") cellrange(A1:J21) firstrow allstring   // import codings only
save TM_US_C22-C24-C97_100.dta, replace
clear

* Generate US_500 .dta dataset 
import excel "US_top0.2-(C22-C24-C97)_manprep.xlsx", ///
sheet("US_500") cellrange(A1:J101) firstrow allstring   // import codings only
save TM_US_C22-C24-C97_500.dta, replace
clear

* Generate US_1000 .dta dataset 
import excel "US_top0.2-(C22-C24-C97)_manprep.xlsx", ///
sheet("US_1000") cellrange(A1:J201) firstrow allstring   // import codings only
save TM_US_C22-C24-C97_1000.dta, replace
clear

* Combine datasets
use TM_AU_C22-C24-C97_100.dta
append using TM_AU_C22-C24-C97_500 TM_AU_C22-C24-C97_1000 /// AU
	TM_CH_C22-C24-C97_100 TM_CH_C22-C24-C97_500 TM_CH_C22-C24-C97_1000 /// CH
	TM_DE_C09-C22-C24-C97_100 TM_DE_C09-C22-C24-C97_500 TM_DE_C09-C22-C24-C97_1000 /// DE
	TM_TR_C16-C17-C18_100 TM_TR_C16-C17-C18_500 TM_TR_C16-C17-C18_1000 /// TR
	TM_US_C22-C24-C97_100 TM_US_C22-C24-C97_500 TM_US_C22-C24-C97_1000, generate(tmid)

	* Label topic model indicator var
label define tmidlb 0 "AU_100" 1 "AU_500" 2 "AU_1000" 3 "CH_100" 4 "CH_500" ///
	5 "CH_1000" 6 "DE_100" 7 "DE_500" 8 "DE_1000" 9 "TR_100" 10 "TR_500" ///
	11 "TR_1000" 12 "US_100" 13 "US_500" 14 "US_1000", modify
label values tmid tmidlb
save TM_AU-CH-DE-TR-US_100-500-1000.dta, replace

	* Generate country var
generate country = tmid
recode country (0 1 2 = 1) (3 4 5 = 2) (6 7 8 = 3) (9 10 11 = 4) (12 13 14 = 5)
label define countrylb 1 "AU" 2 "CH" 3 "DE" 4 "TR" 5 "US", modify
label values country countrylb

	* Generate topic number (hyperparameter) var
generate topicn = tmid
recode topicn (0 3 6 9 12 = 1) (1 4 7 10 13 = 2) (2 5 8 11 14 = 3)
label define topicnlb 1 "100" 2 "500" 3 "1000"
label values topicn topicnlb


	* rename topic indicator var
rename Topic topicid

	* Var reformatting
foreach coder in C09 C16 C17 C18 C22 C24 C97 { 
	rename relevant_`coder' rel_`coder'
	rename certain_`coder' cer_`coder'
	}

foreach coder in C16 C17 C18 C22 C24 C97 { 
	rename coherent_`coder' coh_`coder'
	}

destring _all, replace

	* Prepare coding vars for different coding approaches: tendency (CT), liberal (CL), conservative (CC)

* Create tendency coding vars (ct)
foreach coder in C09 C16 C17 C18 C22 C24 C97 {
	generate rel_`coder'_ct = rel_`coder'
	}

* Create liberal coding vars (cl)
foreach coder in C09 C16 C17 C18 C22 C24 C97 {
	generate rel_`coder'_cl = rel_`coder'
	recode rel_`coder'_cl (0 = 1) if cer_`coder' == 0
	}

* Create conservative coding vars (cc)
foreach coder in C09 C16 C17 C18 C22 C24 C97 {
	generate rel_`coder'_cc = rel_`coder'
	recode rel_`coder'_cc (1 = 0) if cer_`coder' == 0
	}

	
label define codelb 0 "no" 1 "yes", modify
label values rel_* cer_* codelb


* Create vars for binary majority decision about topic relevance
foreach approach in ct cl cc {
	egen relcount_`approach' = anycount(rel_*_`approach'), values(1)
	recode relcount_`approach' (0 1 = 0) (2 3 = 1), gen(relcount_`approach'_bin)
	}
	

**************Step 2: Identify optimal (most reliable) coding approach**************

** Criterion: Overall reliability of different coding approaches

* CT: tendency coding
kappaetc rel_*_ct, wgt(identity) se(conditional) level(95) ///
	benchmark(probabilistic) showscale
bysort country: kappaetc rel_*_ct, wgt(identity) se(conditional) level(95) ///
	benchmark(probabilistic) showscale
	
* CL: liberal coding
kappaetc rel_*_cl, wgt(identity) se(conditional) level(95) ///
	benchmark(probabilistic) showscale
bysort country: kappaetc rel_*_cl, wgt(identity) se(conditional) level(95) ///
	benchmark(probabilistic) showscale
	
* CC: conservative coding
kappaetc rel_*_cc, wgt(identity) se(conditional) level(95) ///
	benchmark(probabilistic) showscale
bysort country: kappaetc rel_*_cc, wgt(identity) se(conditional) level(95) ///
	benchmark(probabilistic) showscale
	

/*RESULTS: CL is most reliable approach to topic-relevance coding (Krippendorff's Alpha)
	Overall CT: .33 (AU: .35; CH: .33; DE: .28; TR: .27; US: .38)
	Overall CL: .35 (AU: .25; CH: .40; DE: .31; TR: .30; US: .44)
	Overall CC: .28 (AU: .29; CH: .24; DE: .23; TR: .29; US: .30)
*/


**************Step 3: Identify optimal topic model**************

** Criterion: mean overall coherence of model

* Calculate reliability of manual topic coherence ratings
	* Overall
kappaetc coh_*, wgt(ordinal, krippendorff) level(95) ///
	benchmark(probabilistic) showscale

	* For different countries
bysort country: kappaetc coh_*, wgt(ordinal, krippendorff) level(95) ///
	benchmark(probabilistic) showscale
	
	* For different hyperparameters (number of topics in model)
bysort topicn: kappaetc coh_*, wgt(ordinal, krippendorff) level(95) ///
	benchmark(probabilistic) showscale

/*RESULTS: Overall coherence coding reliability OK (Krippendorff's Alpha)
	Overall: .70 (AU: .75; CH: .74; DE: .66; TR: .40; US: .77)
	By hyperparameter (n of topics in model): 100: .46; 500: .66; 1000: .71
*/
	
* Calculate mean topic coherence
	* Create mean coherence measure
egen coh_avg = rowmean(coh_*)
	
	* Overall topic coherence
sum coh_*

	* Mean topic coherence, by topic model
bysort tmid: sum coh_avg

/*RESULTS: High overall topic coherence (M==2.38, on 1-3 scale)
	AU: 100: 2.83; 500: 2.82; 1000: 2.33
	CH: 100: 2.53; 500: 2.35; 1000: 2.16
	DE: 100: 2.82; 500: 2.74; 1000: 2.48
	TR: 100: 2.43; 500: 2.09; 1000: 1.89
	US: 100: 2.87; 500: 2.77; 1000: 2.41
*/


**************Step 4: Identify relevant topics (by majority decision, optimal coding approach), by topic model**************
bysort tmid: tab1 relcount_cl_bin
/*RESULTS: Count of relevant topics per topic model:
	AU: 100: 11; 500: 39; 1000: 51
	CH: 100:  7; 500: 40; 1000: 65
	DE: 100: 14; 500: 46; 1000: 73
	TR: 100: 10; 500: 30; 1000: 50
	US: 100: 16; 500: 62; 1000: 77
*/

* List relevant topics per topic model
bysort tmid: list topicid if relcount_cl_bin==1


**************Step 5: Create plots of mean topic coherence, by topic model (dot plots)**************
* Subtract constant of 1 to make scale to range from 0 to 2 (instead of 1 to 3)
generate coh_avg_rec = coh_avg - 1

* Create dot plot
graph dot (mean) coh_avg_rec, over(topicn, label(labsize(small))) over(country, ///
	gap(*2.5) relabel(1 "Australia" 2 "Switzerland" 3 "Germany" 4 "Turkey" 5 "USA")) ///
	marker(1, mcolor(black)) ytitle("Mean topic coherence") ///
	ylabel(0(1)2) scheme(s1mono) name(topiccoh, replace)

* Export graph in emf, png, and pdf formats
graph export "Fig_MeanTopicCoherence.emf", name(topiccoh) replace
graph export "Fig_MeanTopicCoherence.png", name(topiccoh) replace
graph export "Fig_MeanTopicCoherence.pdf", name(topiccoh) replace

* Save final single combined human topic ratings dataset 
save TM_AU-CH-DE-TR-US_100-500-1000.dta, replace

clear all
exit
