


*** Set globals for regression
 global xvar    hh_edu_hs_pr   hh_edu_mhs_pr  hh_age20t30_r hh_age30t40_r hh_age40t55_r   hh_ageu20_r   hh_psndg1 hh_psndg2 age age2 marital2  hh_white_r kidu6 hh_psndg3 
*global xvar   age age2 marital2  sex  hh_edu_hs_r  hh_edu_1_ratio hh_edu_col_r hh_age20t30_r hh_age30t40_r hh_age40t55_r  kidu16  hh_psndg1 hh_psndg2 hh_psndg3  //hh_white_r //white //kidu6  hh_psn kidu16
global zvar1   unemploymentrate  union_cov  perchild  medical_ratio   //povertyrate // lggdpp_state 
global zvar2    snap_2p  snap_1p snap_ratio   nslp_ratio3 sbp_ratio3 eitc_refund   eitc_rate  //wic_ratio   
*global zvar2  snap_1p  snap_2p  snap_3p  snap_4p  eitc_0p  eitc_1p eitc_2p eitc_3p snap_ratio  sbp_ratio2  nslp_ratio2
*global zvar2   snap_3p eitc_3p    eitc_rate  snap_ratio   nslp_ratio3  sbp_ratio3 //wic_ratio 
 
 global indicators `" indicate("State-Level Welfare Policies = snap_2p" "State-Level Economic Attributes = unemploymentrate" "Household Characteristics =  age"  "Year FE = *.year" "State FE = *.gestfips" "State Linear Trend = *.year_trend")   "'

 
global control0 $xvar  
global control $xvar $zvar1 
global controls $xvar $zvar1 $zvar2
global fes i.gestfips i.year  
global fest i.gestfips i.year i.gestfips##c.year_trend
global ui  uijul_fcpi  alt_totwks  
global lgui  lguijul_fcpi  alt_totwks   
global ui2 uijan_fcpi alt_totwks

global agemin 56
global agemax 19

drop if agemin >= $agemin
drop if agemax <= $agemax

keep if year >= 1999
keep if  hh_psn <= 20
