

*************************************************************
* Collapse the Actual UI Benefit Data
*************************************************************

use "Data\actual_ui_1995_2017.dta", clear
drop if FY_Year == 1995
collapse (sum) actual_UI (mean) actual_UI_AWB, by(state FY_Year)
keep if FY_Year >= 1999 & FY_Year <=2018

merge m:1 state using "Data\statetrans.dta", force
drop if _merge == 1
drop _merge

rename FY_Year year

save "Processed/actual_ui_1995_2017.dta", replace
