



use "Processed\ASEC_REG.dta", clear


do "Scripts\Preamble-Controls.do"



*< < < Sample Definition > > > *
// create the indicator for Unemployed HH
cap drop eligible
gen eligible = 0 if  ui_finc_fcpi_ave <= 0   & snap_val <=24900
replace eligible = 1 if  (ui_finc_fcpi_ave >=  actual_UI_AWB * 0.0001 & ui_finc_fcpi_ave < . ) & snap_val <= 24900   //& ui_finc_fcpi_ave <= uijul_fcpi * 10000 * alt_totwks


foreach j of varlist $controls{
cap drop eligible_`j'
gen eligible_`j' = eligible * `j'
}

foreach j of varlist uiave_fcpi uijan_fcpi uijul_fcpi alt_totwks lguiave_fcpi lguijan_fcpi lguijul_fcpi ui_cdep uijul_cdep_fcpi uijan_cdep_fcpi uijul_dep_fcpi uijan_dep_fcpi {
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
label var ui_cdep_eligible   "UI including dependent * UI Eligible"
label var eligible  "UI Eligible"
label var ui_cdep "UI including the dependents"


*** DDD independent variables
global ui_ddd 	uijul_cdep_fcpi_eligible alt_totwks_eligible  uijul_cdep_fcpi alt_totwks   eligible  //ui_cdep  ui_cdep_eligible

global wgt   "[pw = asecwth]"





**********************************************************TABLE 1: IMPACT ON FOOD STAMP TAKEUP ************************************************
/* Dependent Variable: Dummies of STAMP Take-Up status

*/

cap est clear
/* ONLY CONTROL FOR HOUSEHOLD FEATURES */
quietly reg snap_take $ui $control0 $fes $wgt if eligible == 1,  cluster(state)	
quietly su snap_take  if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
eststo m1

/* CONTROL FOR HOUSEHOLD AND STATE FEATURES */
quietly reg snap_take $ui  $control $fes $wgt   if eligible == 1,  cluster(state)	
eststo m2

/* CONTROL FOR HOUSEHOLD, STATE AND WELFARE FEATURES */
quietly reg snap_take $ui $controls $fes $wgt if eligible == 1,  cluster(state)	
eststo m3

/* CONTROL FOR HOUSEHOLD, STATE AND WELFARE FEATURES, AND STATE TIME TREND */
quietly reg snap_take $ui  $controls $fest $wgt   if eligible == 1,  cluster(state)	
eststo m4

gen main_sample = e(sample)


esttab m1 m2 m3 m4, b p keep($ui) order(uiave_fcpi lguiave_fcpi alt_totwks) title(`"The Impact of UI on STAMP Takeup Status"') label   star(* 0.10 ** 0.05 *** 0.01)  varwidth(20) ///
                        $indicators   ///
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) ///
						mtitle("Takeup" "" "" "" " " "" "" "")

					
/* output to excel or latex */			
if $export_option == 1{			 
#delimit ;
esttab m1 m2 m3 m4 using "Results\Mar_SNAP_Takeup", 
			csv replace label  order($ui) keep( $ui) f  b(3)  se(3)  nogaps
		    $indicators	
	        stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) 
			labels(`"Mean Dependent Variable"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) 
			mgroups("Food Stamp Takeup", pattern(1 0 0 0) )           
			title("Impact on UI on Food Stamp Takeup")  
			addnote("$notes1" "$notes2" "$notes3" "$notes4" "$notes5") 
			star(* 0.10 ** 0.05 *** 0.01) ;
#delimit cr 				
}


						

*save "Processed/Mar_REG_Sample.dta", replace									
						

**********************************************************TABLE 2: IMPACT ON FOOD STAMP MARKET VALUE ************************************************
/* Dependent Variable: SNAP MARKET VALUE CONDITIONAL ON TAKING THE STAMP

*/

cap est clear
/* ONLY CONTROL FOR HOUSEHOLD FEATURES */
quietly reg snap_val_fcpi_pos $ui $control0 $fes  $wgt if eligible == 1,  cluster(state)	
quietly su snap_val_fcpi  if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
eststo m1

/* CONTROL FOR HOUSEHOLD AND STATE FEATURES */
quietly reg snap_val_fcpi_pos $ui $control $fes $wgt  if eligible == 1,  cluster(state)	
eststo m2

/* CONTROL FOR HOUSEHOLD, STATE AND WELFARE FEATURES */
quietly reg snap_val_fcpi_pos $ui $controls $fes $wgt if eligible == 1,  cluster(state)	
eststo m3

/* CONTROL FOR HOUSEHOLD, STATE AND WELFARE FEATURES, AND STATE TIME TREND */
quietly reg snap_val_fcpi_pos $ui $controls $fest $wgt  if eligible == 1,  cluster(state)	
eststo m4


esttab m1 m2 m3 m4, b p keep($ui) order(uiave_fcpi lguiave_fcpi alt_totwks) title(`"The Impact of UI on STAMP Market Value "') label   star(* 0.10 ** 0.05 *** 0.01)  varwidth(20) ///
                        $indicators   ///
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) ///
						mtitle( "Value " "" "" "")

						
						
						
/* output to excel or latex */
if $export_option == 1{								 
#delimit ;
esttab m1 m2 m3 m4 using "Results\Mar_SNAP_Value", 
			csv replace label  order($ui) keep( $ui) f  b(3) se(3)  nogaps
	        stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) 
			labels(`"Mean Dependent Variable"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) 
            $indicators
			mgroups("Food Stamp Market Value", pattern(1 0 0 0) )           
			title("Impact on UI on Food Stamp Value")  
			addnote("$notes1" "$notes2" "$notes3" "$notes4" "$notes5") 
			star(* 0.10 ** 0.05 *** 0.01) ;
#delimit cr 				
}

	
	


**********************************************************TABLE 3: IMPACT ON UI INCOME************************************************
/* Dependent Variable: REPORTED UI INCOME

*/
						
cap estimates clear
/* CONTROL FOR HOUSEHOLD, STATE AND WELFARE FEATURES */
quietly reg ui_inc_fcpi $ui  $controls $fes  $wgt  if eligible == 1 & ui_finc > 0,  cluster(state)	
quietly su ui_inc_fcpi  if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m1

/* CONTROL FOR HOUSEHOLD, STATE AND WELFARE FEATURES, AND STATE TIME TREND */
quietly reg ui_inc_fcpi $ui  $controls $fest $wgt if eligible == 1 & ui_finc > 0,  cluster(state)	
estimate store m2

/* CONTROL FOR HOUSEHOLD, STATE AND WELFARE FEATURES */
quietly reg inctot_fcpi  $ui $controls $fes  $wgt  if eligible == 1,  cluster(state)	    //inc_fcpi
quietly su inc if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m3

/* CONTROL FOR HOUSEHOLD, STATE AND WELFARE FEATURES, AND STATE TIME TREND */
quietly reg inctot_fcpi  $ui $controls $fest  $wgt if eligible == 1,  cluster(state)	
estimate store m4

esttab m*, b p keep($ui) title(`"The Impact of UI on UI Income"') label   star(* 0.10 ** 0.05 *** 0.01)   varwidth(50)  ///
                        $indicators  ///
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) ///
						mtitle("UI" "" "Family Income" "")

						
/* output to excel or latex */		
if $export_option == 1{						 
#delimit ;
esttab m1 m2 m3 m4 using "Results\Mar_UIIncome", 
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









				
					
			
			


**********************************************************TABLE 4: PLACEBO TEST ************************************************

*** impact on food stamp take up
cap est clear
quietly reg snap_take $ui $controls $fes $wgt if  eligible == 0,  cluster(state)	
quietly su snap_take  if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
eststo m1

quietly reg snap_take $ui  $controls $fest $wgt   if  eligible == 0,  cluster(state)	
eststo m2



*** impact on food stamp value
quietly reg snap_val_fcpi_pos $ui $controls $fes  $wgt if eligible == 0,  cluster(state)	
quietly su snap_val_fcpi  if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
eststo m3

quietly reg snap_val_fcpi_pos $ui $controls $fest $wgt  if eligible == 0,  cluster(state)	
eststo m4

esttab m*, b p keep($ui) order(uijul_fcpi lguijul_fcpi alt_totwks) title(`"The Impact of UI on STAMP Takeup and Value "') label   star(* 0.10 ** 0.05 *** 0.01)  varwidth(30) ///
                        $indicators  ///
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) ///
						mtitle("Takeup" "" "Value " "")
						
						
						
/* output to excel or latex */	
if $export_option == 1{							 
#delimit ;
esttab m1 m2 m3 m4 using "Results\Mar_Placebo", 
			csv replace label  order($ui) keep( $ui) f  b(3) se(3)  nogaps
	        stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) 
			labels(`"Mean Dependent Variable"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) 
            $indicators
			mgroups("Individual UI Income", pattern(1 0 0 0) )           
			title("Impact on UI on Food Stamp Takeup and Value: Placebo Test")  
			addnote("$notes1" "$notes2" "$notes3" "$notes4" "$notes5") 
			star(* 0.10 ** 0.05 *** 0.01) ;
#delimit cr 		
}	
					
					
					
					
					
					
					
					
				


**********************************************************TABLE 3: DDD IDENTIFICATION ************************************************


global recession //"& !inrange(year, 2009, 2010)"


*** impact on food stamp take up
cap est clear
quietly reg snap_take $ui_ddd  $controls eligible_*  i.gestfips##i.eligible  i.year##i.eligible  $wgt, cluster(state)	
quietly su snap_take  if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m1

quietly reg snap_take  $ui_ddd  $controls eligible_*  i.gestfips##i.eligible  i.year##i.eligible   i.eligible##i.gestfips##c.year $wgt, cluster(state)	
estimate store m2

*** impact on food stamp value
quietly reg snap_val_fcpi_pos $ui_ddd  $controls eligible_*  i.gestfips##i.eligible  i.year##i.eligible   $wgt , cluster(state)	
quietly su snap_val_fcpi  if e(sample) == 1
estadd scalar outcome_mean = r(mean)
estimate store m3


quietly reg snap_val_fcpi_pos $ui_ddd  $controls eligible_*  i.gestfips##i.eligible  i.year##i.eligible  i.eligible##i.gestfips##c.year  $wgt,  cluster(state)	
estimate store m4

esttab m*, b p keep($ui_ddd ) order(uijul_fcpi lguijul_fcpi alt_totwks) title(`"The Impact of UI on STAMP Takeup and Value "') label   star(* 0.10 ** 0.05 *** 0.01)  varwidth(30) ///
						$indicatorsddd /// 
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) ///
						mtitle("Takeup" "" "Value " "")
						
						
					
/* output to excel or latex */
if $export_option == 1{								 
#delimit ;
esttab m1 m2 m3 m4 m5 m6 m7 m8 using "Results\Mar_DDD", 
			csv replace label  order($ui_ddd) keep( $ui_ddd) f  b(3)  se(3) nogaps
	        stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) 
			labels(`"Mean Dependent Variable"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) 
			$indicatorsddd 
			mgroups("Individual UI Income", pattern(1 0 0 0) )           
			title("Impact on UI on Food Stamp Takeup and Value: DDD")  
			addnote("$notes1" "$notes2" "$notes3" "$notes4" "$notes5") 
			star(* 0.10 ** 0.05 *** 0.01) ;
#delimit cr 									
}	
					
					
									
					
					
					
					
					
					
					
					
					
					
					
			
