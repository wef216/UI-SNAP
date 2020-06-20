

*<< Set globals for regression >>
 global xvar    hh_edu_hs_pr  hh_edu_col_pr hh_edu_univ_pr  hh_age20t30_r hh_age30t40_r  hh_age40t55_r hh_ageu20_r   age age2 marital2  white  kidu6 hh_psndg1 hh_psndg2 hh_psndg3  
global zvar1   unemploymentrate union_mem  gdpp_state  povertyrate  //perchild
global zvar2    snap_2p  snap_ratio  nslp_ratio3 sbp_ratio3 //eitc_2p snap_3p eitc_3p

global control0 $xvar  
global control $xvar $zvar1 
global controls $xvar $zvar1 $zvar2
global fes i.gestfips i.year  
global fest i.gestfips i.year i.gestfips##c.year_trend

global ui_month uijul
global ui ${ui_month}_cdep_fcpi  alt_totwks  //ui_cdep
global ui_ddd 	${ui_month}_cdep_fcpi_eligible alt_totwks_eligible   ${ui_month}_cdep_fcpi alt_totwks   eligible  
global lgui  lg${ui_month}_cdep_fcpi  alt_totwks  
global ui2 uiave_cdep_fcpi alt_totwks  // ui_cdep


*<< Set Samples >>
global agemin 56
global agemax 19

drop if agemin >= $agemin
drop if agemax <= $agemax

keep if survey_year >= 1999
keep if survey_year <= 2017
keep if  hh_psn <= 20


*<< Set Esttab Options >> 
 global indicators `" indicate("State-Level Welfare Policies = snap_2p" "State-Level Economic Attributes = unemploymentrate" "Household Characteristics =  age"  "Year FE = *.year" "State FE = *.gestfips" "State Linear Trend = *.year_trend")   "'
 global indicatorsddd `" indicate("Household Characteristics =  age" "State Characteristics = unemploymentrate" "State Welfare Characteristics = snap_2p" "Year FE = *.year" "State FE = *.gestfips")  "'

global export_option = 0



/*
 global xvar    hh_edu_hs_pr  hh_edu_col_pr hh_edu_univ_pr  hh_age20t30_r hh_age30t40_r  hh_age40t55_r hh_ageu20_r   age age2 marital2  white  kidu6 hh_psndg1 hh_psndg2 hh_psndg3  
global zvar1   unemploymentrate union_mem  gdpp_state  povertyrate //perchild
global zvar2    snap_2p  snap_ratio  nslp_ratio3 sbp_ratio3 eitc_2p //snap_2p eitc_3p
*/
