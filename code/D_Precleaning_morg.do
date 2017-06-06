
 *--------------------- Preparing MORG Dataset (1996-2016) --------------------*

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
		 uhourse weight weightp year msafips occ80 occ00 occ2011 occ2012 penatvty ///
		 ownchild chldpres unionmme marital prunedur ftpt94

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
		gen mexican = (ethnic==3) | (ethnic==1)
		gen nmhispan = (ethnic!=8 & ethnic!=9 & ethnic!=3 & ethnic!=1)
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

	* Native *
		
		gen native=1*(penatvty<100)
		
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
	
	* Industry *
	
		gen bluecol=0
		replace bluecol=. if ind80==. | ind02==.
		replace bluecol=1 if (ind80>=10 & ind80<=691) | (ind02>=170 & ind02<=6780)
		replace bluecol=1 if (ind80==991) | (ind02==9890) /* Armed Forces + Unemployed*/
		
		gen whitecol=0
		replace whitecol=. if (ind80==. | ind02==.)		
		replace whitecol=1 if (ind80>=700 & ind80<=932) | (ind02>=6870 & ind02<=9590)
		// Identifying white collars and blue collars
		
		gen workcat=1*(bluecol==1)+2*(whitecol==1)
		replace workcat=. if (bluecol==.&whitecol==.)
		// Generating working categories
	
		label var bluecol "Blue-collar"
		label var whitecol "White-collar"
		label var workcat "Work categories"

		label define lblworkcat 1 "Blue-collar" 2 "White-collar" 
		label values workcat lblworkcat
	
	* Occupation *
		
		gen kindocc = .
		 
		* Years from 1996 to 1999
		replace kindocc=. if occ80==. & (year>=1996&year<2000)
		replace kindocc=0 if (occ80>=3&occ80<=199) & (year>=1996&year<2000)
		replace kindocc=300 if (occ80>=203&occ80<=389) & (year>=1996&year<2000)
		replace kindocc=500 if (occ80>=503&occ80<=699) & (year>=1996&year<2000)
		replace kindocc=600 if (occ80>=703&occ80<=889) & (year>=1996&year<2000)
		replace kindocc=700 if (occ80>=403&occ80<=469) & (year>=1996&year<2000)
		replace kindocc=810 if (occ80>=473&occ80<=499) & (year>=1996&year<2000)
		replace kindocc=1 if (occ80==905) & (year>=1996&year<2000) /*Unemployed + Armed Forces*/
		replace kindocc=. if occ80==. & (year>=1996&year<2000)		
		 

		* Years from 2000 to 2010
		replace occ00=occ00/10 if occ00>=0 & (year>=2000)
		
		replace kindocc=0 if (occ00>=1&occ00<=359) & (year>=2000 & year<2011) 
		replace kindocc=300 if (occ00>=500&occ00<=599) & (year>=2000 & year<2011)
		replace kindocc=400 if (occ00>=470&occ00<=499) & (year>=2000 & year<2011)
		replace kindocc=500 if (occ00>=612&occ00<=983) & (year>=2000 & year<2011)
		replace kindocc=700 if (occ00>=360&occ00<=469) & (year>=2000 & year<2011)
		replace kindocc=810 if (occ00>=600&occ00<=611) & (year>=2000 & year<2011)
		replace kindocc=1 if (occ00==984) & (year>=2000 & year<2011) /*Armed Forces*/
		replace kindocc=. if occ00==. & (year>=2000 & year<2011)		

		* Years 2011
		replace occ2011=occ2011/10 if occ2011>=0 & (year>=2011 & year<2012)
		
		replace kindocc=0 if (occ2011>=1&occ2011<=359) & (year>=2011 & year<2012) 
		replace kindocc=300 if (occ2011>=500&occ2011<=599) & (year>=2011 & year<2012)
		replace kindocc=400 if (occ2011>=470&occ2011<=499) & (year>=2011 & year<2012)
		replace kindocc=500 if (occ2011>=612&occ2011<=983) & (year>=2011 & year<2012)
		replace kindocc=700 if (occ2011>=360&occ2011<=469) & (year>=2011 & year<2012)
		replace kindocc=810 if (occ2011>=600&occ2011<=611) & (year>=2011 & year<2012)
		replace kindocc=1 if (occ2011==984) & (year>=2011 & year<2012) /*Armed Forces*/
		replace kindocc=. if occ2011==. & (year>=2011 & year<2012)		

		* Years from 2012 to 2014		
		replace occ2012=occ2012/10 if occ2012>=0 & (year>=2012)
		
		replace kindocc=0 if (occ2012>=1&occ2012<=359) & (year>=2012) 
		replace kindocc=300 if (occ2012>=500&occ2012<=599) & (year>=2012)
		replace kindocc=400 if (occ2012>=470&occ2012<=499) & (year>=2012)
		replace kindocc=500 if (occ2012>=612&occ2012<=983) & (year>=2012)
		replace kindocc=700 if (occ2012>=360&occ2012<=469) & (year>=2012)
		replace kindocc=810 if (occ2012>=600&occ2012<=611) & (year>=2012)
		replace kindocc=1 if (occ2012==984) & (year>=2012) /*Armed Forces*/
		replace kindocc=. if occ2012==. & (year>=2012)		
		 
		label variable kindocc "Occupation"

		gen collarocc=4 if kindocc>980
		gen collarocc=3 if kindocc==1
		replace collarocc=2 if kindocc>=500 & kindocc<=980
		replace collarocc=1 if kindocc>=0 & kindocc<=499
		
		label variable collarocc "Type of Job"
		label define collarocclbl 1 "White-collar", add 
		label define collarocclbl 2 "Blue-collar", add
		label define collarocclbl 3 "Armed Forces", add
		label define collarocclbl 4 "Unemployed", add
		label values collarocc collarocclbl
	
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
		
		drop metarea metarea1 metarea2 metcode

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



