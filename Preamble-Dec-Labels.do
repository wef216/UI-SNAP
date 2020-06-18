******************** Create the Regression Elements ************


*** impact of UI on food insecurity, stamp take up rate
label var uiave_fcpi "Ave. UI (Jan  $\&$ Jul)"
label var uijan_fcpi "UI in Jan"
label var uijul_fcpi "UI in July"
label var alt_totwks "UI Max Duration"
label var tot_uiave "total UI (by ave)"
label var tot_uijan  "total UI (by jan)"
label var tot_uijul  "total UI (by jul)"
*label var ui_inc_fcpi "Actual UI Income"
label var lguiave_fcpi "Log Ave. UI (Jan $\&$ Jul)"
label var lguijan_fcpi "Log  UI in Jan"
label var lguijul_fcpi "Log UI in Jul"


/*
label var uiave_fcpi_eligible  "Ave. UI (Jan  $\&$ Jul)  $\times$ UI Eligible"
label var alt_totwks_eligible   "UI Max Duration $\times$ UI Eligible"
label var eligible  "UI Eligible"

label var uiave_fcpi_lead1 "Ave UI  (Jan  $\&$ Jul) : 1 Year Leaded"
label var uiave_fcpi_lead2 "Ave UI  (Jan  $\&$ Jul) : 2 Years Leaded"
label var uiave_fcpi_lag1 "Ave UI  (Jan  $\&$ Jul) : 1 Years Lagged"
label var uiave_fcpi_lag2 "Ave UI  (Jan  $\&$ Jul) : 2 Years Lagged"
*/
global outcomes fs fsrawscr_d fsrasch  fsa fsc fs_takeup2 fs_totval fs_takeup2 fs_totval fs fs_d fsrasch

label var fs  "household food insecurity, last year"
label var fsrawscr  "household food insecurity raw score, last year"
label var fsrawscr_pos "household food insecurity: \\ at least one positive raw score, last year"
label var fsrasch "household food rasch score, last year"
label var fsrasch_pos "household food insecurity: \\ rasch score with positive value, last year"
label var fs_takeup2 "household food stamp take up status, last year"
label var fs_totval "household total food stamp values, last year"
label var fs_value  "household food stamp values per month, last year"
label var fs_take  "months household take the stamp, last year"

global notes1 "standard errors are clustered at state level"
