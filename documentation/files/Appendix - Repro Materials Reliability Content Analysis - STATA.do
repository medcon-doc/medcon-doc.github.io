***MedCon1 - Paper 2: Reliability Analyses***

/*

Author: Eike Mark Rinke (University of Leeds)
This Version: 1 Nov 2020

Note 1: Make sure to change working directory (using -cd- cmd) to folder containing	data before running code.

Note 2: List of required packages for code to run successfully:
	kappaetc from https://ideas.repec.org/c/boc/bocode/s458283.html

	
Analytical objective:

1. Calculate human-coder reliability for level of item and actor reference

*/

version 16
set more off
capture log close	
	
*cd [folder containing raw xlsx reliability data]

*****Item Level*****
import excel "ton_codes_marked&nachcod&numerisch.xlsx", sheet("ton_codes") cellrange(A1:J1701) firstrow

keep Ton_1 Ton_2 Ton_3 Ton_4

* tone (outrage) - coders 1 and 2 only
kappaetc Ton_1 Ton_2, wgt(identity) se(conditional) level(95) ///
	benchmark(probabilistic) showscale
	
* tone (outrage) - all coders
kappaetc Ton_*, wgt(identity) se(conditional) level(95) ///
	benchmark(probabilistic) showscale
	
clear all
	
*****Actor-Reference Level*****
import excel "actref_codes_matched_num.xlsx", sheet("actref_codes_matched_num") cellrange(A1:HQ3865) firstrow

keep VALENZ_AKTEUR_NUM_* ///
	ANERKENNUNG_AKTEUR_NUM_* ///
	HETZE_AKTEUR_NUM_* ///
	Q AG AW BM CC // first five placeholders vars for GENUINE-KONSTRUIERTE_RESP_AKTEUR_NUM_ (automatically renamed due to overly long varnames)

* Valence - coders 1 and 2 only
kappaetc VALENZ_AKTEUR_NUM_0 VALENZ_AKTEUR_NUM_1, wgt(identity) se(conditional) level(95) ///
	benchmark(probabilistic) showscale

* Valence - all coders
kappaetc VALENZ_AKTEUR_NUM_*, wgt(identity) se(conditional) level(95) ///
	benchmark(probabilistic) showscale

* Recognition - coders 1 and 2 only
kappaetc ANERKENNUNG_AKTEUR_NUM_0 ANERKENNUNG_AKTEUR_NUM_1, wgt(identity) se(conditional) level(95) ///
	benchmark(probabilistic) showscale

* Recognition - all coders
kappaetc ANERKENNUNG_AKTEUR_NUM_*, wgt(identity) se(conditional) level(95) ///
	benchmark(probabilistic) showscale

* Outrage - coders 1 and 2 only
kappaetc HETZE_AKTEUR_NUM_0 HETZE_AKTEUR_NUM_1, wgt(identity) se(conditional) level(95) ///
	benchmark(probabilistic) showscale

* Outrage - all coders
kappaetc HETZE_AKTEUR_NUM_*, wgt(identity) se(conditional) level(95) ///
	benchmark(probabilistic) showscale

* Responsiveness - coders 1 and 2 only
kappaetc Q AG, wgt(identity) se(conditional) level(95) ///
	benchmark(probabilistic) showscale	

* Responsiveness - all coders
kappaetc Q AG AW BM CC, wgt(identity) se(conditional) level(95) ///
	benchmark(probabilistic) showscale	

clear all
exit