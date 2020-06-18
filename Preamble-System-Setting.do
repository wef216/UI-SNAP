


/***** Set the Stata Environment ******/
********************************************************************************
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



set more off
global miss -1 -2 -3 -4 -5 -6 -7 -8 -9 


