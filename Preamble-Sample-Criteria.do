


*<< Set Samples >>
global agemin 56
global agemax 19

drop if agemin >= $agemin
drop if agemax <= $agemax

keep if survey_year >= 1999
keep if survey_year <= 2017
keep if  hh_psn <= 20
