
*****************Data Summary   ************************************************
/* Dependent Variable: Family Demographic Features
local m: word `k' of `outcomes'
local controls: list global(parentvar) - local(remove`k')

*/




**********DATA SUMMARY: December Sample ************
use "Processed\REG.dta", clear

*<< IMPORT THE CONTROLS AND SAMPLES CRITERIOR >>
do "Scripts\Preamble-Dec-Labels.do"
do "Scripts\Preamble-Controls.do"
do "Scripts\Preamble-Sample-Criteria.do"


global wgt   " [pw = fssuppwth] "
global indicatorsb `" indicate("State-Level Welfare Policies = snap_2p" "State-Level Economic Attributes = unemploymentrate" "Household Characteristics =  age"  "Year FE = *.year" "State FE = *.gestfips")   "'
 

// create the indicator for Unemployed HH
cap drop eligible
gen eligible = 1 if   hh_jobloser_dur52 > 0 & hh_jobloser_dur52 !=.  
replace eligible = 0 if    hh_unemp == 0

label var eligible  "UI Eligible"

do "Scripts\Preamble-Eligible-Interactions.do"


reg fsrawscr_pos  $ui $controls $fest  $wgt  if eligible  == 1,  cluster(state)	
keep if e(sample) == 1


recode sex (2 = 0)
recode fsstatus (1=0) (2 3= 1), gen(fs_insecurity)

 eststo DBSummary:  quietly estpost  sum  fsrawscr_pos  fsrasch_pos fs_insecurity $xvar
 
 esttab  DBSummary using "Results\T-Summary_Dec.csv", csv main(mean %9.3f)  aux(sd %9.3f)   replace numbers  nogaps wide ///
		 label title("Summary Statistics")   //

		 
		 
		 
		 

**********DATA SUMMARY: March Sample ************		 
use "Processed\ASEC_REG.dta", clear


*<< IMPORT THE CONTROLS AND SAMPLES CRITERIOR >>
do "Scripts\Preamble-Controls.do"
do "Scripts\Preamble-Sample-Criteria.do"

global wgt   "[pw = asecwth]"

// create the indicator for Unemployed HH
cap drop eligible
gen eligible = 0 if  ui_finc_fcpi_ave <= 0   &  snap_val <=24900
replace eligible = 0 if  ui_finc_fcpi_ave == .   &  snap_val <=24900
replace eligible = 1 if  ui_finc_fcpi_ave > 0 & ui_finc_fcpi_ave < . & snap_val <= 24900


label var eligible  "UI Eligible"

do "Scripts\Preamble-Eligible-Interactions.do"


quietly reg snap_take $ui  $controls $fest $wgt   if eligible == 1,  cluster(state)	
keep if e(sample) == 1


recode sex (2 = 0)

 eststo DBSummary:  quietly estpost  sum snap_take snap_val_fcpi_pos  ui_inc_fcpi inc_fcpi $xvar
 
 
 esttab  DBSummary using "Results\T-Summary_Mar.csv", csv main(mean %9.3f)  aux(sd %9.3f)   replace numbers  nogaps wide ///
		 label title("Summary Statistics")   //

		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
**********UI INFORMATION BY STATE AND YEAR ************
use "Processed\REG.dta", clear	

duplicates drop state year, force
keep uijul_cdep_fcpi uijul_cdep state year statelong	 
replace uijul_cdep_fcpi = uijul_cdep_fcpi * 100
gen uijul_cdep_nofcpi = uijul_cdep 	 

keep if year >= 1999 & year <= 2017

reshape wide uijul_cdep_fcpi uijul_cdep_nofcpi , i(state) j(year)

preserve 

forvalues j = 1999/2017{
rename uijul_cdep_fcpi`j' Yr`j'
}
drop uijul*
export excel using "Results\UI-STATE-YEAR_CPI.xls", replace firstrow(variable)
restore



		 
