




use "Processed\REG.dta", clear


*<< IMPORT THE CONTROLS ANtata D SAMPLES CRITERIOR >>
do "Scripts\Preamble-Dec-Labels.do"
do "Scripts\Preamble-Controls.do"

global wgt   " [pw = fssuppwth] "


global ui_lf   uijul_cdep_fcpi    uijul_cdep_fcpi_l1 uijul_cdep_fcpi_l2  uijul_cdep_fcpi_f1    uijul_cdep_fcpi_f2  

global controlss $controls    F1_* L1_*  //marginallyfoodinsecure  c.unemploymentrate##c.year  c.union_mem##c.year  c.gdpp_state##c.year  c.povertyrate##c.year


// create the indicator for Unemployed HH
cap drop eligible
gen eligible = 1 if   hh_jobloser_dur52 > 0 & hh_jobloser_dur52 !=.  
replace eligible = 0 if    hh_unemp == 0

label var eligible  "UI Eligible"

do "Scripts\Preamble-Eligible-Interactions.do"



cap drop _merge
merge m:1 state year using "Processed\UI_data_lead_forward.dta", force
drop _merge
merge m:1 state year using "Processed\State_data_lead_forward.dta", force

*global ui_lf   uijul_cdep_fcpi   uijul_cdep_fcpi_f1   uijul_cdep_fcpi_f2    uijul_cdep_fcpi_l1  uijul_cdep_fcpi_l2    alt_totwks perchild  uijul_cdep_fcpi_l3  //uijul_cdep_fcpi_f3


/* OUTCOME-1: dependent variable: at least one item positive in the 18 food insecurity scenario */
local j fsrawscr_pos
local labs1: variable label `j'

cap estimates clear
quietly reg `j' $ui_lf  $controlss $fes  $wgt if eligible == 1 ,  cluster(state)	
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m1

quietly reg `j' $ui_lf  $controlss $fest  $wgt if eligible == 1 ,  cluster(state)	
estimate store m2


/* OUTCOME-2: depdendent variable: food insecurity score */
local j fsrasch_pos
local labs2: variable label `j'

quietly reg `j' $ui_lf  $controlss $fes  $wgt if eligible == 1,  cluster(state)	
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m3

quietly reg `j' $ui_lf  $controlss $fest $wgt if eligible == 1,  cluster(state)	
estimate store m4

esttab m1 m2 m3 m4 , b p keep($ui_lf) title(`"The Impact of UI on Food Insecurity Status "') label   star(* 0.10 ** 0.05 *** 0.01)  varwidth(30) ///
						$indicators ///
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) ///
                        mtitle("Binary"  ""  "Score"  "")            
