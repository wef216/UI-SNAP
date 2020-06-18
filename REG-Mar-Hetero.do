

use "Processed\ASEC_REG.dta", clear


do "Scripts\Preamble-Controls.do"




*< < < Sample Definition > > > *

* Restrition on the Family per UI-taker UI amount
cap drop regcons
gen regcons =   (ui_finc_fcpi_ave >= actual_UI_AWB   & ui_finc_fcpi_ave <= uijul_fcpi * 1000 * alt_totwks)  & snap_val <= 24900 //24900 //24990

* Drop the ASEC Over-Sample Observations
*drop if cpsid == 0

global wgt   "[pw = asecwth]"





// create the indicator for Unemployed HH

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


foreach j of varlist $controls{
cap drop eligible_`j'
gen eligible_`j' = eligible * `j'
}

foreach j of varlist uiave_fcpi uijan_fcpi uijul_fcpi alt_totwks lguiave_fcpi lguijan_fcpi lguijul_fcpi{
cap drop `j'_eligible
gen `j'_eligible = eligible * `j'
}

label var uijul_fcpi "Jul UI "
label var lguijul_fcpi "Log Jul UI "
label var uiave_fcpi_eligible  "Ave. UI (Jan  $\&$ Jul) * UI Eligible"
label var uijan_fcpi_eligible  "Jan. UI * UI Eligible"
label var uijul_fcpi_eligible  "Jul. UI * UI Eligible"
label var lguiave_fcpi_eligible  "Log Ave. UI (Jan  $\&$ Jul) * UI Eligible"
label var lguijan_fcpi_eligible  "Log Jan. UI * UI Eligible"
label var lguijul_fcpi_eligible  "Log Jul. UI * UI Eligible"
label var alt_totwks_eligible   "UI Max Duration * UI Eligible"
label var eligible  "UI Eligible"




**********************************************************TABLE 3: DDD IDENTIFICATION ************************************************
*** DDD independent variables
global ui_ddd 	uijul_fcpi_eligible alt_totwks_eligible  uijul_fcpi  alt_totwks  eligible
global lgui_ddd lguijul_fcpi uijul_fcpi_eligible alt_totwks_eligible   eligible  alt_totwks

global recession //"& !inrange(year, 2009, 2010)"


*** impact on food stamp take up
cap est clear
quietly reg snap_take $ui_ddd  $controls eligible_*  i.gestfips##i.eligible  i.year##i.eligible  $wgt if regcons == 1 $recession, cluster(state)	
quietly su snap_take  if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m1

quietly reg snap_take  $ui_ddd  $controls eligible_*  i.gestfips##i.eligible  i.year##i.eligible   i.eligible##i.gestfips##c.year $wgt  if regcons  == 1 $recession, cluster(state)	
estimate store m2

*** impact on food stamp value
quietly reg snap_val_fcpi_pos $ui_ddd  $controls eligible_*  i.gestfips##i.eligible  i.year##i.eligible   $wgt if regcons  == 1 $recession, cluster(state)	
quietly su snap_val_fcpi  if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m3


quietly reg snap_val_fcpi_pos $ui_ddd  $controls eligible_*  i.gestfips##i.eligible  i.year##i.eligible  i.eligible##i.gestfips##c.year  $wgt  if regcons  == 1 $recession,  cluster(state)	
estimate store m4

esttab m*, b p keep($ui_ddd ) order(uijul_fcpi lguijul_fcpi alt_totwks) title(`"The Impact of UI on STAMP Takeup and Value "') label   star(* 0.10 ** 0.05 *** 0.01)  varwidth(30) ///
                     	indicate("Household Characteristics =  age" "State Characteristics = unemploymentrate" "State Welfare Characteristics = snap_3p" "Year FE = *.year" "State FE = *.gestfips" )  /// 
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) ///
						mtitle("Takeup" "" "Value " "")
						
						
					
/* output to excel or latex */
if $export_option == 1{								 
#delimit ;
esttab m1 m2 m3 m4 m5 m6 m7 m8 using "Results\Mar_Hetero_DDD", 
			csv replace label  order($ui_ddd) keep( $ui_ddd) f  b(3)  se(3) nogaps
	        stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) 
			labels(`"Mean Dependent Variable"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) 
            indicate("State-Level Welfare Policies = snap_3p" "State-Level Economic Attributes = unemploymentrate" "Household Characteristics =  age"  "Year FE = *.year" "State FE = *.gestfips"）  
			mgroups("Individual UI Income", pattern(1 0 0 0) )           
			title("Impact on UI on Food Stamp Takeup and Value: DDD")  
			addnote("$notes1" "$notes2" "$notes3" "$notes4" "$notes5") 
			star(* 0.10 ** 0.05 *** 0.01) ;
#delimit cr 									
}	
					
