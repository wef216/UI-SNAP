
*****************Data Summary   ************************************************
/* Dependent Variable: Family Demographic Features
local m: word `k' of `outcomes'
local controls: list global(parentvar) - local(remove`k')

*/

						
version 14
set matsize 5000
set more off

global mode = 2

if $mode == 1{
// add new path for new device
global base "C:\Users\wef216\Dropbox\IPUMS-CPS"
global data "$base\data"
*global prog "$base\Code"
global output "$base\output"
global work "$base\work"

cd   "C:\Users\wef216\Dropbox\IPUMS-CPS"
}

if $mode == 2{
// add new path for new device
global base "C:\Users\fuwei\Dropbox\IPUMS-CPS"

cd   "C:\Users\fuwei\Dropbox\IPUMS-CPS\Analysis"
}



**********DATA SUMMARY: December Sample ************
use "Processed\Dec_REG_Sample.dta", clear
cap drop marital2
recode marst (1  = 1) (2 3 4 5 6 = 0), gen(marital2)

keep if main_sample == 1

do "Processed\Preamble-Dec-Labels.do"
do "Processed\Preamble-Controls.do"

recode sex (2 = 0)
recode fsstatus (1=0) (2 3= 1), gen(fs_insecurity)

 eststo DBSummary:  quietly estpost  sum  fsrawscr_pos  fsrasch_pos fs_insecurity $xvar
 
 
 esttab  DBSummary using "Results\T-Summary_Dec.csv", csv main(mean %9.3f)  aux(sd %9.3f)   replace numbers  nogaps wide ///
		 label title("Summary Statistics")   //

		 
		 
		 
		 

**********DATA SUMMARY: March Sample ************		 
use "Processed\Mar_REG_Sample.dta", clear

keep if main_sample == 1

do "Scripts\Preamble-Controls.do"
recode sex (2 = 0)

 eststo DBSummary:  quietly estpost  sum snap_take snap_val_fcpi_pos  ui_inc_fcpi inc_fcpi $xvar
 
 
 esttab  DBSummary using "Results\T-Summary_Mar.csv", csv main(mean %9.3f)  aux(sd %9.3f)   replace numbers  nogaps wide ///
		 label title("Summary Statistics")   //

		 
		 
		 
		 
		 
		 
		 
		 
		 
		 z
		 
		 
		 
**********UI INFORMATION BY STATE AND YEAR ************
use "$work\Dec_REG_Sample.dta", clear	

duplicates drop state year, force
keep uijul_fcpi uijul state year statelong	 
replace uijul_fcpi = uijul_fcpi * 100
replace uijul = uijul  * 100		 

keep if year >= 1999 & year <= 2016
reshape wide uijul_fcpi uijul, i(state) j(year)

preserve 
forvalues j = 1999/2016{
rename uijul_fcpi`j' Yr`j'
}
drop uijul*
export excel using "C:\Users\fuwei\Dropbox\IPUMS-CPS\output\UI-STATE-YEAR_CPI.xls", replace firstrow(variable)
restore

preserve 
forvalues j = 1999/2016{
rename uijul`j' Yr`j'
}
drop uijul*
export excel using "C:\Users\fuwei\Dropbox\IPUMS-CPS\output\UI-STATE-YEAR_NoCPI.xls", replace firstrow(variable)
restore


		 
