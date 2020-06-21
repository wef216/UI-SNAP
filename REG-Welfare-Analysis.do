




/*-------------------------------------------------------------------------
*Impact of Food Security -- Welfare Analysis
*Data: CPS Mar

---------------------------------------------------------------------------*/




*use "Processed\Mar_REG_Sample.dta", clear
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
// (ui_finc_fcpi_ave >=  actual_UI_AWB * 0.0001 & ui_finc_fcpi_ave < . ) & snap_val <= 24900   //& ui_finc_fcpi_ave <= uijul_fcpi * 10000 * alt_totwks


label var eligible  "UI Eligible"

do "Scripts\Preamble-Eligible-Interactions.do"

global  indicatorswel `"indicate("State Characteristics = unemploymentrate" "State Welfare Characteristics = snap_2p" "Year FE = *.year" "State FE = *.gestfips" "State Linear Trend = *.year_trend")"'  /// 


quietly reg snap_take $ui  $controls $fest $wgt   if eligible == 1,  cluster(state)	
keep if e(sample) == 1







/***** IMPACT OF MAXIMUM UI ON ACTUAL UI EXPENDITURE *****/
duplicates drop state year, force

cap est clea
*** Average Actual weekly UI
reg actual_UI_AWB $ui $zvar1 $zvar2 $fes, cluster(state)
su actual_UI_AWB if e(sample) == 1
estadd scalar outcome_mean = r(mean)
eststo m1

reg actual_UI_AWB $ui $zvar1 $zvar2 $fest, cluster(state)
eststo m2

***  Total Actual UI
reg actual_UI  $ui $zvar1 $zvar2 $fes, cluster(state)
su actual_UI if e(sample) == 1
estadd scalar outcome_mean = r(mean)
eststo m3

reg actual_UI  $ui $zvar1 $zvar2 $fest, cluster(state)
eststo m4

esttab m1 m2 m3 m4, b p keep($ui) title(`"The Impact of UI Expenditure"') label   star(* 0.10 ** 0.05 *** 0.01)   varwidth(50)  ///
                       	$indicatorswel  /// 
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) ///
						mtitle("Weekly UI" "" "Total UI" "")

						
/* output to excel or latex */						 
#delimit ;
esttab m1 m2 m3 m4 using "Results\Welfare_UI", 
			csv replace label  order($ui) keep( $ui) f  b(3)  se(3)  nogaps
	        stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) 
			labels(`"Mean Dependent Variable"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) 
			$indicatorswel
			mgroups("Average Weekly UI Expenditure" "Total UI Expenditure", pattern(1 0 1 0) )           
			title("Impact on UI on Individual Actual UI Income & Family Income")  
			addnote("$notes1" "$notes2" "$notes3" "$notes4" "$notes5") 
			star(* 0.10 ** 0.05 *** 0.01) ;
#delimit cr 									










* << CPS March UI & SNAP By state and year >>

use "Processed\ASEC_REG.dta", clear
// UI Households
gen ui_take_hh = 1 if ui_hhtaker > 0 & ui_hhtaker < .
replace ui_take_hh = 0 if ui_hhtaker == 0

// SNAP among UI Households
gen snap_take_ui = 0 if ui_take_hh == 1
replace snap_take_ui = snap_take if  ui_take_hh == 1


preserve
*** UI, SNAP by year
replace ui_inc = . if ui_inc <= 0
collapse  (mean) ui_inc  (mean) ui_take_hh  (sum) ui_hh = ui_take_hh (sum) snap_val  (mean) snap_take (sum) snap_take_hh  = snap_take  (mean) snap_take_ui  (sum) snap_take_ui_hh = snap_take_ui  [iw = asecwth] , by( year)
export excel using "Results\UI_SNAP_Year.xlsx", replace firstrow(var)
restore


preserve
*** UI, SNAP by state year
replace ui_inc = . if ui_inc <= 0
collapse  (mean) ui_inc  (mean) ui_take_hh  (sum) ui_hh = ui_take_hh (sum) snap_val  (mean) snap_take (sum) snap_take_hh  = snap_take  (mean) snap_take_ui  (sum) snap_take_ui_hh = snap_take_ui  [iw = asecwth] , by(state year)
export excel using "Results\UI_SNAP_State_Year.xlsx", replace firstrow(var)
restore




