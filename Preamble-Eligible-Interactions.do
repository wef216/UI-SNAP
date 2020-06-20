


foreach j of varlist $controls {
cap drop eligible_`j'
gen eligible_`j' = eligible * `j'
}

foreach j of varlist uiave_fcpi uijan_fcpi uijul_fcpi alt_totwks lguiave_fcpi lguijan_fcpi lguijul_fcpi ui_cdep uijul_cdep_fcpi uijan_cdep_fcpi uijul_dep_fcpi uijan_dep_fcpi uiave_cdep_fcpi {
cap drop `j'_eligible
gen `j'_eligible = eligible * `j'
}

label var uijul_fcpi "Jul UI "
label var lguijul_fcpi "Log Jul UI "
label var uijul_cdep_fcpi "Jul UI with Dependent Allowance"
label var uijan_cdep_fcpi "Jan UI with Dependent Allowance"
label var uiave_fcpi_eligible  "Ave. UI (Jan  $\&$ Jul) * UI Eligible"
label var uijan_fcpi_eligible  "Jan. UI  $\times$ UI Eligible"
label var uijul_fcpi_eligible  "Jul. UI  $\times$ UI Eligible"
label var uijul_cdep_fcpi_eligible "Jul UI with Dependent Allowance * UI Eligible"
label var uijan_cdep_fcpi_eligible "Jan UI with Dependent Allowance * UI Eligible"
label var lguiave_fcpi_eligible  "Log Ave. UI (Jan  $\&$ Jul) * UI Eligible"
label var lguijan_fcpi_eligible  "Log Jan. UI * UI Eligible"
label var lguijul_fcpi_eligible  "Log Jul. UI * UI Eligible"
label var alt_totwks_eligible   "UI Max Duration $\times$ UI Eligible"
label var ui_cdep_eligible   "UI including dependent * UI Eligible"
label var eligible  "UI Eligible"
label var ui_cdep "UI including the dependents"

