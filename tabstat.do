clear all
set more off, permanently
set matsize 800
adopath + ../lib/stata/gslab_misc/ado

cd "C:\Users\dgentil1\Desktop\Master Project\Build\code" 

* Computing decriptives evacuees vs nonevacuees

use "../raw/rawCPSASEC.dta", clear

keep if year == 2006
keep if age >= 24 & age <= 60

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

gen nohighsch = educ < 70 
gen highsch = educ < 80 & educ >=70
gen somecollege = educ < 110 & educ >=80
gen college = educ >= 110

gen poor = (offpov == 1)
gen hhld_inc = hhincome if hhincome >= 0
gen hours_worked =  ahrsworkt if  ahrsworkt != 999

gen evac = (katevac2 == 1)

clear matrix 
quietly: tabstat age nohighsch highsch somecollege college black mexican ///
    nmhispan white other poor if evac == 1 [aw=wtsupp], c(s) stat(mean semean) save
matrix pre_output = r(StatTotal)'
quietly: tabstat age nohighsch highsch somecollege college black mexican ///
    nmhispan white other poor if evac == 0 [aw=wtsupp], c(s) stat(mean semean) save
matrix pre_output = (pre_output , r(StatTotal)')

svmat pre_output

drop if missing(pre_output1)
keep pre_output*
rename (pre_output1 pre_output2 pre_output3 pre_output4) (evac_mean evac_semean nevac_mean nevac_semean)
gen diff_mean = evac_mean - nevac_mean
gen se_diff_mean = sqrt(evac_semean^2 + nevac_semean^2)

mkmat evac_mean nevac_mean diff_mean se_diff_mean, matrix(output)

matrix_to_txt, matrix(output) saving("../tables/descriptive_evac_vs_nevac.txt") replace ///
    format(%20.5f) title(<tab:descriptive>)

* Computing table of labor status of evacuees * 

use "../derived/CPSASECfinal.dta", clear

label var emplyd "Employment"
label var unem "Unemployment"
label var inactive "Inactive"

save "../derived/CPSASECfinal.dta", replace

keep if year == 2006
clear matrix 
quietly: tabstat emplyd inactive unem hours_worked [aw=wtsupp], c(s) stat(mean semean) save
matrix output = r(StatTotal)
quietly: tabstat emplyd inactive unem hours_worked if treatment == 1 [aw=wtsupp], c(s) stat(mean semean) save
matrix output = (output \ r(StatTotal))
quietly: tabstat emplyd inactive unem hours_worked if control == 1 [aw=wtsupp], c(s) stat(mean semean) save
matrix output = (output \ r(StatTotal))
quietly: tabstat emplyd inactive unem hours_worked if evac == 1 [aw=wtsupp], c(s) stat(mean semean) save
matrix output = (output \ r(StatTotal))
quietly: tabstat emplyd inactive unem hours_worked if (treat == 1 & evac == 1) [aw=wtsupp], c(s) stat(mean semean) save
matrix output = (output \ r(StatTotal))

matrix_to_txt, matrix(output) saving("../tables/labor_status_sample.txt") replace ///
    format(%20.5f) title(<tab:labor_status_sample>)

