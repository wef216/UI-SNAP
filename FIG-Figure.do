
*****************Data Summary   ************************************************
/* Dependent Variable: Family Demographic Features
local m: word `k' of `outcomes'
local controls: list global(parentvar) - local(remove`k')

*/

						
version 14
set matsize 5000
set more off

global mode = 2

if $mode == 1{
// add new path for new device
global base "C:\Users\wef216\Dropbox\IPUMS-CPS"
global data "$base\data"
*global prog "$base\Code"
global output "$base\output"
global work "$base\work"

cd   "C:\Users\wef216\Dropbox\IPUMS-CPS"
}

if $mode == 2{
// add new path for new device
global base "C:\Users\fuwei\Dropbox\IPUMS-CPS"
cd   "C:\Users\fuwei\Dropbox\IPUMS-CPS\Analysis"
}



**********DATA SUMMARY: December Sample ************
use "Processed\Dec_REG_Sample.dta", clear

keep if main_sample == 1

/*duplicates drop state year, force
keep uijul_fcpi year state
sort state year*/

collapse uijul_fcpi uijul fsrawscr_pos , by(year)

twoway (line uijul_fcpi year, yaxis(1)) (line fsrawscr_pos year, yaxis(2))
