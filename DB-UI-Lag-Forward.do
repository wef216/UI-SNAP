



use "Data\ui_data_2020.dta", clear

cap drop _merge
merge m:1 year using  "Data\US_Food_CPI_2020.dta", force
drop if _merge == 2

gen cpi_denominator = 170.313   // if 2016 166.463



* UI
replace uijan = (uijan / 100)   // /cpi * 240.007
replace uijul = (uijul / 100)    // / cpi * 240.007
replace  cdepjul = cdepjul/100
replace cdepjan = cdepjan/100

cap drop uijul_cdep
gen uijul_cdep = uijul if cdepjul == .
replace uijul_cdep =  cdepjul  if cdepjul != .


cap drop uijan_cdep
gen uijan_cdep = uijan if cdepjul == .
replace uijan_cdep =  cdepjan   if cdepjul != .

replace uijul_cdep = uijan_cdep if year == 2020

gen uijul_cdep_fcpi =  uijul_cdep /food_cpi * cpi_denominator
gen uijan_cdep_fcpi =  uijan_cdep /food_cpi * cpi_denominator

gen uiave_cdep = (uijul_cdep + uijan_cdep)/2

gen uiave_cdep_fcpi = (uijul_cdep_fcpi + uijan_cdep_fcpi)/2

*replace uijul_cdep_fcpi = uijan_cdep_fcpi if month == 4

duplicates drop state year, force
drop if state == ""

sort state year
xtset gestfips year
forv j = 1/5{
gen uijul_cdep_l`j' = L`j'.uijul_cdep
gen uijul_cdep_fcpi_l`j' = uijul_cdep_l`j'  /food_cpi * cpi_denominator  //- uijul_cdep_fcpi
gen uijul_cdep_fcpi2_l`j' = L`j'.uijul_cdep_fcpi

gen uijul_cdep_f`j' = F`j'.uijul_cdep
gen uijul_cdep_fcpi_f`j' = uijul_cdep_f`j'  /food_cpi * cpi_denominator  //- uijul_cdep_fcpi
gen uijul_cdep_fcpi2_f`j' = F`j'.uijul_cdep_fcpi

gen uijan_cdep_l`j' = L`j'.uijan_cdep
gen uijan_cdep_fcpi_l`j' = uijan_cdep_l`j'  /food_cpi * cpi_denominator  //- uijul_cdep_fcpi
gen uijan_cdep_fcpi2_l`j' = L`j'.uijan_cdep_fcpi

gen uijan_cdep_f`j' = F`j'.uijan_cdep
gen uijan_cdep_fcpi_f`j' = uijan_cdep_f`j'  /food_cpi * cpi_denominator  //- uijul_cdep_fcpi
gen uijan_cdep_fcpi2_f`j' = F`j'.uijan_cdep_fcpi

gen uiave_cdep_l`j' = L`j'.uiave_cdep
gen uiave_cdep_fcpi_l`j' = uiave_cdep_l`j'  /food_cpi * cpi_denominator  //- uijul_cdep_fcpi
gen uiave_cdep_fcpi2_l`j' = L`j'.uiave_cdep_fcpi

gen uiave_cdep_f`j' = F`j'.uiave_cdep
gen uiave_cdep_fcpi_f`j' = uiave_cdep_f`j'  /food_cpi * cpi_denominator  //- uijul_cdep_fcpi
gen uiave_cdep_fcpi2_f`j' = F`j'.uiave_cdep_fcpi
}



cap drop lguijul_cdep_fcpi 
gen lguijul_cdep_fcpi = log(uijul_cdep_fcpi)


keep state year  uijul_cdep_* uijul_cdep_fcpi  uijul_cdep uijul_cdep_fcpi_* uijan_cdep_fcpi*  uiave_cdep_fcpi* uiave_cdep_fcpi 


save "Processed\UI_data_lead_forward.dta", replace





use "Processed\REG.dta", clear


duplicates drop state year , force
keep $zvar1 $zvar2 state year gestfips statelong alt_totwks
drop if year < 1995 |  year > 2019

sort state year
xtset gestfips year
foreach var in $zvar1 $zvar2 alt_totwks{
forv j = 1/3{
gen L`j'_`var' = L`j'.`var'

gen F`j'_`var' = F`j'.`var'

}
gen Yr_`var' = `var' * year
}

save "Processed\State_data_lead_forward.dta", replace


