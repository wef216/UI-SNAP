


use "Processed\ASEC_REG.dta", clear


do "Scripts\Preamble-Controls.do"




*< < < Sample Definition > > > *

* Restrition on the Family per UI-taker UI amount
cap drop regcons
gen regcons =   (ui_finc_fcpi_ave >= actual_UI_AWB * 0.00001  & ui_finc_fcpi_ave < .)  & snap_val <= 24900 //24900 //24990

* Drop the ASEC Over-Sample Observations
*drop if cpsid == 0

global wgt   "[pw = asecwth]"





			
**********************************************************TABLE 1: IMPACT ON FOOD INSECURITY: ROBUSTNESS CHECKS ************************************************
/*
1. drop great receesion
2. probit
3. sample weight
4. log ui

*/

******************************** DROP GREAT RECESSION **********************
/* OUTCOME-1: dependent variable: at least one item positive in the 18 food insecurity scenario*/
local j snap_take
local labs1: variable label `j'

cap estimates clear
quietly reg `j' $ui  $controls $fes  $wgt if regcons == 1 & !inrange(year, 2009, 2011),  cluster(state)	
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m1

quietly reg `j' $ui  $controls  $fest  $wgt  if regcons == 1  & !inrange(year, 2009, 2011),  cluster(state)	
estimate store m2

/* OUTCOME-2:  depdendent variable: food insecurity score */
local j snap_val_fcpi_pos
local labs2: variable label `j'

quietly reg `j' $ui $controls  $fes  $wgt  if regcons == 1  & !inrange(year, 2009, 2011),  cluster(state)	
estimate store m3
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)

quietly reg `j' $ui $controls  $fest $wgt  if regcons == 1  & !inrange(year, 2009, 2011),  cluster(state)	
estimate store m4


esttab m1 m2 m3 m4, b p keep($ui) title(`"The Impact of UI on Household Food Stamp Take-up: Robustness Checks "') label  star(* 0.10 ** 0.05 *** 0.01)  varwidth(80)  ///
                        $indicators   ///
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) ///
                        mtitle("Binary" "" "Value" "")						

						
* output to excel or latex */	
if $export_option == 1{							 
#delimit ;
esttab m1 m2 m3 m4 using "Results\Mar_Robust_GR", 
			csv replace label  order($ui) kee( $ui) f  b(3)  se(3) nogaps
	        stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) 
			labels(`"Mean Dependent Variable"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) 
            $indicators   
			mgroups("Food Insecurity (Binary)" "Food Insecurity (Score)", pattern(1 0 0 0) )           
			title("Impact on UI on Food Stamp Take-up: Drop Geat Recession")  
			addnote("$notes1" "$notes2" "$notes3" "$notes4" "$notes5") 
			star(* 0.10 ** 0.05 *** 0.01) ;
#delimit cr 								
}						
						
					
					
					
					
					
					
					
					
					
					
					
******************************** LOG UI **********************
/* OUTCOME-1: dependent variable: at least one item positive in the 18 food insecurity scenario*/
local j snap_take
local labs1: variable label `j'

cap estimates clear
quietly reg `j' $lgui  $controls $fes  $wgt if regcons == 1,  cluster(state)	
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m1

quietly reg `j' $lgui  $controls  $fest  $wgt  if regcons == 1,  cluster(state)	
estimate store m2

/* OUTCOME-2:  depdendent variable: food insecurity score */
local j snap_val_fcpi_pos
local labs2: variable label `j'

quietly reg `j' $lgui $controls  $fes  $wgt  if regcons == 1,  cluster(state)	
estimate store m3
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)

quietly reg `j' $lgui $controls  $fest $wgt  if regcons == 1,  cluster(state)	
estimate store m4


esttab m1 m2 m3 m4, b p keep($lgui) title(`"The Impact of UI on Household Food Stamp Take-up: Robustness Checks "') label  star(* 0.10 ** 0.05 *** 0.01)  varwidth(80)  ///
                        $indicators   ///
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) ///
                        mtitle("Binary" "" "Value" "")						

						
* output to excel or latex */	
if $export_option == 1{							 
#delimit ;
esttab m1 m2 m3 m4 using "Results\Mar_Robust_LogUI", 
			csv replace label  order($lgui) kee( $lgui) f  b(3)  se(3) nogaps
	        stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) 
			labels(`"Mean Dependent Variable"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) 
            $indicators   
			mgroups("Food Insecurity (Binary)" "Food Insecurity (Score)", pattern(1 0 0 0) )           
			title("Impact on UI on Food Stamp Take-up: Drop Geat Recession")  
			addnote("$notes1" "$notes2" "$notes3" "$notes4" "$notes5") 
			star(* 0.10 ** 0.05 *** 0.01) ;
#delimit cr 								
}						







******************************** UI in Jan **********************
* Restrition on the Family per UI-taker UI amount
cap drop regcons
gen regcons =   (ui_finc_fcpi_ave >= actual_UI_AWB*0.00001   & ui_finc_fcpi_ave < .)  & snap_val <= 24900 //24900 //24990


/* OUTCOME-1: dependent variable: at least one item positive in the 18 food insecurity scenario*/
local j snap_take
local labs1: variable label `j'

cap estimates clear
quietly reg `j' $ui2  $controls $fes  $wgt if regcons == 1,  cluster(state)	
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m1

quietly reg `j' $ui2  $controls  $fest  $wgt  if regcons == 1,  cluster(state)	
estimate store m2

/* OUTCOME-2:  depdendent variable: food insecurity score */
local j snap_val_fcpi_pos
local labs2: variable label `j'

quietly reg `j' $ui2 $controls  $fes  $wgt  if regcons == 1,  cluster(state)	
estimate store m3
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)

quietly reg `j' $ui2 $controls  $fest $wgt  if regcons == 1,  cluster(state)	
estimate store m4


esttab m1 m2 m3 m4, b p keep($ui2) title(`"The Impact of UI on Household Food Stamp Take-up: Robustness Checks "') label  star(* 0.10 ** 0.05 *** 0.01)  varwidth(80)  ///
                        $indicators   ///
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) ///
                        mtitle("Binary" "" "Value" "")						

						
* output to excel or latex */	
if $export_option == 1{							 
#delimit ;
esttab m1 m2 m3 m4 using "Results\Mar_Robust_JanUI", 
			csv replace label  order($ui2) kee( $ui2) f  b(3)  se(3) nogaps
	        stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) 
			labels(`"Mean Dependent Variable"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) 
            $indicators   
			mgroups("Food Insecurity (Binary)" "Food Insecurity (Score)", pattern(1 0 0 0) )           
			title("Impact on UI on Food Insecurity: Drop Geat Recession")  
			addnote("$notes1" "$notes2" "$notes3" "$notes4" "$notes5") 
			star(* 0.10 ** 0.05 *** 0.01) ;
#delimit cr 								
}						















