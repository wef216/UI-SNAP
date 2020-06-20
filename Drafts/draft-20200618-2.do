




use "Processed\ASEC_REG.dta", clear


*<< IMPORT THE CONTROLS AND SAMPLES CRITERIOR >>
do "Scripts\Preamble-Controls.do"
global wgt   "[pw = asecwth]"

// create the indicator for Unemployed HH
cap drop eligible
gen eligible = 0 if  ui_finc_fcpi_ave <= 0   &  snap_val <=24900
replace eligible = 0 if  ui_finc_fcpi_ave == .   &  snap_val <=24900
replace eligible = 1 if  ui_finc_fcpi_ave > 0 & ui_finc_fcpi_ave < . & snap_val <= 24900
// (ui_finc_fcpi_ave >=  actual_UI_AWB * 0.0001 & ui_finc_fcpi_ave < . ) & snap_val <= 24900   //& ui_finc_fcpi_ave <= uijul_fcpi * 10000 * alt_totwks


label var eligible  "UI Eligible"

do "Scripts\Preamble-Eligible-Interactions.do"



cap drop _merge
merge m:1 state year using "Processed\UI_data_lead_forward.dta", force
drop _merge
merge m:1 state year using "Processed\State_data_lead_forward.dta", force




*drop if inrange(year, 2008, 2011)

/* OUTCOME-1: dependent variable: at least one item positive in the 18 food insecurity scenario */
local j snap_take
local labs1: variable label `j'

cap estimates clear
quietly reg `j' $ui_lf  $controlss $fes  $wgt if eligible == 1 ,  cluster(state)	
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m1

quietly reg `j' $ui_lf  $controlss $fest  $wgt if eligible == 1 ,  cluster(state)	
estimate store m2


/* OUTCOME-2: depdendent variable: food insecurity score */
local j snap_val_fcpi_pos
local labs2: variable label `j'

quietly reg `j' $ui_lf  $controlss $fes  $wgt if eligible == 1,  cluster(state)	
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m3

quietly reg `j' $ui_lf  $controlss $fest $wgt if eligible == 1,  cluster(state)	
estimate store m4

esttab m1 m2 m3 m4 , b p keep($ui_lf) title(`"The Impact of UI on SNAP Takeup and Value "') label   star(* 0.10 ** 0.05 *** 0.01)  varwidth(30) ///
						$indicators ///
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) ///
                        mtitle("Binary"  ""  "Score"  "")            
