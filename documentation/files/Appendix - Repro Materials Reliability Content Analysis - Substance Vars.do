***MedCon1 - Substance Paper: Reliability Analyses***

/*

Author: Eike Mark Rinke (University of Leeds)
This Version: 30 Jan 2023

Note 1: Make sure to change working directory (using -cd- cmd) to folder containing	data before running code.

Note 2: List of required packages for code to run successfully:
	kappaetc from https://ideas.repec.org/c/boc/bocode/s458283.html

Note 3: Brief genealogy of datasets analysed in this file:
	* All data files contain complete independent double-coding of main material analyzed (before consensus decision were used to resolve coding disagreements in these files).
	* This do file computes final pre-consensus-decision reliability coefficients for each variable.
	
Analytical objective:

1. Calculate human-coder reliability for item-, actor-, and justification-level vars

*/

version 17
set more off
capture log close	
	
*cd [folder containing raw xlsx reliability data]

*****Actor inclusiveness*****
import excel "Appendix - Repro Materials Reliability Content Analysis - Substance Vars.xlsx", sheet("actors_matched") cellrange(A1:BB10969) firstrow

keep ROLLE_ALLGEMEIN ROLLE_ALLGEMEIN2 ROLLE_POL_INLAND_NATIONAL ROLLE_POL_INLAND_NATIONAL2 RELIGIONSZUGEHOERIGKEIT RELIGIONSZUGEHOERIGKEIT2

* Convert string variables with non-numeric values into numeric values
encode ROLLE_ALLGEMEIN, generate(ROLLE_ALLGEMEIN_num)
encode ROLLE_ALLGEMEIN2, generate(ROLLE_ALLGEMEIN2_num)

encode ROLLE_POL_INLAND_NATIONAL, generate(ROLLE_POL_INLAND_NATIONAL_num)
encode ROLLE_POL_INLAND_NATIONAL2, generate(ROLLE_POL_INLAND_NATIONAL2_num)

	* Manual conversion for religious multiperspectivalness b/c RELIGIONSZUGEHOERIGKEIT2 has one more cat than RELIGIONSZUGEHOERIGKEIT
generate RELIGIONSZUGEHOERIGKEIT_num = RELIGIONSZUGEHOERIGKEIT
generate RELIGIONSZUGEHOERIGKEIT2_num = RELIGIONSZUGEHOERIGKEIT2

foreach relcode of varlist RELIGIONSZUGEHOERIGKEIT_num RELIGIONSZUGEHOERIGKEIT2_num {
	replace `relcode' = "1" if `relcode' == ">Mainline<-Protestantisch"
	replace `relcode' = "2" if `relcode' == "Alevitisch"
	replace `relcode' = "3" if `relcode' == "Christlich (nicht spezifiziert)"
	replace `relcode' = "4" if `relcode' == "Evangelikal"
	replace `relcode' = "5" if `relcode' == "Evangelisch"
	replace `relcode' = "6" if `relcode' == "Explizit keine Religionszugehörigkeit, agnostisch, atheistisch"
	replace `relcode' = "7" if `relcode' == "Griechisch-/Antiochenisch-/Rum-orthodox"
	replace `relcode' = "8" if `relcode' == "Islamisch (nicht spezifiziert)"
	replace `relcode' = "9" if `relcode' == "Ismaelitisch"
	replace `relcode' = "10" if `relcode' == "Jüdisch"
	replace `relcode' = "11" if `relcode' == "Maronitisch"
	replace `relcode' = "12" if `relcode' == "Melkitisch griechisch-katholisch"
	replace `relcode' = "13" if `relcode' == "NA"
	replace `relcode' = "14" if `relcode' == "Religionszugehörigkeit nicht erkennbar"
	replace `relcode' = "15" if `relcode' == "Römisch-katholisch"
	replace `relcode' = "16" if `relcode' == "Schiitisch"
	replace `relcode' = "17" if `relcode' == "Sonstig christlich"
	replace `relcode' = "18" if `relcode' == "Sonstig evangelisch (Zeugen Jehovas, Mormonen/Latter-Day Saints)"
	replace `relcode' = "19" if `relcode' == "Sonstig islamisch"
	replace `relcode' = "20" if `relcode' == "Sonstige"
	replace `relcode' = "21" if `relcode' == "Sunnitisch"
}

destring RELIGIONSZUGEHOERIGKEIT_num RELIGIONSZUGEHOERIGKEIT2_num, replace

* civil society presence, citizen presence, expert presence
kappaetc ROLLE_ALLGEMEIN_num ROLLE_ALLGEMEIN2_num, wgt(identity) se(conditional) ///
	level(95) benchmark(probabilistic) showscale

* opposition speaker presence
kappaetc ROLLE_POL_INLAND_NATIONAL_num ROLLE_POL_INLAND_NATIONAL2_num, wgt(identity) ///
	se(conditional) level(95)	benchmark(probabilistic) showscale

* religious multiperspectivalness 
kappaetc RELIGIONSZUGEHOERIGKEIT_num RELIGIONSZUGEHOERIGKEIT2_num, wgt(identity) ///
	se(conditional) level(95) benchmark(probabilistic) showscale
	
clear all

*****Idea inclusiveness*****
import excel "Appendix - Repro Materials Reliability Content Analysis - Substance Vars.xlsx", sheet("texts_matched") cellrange(A1:F1700) firstrow

keep GEGENSAETZLICHEPOS GEGENSAETZLICHEPOS2

* Opposing positions 
kappaetc GEGENSAETZLICHEPOS GEGENSAETZLICHEPOS2, wgt(identity) se(conditional) level(95) ///
	benchmark(probabilistic) showscale

clear all

*****Justification quantity*****
/* Not available as this variable is based on unitization coding (justification pick-up) process, which was not included in final reliability testing procedures.*/

*****Justification quality*****
import excel "Appendix - Repro Materials Reliability Content Analysis - Substance Vars.xlsx", sheet("justifications_matched") cellrange(A1:O4868) firstrow

keep IN_GROUP ALLGEMEINWOHL OUT_GROUP IN_GROUP2 ALLGEMEINWOHL2 OUT_GROUP2

* Justification types (DQI)
/* NB: Need to recode data to match summary variable used for analyses reported in paper rather than individual DQI categories.*/

	* Individual indicator variables
kappaetc IN_GROUP IN_GROUP2, wgt(identity) se(conditional) level(95) ///
	benchmark(probabilistic) showscale

kappaetc OUT_GROUP OUT_GROUP2, wgt(identity) se(conditional) level(95) ///
	benchmark(probabilistic) showscale

kappaetc ALLGEMEINWOHL ALLGEMEINWOHL2, wgt(identity) se(conditional) level(95) ///
	benchmark(probabilistic) showscale

	* Summary index variable
generate just_dqi_ref = IN_GROUP
replace just_dqi_ref = 2 if OUT_GROUP == 1
replace just_dqi_ref = 3 if ALLGEMEINWOHL == 1

generate just_dqi_ref2 = IN_GROUP2
replace just_dqi_ref2 = 2 if OUT_GROUP2 == 1
replace just_dqi_ref2 = 3 if ALLGEMEINWOHL2 == 1

kappaetc just_dqi_ref just_dqi_ref2, wgt(ordinal) se(conditional) level(95) ///
	benchmark(probabilistic) showscale
	
clear all
exit