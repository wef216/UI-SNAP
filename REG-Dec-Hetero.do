
/*-------------------------------------------------------------------------
*Impact of Food Security: Heterogeneity Test
*Data: CPS Dec
---------------------------------------------------------------------------*/


use "Processed\REG.dta", clear


*<< IMPORT THE CONTROLS AND SAMPLES CRITERIOR >>
do "Scripts\Preamble-Dec-Labels.do"
do "Scripts\Preamble-Controls.do"

global wgt   " [pw = fssuppwth] "



// create the indicator for Unemployed HH
cap drop eligible_p1
gen eligible_p1 = 1 if   hh_jobloserm_dur52 > 0 & hh_jobloserm_dur52 !=.  
replace eligible_p1 = 0 if    hh_unemp == 0

do "Scripts\Preamble-Hetero-Classifications.do"

forv j = 1/7{

cap drop eligible
gen eligible = 1 if eligible_p1 == 1 & eligible`j' == 1
replace eligible = 0 if eligible_p1 == 1 & eligible`j' == 0

label var eligible  "UI Eligible"

do "Scripts\Preamble-Eligible-Interactions.do"



*<< TABLE : DDD IDENTIFICATION >>

/* OUTCOME-1: dependent variable: at least one item positive in the 18 food insecurity scenario */
local j fsrawscr_pos
local labs1: variable label `j'

cap estimates clear
quietly reg `j' $ui_ddd  $controls eligible_*  i.gestfips##i.eligible  i.year##i.eligible  $wgt ,  cluster(state)	
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m1

quietly reg `j' $ui_ddd  $controls eligible_*  i.gestfips##i.eligible  i.year##i.eligible i.eligible##i.gestfips##c.year $wgt,  cluster(state)	
estimate store m2


/* OUTCOME-2: depdendent variable: food insecurity score */
local j fsrasch_pos
local labs2: variable label `j'

quietly reg `j' $ui_ddd  $controls eligible_* i.gestfips##i.eligible  i.year##i.eligible $wgt,  cluster(state)	
quietly su `j' if e(sample) == 1 
estadd scalar outcome_mean = r(mean)
estimate store m3

quietly reg `j' $ui_ddd  $controls eligible_*  i.gestfips##i.eligible  i.year##i.eligible i.eligible##i.gestfips##c.year $wgt,  cluster(state)	
estimate store m4



esttab m1  m2  m3 m4, b p keep($ui_ddd) title(`"The Impact of UI --  Heterogenity Group: ${title`k'} "') label   star(* 0.10 ** 0.05 *** 0.01)  varwidth(50) ///
                       	$indicatorsddd /// 
						stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) labels(`"Outcome Mean"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) ///
                        mtitle("Binary" ""  "Score" "" )            


}						
						
/* output to excel or latex */		
if $export_option == 1{						 
#delimit ;
esttab m1 m2 m3 m4 using "Results\Dec_Hetero_DDD_`k'", 
			csv replace label  order($ui_ddd ) kee($ui_ddd ) f  b(3)  se(3) nogaps
	        stats(outcome_mean r2_a N N_clust , fmt(3 3 0 0) 
			labels(`"Mean Dependent Variable"' `"Adjusted \$R^2\$"' `"Observations"' `"City Clusters"')) 
            $indicatorsddd 
			mgroups("Food Insecurity (Binary)" "Food Insecurity (Score)", pattern(1 0 1 0  ) )           
			title("Impact on UI on Food Insecurity -- Heterogeneity Group: ${title`k'}")  
			addnote("$notes1" "$notes2" "$notes3" "$notes4" "$notes5") 
			star(* 0.10 ** 0.05 *** 0.01) ;
#delimit cr 								
}					

			
			
			
			
