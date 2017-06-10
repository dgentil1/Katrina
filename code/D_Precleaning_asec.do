 
 *--------------------- Preparing ASEC Dataset (1996-2016)---------------------*

  ***** Define Program 

  program define d_precleaning_asec

	* adopath + ../lib/stata/gslab_misc/ado

 ***** Open dataset

	use "../raw/rawCPSASEC.dta", clear 
	// Using CPS ASEC (March supplement) data from 1996 to 2014
	
 ***** Keeping needed variables

	keep year serial hwtsupp metarea hhincome cpi99 month pernum wtsupp age sex race     ///
		 hispan educ educ99 empstat ind1950 wkswork1 wkswork2 ahrsworkt hourwage incwage ///
		 offpov katevac2 katprior wksunem1 marst occ2010 relate famrel migrate1 ///
		 occ bpl whymove
	
 ***** Dropping/Adjusting variables 

	* Age *

		keep if (age>=24 & age<=60)
		// We will work with observations from 24 to 60 years

	* Gender *
	
		recode sex (1=0)
		recode sex (2=1)
		// Re-coding gender

		label var sex "Gender"
		label define lblsex 1 "Female" 0 "Male"
		label values sex lblsex

	* Ethnicity *
	
		gen mexican = (hispan>=100 & hispan<=109)	
		gen nmhispan = (hispan!=0 & hispan!=100 & hispan!=102 ///
						& hispan!=103 & hispan!=104 & hispan!=108 & hispan!=109)	
		gen black = (race==200 & mexican==0 & nmhispan==0)
		gen white = (race==100 & mexican==0 & nmhispan==0)
		gen other = (white!=1 & black!=1 & mexican!=1 & nmhispan!=1)
		// Identifying race
		
		gen ethnic=1*(mexican==1)+2*(nmhispan==1)+3*(black==1)+ ///
						  4*(white==1)+5*(other==1)
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

	* Native US * 
	
		gen native_usa=1*(bpl<15000)
	
	* Local Native *
		
		gen whymove_job=1*(whymove>=4 & whymove<=8)
		gen sameplace=1*(migrate1>=1 & migrate1<=3 & whymove_job!=1)
		
		gen native_msa= 1*(native_usa==1 & sameplace==1)
		
	* Education status *
	
		gen nohighsch = educ<70 
		gen highsch = (educ<80 & educ>=70)
		gen somecollege = (educ<110 & educ>=80)
		gen college = educ>=110
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

		gen inactive = empstat>=30
		gen emplyd = (empstat==01 | empstat==10 | empstat==12) 
		gen unem = (inactive==0 & emplyd==0)
		// Identifying employed, unemployed and inactive
		  // We consider armed forces as employed
		
		label var inactive "Inactive"
		label var emplyd "Employment"
		label var unem "Unemployment"
	
	* Industry *
	
		gen bluecol=0
		replace bluecol=. if (ind1950==0 |ind1950==997 |ind1950==998) 
		replace bluecol=1 if (ind1950>=105 & ind1950<=699)

		gen whitecol=0
		replace whitecol=. if (ind1950==0 |ind1950==997 |ind1950==998)
		replace whitecol=1 if (ind1950>=716 & ind1950<=936)
		// Identifying white collars and blue collars
		
		gen workcat=1*(bluecol==1)+2*(whitecol==1)
		replace workcat=. if (bluecol==.&whitecol==.)
		// Generating working categories
	
		label var bluecol "Blue-collar"
		label var whitecol "White-collar"
		label var workcat "Work categories"

		label define lblworkcat 0 "Unknown" 1 "Blue-collar" 2 "White-collar"
		label values workcat lblworkcat
	
	* Occupation *

		gen kindocc = .

		* Years from 1996 to 2002
		replace kindocc=0 if (occ>=3&occ<=199) & (year>=1996&year<=2002)
		replace kindocc=300 if (occ>=203&occ<=389) & (year>=1996&year<=2002)
		replace kindocc=500 if (occ>=503&occ<=699) & (year>=1996&year<=2002)
		replace kindocc=600 if (occ>=703&occ<=889) & (year>=1996&year<=2002)
		replace kindocc=700 if (occ>=403&occ<=469) & (year>=1996&year<=2002)
		replace kindocc=810 if (occ>=473&occ<=499) & (year>=1996&year<=2002)
		replace kindocc=999 if (occ==0) & (year>=1996&year<=2002) /*Unknown*/
		replace kindocc=1 if (occ>=900) & (year>=1996&year<=2002) /*Armed forces + Unemployed*/

		* Years from 2003 to 2014
		replace occ=occ/10 if occ>=0 & year>=2003
		
		replace kindocc=0 if (occ>=1&occ<=359) & year>=2003 
		replace kindocc=300 if (occ>=500&occ<=599) & year>=2003
		replace kindocc=400 if (occ>=470&occ<=499) & year>=2003
		replace kindocc=500 if (occ>=612&occ<=983) & year>=2003
		replace kindocc=700 if (occ>=360&occ<=469) & year>=2003
		replace kindocc=810 if (occ>=600&occ<=611) & year>=2003
		replace kindocc=999 if (occ==0) & year>=2003 /*Unknown*/
		replace kindocc=1 if (occ>=984) & year>=2003 /*Armed forces*/
		
		label variable kindocc "Occupation"

		gen collarocc=4 if kindocc>980 /*Unknown*/
		gen collarocc=3 if kindocc==1 /*Armed forces*/
		replace collarocc=2 if kindocc>=500 & kindocc<=980
		replace collarocc=1 if kindocc>=2 & kindocc<=499
		
		label variable collarocc "Type of Job"
		label define collarocclbl 1 "White-collar", add 
		label define collarocclbl 2 "Blue-collar", add
		label define collarocclbl 3 "Armed Forces", add
		label define collarocclbl 4 "Unknown", add
		label values collarocc collarocclbl
	
	* Wages *
	
		gen hours_worked = ahrsworkt if ahrsworkt != 999
		// Generating hours worked last week
		
		replace wkswork2=0*(wkswork2==0)+7*(wkswork2==1)+20*(wkswork2==2) ///
						 +33*(wkswork2==3)+44*(wkswork2==4) ///
						 +48.5*(wkswork2==5)+51*(wkswork2==6)
		replace wkswork1=wkswork2 if (wkswork1==. & wkswork2!=.)
		drop wkswork2
		// Extrapolating the weeks worked bins
		  // wkswork2 gives the weeks worked (intervalled). 
		  // We replace each interval with its average weeks worked for that interval
		
		gen w_wage=incwage/wkswork1
		gen h_wage=w_wage/hours_worked
		// Generating yearly and weekly income wages
		
		gen r_w_wage=w_wage*cpi99
		gen r_h_wage=h_wage*cpi99
		// Deflating income variables
		
		gen lr_w_wage=ln(r_w_wage)
		gen lr_h_wage=ln(r_h_wage)
		// Generating logarithm of yearly and weekly wages
	
		label var hours_worked "Hours worked last week"
		label var wkswork1 "Weeks worked last year"
		label var w_wage "Weekly wage"
		label var h_wage "Hourly wage"
		label var r_w_wage "Real weekly wage"
		label var r_h_wage "Real hourly wage"
		label var lr_w_wage "Logarithm real weekly wage"
		label var lr_h_wage "Logarithm real hourly wage"
		
	* Poverty status *

		gen poor = (offpov==1)
		// Generating dummy for observation being below poverty line

		label var poor "Poverty status"

	* Household income *
	
		gen hhld_inc = hhincome if hhincome>=0
		// Generating household income

		label var hhld_inc "Household income"

	* Metropolitan Areas *
	
		drop if inlist(metarea,9999,9998,9997)
		// We drop unidentified metropolitan areas, households not in a metropolitan 
		// area, and missing data
				
		tostring metarea, gen(metarea1)
		destring metarea1, gen(metarea2)
		
		gen metcode=substr(metarea1,1,1) if metarea2<100
		replace metcode=substr(metarea1,1,2) if (metarea2>=100 & metarea2<1000)
		replace metcode=substr(metarea1,1,3) if metarea2>=1000 
		
		destring metcode, gen(metcode2)
		// Unifying metarea codes, because there were changes in definitions

		label var metcode2 "Metropolitan Area"

	* Individual identifier *
	
		gen id = _n
		// Generate identifier for every observation

		label var id "Individual identifier"
		
	* Saving the dataset
	
	save "../temp/CPSASEC.dta", replace

  end

********************************************************************************
