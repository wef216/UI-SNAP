


/*-------------------------------------------------------------------------
*Impact of Food Security: Lag and Forward UI test
*Data: CPS Dec
---------------------------------------------------------------------------*/


use "Processed\REG.dta", clear


*<< IMPORT THE CONTROLS ANtata D SAMPLES CRITERIOR >>
do "Scripts\Preamble-Dec-Labels.do"
do "Scripts\Preamble-Controls.do"
do "Scripts\Preamble-Sample-Criteria.do"

global wgt   " [pw = fssuppwth] "
global ui_lf   uijul_cdep_fcpi    uijul_cdep_fcpi_l1 uijul_cdep_fcpi_l2  uijul_cdep_fcpi_f1    uijul_cdep_fcpi_f2  
global control_event $controls    F1_* L1_*  L2_*


// create the indicator for Unemployed HH
cap drop eligible
gen eligible = 1 if   hh_jobloser_dur52 > 0 & hh_jobloser_dur52 !=.  
replace eligible = 0 if    hh_unemp == 0

label var eligible  "UI Eligible"

do "Scripts\Preamble-Eligible-Interactions.do"




*<< MERGE THE UI AND STATE-LEVEL CHARACTERISTICS LAG AND FORWARD VALUES >>
cap drop _merge
merge m:1 state year using "Processed\UI_data_lead_forward.dta", force
drop _merge
merge m:1 state year using "Processed\State_data_lead_forward.dta", force



*<< REGRESSION ANALYSIS>>

/* OUTCOME-1: dependent variable: at least one item positive in the 18 food insecurity scenario */
local j fsrawscr_pos
local labs1: variable label `j'

cap estimates clear
quietly reg `j' $ui_lf  $control_event $fes  $wgt if eligible == 1 ,  cluster(state)	
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m1

quietly reg `j' $ui_lf  $control_event $fest  $wgt if eligible == 1 ,  cluster(state)	
estimate store m2


/* OUTCOME-2: depdendent variable: food insecurity score */
local j fsrasch_pos
local labs2: variable label `j'

quietly reg `j' $ui_lf  $control_event $fes  $wgt if eligible == 1,  cluster(state)	
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m3

quietly reg `j' $ui_lf  $control_event $fest $wgt if eligible == 1,  cluster(state)	
estimate store m4

esttab m1 m2 m3 m4 , b p keep($ui_lf) title(`"The Impact of UI on Food Insecurity Status "') label   star(* 0.10 ** 0.05 *** 0.01)  varwidth(30) ///
						$indicators ///
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) ///
                        mtitle("Binary"  ""  "Score"  "")            

/* output to excel or latex */				
if $export_option == 1{				 
#delimit ;
esttab m1 m2 m3 m4 using "Results\Dec_FoodInsecurity-Lag-Forward", 
			csv replace label  order($ui_lf) keep( $ui_lf) f  b(3)  se(3) nogaps
	        stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) 
			labels(`"Mean Dependent Variable"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) 
			$indicators 
			mgroups("Food Insecurity (Binary)", pattern(1 0 0 0) )           
			title("Impact of UI on Food Insecurity")  
			addnote("$notes1" "$notes2" "$notes3" "$notes4" "$notes5") 
			star(* 0.10 ** 0.05 *** 0.01) ;
#delimit cr 						   
}


						
