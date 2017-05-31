
 *------------------ Preparing the dataset MORG (1994-2016) ------------------*

  ***** Define Program 
  
  program d_precleaning_morg

  ***** Loading the data

	use "../raw/morg96.dta", clear

	local year_list "97 98 99 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14"

	forvalues i=1/18 {
		local year: word `i' of `year_list'
		append using "../raw/morg`year'.dta"
	}

  ***** Keeping needed variables

	keep age cbsafips earnhre earnwke earnwt earnwtp ethnic grade92 hhid hhnum ///
		 hrhtype hrhhid2 hrsample ind02 ind80 lfsr94 purkat1 purkat2 race sex ///
		 uhourse weight weightp year msafips 

  ***** Adding CPI base 99 index (source FED data)
	
	merge m:1 year using "../derived_morg/CPI99morg.dta", nogen keep(3) assert(3) keepusing(cpi99)

  ***** Generate the same labor and demographic variables that in our March ASEC

	* Age *
	
		keep if age >= 24 & age <= 60
		// We will work with observations from 24 to 60 years

	* Gender *
	
		recode sex (1=0)
		recode sex (2=1)
		// Re-coding gender

		label var sex "Gender"
		label define lblsex 1 "Female" 0 "Male"
		label values sex lblsex

	* Ethnicity *
	
		gen white = (race==1 & ethnic==8) | (race==1 & ethnic==9) | (race==1 & ethnic==.)
		gen black = (race==2 & ethnic==8) | (race==2 & ethnic==9) | (race==2 & ethnic==.)
		gen mexican = (ethnic==3)
		gen nmhispan = (ethnic!=8 & ethnic!=9 & ethnic!=3 & race!=1 & race!=2)
		gen other = (white==0 & black==0 & mexican==0 & nmhispan==0)
		// Identifying race
		
		drop ethnic
		gen ethnic=1*(mexican==1)+2*(nmhispan==1)+3*(black==1)+4*(white==1)+5*(other==1)
		// Generating ethnicity categories

		label var mexican "Mexican"
		label var nmhispan "Non-Mexican, Hispanic"
		label var black "Black"
		label var white "White"
		label var other "Other"
		label var ethnic "Ethnicity"

		label define lblethnic 1 "Mexican" 2 "Non-Mexican, Hispanic" ///
							   3 "Black" 4 "White" 5 "Other"
		label values ethnic lblethnic

	* Education status *
	
		gen nohighsch = grade92<38
		gen highsch = (grade92>=38 & grade92<40)
		gen somecollege = (grade92>=40 & grade92<43)
		gen college = grade92>=43
		// Identifying education levels

		gen educat = 1*(nohighsch==1)+2*(highsch==1)+3*(somecollege==1)+4*(college==1)
		// Generating education categories

		label var nohighsch "High school dropout"
		label var highsch "High school completed"
		label var somecollege "Some college completed"
		label var college "College completed"
		label var educat "Education levels"

		label define lbleducat 1 "High school dropout" 2 "High school completed" ///
							   3 "Some college completed" 4 "College completed"
		label values educat lbleducat

	* Labor status *

		gen inactive = lfsr94>3
		gen emplyd = lfsr94<=2 
		gen unem = (lfsr94>2 & lfsr94<=3)
		// Identifying employed, unemployed and inactive
		  // We consider armed forces as employed
		
		label var inactive "Inactive"
		label var emplyd "Employment"
		label var unem "Unemployment"
		
		gen bluecol=.
		replace bluecol=1 if (ind80>=10 & ind80<=691) | (ind02>=170 & ind02<=6780)
		replace bluecol=0 if bluecol==.
		
		gen whitecol=.
		replace whitecol=1 if (ind80>=700 & ind80<=932) | (ind02>=6870 & ind02<=9590)
		replace whitecol=0 if whitecol==.		
		// Identifying white collars, blue collars and manufacturing
		
		gen workcat=1*(bluecol==1)+2*(whitecol==1)
		// Generating working categories
	
		label var bluecol "Blue collar"
		label var whitecol "White collar"
		label var workcat "Work categories"

		label define lblworkcat 1 "Blue collar" 2 "White collar" 
		label values workcat lblworkcat

	* Wages *
	
		gen hours_worked = uhourse
		// Generating usual hours worked per week

		gen h_wage = earnwke/uhourse
		rename earnwke w_wage
		// Generating hourly and weekly income wages
		
		gen r_w_wage=w_wage*cpi99
		gen r_h_wage=h_wage*cpi99
		// Deflating income variables
		
		gen lr_w_wage=ln(r_w_wage)
		gen lr_h_wage=ln(r_h_wage)
		// Generating logarithm of yearly and weekly wages
		
		label var hours_worked "Usual hours worked per week"
		label var w_wage "Weekly wage"
		label var h_wage "Hourly wage"
		label var r_w_wage "Real weekly wage"
		label var r_h_wage "Real hourly wage"
		label var lr_w_wage "Logarithm real weekly wage"
		label var lr_h_wage "Logarithm real hourly wage"
		
	* Metropolitan Areas *
	
		gen metarea = .
		replace metarea = msafips 
		replace metarea = cbsafips if missing(msafips)

		tostring metarea, gen(metarea1)
		destring metarea1, gen(metarea2)

		gen metcode=substr(metarea1,1,1) if metarea2<100
		replace metcode=substr(metarea1,1,2) if metarea2>=100 & metarea2<1000
		replace metcode=substr(metarea1,1,3) if metarea2>=1000 

		destring metcode, gen(metcode2)
		label var metcode2 "Metropolitan Area"
		
		drop metarea1 metarea2 metcode

		* We drop observations out of metropolitan areas or in unidentified ones *
		drop if missing(metcode2)

	* Individual identifier *
	
		gen id = _n
		// Generate identifier for every observation

		label var id "Individual identifier"

	* Saving the dataset
	
	save "../temp/MORG.dta", replace
		 	 
		 
  end

********************************************************************************



