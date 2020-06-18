


*** Set globals for regression
 global xvar    hh_edu_hs_pr  hh_edu_col_pr hh_edu_univ_pr  hh_age20t30_r hh_age30t40_r  hh_age40t55_r hh_ageu20_r   age age2 marital2  white  kidu6 hh_psndg1 hh_psndg2 hh_psndg3  
global zvar1   unemploymentrate union_cov  gdp_state  povertyrate perchild
global zvar2    snap_2p  snap_ratio  nslp_ratio3 sbp_ratio3 eitc_2p  //snap_3p   eitc_3p  //eitc_refund //eitc_rate //medicaid_ratio state_mw  //medicaid_ratio //wic_ratio   
*global zvar2    snap_2p  snap_ratio  nslp_ratio3 sbp_ratio3 eitc_refund eitc_rate
*global zvar1   unemploymentrate union_cov  perchild
 
 global indicators `" indicate("State-Level Welfare Policies = snap_2p" "State-Level Economic Attributes = unemploymentrate" "Household Characteristics =  age"  "Year FE = *.year" "State FE = *.gestfips" "State Linear Trend = *.year_trend")   "'
 global indicatorsddd `" indicate("Household Characteristics =  age" "State Characteristics = unemploymentrate" "State Welfare Characteristics = snap_2p" "Year FE = *.year" "State FE = *.gestfips")  "'
 
global control0 $xvar  
global control $xvar $zvar1 
global controls $xvar $zvar1 $zvar2
global fes i.gestfips i.year  
global fest i.gestfips i.year i.gestfips##c.year_trend
*global ui  uijul_fcpi  alt_totwks  ui_cdep
global ui uijul_cdep_fcpi  alt_totwks  //ui_cdep
global lgui  lguijul_fcpi  alt_totwks  ui_cdep
global ui2 uijan_fcpi alt_totwks  ui_cdep

global agemin 56
global agemax 19

drop if agemin >= $agemin
drop if agemax <= $agemax

keep if year >= 1999
keep if  hh_psn <= 20


global export_option = 0




