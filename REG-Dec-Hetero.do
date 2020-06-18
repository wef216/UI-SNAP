
use "Processed\REG.dta", clear

do "Scripts\Preamble-Dec-Labels.do"
do "Scripts\Preamble-Controls.do"

global wgt   " [pw = fssuppwth] "


*** sample definition ***
cap drop regcons
gen regcons =  hh_jobloserm_dur52 > 0 & hh_jobloserm_dur52!=. 
global sample_notes "Household has joblosers (less than 52 weeks) , should have prime-age workers (20-55)"

su unemploymentrate,de
gen eligible = 1 if unemploymentrate >= r(p50)
replace eligible = 0 if unemploymentrate < r(p50)

*gen eligible = 1 if hh_edu_hs_pr + hh_edu_mhs_pr <= 0.5 
*replace eligible = 0 if hh_edu_hs_pr + hh_edu_mhs_pr > 0.5 
*gen eligible = (hh_edu_mhs_pr == 1)
*gen eligible = hh_edu_mhs_pr

*gen eligible = (hh_white_r >= 0.5)

*gen eligible = marital2

*su inc_fcpi,de
*gen eligible = (inc_fcpi >= r(p50))

foreach j of varlist $controls {
gen eligible_`j' = eligible * `j'
}

foreach j of varlist uiave_fcpi uijan_fcpi uijul_fcpi alt_totwks lguiave_fcpi lguijan_fcpi lguijul_fcpi{
gen `j'_eligible = eligible * `j'
}

label var uijul_fcpi "Jul UI "
label var lguijul_fcpi "Log Jul UI "
label var uiave_fcpi_eligible  "Ave. UI (Jan  $\&$ Jul) * UI Eligible"
label var uijan_fcpi_eligible  "Jan. UI  $\times$ UI Eligible"
label var uijul_fcpi_eligible  "Jul. UI  $\times$ UI Eligible"
label var lguiave_fcpi_eligible  "Log Ave. UI (Jan  $\&$ Jul) * UI Eligible"
label var lguijan_fcpi_eligible  "Log Jan. UI * UI Eligible"
label var lguijul_fcpi_eligible  "Log Jul. UI * UI Eligible"
label var alt_totwks_eligible   "UI Max Duration $\times$ UI Eligible"
label var eligible  "UI Eligible"



*** DDD independent variables
global ui_ddd 	uijul_fcpi_eligible alt_totwks_eligible  uijul_fcpi alt_totwks eligible 


/* OUTCOME-1: dependent variable: at least one item positive in the 18 food insecurity scenario */
local j fsrawscr_pos
local labs1: variable label `j'

cap estimates clear
quietly reg `j' $ui_ddd  $controls eligible_*  i.gestfips##i.eligible  i.year##i.eligible  $wgt  if regcons == 1,  cluster(state)	
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m1

quietly reg `j' $ui_ddd  $controls eligible_*  i.gestfips##i.eligible  i.year##i.eligible i.eligible##i.gestfips##c.year $wgt  if regcons == 1,  cluster(state)	
estimate store m2


/* OUTCOME-2: depdendent variable: food insecurity score */
local j fsrasch_pos
local labs2: variable label `j'

quietly reg `j' $ui_ddd  $controls eligible_* i.gestfips##i.eligible  i.year##i.eligible $wgt if regcons == 1,  cluster(state)	
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m3

quietly reg `j' $ui_ddd  $controls eligible_*  i.gestfips##i.eligible  i.year##i.eligible i.eligible##i.gestfips##c.year $wgt  if regcons == 1,  cluster(state)	
estimate store m4

esttab m1  m2  m3 m4, b p keep($ui_ddd) title(`"The Impact of UI on Food Insecurity Status "') label   star(* 0.10 ** 0.05 *** 0.01)  varwidth(30) ///
                       	indicate("Household Characteristics =  age" "State Characteristics = unemploymentrate" "State Welfare Characteristics = snap_3p" "Year FE = *.year" "State FE = *.gestfips")  /// 
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) ///
                        mtitle("Binary" ""  "Score" "" )            


						
						
/* output to excel or latex */		
if $export_option == 1{						 
#delimit ;
esttab m1 m2 m3 m4 using "Results\Dec_Hetero_DDD", 
			csv replace label  order($ui_ddd ) kee($ui_ddd ) f  b(3)  se(3) nogaps
	        stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) 
			labels(`"Mean Dependent Variable"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) 
            indicate("State-Level Welfare Policies = snap_3p" "State-Level Economic Attributes = unemploymentrate" "Household Characteristics =  age"  "Year FE = *.year" "State FE = *.gestfips" "State Linear Trend = *.year_trend")  
			mgroups("Food Insecurity (Binary)" "Food Insecurity (Score)", pattern(1 0 0 0 1 0 0 0 ) )           
			title("Impact on UI on Food Insecurity: Triple Differene")  
			addnote("$notes1" "$notes2" "$notes3" "$notes4" "$notes5") 
			star(* 0.10 ** 0.05 *** 0.01) ;
#delimit cr 								
}					

			
			
			
			
