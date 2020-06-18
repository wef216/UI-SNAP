

*****************Balance Test   ************************************************
/* Dependent Variable: Family Demographic Features
local m: word `k' of `outcomes'
local controls: list global(parentvar) - local(remove`k')

*/



use "Processed\Dec_REG_Sample.dta", clear

keep if main_sample == 1

do "Scripts\Preamble-Dec-Labels.do"
do "Scripts\Preamble-Controls.do"

global xvarb   age  marital2  hh_edu_1_ratio hh_edu_hs_r   hh_edu_col_r hh_age20t30_r hh_age30t40_r hh_age40t55_r  hh_psndg1 hh_psndg2 hh_psndg3  kidu16 sex   //hh_white_r //white //kidu6  hh_psn


local remove1 "age age2"
local remove2 "marital2"
local remove3 "hh_edu_1_ratio hh_edu_hs_r   hh_edu_col_r "
local remove4 "hh_edu_1_ratio hh_edu_hs_r   hh_edu_col_r "
local remove5 "hh_edu_1_ratio hh_edu_hs_r   hh_edu_col_r "
local remove6 "hh_age20t30_r hh_age30t40_r hh_age40t55_r "
local remove7 "hh_age20t30_r hh_age30t40_r hh_age40t55_r "
local remove8 "hh_age20t30_r hh_age30t40_r hh_age40t55_r "
local remove9 "hh_psndg1 hh_psndg2 hh_psndg3"
local remove10 "hh_psndg1 hh_psndg2 hh_psndg3"
local remove11 "hh_psndg1 hh_psndg2 hh_psndg3"
local remove12 "kidu16"
local remove 13 "sex"



cap estimates clear
forvalues i =  1/12{
local j: word `i' of  $xvarb

local xvar2: list global(xvar) -  local(remove`i')

 
global controls `xvar2' $zvar1 $zvar2
global fes i.gestfips i.year  
global fest i.gestfips i.year i.gestfips##c.year_trend
//global ui  uijul_fcpi  alt_totwks  
global ui  uijul_fcpi  alt_totwks  
global lgui  lguijul_fcpi  alt_totwks   




/* CONTROL FOR HOUSEHOLD, STATE AND WELFARE FEATURES */
quietly reg `j' $ui $controls $fes  $wgt  if regcons == 1,  cluster(state)	
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m`i'_1

/* CONTROL FOR HOUSEHOLD, STATE AND WELFARE FEATURES, AND STATE TIME TREND */
reg `j'  $ui $controls $fest  $wgt  if regcons == 1,  cluster(state)	
estimate store m`i'_2



}


esttab m* , b p keep($ui) title(`"The Impact of UI on Household Food Insecurity Status: `j' "') label   star(* 0.10 ** 0.05 *** 0.01)   nomtitle varwidth(50)  ///
                       	indicate("State Characteristics = unemploymentrate" "State Welfare Characteristics = snap_3p" "Year FE = *.year" "State FE = *.gestfips" "State Linear Trend = *.year_trend")  /// 
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) //



/* output to excel or latex */						 
#delimit ;
esttab m* using "Results\Dec_BalanceTest", 
			csv replace label  order($ui) keep( $ui) f  b(3)  se(3) nogaps
	        stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) 
			labels(`"Mean Dependent Variable"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) 
            indicate("State-Level Welfare Policies = snap_3p" "State-Level Economic Attributes = unemploymentrate" "Household Characteristics =  hh_edu_hs_r"  "Year FE = *.year" "State FE = *.gestfips" "State Linear Trend = *.year_trend")  
			mgroups("HH Age" "" "HH Married" "" "Share of LHS" "" "Share of HS" "" "Share of Some College" "" "Share of Age (20-30)" "" "Share of Age (30-40)" "" "Share of Age (40-55)" ""
			"One-Person Family" "" "Regular Family" "" "Large Family" "" "Presence of Child Under 6" "", pattern(1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0) )           
			title("Impact of UI on Family Characteristics")  
			addnote("$notes1" "$notes2" "$notes3" "$notes4" "$notes5") 
			star(* 0.10 ** 0.05 *** 0.01) ;
#delimit cr 						   

