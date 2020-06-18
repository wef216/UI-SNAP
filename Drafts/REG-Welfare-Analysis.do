




use "Processed\Mar_REG_Sample.dta", clear

keep if main_sample == 1

do "Scripts\Preamble-Controls.do"



/***** IMPACT OF MAXIMUM UI ON ACTUAL UI EXPENDITURE *****/
duplicates drop state year, force

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

esttab m*, b p keep($ui) title(`"The Impact of UI Expenditure"') label   star(* 0.10 ** 0.05 *** 0.01)   varwidth(50)  ///
                       	indicate("State Characteristics = unemploymentrate" "State Welfare Characteristics = snap_3p" "Year FE = *.year" "State FE = *.gestfips" "State Linear Trend = *.year_trend")  /// 
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) ///
						mtitle("Weekly UI" "" "Total UI" "")

						
/* output to excel or latex */						 
#delimit ;
esttab m1 m2 m3 m4 using "Results\Welfare_UI", 
			csv replace label  order($ui) keep( $ui $ui) f  b(3)  se(3)  nogaps
	        stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) 
			labels(`"Mean Dependent Variable"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) 
                       	indicate("State Characteristics = unemploymentrate" "State Welfare Characteristics = snap_3p" "Year FE = *.year" "State FE = *.gestfips" "State Linear Trend = *.year_trend")  /// 
			mgroups("Average Weekly UI Expenditure" "Total UI Expenditure", pattern(1 0 1 0) )           
			title("Impact on UI on Individual Actual UI Income & Family Income")  
			addnote("$notes1" "$notes2" "$notes3" "$notes4" "$notes5") 
			star(* 0.10 ** 0.05 *** 0.01) ;
#delimit cr 									




use "Processed\ASEC_REG.dta", clear
// UI Households
gen ui_take_hh = 1 if ui_hhtaker > 0 & ui_hhtaker < .
replace ui_take_hh = 0 if ui_hhtaker == 0

// SNAP among UI Households
gen snap_take_ui = 0 if ui_take_hh == 1
replace snap_take_ui = snap_take if  ui_take_hh == 1


preserve
*** UI, SNAP by year
collapse  (mean) ui_inc  (mean) ui_take_hh  (sum) ui_hh = ui_take_hh (sum) snap_val  (mean) snap_take (sum) snap_take_hh  = snap_take  (mean) snap_take_ui  (sum) snap_take_ui_hh = snap_take_ui  [iw = asecwth] , by( year)
export excel using "Results\UI_SNAP_Year.xlsx", replace firstrow(var)
restore


preserve
*** UI, SNAP by state year
collapse  (mean) ui_inc  (mean) ui_take_hh  (sum) ui_hh = ui_take_hh (sum) snap_val  (mean) snap_take (sum) snap_take_hh  = snap_take  (mean) snap_take_ui  (sum) snap_take_ui_hh = snap_take_ui  [iw = asecwth] , by(state year)
export excel using "Results\UI_SNAP_State_Year.xlsx", replace firstrow(var)
restore
