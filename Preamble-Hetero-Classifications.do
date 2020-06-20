



*[Group by State Unemployment Rate]
su unemploymentrate,de
cap drop eligible1 
gen eligible1 = 1 if unemploymentrate >= r(mean)
replace eligible1 = 0 if unemploymentrate < r(mean)
global title1 "Unemployment"

*[Group by Household Education Background-1]
cap drop eligible2
gen eligible2 = 1 if hh_edu_hs_pr + hh_edu_mhs_pr <= 0.5 
replace eligible2 = 0 if hh_edu_hs_pr + hh_edu_mhs_pr > 0.5 
global title2 "Education: Share 0.5"

*[Group by Household Education Background-2]
cap drop eligible3
gen eligible3 = 1 if  hh_edu_mhs_pr == 0
replace eligible3 = 0 if  hh_edu_mhs_pr > 0
global title3 "Education: no MHS"

*[Group by Household Education Background-3]
cap drop eligible4
gen eligible4 =  hh_edu_mhs_pr  
global title4 "Education: Share MHS"

*[Group by Marital Status}
cap drop eligible5
gen eligible5 = 1 if  marital2 == 0
replace eligible5 = 0 if marital2 == 1
global title5 "Married"

*[Group by Children Number]
cap drop eligible6
gen eligible6 = hh_ageu6
global title6 "# Child"

*[Group by Race]
cap drop eligible7
gen eligible7 = 1 if hh_white_r < 0.5
replace eligible7 = 0 if hh_white_r >= 0.5
global title7 "White"

*[Group by Income]
*su inc_fcpi,de
*gen eligible = (inc_fcpi >= r(p50))


*gen eligible = 1 if hh_edu_hs_pr + hh_edu_mhs_pr <= 0.5 
*replace eligible = 0 if hh_edu_hs_pr + hh_edu_mhs_pr > 0.5 
*gen eligible = (hh_edu_mhs_pr == 1)
*gen eligible = hh_edu_mhs_pr

*

*gen eligible = marital2

*su inc_fcpi,de
*gen eligible = (inc_fcpi >= r(p50))

