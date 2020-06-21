

/*-------------------------------------------------------------------------
*Impact of SNAP Takeup and Value
*Data: CPS Mar
---------------------------------------------------------------------------*/


use "Processed\ASEC_REG.dta", clear


*<< IMPORT THE CONTROLS AND SAMPLES CRITERIOR >>
do "Scripts\Preamble-Controls.do"
do "Scripts\Preamble-Sample-Criteria.do"

global wgt   "[pw = asecwth]"


// create the indicator for Unemployed HH
cap drop eligible_p1
gen eligible_p1 = 0 if  ui_finc_fcpi_ave <= 0   &  snap_val <=24900
replace eligible_p1 = 0 if  ui_finc_fcpi_ave == .   &  snap_val <=24900
replace eligible_p1 = 1 if  ui_finc_fcpi_ave > 0 & ui_finc_fcpi_ave < . & snap_val <= 24900

do "Scripts\Preamble-Hetero-Classifications.do"


forv k= 1/7{

cap drop eligible
gen eligible = 1 if eligible_p1 == 1 & eligible`k' == 1
replace eligible = 0 if eligible_p1 == 1 & eligible`k' == 0

label var eligible  "Eligible"

do "Scripts\Preamble-Eligible-Interactions.do"





*<< TABLE : DDD IDENTIFICATION >>

*** impact on food stamp take up
cap est clear
quietly reg snap_take $ui_ddd  $controls eligible_*  i.gestfips##i.eligible  i.year##i.eligible  $wgt, cluster(state)	
quietly su snap_take  if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m1

quietly reg snap_take  $ui_ddd  $controls eligible_*  i.gestfips##i.eligible  i.year##i.eligible   i.eligible##i.gestfips##c.year $wgt, cluster(state)	
estimate store m2

*** impact on food stamp value
quietly reg snap_val_fcpi_pos $ui_ddd  $controls eligible_*  i.gestfips##i.eligible  i.year##i.eligible   $wgt, cluster(state)	
quietly su snap_val_fcpi  if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m3


quietly reg snap_val_fcpi_pos $ui_ddd  $controls eligible_*  i.gestfips##i.eligible  i.year##i.eligible  i.eligible##i.gestfips##c.year  $wgt ,  cluster(state)	
estimate store m4

esttab m*, b p keep($ui_ddd ) order($ui_ddd) title("The Impact of UI -- Heterogenity Group: ${title`k'} ") label   star(* 0.10 ** 0.05 *** 0.01)  varwidth(50) ///
						$indicatorsddd   ///
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) ///
						mtitle("Takeup" "" "Value " "")					
						
					
/* output to excel or latex */
if $export_option == 1{								 
#delimit ;
esttab m1 m2 m3 m4  using "Results\Mar_Hetero_DDD_`k'", 
			csv replace label  order($ui_ddd) keep( $ui_ddd) f  b(3)  se(3) nogaps
	        stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) 
			labels(`"Mean Dependent Variable"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) 
			$indicatorsddd  
			mgroups("Food Insecurity (Binary)" "Food Insecurity (Score)", pattern(1 0 1 0  ) )     			
			title("Impact on UI on Food Stamp Takeup and Value: -- Heterogeneity Group ${title`k'} ")  
			addnote("$notes1" "$notes2" "$notes3" "$notes4" "$notes5") 
			star(* 0.10 ** 0.05 *** 0.01) ;
#delimit cr 									
}	

}
			
			
