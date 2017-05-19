clear all
set more off, permanently
set matsize 800
adopath + ../lib/stata/gslab_misc/ado

cd "C:\Users\dgentil1\Desktop\Master Project\Build\code" 

****** Using CPS ASEC (March supplement) data from 1996 to 2014 ****** 
use "../raw/rawCPSASEC.dta", clear

* We drop observations out of metropolitan areas or in unidentified ones *
drop if inlist(metarea,9999,9998,9997)

* We will work with observations from 24 to 60 years *
keep if age >= 24 & age <= 60

* Unifying metarea codes, because there were changes in definitions *
tostring metarea, gen(metarea1)
destring metarea1, gen(metarea2)

gen metcode=substr(metarea1,1,1) if metarea2<100
replace metcode=substr(metarea1,1,2) if metarea2>=100 & metarea2<1000
replace metcode=substr(metarea1,1,3) if metarea2>=1000 

destring metcode, gen(metcode2)

* Extrapolating the weeks worked bins *
replace wkswork2 = 0 if wkswork2 == 0
replace wkswork2 = 7 if wkswork2 == 1
replace wkswork2 = 20 if wkswork2 == 2
replace wkswork2 = 33 if wkswork2 == 3
replace wkswork2 = 44 if wkswork2 == 4
replace wkswork2 = 48.5 if wkswork2 == 5
replace wkswork2 = 51 if wkswork2 == 6
replace wkswork1 = wkswork2 if wkswork1 == . & wkswork2 != .
drop wkswork2

gen weekly_incwage = incwage / wkswork1
rename incwage yearly_incwage 

* Deflating income variables *
gen r_y_wage=yearly_incwage*cpi99
gen r_w_wage=weekly_incwage*cpi99

* Identifying employed, unemployed and inactive * 
gen inactive=0
replace inactive=1 if empstat>=30
gen emplyd=0
replace emplyd=1 if (empstat==01 | empstat==10 | empstat==12) /* we consider armed forces as employed */
gen unem=0 
replace unem=1 if inactive==0 & emplyd==0

* Creating sociodemographic variables *
recode sex (1=0)
recode sex (2=1)
label define sex 1 "Female" 0 "Male"
label values sex sex

gen manuf = .
replace manuf = 1 if ind1950 > 300 & ind1950 < 500
replace manuf = 0 if manuf == . & ind1950 != 0
gen bluecol = .
replace bluecol = 1 if ind1950 !=0 & ind1950 < 500
replace bluecol = 0 if bluecol == . & ind1950 != 0
gen whitecol = .
replace whitecol = 1 if ind1950 > 700
replace whitecol = 0 if whitecol == . & ind1950 != 0

gen workcat=1 if manuf==1
replace workcat=2 if bluecol==1
replace workcat=3 if whitecol==1

gen mexican=0
replace mexican=1 if (hispan>=100 & hispan<=109)	
gen nmhispan=0
replace nmhispan=1 if hispan!=0 & hispan!=100 & hispan!=102 & hispan!=103 & hispan!=104 ///
& hispan!=108 & hispan!=109	
gen black=0
replace black=1 if race==200 & mexican==0 & nmhispan==0
gen white=0
replace white=1 if race==100 & mexican==0 & nmhispan==0 
gen other=0
replace other=1 if white!=1 & black!=1 & mexican!=1 & nmhispan!=1

gen ethnic=1 if mexican==1
replace ethnic=2 if nmhispan==1
replace ethnic=3 if black==1
replace ethnic=4 if white==1
replace ethnic=5 if other==1

gen lr_y_wage=ln(r_y_wage)
gen lr_w_wage=ln(r_w_wage)

gen nohighsch = educ < 70 
gen highsch = educ < 80 & educ >=70
gen somecollege = educ < 110 & educ >=80
gen college = educ >= 110

gen educat=1 if nohighsch==1
replace educat=2 if highsch==1
replace educat=3 if somecollege==1
replace educat=4 if college==1

gen poor = (offpov == 1)
gen hhld_inc = hhincome if hhincome >= 0
gen hours_worked =  ahrsworkt if  ahrsworkt != 999

gen id = _n	
save "../temp/CPSASEC.dta", replace

* Identifying Katrina affected areas, and areas with large inflow of evacuees to take them out of the control * 
gen kat_affected=0
replace kat_affected=1 if inlist(metcode2,516,76,388,396,335,556,92,268, ///
    275,500,534,601,608,896)

gen evac = (katevac2 == 1)

save "../temp/CPSASEC.dta", replace

use "../temp/CPSASEC.dta", clear

keep if year == 2006
bysort metcode2: gen num_obs=_N
keep if num_obs > 100

collapse (mean) share_evac = evac kat_affected num_obs (sd) share_evac_sd = evac ///
    (count) obs = id [aw=wtsupp], by(metcode2)
sort share_evac

save "../derived/lot_evac_list_to_match.dta", replace

local upper_threshold = 0.005
local lower_threshold = 0.0001
local significance_10 = 1.285

gen t_stat_bigger = (share_evac - `upper_threshold')/(share_evac_sd/sqrt(obs))
gen t_stat_lower = (share_evac - `lower_threshold')/(share_evac_sd/sqrt(obs))

gen treat =(share_evac > `upper_threshold' & kat_affected == 0 & t_stat_bigger > `significance_10') /* One tail test (bigger than 1%) */

gen control = (kat_affected == 0 & (t_stat_lower < - `significance_10' | missing(t_stat_lower)))

save "../derived/lot_evac_list.dta", replace

* adding in-sample pre-treatment labor outcomes 

use "../temp/CPSASEC.dta", clear

keep if (year == 2005)
collapse (mean) lr_w_wage_1 = lr_w_wage hourwage_1 = hourwage unem_1 = unem [aw=wtsupp], by(metcode2)

merge 1:1 metcode2 using "../derived/lot_evac_list.dta", nogen

save "../derived/lot_evac_list.dta", replace

use "../temp/CPSASEC.dta", clear

keep if (year == 2001 | year == 2002 | year == 2003 | year == 2004 | year == 2005)
collapse (mean) lr_w_wage_5 = lr_w_wage hourwage_5 = hourwage unem_5 = unem [aw=wtsupp], by(metcode2)

merge 1:1 metcode2 using "../derived/lot_evac_list.dta", nogen

save "../derived/lot_evac_list.dta", replace

merge 1:m metcode2 using "../temp/CPSASEC.dta", nogen
sort metcode2 year

drop union /* Let's drop whatever we don't use to make the data cleaner */

* Flagging treated cities *
gen houston = (metcode2 == 336)
gen dallas = (metcode2 == 192)
gen fayetteville = (metcode2 == 258)

gen postkat=0
replace postkat=1 if year>=2006

* Saving final dataset * 

save "../derived/CPSASECfinal.dta", replace
