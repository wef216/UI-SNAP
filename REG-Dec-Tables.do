

use "Processed\REG.dta", clear

do "Scripts\Preamble-Dec-Labels.do"
do "Scripts\Preamble-Controls.do"


/*
*** sample definition ***
cap drop regcons
gen regcons =  hh_jobloserm_dur52 > 0 & hh_jobloserm_dur52!=. 
global sample_notes "Household has joblosers (less than 52 weeks) , should have prime-age workers (20-55)"
*/

// create the indicator for Unemployed HH
cap drop eligible
gen eligible = 1 if   hh_jobloserm_dur52 > 0 & hh_jobloserm_dur52 !=.  
replace eligible = 0 if    hh_unemp == 0

label var eligible  "UI Eligible"

foreach j of varlist $controls {
gen eligible_`j' = eligible * `j'
}

foreach j of varlist uiave_fcpi uijan_fcpi uijul_fcpi alt_totwks lguiave_fcpi lguijan_fcpi lguijul_fcpi ui_cdep uijul_cdep_fcpi uijan_cdep_fcpi uijul_dep_fcpi uijan_dep_fcpi {
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
label var ui_cdep_eligible   "UI including dependent * UI Eligible"
label var eligible  "UI Eligible"
label var ui_cdep "UI including the dependents"


*** DDD independent variables
global ui_ddd 	uijul_cdep_fcpi_eligible alt_totwks_eligible   uijul_cdep_fcpi alt_totwks   eligible  //ui_cdep_eligible  ui_cdep

global wgt   " [pw = fssuppwth] "



**********************************************************TABLE 1: IMPACT ON FOOD INSECURITY ************************************************
/* Dependent Variable: at least one item in the 18 food insecurity scenarios
		fsrawscr_pos: 1 when fsrawscr > 0 and 0 when fsrawscr == 0
*/
local j fsrawscr_pos
local labs: variable label `j'


cap estimates clear
/* ONLY CONTROL FOR HOUSEHOLD FEATURES */
quietly reg `j' $ui  $control0 $fes  $wgt if eligible == 1,  cluster(state)	   
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m1

/* CONTROL FOR HOUSEHOLD AND STATE FEATURES */
quietly reg `j' $ui  $control $fes $wgt if  eligible == 1,  cluster(state)	
estimate store m2

/* CONTROL FOR HOUSEHOLD, STATE AND WELFARE FEATURES */
quietly reg `j' $ui $controls $fes  $wgt  if eligible == 1,  cluster(state)	
estimate store m3

/* CONTROL FOR HOUSEHOLD, STATE AND WELFARE FEATURES, AND STATE TIME TREND */
quietly reg `j'  $ui $controls $fest  $wgt  if eligible  == 1,  cluster(state)	
estimate store m4

gen main_sample =  e(sample)

esttab m*, b p keep($ui) title(`"The Impact of UI on Household Food Insecurity Status"') label   star(* 0.10 ** 0.05 *** 0.01)   nomtitle varwidth(50)  ///
						$indicators ///
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) //

						
/* output to excel or latex */				
if $export_option == 1{				 
#delimit ;
esttab m1 m2 m3 m4 using "Results\Dec_FoodInsecurity", 
			csv replace label  order($ui) keep( $ui) f  b(3)  se(3) nogaps
	        stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) 
			labels(`"Mean Dependent Variable"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) 
			$indicators 
			mgroups("Food Insecurity (Binary)", pattern(1 0 0 0) )           
			title("Impact of UI on Food Insecurity")  
			addnote("$notes1" "$notes2" "$notes3" "$notes4" "$notes5") 
			star(* 0.10 ** 0.05 *** 0.01) ;
#delimit cr 						   
}

save "Processed/Dec_REG_Sample.dta", replace




**********************************************************TABLE 2: IMPACT ON FOOD INSECURITY SCORE ************************************************
/* Dependent Variable: Food insecurity score
		fsrasch_pos: the positive food insecurity rasch score
*/	
 
local j fsrasch_pos
local labs: variable label `j'

cap estimates clear
/* ONLY CONTROL FOR HOUSEHOLD FEATURES */
quietly reg `j' $ui  $control0 $fes  $wgt  if eligible == 1 & main_sample == 1,  cluster(state)	
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m1

/* CONTROL FOR HOUSEHOLD AND STATE FEATURES */
quietly reg `j' $ui  $control $fes  $wgt  if eligible == 1 & main_sample == 1,  cluster(state)	
estimate store m2

/* CONTROL FOR HOUSEHOLD, STATE AND WELFARE FEATURES */
quietly reg `j' $ui $controls $fes  $wgt  if eligible == 1 & main_sample == 1,  cluster(state)	
estimate store m3

/* CONTROL FOR HOUSEHOLD, STATE AND WELFARE FEATURES, AND STATE TIME TREND */
quietly reg `j' $ui $controls $fest $wgt  if eligible == 1 & main_sample == 1,  cluster(state)	
estimate store m4


esttab m*, b p keep($ui) title(`"The Impact of UI on Levels of Food Insecurity "') label   star(* 0.10 ** 0.05 *** 0.01)  nomtitle varwidth(50)  ///
						$indicators ///
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) //
	

/* output to excel or latex */			
if $export_option == 1{					 
#delimit ;
esttab m1 m2 m3 m4 using "Results\Dec_SecurityScore", 
			csv replace label  order($ui) kee( $ui) f  b(3)  se(3) nogaps
	        stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) 
			labels(`"Mean Dependent Variable"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) 
			$indicators 
			mgroups("Food Insecurity (Score)", pattern(1 0 0 0) )           
			title("Impact on UI on Food Insecurity")  
			addnote("$notes1" "$notes2" "$notes3" "$notes4" "$notes5") 
			star(* 0.10 ** 0.05 *** 0.01) ;
#delimit cr 		
}
	
	
	
	
	
	

	
	
	
	
	
**********************************************************TABLE 3: IMPACT ON FOOD INSECURITY SCORE ************************************************
/* Dependent Variable: Food Insecurity Status in the Literature
*/	

recode fsstatus (1=0) (2 3= 1), gen(fs_insecurity)
label var fs_insecurity "Food Insecurity Status in the Literature"
local j fs_insecurity 
local labs: variable label `j'

cap estimates clear
/* ONLY CONTROL FOR HOUSEHOLD FEATURES */
quietly reg `j' $ui  $control0 $fes  $wgt if eligible ==  1 & main_sample == 1,  cluster(state)	
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m1

/* CONTROL FOR HOUSEHOLD AND STATE FEATURES */
quietly reg `j' $ui  $control $fes $wg  if eligible == 1 & main_sample == 1,  cluster(state)	
estimate store m2

/* CONTROL FOR HOUSEHOLD, STATE AND WELFARE FEATURES */
quietly reg `j' $ui $controls $fes  $wgt  if eligible == 1 & main_sample == 1,  cluster(state)	
estimate store m3

/* CONTROL FOR HOUSEHOLD, STATE AND WELFARE FEATURES, AND STATE TIME TREND */
quietly reg `j' $ui $controls $fest  $wgt  if eligible == 1 & main_sample == 1,  cluster(state)	
estimate store m4


esttab m*, b p keep($ui) title(`"The Impact of UI on Household Food Insecurity Status"') label   star(* 0.10 ** 0.05 *** 0.01)   nomtitle varwidth(50)  ///
						$indicators ///
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) //


/* output to excel or latex */		
if $export_option == 1{						 
#delimit ;
esttab m1 m2 m3 m4 using "Results\Dec_Insecurity_Literature", 
			csv replace label  order($ui) kee( $ui) f  b(3) se(3)   nogaps
	        stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) 
			labels(`"Mean Dependent Variable"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) 
			$indicators 
			mgroups("Food Insecurity (Binary)", pattern(1 0 0 0) )           
			title("Impact on UI on Food Insecurity (Literature Definition)")  
			addnote("$notes1" "$notes2" "$notes3" "$notes4" "$notes5") 
			star(* 0.10 ** 0.05 *** 0.01) ;
#delimit cr 								
}				
						
						
						
						
						
						
						
						
						
**********************************************************TABLE 4: IMPACT ON FOOD INSECURITY: PLACEBO TEST ************************************************
/*
To test the impact of UI on the food insecurity of the UI-Ineligible household,  we define the household as UI-Ineligible if there are no unemployed household members in the household. 

*/


/* OUTCOME-1: dependent variable: at least one item positive in the 18 food insecurity scenario*/
local j fsrawscr_pos
local labs1: variable label `j'

cap estimates clear
quietly reg `j' $ui  $controls $fes  $wgt if eligible == 0,  cluster(state)	
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m1

quietly reg `j' $ui  $controls  $fest  $wgt  if eligible ==  0,  cluster(state)	
estimate store m2

/* OUTCOME-2:  depdendent variable: food insecurity score */
local j fsrasch_pos
local labs2: variable label `j'

quietly reg `j' $ui $controls  $fes  $wgt  if eligible == 0,  cluster(state)	
estimate store m3
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)

quietly reg `j' $ui $controls  $fest $wgt  if eligible == 0,  cluster(state)	
estimate store m4


esttab m1 m2 m3 m4, b p keep($ui) title(`"The Impact of UI on Household Food Insecurity "') label  star(* 0.10 ** 0.05 *** 0.01)  varwidth(80)  ///
						$indicators ///
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) ///
                        mtitle("Binary" "" "Score" "")						

				
/* output to excel or latex */			
if $export_option == 1{					 
#delimit ;
esttab m1 m2 m3 m4 using "Results\Dec_Placebo", 
			csv replace label  order($ui) kee( $ui) f  b(3)  se(3)  nogaps
	        stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) 
			labels(`"Mean Dependent Variable"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) 
			$indicators 
			mgroups("Food Insecurity (Binary)" "Food Insecurity (Score)", pattern(1 0 0 0) )           
			title("Impact on UI on Food Insecurity: Placebo Test")  
			addnote("$notes1" "$notes2" "$notes3" "$notes4" "$notes5") 
			star(* 0.10 ** 0.05 *** 0.01) ;
#delimit cr 								
}					
						
						
	
						
						
						

**********************************************************TABLE 5: IMPACT ON FOOD INSECURITY: DDD ESTIMATION ************************************************

/* OUTCOME-1: dependent variable: at least one item positive in the 18 food insecurity scenario */
local j fsrawscr_pos
local labs1: variable label `j'

cap estimates clear
quietly reg `j' $ui_ddd  $controls eligible_*  i.gestfips##i.eligible  i.year##i.eligible  $wgt ,  cluster(state)	
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m1

quietly reg `j' $ui_ddd  $controls eligible_*  i.gestfips##i.eligible  i.year##i.eligible i.eligible##i.gestfips##c.year $wgt ,  cluster(state)	
estimate store m2


/* OUTCOME-2: depdendent variable: food insecurity score */
local j fsrasch_pos
local labs2: variable label `j'

quietly reg `j' $ui_ddd  $controls eligible_* i.gestfips##i.eligible  i.year##i.eligible $wgt ,  cluster(state)	
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m3

quietly reg `j' $ui_ddd  $controls eligible_*  i.gestfips##i.eligible  i.year##i.eligible i.eligible##i.gestfips##c.year $wgt,  cluster(state)	
estimate store m4

esttab m1 m2 m3 m4 , b p keep($ui_ddd) title(`"The Impact of UI on Food Insecurity Status "') label   star(* 0.10 ** 0.05 *** 0.01)  varwidth(30) ///
						$indicatorsddd ///
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) ///
                        mtitle("Binary" "" "" ""  "Score" "" "" "")            


						
						
/* output to excel or latex */		
if $export_option == 1{						 
#delimit ;
esttab m1 m2 m3 m4 using "Results\Dec_DDD", 
			csv replace label  order($ui_ddd ) kee($ui_ddd ) f  b(3)  se(3) nogaps
	        stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) 
			labels(`"Mean Dependent Variable"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) 
			$indicatorsddd 
			mgroups("Food Insecurity (Binary)" "Food Insecurity (Score)", pattern(1 0 0 0 1 0 0 0 ) )           
			title("Impact on UI on Food Insecurity: Triple Differene")  
			addnote("$notes1" "$notes2" "$notes3" "$notes4" "$notes5") 
			star(* 0.10 ** 0.05 *** 0.01) ;
#delimit cr 								
}					

			
			
			
			
			
			
			
			
	
	
	
	
	
**********************************************************TABLE 6: IMPACT ON INCOME ************************************************
/*
Family Income
*/					
		
cap estimates clear
/* CONTROL FOR HOUSEHOLD, STATE AND WELFARE FEATURES */
quietly reg inc_fcpi $ui  $control0 $fes  $wgt  if eligible == 1,  cluster(state)	
quietly su inc_fcpi  if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m1

/* CONTROL FOR HOUSEHOLD, STATE AND WELFARE FEATURES, AND STATE TIME TREND */
quietly reg inc_fcpi $ui  $control $fes $wgt if eligible ==  1,  cluster(state)	
estimate store m2

/* CONTROL FOR HOUSEHOLD, STATE AND WELFARE FEATURES */
quietly reg inc_fcpi  $ui $controls $fes  $wgt  if eligible == 1,  cluster(state)	    //inc_fcpi
quietly su inc if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m3

/* CONTROL FOR HOUSEHOLD, STATE AND WELFARE FEATURES, AND STATE TIME TREND */
quietly reg inc_fcpi  $ui $controls $fest  $wgt if eligible ==  1,  cluster(state)	
estimate store m4

esttab m*, b p keep($ui) title(`"The Impact of UI on Family Income"') label   star(* 0.10 ** 0.05 *** 0.01)   varwidth(50)  ///
						$indicators ///
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) ///
						mtitle("Family Income" "" "" "")

						
/* output to excel or latex */		
if $export_option == 1{						 
#delimit ;
esttab m1 m2 m3 m4 using "Results\Dec_Income", 
			csv replace label  order($ui) keep( $ui $ui) f  b(3)  se(3)  nogaps
	        stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) 
			labels(`"Mean Dependent Variable"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) 
		    $indicators 
			mgroups("Individual UI Income" "Family Income", pattern(1 0 1 0) )           
			title("Impact on UI on Individual Actual UI Income & Family Income")  
			addnote("$notes1" "$notes2" "$notes3" "$notes4" "$notes5") 
			star(* 0.10 ** 0.05 *** 0.01) ;
#delimit cr 									
}

			
			
			
			
			
			
			
			
			
			
			
			
			
			
	

	
	












								
								
								
								
