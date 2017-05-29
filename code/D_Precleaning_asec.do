 
 *----------------------------- Preparing Dataset -----------------------------*

  ***** Define Program 

  program define d_precleaning_asec

	* adopath + ../lib/stata/gslab_misc/ado

 ***** Open dataset

	use "../raw/rawCPSASEC.dta", clear 
	// Using CPS ASEC (March supplement) data from 1996 to 2014
	
 ***** Keeping needed variables

	keep year serial hwtsupp metarea hhincome cpi99 month pernum wtsupp age sex race ///
		 hispan educ educ99 empstat ind1950 wkswork1 wkswork2 ahrsworkt hourwage  	 ///
		 incwage offpov katevac katevac2 katprior wksunem1 marst occ2010
	
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

	* Education status *
	
		gen nohighsch = educ<70 
		gen highsch = (educ<80 & educ>=70)
		gen somecollege = (educ<110 & educ>=80)
		gen college = educ>=110
		// Identifying education levels

		gen educat = 1 if nohighsch==1
		replace educat = 2 if highsch==1
		replace educat = 3 if somecollege==1
		replace educat = 4 if college==1
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
		  	
		gen manuf=.
		replace manuf=1 if (ind1950>300 & ind1950<500)
		replace manuf=0 if (manuf==. & ind1950!=0)
		gen bluecol=.
		replace bluecol=1 if (ind1950!=0 & ind1950<500)
		replace bluecol=0 if (bluecol==. & ind1950!=0)
		gen whitecol=.
		replace whitecol=1 if ind1950>700
		replace whitecol=0 if (whitecol==. & ind1950!=0)
		// Identifying white collars, blue collars and manufacturing
		
		gen workcat=1*(manuf==1)+2*(bluecol==1)+3*(whitecol==1)
		// Generating working categories
	
		label var manuf "Manufacturing"
		label var bluecol "Blue collar"
		label var whitecol "White collar"
		label var workcat "Work categories"

		label define lblworkcat 1 "High school dropout" 2 "High school completed" ///
							   3 "Some college completed" 4 "College completed"
		label values workcat lblworkcat

	* Wages *
	
		gen hours_worked = ahrsworkt if ahrsworkt != 999
		// Generating hours workerd
		
		replace wkswork2=0*(wkswork2==0)+7*(wkswork2==1)+20*(wkswork2==2) ///
							   +33*(wkswork2==3)+44*(wkswork2==4) ///
							   +48.5*(wkswork2==5)+51*(wkswork2==6)
		replace wkswork1=wkswork2 if (wkswork1==. & wkswork2!=.)
		drop wkswork2
		// Extrapolating the weeks worked bins
		  // wkswork2 gives the weeks worked (intervalled). 
		  // We replace each interval with its average weeks worked for that interval
		
		gen w_wage=incwage/wkswork1
		rename incwage y_wage 
		// Generating yearly and weekly income wages
		
		gen r_w_wage=w_wage*cpi99
		gen r_y_wage=y_wage*cpi99
		// Deflating income variables
		
		gen lr_w_wage=ln(r_w_wage)
		gen lr_y_wage=ln(r_y_wage)
		// Generating logarithm of yearly and weekly wages
	
		label var hours_worked "Hours worked last week"
		label var wkswork1 "Weeks worked last year"
		label var w_wage "Weekly wage"
		label var y_wage "Yearly wage"
		label var r_w_wage "Real weekly wage"
		label var r_y_wage "Real yearly wage"
		label var lr_w_wage "Logarithm real weekly wage"
		label var lr_y_wage "Logarithm real yearly wage"
		
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
		  // SORTED BY METAREA?

		label var id "Individual identifier"
		
	* saving dataset
	
	save "../temp/CPSASEC.dta", replace
	cap saveold "../temp/CPSASEC.dta", v(12) replace

  end

********************************************************************************  
