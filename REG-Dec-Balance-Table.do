



/*-------------------------------------------------------------------------
*Impact of Food Security -- Balance Test
*Data: CPS Dec

*Dependent Variable: Family Demographic Features
local m: word `k' of `outcomes'
local controls: list global(parentvar) - local(remove`k')
---------------------------------------------------------------------------*/



*use "Processed\Dec_REG_Sample.dta", clear
use "Processed\REG.dta", clear

*<< IMPORT THE CONTROLS AND SAMPLES CRITERIOR >>
do "Scripts\Preamble-Dec-Labels.do"
do "Scripts\Preamble-Controls.do"
do "Scripts\Preamble-Sample-Criteria.do"


global wgt   " [pw = fssuppwth] "
global indicatorsb `" indicate("State-Level Welfare Policies = snap_2p" "State-Level Economic Attributes = unemploymentrate" "Household Characteristics =  age"  "Year FE = *.year" "State FE = *.gestfips")   "'
 

// create the indicator for Unemployed HH
cap drop eligible
gen eligible = 1 if   hh_jobloser_dur52 > 0 & hh_jobloser_dur52 !=.  
replace eligible = 0 if    hh_unemp == 0

label var eligible  "UI Eligible"

do "Scripts\Preamble-Eligible-Interactions.do"


reg fsrawscr_pos  $ui $controls $fest  $wgt  if eligible  == 1,  cluster(state)	
keep if e(sample) == 1







*************************REGRESSION ANALYSIS ************************

global xvarb   age  marital2 hh_edu_hs_pr  hh_edu_col_pr hh_edu_univ_pr hh_age20t30_r hh_age30t40_r hh_age40t55_r  hh_psndg1 hh_psndg2 hh_psndg3  kidu6 white
 
local remove1 "age age2"
local remove2 "marital2"
local remove3 "hh_edu_hs_pr  hh_edu_col_pr hh_edu_univ_pr "
local remove4 "hh_edu_hs_pr  hh_edu_col_pr hh_edu_univ_pr"
local remove5 "hh_edu_hs_pr  hh_edu_col_pr hh_edu_univ_pr "
local remove6 "hh_age20t30_r hh_age30t40_r hh_age40t55_r "
local remove7 "hh_age20t30_r hh_age30t40_r hh_age40t55_r "
local remove8 "hh_age20t30_r hh_age30t40_r hh_age40t55_r "
local remove9 "hh_psndg1 hh_psndg2 hh_psndg3"
local remove10 "hh_psndg1 hh_psndg2 hh_psndg3"
local remove11 "hh_psndg1 hh_psndg2 hh_psndg3"
local remove12 "kidu6"
local remove13 "white"

local title1 "Age"
local title2 "Married"
local title3 "Share: Edu = HS"
local title4 "Share: Edu = College"
local title5 "Share: Edu = University"
local title6 "Share: Age 20-30"
local title7 "Share: Age 30-40"
local title8 "Share: Age 40-55"
local title9 "1-member household"
local title10 "2-6-member household"
local title11 "7-10-member household"
local title12 "Presence of children under 6"
local title13 "White"


local m_titles "`title1'"
cap estimates clear
forvalues i =  1/13{
local j: word `i' of  $xvarb

local xvar2: list global(xvar) -  local(remove`i')

 
global controls `xvar2' $zvar1 $zvar2

/* CONTROL FOR HOUSEHOLD, STATE AND WELFARE FEATURES */
quietly reg `j' $ui $controls $fes  $wgt  if eligible == 1,  cluster(state)	
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m`i'_b1

/* CONTROL FOR HOUSEHOLD, STATE AND WELFARE FEATURES, AND STATE TIME TREND */
reg `j'  $ui $controls $fest  $wgt  if eligible == 1,  cluster(state)	
estimate store m`i'_b2

if `i' > 1{
local m_titles "`m_titles'"  "`title`i''"
}
}



esttab m*_b1, b p keep($ui) title(`"The Impact of UI on Household Food Insecurity Status: `j' "') label   star(* 0.10 ** 0.05 *** 0.01)   varwidth(30)  modelwidth(10)  ///
                       	$indicatorsb  /// 
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) ///
						mtitle("`m_titles'")

esttab m*_b2, b p keep($ui) title(`"The Impact of UI on Household Food Insecurity Status: `j' "') label   star(* 0.10 ** 0.05 *** 0.01)   varwidth(30)  modelwidth(10)  ///
                       	$indicators  /// 
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) ///
						mtitle("`m_titles'")
						
if $export_option == 1{
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
}
