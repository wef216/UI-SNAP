

***********************************************************************
*  CLEAN THE CPS-ASEC DATA
*
***********************************************************************




								*** DATA CLEAN: CPS-ASEC *** 
*---------------------------------------------------------------------------------------------------------*
use "Data\cps_asec_1995_2018.dta" , clear


*< < < EXTRACT INDIVIDUAL VARIABLES > > >
format cpsid %20.0g
format cpsidp %20.0g


* PERSONAL UNEMPLOYMENT INSURANCE
gen ui_inc= incunemp
replace ui_inc  = . if incunemp == 99997 | incunemp == 99999
label var ui_inc "(Individual) Income from unemployment benefits, last year"


* PERSONAL INCOME
*inctot

* AGE
recode age (0/30 =1)  (31/40=2) (41/50 = 3) (51/60 = 4) (60/200 = 5), gen(ageg)
gen age2 =age*age

*RACE
gen white = 1 if race == 100
replace white = 0 if race != 100 & race != .


*MARITAL STATUS
cap drop marital2
recode marst (1  = 1) (2 3 4 5 6 = 0), gen(marital2)

cap drop marital3
recode marst (1 2  = 1) ( 3 4 5 6 = 2), gen(marital3)


*EDUCATION
sort serial year
recode educ  (2 = 0) (10 20 30 = 1) (40 50 60 71 73 = 2) (81 91 92 = 3) (111 120 121 122 123 124 125 = 4), gen(educ_lvl)
label define educ_lvl 0 "no school" 1 "less HS"  2 "HS"  3 "college" 4 "university"
label values educ_lvl educ_lvl

cap drop educ_lvld*
ta educ_lvl, gen(educ_lvld)


* HOUSEHOLD FOOD STAMP INFORATION>
// food stamp related information during the previous year
* take up
gen snap_take = 1 if foodstmp == 2
replace snap_take = 0 if foodstmp == 1
label var snap_take "(Household) Food stamp recipiency, past year"

* covered persons, topcoded at 9.
gen snap_psn = stampno
label var snap_psn "(Household) Number of persons covered by food stamps, last year"

* received months
gen snap_mth = stampmo
label var snap_mth "(Houhseold)  Number of months received food stamps, last year"

cap drop snap_mth_pos
gen snap_mth_pos = snap_mth if snap_mth > 0
label var snap_mth_pos "(Houhseold)  Number of months received food stamps conditional on positive month, last year"

* snap value
gen snap_val = stampval
label var snap_val "(Household) Total value of food stamps, last year"

cap drop snap_val_pos
gen snap_val_pos = snap_val if snap_val > 0
label var snap_val "(Household) Total value of food stamps conditional on postive snap value, last year"






*< < < EXTRACT HOUSEHOLDS VARIABLES > > >

* HH Unemployment Insurance
cap drop ui_finc
bysort serial year: egen ui_finc = total(ui_inc), missing  //REMARK: 11/30/2019
label var ui_finc "(Household) Total Unemployment Insurance Income"


cap drop ui_hhtaker
bysort serial year: egen ui_hhtaker = total(ui_inc > 0), missing  //REMARK: 11/30/2019
label var ui_hhtaker "(Household) Total number of persons within the household taking the UI"

cap drop ui_finc_ave
gen ui_finc_ave = ui_finc/ui_hhtaker 
label var ui_finc_ave "(Household) Average Unemployment Insurance Income per UI Taker"


* HH DEMOGRAPHIC INFORMATION
* AGE structure
sort serial year
 by  serial year:  egen hh_psn = total(age!=.)
label var hh_psn "(Household) Number of household members"

*recode hh_psn (1=1) (2=2) (3=3) (4=4) (5/16=5), gen(hh_psnd)
recode hh_psn (1 = 1 ) (2/5 = 2) (6/10 = 3) (11/20 = 4), gen(hh_psndd)
ta hh_psndd, gen(hh_psndg)

 by  serial year: egen hh_age18t65 = total(inrange(age, 18,65))
label var hh_age18t65 "(Household) Number of 18-65 household members"

 by   serial year: egen hh_age16t60 = total(inrange(age, 16,60))
label var hh_age16t60 "(Household) Number of 16-60 household members"

 by   serial year: egen hh_age16t65 = total(inrange(age, 16,65))
label var hh_age16t65 "(Household) Number of 16-65 household members"

 by   serial year: egen hh_age20t65 = total(inrange(age, 20,65))
label var hh_age20t65 "(Household) Number of 20-65 household members"

 by   serial year: egen hh_age20t60 = total(inrange(age, 20,60))
label var hh_age20t60 "(Household) Number of 20-60 household members"

 by   serial year: egen hh_age20t55 = total(inrange(age, 20,55))
label var hh_age20t55 "(Household) Number of 20-55 household members"

 by   serial year:  egen hh_ageu65 = total(inrange(age,65,200))
label var hh_ageu65 "(Household) Number of over 65 household members"

 by   serial year:  egen hh_ageu55 = total(inrange(age,55,200))
label var hh_ageu65 "(Household) Number of over 55 household members"

 by   serial year:  egen hh_ageu10 = total(inrange(age, 0,10))
label var hh_ageu10 "(Household) Number of u10 household members"

 by   serial year:  egen hh_ageu20 = total(inrange(age, 0,19))
label var hh_ageu20 "(Household) Number of u20 household members"

 by   serial year:  egen hh_ageu18 = total(inrange(age, 0,18))
label var hh_ageu18 "(Household) Number of u18 household members"

 by   serial year:  egen hh_ageu16 = total(inrange(age, 0,16))
label var hh_ageu16 "(Household) Number of u18 household members"

 by   serial year:  egen hh_ageu6 = total(inrange(age, 0,6))
label var hh_ageu6 "(Household) Number of u6 household members"

 by   serial year:  egen hh_age10t20 = total(inrange(age, 10,19))
label var hh_age10t20 "(Household) Number of 10-20 household members"

 by   serial year:  egen hh_age20t30 = total(inrange(age, 20,29))
label var hh_age20t30 "(Household) Number of 20-30 household members"

 by   serial year:  egen hh_age30t40 = total(inrange(age,30,39))
label var hh_age30t40 "(Household) Number of 30-40 household members"

 by   serial year:  egen hh_age40t55 = total(inrange(age,40,55))
label var hh_age40t55 "(Household) Number of 40-55 household members"

 by   serial year:  egen hh_age40t50 = total(inrange(age,40,49))
label var hh_age40t50 "(Household) Number of 40-50 household members"

 by   serial year:  egen hh_age50t60 = total(inrange(age,50,59))
label var hh_age50t60 "(Household) Number of 50-60 household members"


cap drop kidu18
gen kidu18 =  1 if hh_ageu18 > 0 & hh_ageu18 !=. 
replace kidu18 = 0 if hh_ageu18 == 0
label var kidu18 "presence of child under 18"

cap drop kidu6
gen kidu6 =  1 if hh_ageu6 > 0 & hh_ageu6 !=. 
replace kidu6 = 0 if hh_ageu6 == 0
label var kidu6 "presence of child under 6"

cap drop kidu16
gen kidu16 =  1 if hh_ageu16 > 0 & hh_ageu16 !=. 
replace kidu16 = 0 if hh_ageu16 == 0
label var kidu16 "presence of child under 16"



gen hh_ageu65_r = hh_ageu65/hh_psn
label var hh_ageu65_r "share of family members aging under 65"

gen hh_ageu18_r = hh_ageu18/hh_psn
label var hh_ageu18_r "share of family members aging under 18"

gen hh_ageu16_r = hh_ageu16/hh_psn
label var hh_ageu16_r "share of family members aging under 16"

gen hh_ageu6_r = hh_ageu6/hh_psn
label var hh_ageu6_r "share of family members aging under 6"


gen hh_age18t65_r = hh_age18t65/hh_psn
label var hh_age18t65_r "share of family members aging 18 to 65"

gen hh_age16t60_r = hh_age16t60/hh_psn
label var hh_age16t60_r "share of family members aging 16 to 60"

gen hh_age16t65_r = hh_age16t65/hh_psn
label var hh_age16t65_r "share of family members aging 16 to 65"

gen hh_age20t65_r = hh_age20t65/hh_psn
label var hh_age20t65_r "share of family members aging 20 to 65"

gen hh_age20t60_r = hh_age20t60/hh_psn
label var hh_age20t60_r "share of family members aging 20 to 60"

gen hh_age20t55_r = hh_age20t55/hh_psn
label var hh_age20t55_r "share of family members aging 20 to 55"

gen hh_ageu20_r = hh_ageu20/hh_psn
label var hh_ageu20_r "share of family members aging under 20"

gen hh_age20t30_r = hh_age20t30/hh_psn
label var hh_age20t30_r "share of family members aging 20 to 30"

gen hh_age30t40_r = hh_age30t40/hh_psn
label var hh_age30t40_r "share of family members aging 30 to 40"

gen hh_age40t55_r = hh_age40t55/hh_psn
label var hh_age40t55_r "share of family members aging 40 to 55"





* RACE structure
 by   serial year:  egen hh_white = total(race == 100)
label var hh_white "(Household) Number of white household members"

gen hh_white_r = hh_white/hh_psn
label var hh_white_r "share of family members white"



* EDUCATION structure
sort  serial year
 by   serial year: egen hh_edu_none = total(inlist(educ,2))
label var hh_edu_none "(Household) Number of none school member"

 by   serial year:  egen hh_edu_lhs = total(inlist(educ,10,20,30))
label var hh_edu_lhs "(Household) Number of less-HS member"

 by   serial year: egen hh_edu_hs = total(inlist(educ, 40,50,60,71,73))
label var hh_edu_hs "(Household) Number of HS member"
 
 by   serial year: egen hh_edu_col = total(inlist(educ,81,91,92))
label var hh_edu_col "(Household) Number of College member"

 by   serial year:  egen hh_edu_univ = total(inlist(educ,111,120, 121, 122, 123,124,125))
label var hh_edu_univ "(Household) Number of University or more member"



gen hh_edu_hs_r = hh_edu_hs/hh_psn
label var hh_edu_hs_r "share of family members with HS"

gen hh_edu_col_r = hh_edu_col/hh_psn
label var hh_edu_col_r "share of family members with some college"

gen hh_edu_univ_r = hh_edu_univ/hh_psn
label var hh_edu_univ_r "share of family members with university"

gen hh_edu_mhs_r = (hh_edu_col + hh_edu_univ)/hh_psn
label var hh_edu_mhs_r "share of family members with more than some college"

gen hh_edu_lhs_r = hh_edu_lhs/hh_psn
label var hh_edu_lhs_r "share of family members with less than HS"

gen hh_edu_none_r = hh_edu_none/hh_psn
label var hh_edu_none_r "share of family members with no education"

gen hh_edu_1_ratio  = (hh_edu_none + hh_edu_lhs  )/hh_psn
label var hh_edu_1_ratio "share of family members with no education and less than HS"





//* education structure in prime workers
sort  serial year
 by   serial year: egen hh_edu_none_p = total(inlist(educ,2) & inrange(age, 20, 55))
label var hh_edu_none_p "(Household) Number of none school member of prime age"
gen hh_edu_none_pr = hh_edu_none_p /hh_psn
label var hh_edu_none_pr "(Household) Share of none school member of prime age"

 by   serial year:  egen hh_edu_lhs_p = total(inlist(educ,10,20,30) & inrange(age, 20, 55))
label var hh_edu_lhs_p "(Household) Number of less-HS member of prime age"
gen hh_edu_lhs_pr = hh_edu_lhs_p /hh_psn
label var hh_edu_lhs_pr "(Household) Share of less-HS member of prime age"

 by   serial year: egen hh_edu_hs_p = total(inlist(educ, 40,50,60,71,73) & inrange(age, 20, 55))
label var hh_edu_hs_p "(Household) Number of HS member of prime age"
 gen hh_edu_hs_pr = hh_edu_hs_p /hh_psn
label var hh_edu_hs_pr "(Household) Share of HS member of prime age"
 
 by   serial year: egen hh_edu_col_p = total(inlist(educ,81,91,92) & inrange(age, 20, 55))
label var hh_edu_col_p "(Household) Number of College member of prime age"
 gen hh_edu_col_pr = hh_edu_col_p /hh_psn
label var hh_edu_col_pr "(Household) Share of College member of prime age"
 
 
 by   serial year:  egen hh_edu_univ_p = total(inlist(educ,111,120, 121, 122, 123,124,125) & inrange(age, 20, 55))
label var hh_edu_univ_p "(Household) Number of University or more member of prime age"
 gen hh_edu_univ_pr = hh_edu_univ_p /hh_psn
label var hh_edu_univ_pr "(Household) Share of University member of prime age"

gen hh_edu_mhs_p = hh_edu_col_p + hh_edu_univ_p
label var hh_edu_mhs_p "(Household) Number of more than HS member of prime age"
gen hh_edu_mhs_pr = hh_edu_col_pr + hh_edu_univ_pr
label var hh_edu_mhs_pr "(Household) Share of more than HS member of prime age"

bysort  serial year: egen agemax = max(age)
label var agemax "max age within the household"

bysort  serial year: egen agemin = min(age)
label var agemin "min age within the household"




* UNEMPLOYMENT structure
 by   serial year:  egen hh_unemp = total(inlist(empstat, 20, 21, 22))
label var hh_unemp "(Household) Number of Unemployed"

 by   serial year:  egen hh_emp = total(inlist(empstat, 12, 10))
label var hh_emp "(Household) Number of Employed"

 by   serial year:  egen hh_unemp_dur52 = total(inrange(durunemp, 0, 52))
label var hh_unemp_dur52 "(Household) Number of Unemployed, in 52 weeks"

 by   serial year:  egen hh_jobloser = total(inlist(whyunemp, 1,2))
label var hh_jobloser "(Household) Number of job losers"

 by   serial year:  egen hh_jobloserm = total(inlist(whyunemp, 1,2,3))
label var hh_jobloserm "(Household) Number of job losers"


 by   serial year:  egen hh_jobloser_dur53 = total(inlist(whyunemp, 1,2) & inrange(durunemp, 0, 53) )
label var hh_jobloser_dur53 "(Household) Number of job losers, in 53 weeks"

 by   serial year:  egen hh_jobloser_dur52 = total(inlist(whyunemp, 1,2) & inrange(durunemp, 0, 52) )
label var hh_jobloser_dur52 "(Household) Number of job losers, in 52 weeks"

 by   serial year:  egen hh_jobloser_dur51 = total(inlist(whyunemp, 1,2) & inrange(durunemp, 0, 51) )
label var hh_jobloser_dur51 "(Household) Number of job losers, in 51 weeks"

 by   serial year:  egen hh_jobloser_dur26 = total(inlist(whyunemp, 1,2) & inrange(durunemp, 0, 26) )
label var hh_jobloser_dur26 "(Household) Number of job losers, in 26 weeks"

 by   serial year:  egen hh_jobloserm_dur52 = total(inlist(whyunemp, 1,2,3) & inrange(durunemp, 0, 52) )
label var hh_jobloserm_dur52 "(Household) Number of job losers, in 52 weeks"

 by   serial year:  egen hh_jobloserm_dur51 = total(inlist(whyunemp, 1,2,3) & inrange(durunemp, 0, 51) )
label var hh_jobloserm_dur51 "(Household) Number of job losers, in 51 weeks"

 by   serial year:  egen hh_jobloserm_dur50 = total(inlist(whyunemp, 1,2,3) & inrange(durunemp, 0, 50) )
label var hh_jobloserm_dur50 "(Household) Number of job losers, in 50 weeks"

 by   serial year:  egen hh_jobloserm_dur49 = total(inlist(whyunemp, 1,2,3) & inrange(durunemp, 0, 49) )
label var hh_jobloserm_dur49 "(Household) Number of job losers, in 49 weeks"

 by   serial year:  egen hh_jobloserm_dur48 = total(inlist(whyunemp, 1,2,3) & inrange(durunemp, 0, 48) )
label var hh_jobloserm_dur48 "(Household) Number of job losers, in 48 weeks"

 by   serial year:  egen hh_jobloserm_dur47 = total(inlist(whyunemp, 1,2,3) & inrange(durunemp, 0, 47) )
label var hh_jobloserm_dur47 "(Household) Number of job losers, in 47 weeks"

 by   serial year:  egen hh_jobloser_dur52_age = total(inlist(whyunemp, 1,2) & inrange(durunemp, 0, 52) & inrange(age, 20,65)) 
label var hh_jobloser_dur52_age "(Household) Number of job losers, in 52 weeks, age 20-65"

 by   serial year:  egen hh_jobloser_dur51_age = total(inlist(whyunemp, 1,2) & inrange(durunemp, 0, 51) & inrange(age, 20,65))
label var hh_jobloser_dur51_age "(Household) Number of job losers, in 51 weeks, age 20-65"

 by   serial year:  egen hh_jobloserm_dur52_age = total(inlist(whyunemp, 1,2,3) & inrange(durunemp, 0, 52) & inrange(age, 20,65)) 
label var hh_jobloserm_dur52_age "(Household) Number of job losers, in 52 weeks, age 20-65"

 by   serial year:  egen hh_jobloserm_dur51_age = total(inlist(whyunemp, 1,2,3) & inrange(durunemp, 0, 51) & inrange(age, 20,65))
label var hh_jobloserm_dur51_age "(Household) Number of job losers, in 51 weeks, age 20-65"




*< < <OTHER SURVEY RELATED VARIABLES > > > 


*KEEP THE HOUSEHOLD HOLD: SO each observation is represents a household.

keep if relate == 101

* DROP THE CPS-ASEC OVER SAMPLE HOUSEHOLD 
* oversample of Hispanic households see here: https://www.census.gov/topics/population/foreign-born/guidance/cps-guidance/cps-vs-asec.html
*drop if cpsid == 0  // 


*
*keep ui_inc snap_take snap_psn snap_mth snap_val year  cpsid asecfwt asecwth age sex race marst 

*collapse ui snap_take snap_psn snap_mth snap_val asecfwt asecwth, by(year cpsid)

// each observation is a piece of one household member in the household.

* CREATE LAGGED TIME FOR MATCH WITH EXTERNAL DATA SET 
// generate the year variables for the year lagged, and match the state information in the previous year.
gen aesc_year = year
replace year = aesc_year - 1   //"1995 --> 1994"

save "Processed\ASEC.dta", replace







								*** MERGE WITH EXTERNAL DATA SET *** 
*---------------------------------------------------------------------------------------------------------*
/* ALL THE STATE LEVEL ECONOMIC CHARACTERISTICS ARE MATCHED TO THE PREVIOUS YEAR*/

*< < <  MERGING > > > *
rename statefip gestfips

* match the state identifier
merge m:1 gestfips using "Data\statetrans.dta",force
keep if _merge == 3 | _merge == 1
drop _merge

* match the state UI benefits to the CPS-Match data
merge m:1 gestfips year using "Data\ui_data_2018.dta",force
keep if _merge==3 | _merge == 1
drop _merge

* match the ui duration weeks
merge m:1 state year month using "Data\ui_wks.dta", force
replace alt_totwks =  26 if year < 2004
replace alt_totwks =  26 if year >= 2011  // may need to check

replace alt_totwks = 30 if year < 2004 &  state == "MA"
replace alt_totwks = 30 if year >=  2011 &  state == "MA"  // may need to check
replace alt_totwks = 30 if year < 2004 &  state == "WA"
replace alt_totwks = 30 if year >= 2011 &  state == "WA" // may need to check
keep if _merge == 3 | _merge == 1
drop _merge


* UI Paycheck Frequence
gen biweek = 1
replace biweek = 2 if inlist(state, "CA", "NJ", "IL", "PA", "OH", "TX")
replace biweek = 2 if inlist(state, "FL", "MI", "HI", "KY", "AK", "GA", "MT", "WY")
/* Remark: paid every two weeks https://www.uc.pa.gov/unemployment-benefits/handbook/Pages/Payment-of-Benefits.aspx 
biweeks: CA, NJ, IL, PA, OH, TX, FL, MI, HA (both), Kentucky, Alaska, Georgia, Montana(both), Wyoming
weekly: AL, NY, Missouri, North Carolina, South Dakota, Wisconsin, Louisiana, North Dakota. Tennessee, Maine, Nebraska, Arkansas, Idaho, Maryland,  Nevada, Oklahoma, Utah, Mississippi, New Hampshire, 
				New Mexico, Oregon, Rhode Island, Vermont 
*/


* match the state characteristics
merge m:1 state year using "Data\US_Current_Policy_1980_2018.dta",force
keep if _merge == 3 | _merge == 1
drop _merge


* merge the union coverage data
cap drop _merge
merge m:1 statelong year using "Data\union_coverage_1977_2017.dta", force
keep if _merge == 3 |  _merge == 1


* merge the CPI data
cap drop _merge
merge m:1 year using  "Data\US_CPI.dta", force

cap drop _merge
merge m:1 year using  "Data\US_Food_CPI.dta", force


* merge actual UI data
cap drop _merge
merge m:1 state year using "Processed\actual_ui_1995_2017.dta", force
keep if _merge == 3



*< < <  STATE LEVEL VARIABLE CREATION > > > *

// modify the state characteristics
scalar show_state_characteristics = 1
if show_state_characteristics == 1{

rename population pop
cap drop lgpop
gen lgpop = log(pop)

rename grossstateproduct gdp_state
cap drop lggdp_state
gen lggdp_state = log(gdp_state * 1000000)

cap drop gdpp_state
gen gdpp_state = gdp_state*1000000/pop

cap drop lggdpp_state
gen lggdpp_state = log(gdp_state*1000000/pop)

// state worker's compensation
cap drop wkcomp
gen wkcomp = log(workerscompensation)

// state wic participation ratio
cap drop wic_ratio
gen wic_ratio = wicparticipation/pop

cap drop aftc_ratio
gen aftc_ratio =  afdctanfrecipients/pop

cap drop snap_ratio
gen snap_ratio =  foodstampsnaprecipients/pop

cap drop snap_ratio_hh
gen snap_ratio_hh = foodstampsnapcaseloads/pop

rename stateminimumwage state_mw
replace state_mw = state_mw

rename fssnapbenefitfor1personfamily snap_1p
rename fssnapbenefitfor2personfamily snap_2p
rename fssnapbenefitfor3personfamily snap_3p
rename fssnapbenefitfor4personfamily snap_4p

rename eitcmaximumcreditnodependents eitc_0p
rename eitcmaximumcredit1dependent   eitc_1p
rename eitcmaximumcredit2dependents  eitc_2p
rename eitcmaximumcredit3dependents  eitc_3p
rename stateeitcrate eitc_rate
rename refundablestateeitc1yes eitc_refund

cap drop medicaid_ratio2
gen medicaid_ratio2 = medicaidbeneficiaries/pop

rename afdctanfbenefitfor2personfamily afdc_2p
rename afdctanfbenefitfor3personfamily afdc_3p
rename afdctanfbenefitfor4personfamily afdc_4p

cap drop medicaid_enroll
gen medicaid_enroll = medicaidbeneficiaries
replace medicaid_enroll = 400029 if state == "KS" & year == 2011
replace medicaid_enroll = 438322 if state == "ME" & year == 2011
replace medicaid_enroll = 963588 if state == "OK" & year == 2011
replace medicaid_enroll = 369608 if state == "UT" & year == 2011

cap drop medicaid_ratio
gen medicaid_ratio = medicaid_enroll/pop
	
cap drop nslp_ratio
gen nslp_ratio = nslptotalparticipation / pop
	
 cap drop nslp_ratio2
 gen nslp_ratio2 = nslpfreeparticipation/pop
 
cap drop nslp_ratio3
gen nslp_ratio3 = nslpreducedparticipation/pop

cap drop sbp_ratio
gen sbp_ratio =  sbptotalparticipation/pop

cap drop sbp_ratio2
gen sbp_ratio2 =  sbpfreeparticipation/pop

cap drop sbp_ratio3
gen sbp_ratio3 = sbpreducedparticipation/pop
}



rename percentlowincomeunisuredchildren perchild
label var perchild "percent of low income uninsured children"

cap drop ssi_ratio
gen ssi_ratio  = ssirecipients/pop

cap drop afdc_ratio
gen afdc_ratio = afdctanfrecipients/pop


*< < < CPI ADJUSTMENT FOR MONETARY VARIABLES > > >
gen cpi_denominator = 170.313   // if 2016 166.463


foreach j of varlist snap_1p snap_2p  snap_3p  snap_4p eitc_0p eitc_1p eitc_2p eitc_3p state_mw  afdc_2p afdc_3p afdc_4p ssifederal ssistate totalssi ssi_fsbenefit  gdp_state gdpp_state {
	replace `j' =  `j'/food_cpi * cpi_denominator

}


* transformations of UI
replace uijan = (uijan / 100)   // /cpi * 240.007
replace uijul = (uijul / 100)    // / cpi * 240.007


gen uijan_fcpi = (uijan )   /food_cpi * cpi_denominator
gen uijul_fcpi = (uijul )   /food_cpi * cpi_denominator
gen  ui_inc_fcpi = ui_inc/food_cpi * cpi_denominator

gen uijan_cpi = (uijan )   /cpi * 240.007
gen uijul_cpi = (uijul )   / cpi * 240.007

gen uiave = uijan/2 + uijul/2
gen uiave_cpi = uijan_cpi/2 + uijul_cpi/2
gen uiave_fcpi = uijan_fcpi/2 + uijul_fcpi/2

gen tot_uijan  = uijan * alt_totwks
gen tot_uijul  = uijul * alt_totwks
gen tot_uiave  = uiave * alt_totwks

gen tot_uijan_fcpi = tot_uijan/food_cpi * cpi_denominator
gen tot_uijul_fcpi = tot_uijul/food_cpi * cpi_denominator
gen tot_uiave_fcpi = tot_uiave/food_cpi * cpi_denominator


gen lguijan_fcpi = log(uijan_fcpi)
gen lguijul_fcpi = log(uijul_fcpi)
gen lguiave_fcpi = log(uiave_fcpi)
gen lgtot_uiave_fcpi = log(tot_uiave_fcpi)
gen lgtot_uijan_fcpi = log(tot_uijan_fcpi)
gen lgtot_uijul_fcpi = log(tot_uijul_fcpi)

gen lguijan = log(uijan)
gen lguijul = log(uijul)

gen ui_cdep = 1 if cdepjul > 0 & cdepjul != .
replace ui_cdep = 1 if cdepjan > 0 & cdepjan != .
replace ui_cdep = 0 if cdepjul == . & cdepjan == .

gen cdepjul_fcpi = cdepjul / food_cpi *  cpi_denominator / 100
gen cdepjan_fcpi =  cdepjan / food_cpi *  cpi_denominator / 100

cap drop uijul_cdep_fcpi
gen uijul_cdep_fcpi = uijul_fcpi if cdepjul == .
replace uijul_cdep_fcpi =  cdepjul_fcpi   if cdepjul != .

gen uijul_dep_fcpi = uijul_cdep_fcpi - uijul_fcpi

cap drop uijan_cdep_fcpi
gen uijan_cdep_fcpi = uijan_fcpi if cdepjul == .
replace uijan_cdep_fcpi =  cdepjan_fcpi   if cdepjul != .

gen uijan_dep_fcpi = uijan_cdep_fcpi - uijan_fcpi

cap drop lguijul_cdep_fcpi 
gen lguijul_cdep_fcpi = log(uijul_cdep_fcpi)
cap drop lguijan_cdep_fcpi 
gen lguijan_cdep_fcpi = log(uijan_cdep_fcpi)
cap drop uiave_cdep_fcpi 
gen uiave_cdep_fcpi = (uijul_cdep_fcpi + uijan_cdep_fcpi)/2
cap drop lguiave_cdep_fcpi
gen lguiave_cdep_fcpi = log(uiave_cdep_fcpi)


replace actual_UI_AWB= actual_UI_AWB / food_cpi * cpi_denominator
replace actual_UI= actual_UI/ food_cpi * cpi_denominator

//  Actual UI income 
gen ui_finc_fcpi_ave = ui_finc_ave / food_cpi * cpi_denominator

gen ui_finc_fcpi = ui_finc /food_cpi * cpi_denominator //REMARK: 11/30/2019
label var ui_finc_fcpi "(Household) Total Unemployment Insurance Income"

cap drop lgui_inc_fcpi
gen lgui_inc_fcpi = log(ui_inc_fcpi)




// Family Income
cap drop inc
gen inc = 2500 if faminc == 100
replace inc = (5000 + 7500)/2 if faminc == 210
replace inc = (7500+10000)/2 if faminc == 300
replace inc = (10000 + 12500)/2 if faminc == 430
replace inc = (12500 + 15000)/2 if faminc == 470
replace inc = (15000 + 20000)/2 if faminc == 500
replace inc = (20000 + 25000)/2 if faminc == 600
replace inc = (25000 + 30000)/2 if faminc == 710
replace inc = (30000 + 35000)/2 if faminc == 720
replace inc = (35000 + 40000)/2 if faminc == 730
replace inc = (40000 + 50000)/2 if faminc == 740
replace inc = (50000 + 60000)/2 if faminc == 820
replace inc = (60000 + 75000)/2 if faminc == 830
replace inc = 100000 if inlist(faminc, 840, 841, 842, 843) 

gen inc_fcpi = (inc)   /food_cpi * cpi_denominator

gen hhincome_fcpi = hhincome/food_cpi * cpi_denominator
gen ftotval_fcpi = ftotval/food_cpi * cpi_denominator

* Inidividual income
gen inctot_fcpi = inctot/food_cpi * cpi_denominator



*< < < Food insecurity CPI ADJUSTMENT> > >
cap drop lgsnap_val
gen lgsnap_val = log(snap_val)

cap drop lguiave_fcpi
gen lguiave_fcpi = log(uiave_fcpi)

cap drop snap_val_fcpi
gen  snap_val_fcpi = snap_val/food_cpi * cpi_denominator

cap drop snap_val_fcpi_pos
gen snap_val_fcpi_pos = snap_val_fcpi if snap_val_fcpi > 0

cap drop lgsnap_val_fcpi
gen lgsnap_val_fcpi = log(snap_val_fcpi)

cap drop ui_inc_fcpi_m
gen ui_inc_fcpi_m = ui_inc_fcpi / alt_totwks

cap drop lgui_inc_fcpi_m 
gen lgui_inc_fcpi_m = log(ui_inc_fcpi_m)

gen ui_take = 1 if ui_inc > 0 & ui_inc != .
replace ui_take = 0 if ui_inc == 0 

cap drop totui
gen totui =  uiave_fcpi * alt_totwks

cap drop lgsnap_val_fcpi_pos 
gen lgsnap_val_fcpi_pos = log(snap_val_fcpi_pos)






* < < < OTHER VARIABLES > > >*
ta gestfips, gen(ss)
*ta year, gen(yy)


cap drop year_trend
gen year_trend  = year


cap drop yy*
ta year, gen(yy)

cap drop gest_state
ta gestfips, gen(gest_state)




*** impact of UI on food insecurity, stamp take up rate
label var uiave_fcpi "Ave. UI (Jan  $\&$ Jul)"
label var uijan_fcpi "UI in Jan"
label var uijul_fcpi "UI in July"
label var alt_totwks "UI Max Duration"
label var tot_uiave "total UI (by ave)"
label var tot_uijan  "total UI (by jan)"
label var tot_uijul  "total UI (by jul)"
label var ui_inc_fcpi "Actual UI Income"
label var lguiave_fcpi "Log Ave. UI (Jan $\&$ Jul)"
label var lguijan_fcpi "Log  UI in Jan"
label var lguijul_fcpi "Log UI in Jul"

label var snap_take "Food Stamp Take-up Status"
label var snap_mth "Food Stamp Takeup Month"
label var snap_mth_pos "Food Stamp Takeup Month \\ (if taking)"
label var snap_val_fcpi "Food Stamp Market Value"
label var snap_val_fcpi_pos "Food Stamp Market Value \\ (if taking)"
label var lgsnap_val_fcpi "Log Food Stamp Market Value \\(if taking)"




save "Processed\ASEC_REG.dta", replace




