program precleaning_morg

* loading data

use "../raw/morg96.dta", clear

local year_list "97 98 99 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14"

forval i=1/18 {
    local year: word `i' of `year_list'
	append using "../raw/morg`year'.dta"
}

* generating unified MSA codes

gen metarea = .
replace metarea = msafips 
replace metarea = cbsafips if missing(msafips)

tostring metarea, gen(metarea1)
destring metarea1, gen(metarea2)

gen metcode=substr(metarea1,1,1) if metarea2<100
replace metcode=substr(metarea1,1,2) if metarea2>=100 & metarea2<1000
replace metcode=substr(metarea1,1,3) if metarea2>=1000 

destring metcode, gen(metcode2)

* We drop observations out of metropolitan areas or in unidentified ones *
drop if missing(metcode2)

* We will work with observations from 24 to 60 years *
keep if age >= 24 & age <= 60

* adding cpi base 99 index (created for fed data)
merge m:1 year using "../derived_morg/CPI99morg.dta", keep(3) assert(3) keepusing(cpi99)

* flagging treatment and control
merge m:1 metcode2 using "../derived_asec/treat_and_control_list.dta", nogen keep(3)

gen houston = (metcode2 == 336)
gen dallas = (metcode2 == 192)
gen fayetteville = (metcode2 == 258)

* Generate the same labor and demographic variables that in our March ASEC
end
