 
 *--------------------- Preparing ASEC Dataset (1996-2016)---------------------*

  ***** Define Program 

  program define d_precleaning_asec

	* adopath + ../lib/stata/gslab_misc/ado

 ***** Open dataset

	use "../raw/rawCPSASEC.dta", clear 
	// Using CPS ASEC (March supplement) data from 1996 to 2014
	
 ***** Keeping needed variables

	keep year serial metarea hhincome cpi99 month pernum wtsupp age sex race  ///
		 hispan educ educ99 empstat ind1950 wkswork1 wkswork2 ahrsworkt hourwage incwage ///
		 offpov katevac katevac2 katprior wksunem1 marst occ2010 relate famrel migrate1 ///
		 bpl
	rename (wtsupp marst) (weight marital)
	
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

	* Local individuals * 
		
		gen locals = (migrate1==1 | migrate1==3)
		// Flagging locals as those individuals living in the same place or have moved
		// within county. This is the best proxy to identify natives from a metropolitan area.
	
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
		
	* Occupation *
	
		replace occ2010=430  if occ2010==320	 	 
		* Funeral directors --> Managers, nec
		replace occ2010=1240 if occ2010==1230		 
		* Statisticians --> Mathematical science occupations, nec
		replace occ2010=3240 if occ2010==3120		 
		* Podiatrists --> Therapists, nec
		replace occ2010=6765 if occ2010==6430		 
		* Paperhangers --> Construction workers, nec
		replace occ2010=7260 if occ2010==7125		 
		* Electronic Repairs, nec --> Vehicle and Mobile Equipment Mechanics, Installers, and Repairers, nec
		replace occ2010=8220 if occ2010==7930		 
		* Forging Machine Setters, Operators, and Tenders, Metal and Plastic --> Metal workers and plastic workers, nec
		replace occ2010=8220 if occ2010==7960		 
		* Drilling and Boring Machine Tool Setters, Operators, and Tenders, Metal and Plastic --> Metal workers and plastic workers, nec
		replace occ2010=8220 if occ2010==8060		 
		* Model Makers and Patternmakers, Metal and Plastic --> Metal workers and plastic workers, nec
		replace occ2010=8220 if occ2010==8150		 
		* Heat Treating Equipment Setters, Operators, and Tenders, Metal and Plastic --> Metal workers and plastic workers, nec
		replace occ2010=8460 if occ2010==8340		 
		* Shoe Machine Operators and Tenders --> Textile, Apparel, and Furnishings workers, nec
		replace occ2010=9420 if occ2010==9230		 
		* Railroad Brake, Signal, and Switch Operators --> Transportation workers, nec

		gen kindocc = .
		
		replace kindocc = 1 if occ2010>=10 & occ2010<=430
		replace kindocc = 2 if occ2010>=500 & occ2010<=730
		replace kindocc = 3 if occ2010>=800 & occ2010<=950
		replace kindocc = 4 if occ2010>=1000 & occ2010<=1240
		replace kindocc = 5 if occ2010>=1300 & occ2010<=1540
		replace kindocc = 6 if occ2010>=1550 & occ2010<=1560
		replace kindocc = 7 if occ2010>=1600 & occ2010<=1980
		replace kindocc = 8 if occ2010>=2000 & occ2010<=2060
		replace kindocc = 9 if occ2010>=2100 & occ2010<=2150
		replace kindocc = 10 if occ2010>=2200 & occ2010<=2550
		replace kindocc = 11 if occ2010>=2600 & occ2010<=2920
		replace kindocc = 12 if occ2010>=3000 & occ2010<=3540
		replace kindocc = 13 if occ2010>=3600 & occ2010<=3650
		replace kindocc = 14 if occ2010>=3700 & occ2010<=3950
		replace kindocc = 15 if occ2010>=4000 & occ2010<=4150
		replace kindocc = 16 if occ2010>=4200 & occ2010<=4250
		replace kindocc = 17 if occ2010>=4300 & occ2010<=4650
		replace kindocc = 18 if occ2010>=4700 & occ2010<=4965
		replace kindocc = 19 if occ2010>=5000 & occ2010<=5940
		replace kindocc = 20 if occ2010>=6005 & occ2010<=6130
		replace kindocc = 21 if occ2010>=6200 & occ2010<=6765
		replace kindocc = 22 if occ2010>=6800 & occ2010<=6940
		replace kindocc = 23 if occ2010>=7000 & occ2010<=7630
		replace kindocc = 24 if occ2010>=7700 & occ2010<=8965
		replace kindocc = 25 if occ2010>=9000 & occ2010<=9750
		replace kindocc = 26 if occ2010>=9800 & occ2010<=9830
		replace kindocc = 27 if occ2010==9920 
		
		label define kindocclbl 1 "Management in Business, Science, and Arts", add 
		label define kindocclbl 2 "Business Operations Specialists", add 
		label define kindocclbl 3 "Financial Specialists", add 
		label define kindocclbl 4 "Computer and Mathematical", add 
		label define kindocclbl 5 "Architecture and Engineering", add 
		label define kindocclbl 6 "Technicians", add 
		label define kindocclbl 7 "Life, Physical, and Social Science", add 
		label define kindocclbl 8 "Community and Social Services", add 
		label define kindocclbl 9 "Legal", add 
		label define kindocclbl 10 "Education, Training, and Library", add 
		label define kindocclbl 11 "Arts, Design, Entertainment, Sports, and Media", add 
		label define kindocclbl 12 "Healthcare Practitioners and Technicians", add 
		label define kindocclbl 13 "Healthcare Support", add 
		label define kindocclbl 14 "Protective Service", add 
		label define kindocclbl 15 "Food Preparation and Serving", add 
		label define kindocclbl 16 "Building and Grounds Cleaning and Maintenance", add 
		label define kindocclbl 17 "Personal Care and Service", add 
		label define kindocclbl 18 "Sales and Related", add 
		label define kindocclbl 19 "Office and Administrative Support", add 
		label define kindocclbl 20 "Farming, Fisheries, and Forestry", add 
		label define kindocclbl 21 "Construction", add 
		label define kindocclbl 22 "Extraction", add 
		label define kindocclbl 23 "Installation, Maintenance, and Repair", add 
		label define kindocclbl 24 "Production", add 
		label define kindocclbl 25 "Transportation and Material Moving", add 
		label define kindocclbl 26 "Military", add 
		label define kindocclbl 27 "Unemployed", add 
		label values kindocc kindocclbl
		label variable kindocc "Occupation"
		// Generating occupation categories

		gen bluecol = 0	
		replace bluecol = 1 if (occ2010>=6000&occ2010<=9840)
		replace bluecol = 1 if (occ2010>=3600&occ2010<=4690)

		gen whitecol = 0	
		replace whitecol = 1 if (occ2010>=10&occ2010<=3590)
		replace whitecol = 1 if (occ2010>=4700&occ2010<=5990)
		// Identifying white collars and blue collars								 
								 
		gen workcat=1*(bluecol==1)+2*(whitecol==1)
		// Generating working categories
	
		label var bluecol "Blue-collar"
		label var whitecol "White-collar"
		label var workcat "Work categories"

		label define lblworkcat 0 "Unemployed" 1 "Blue-collar" 2 "White-collar" 
		label values workcat lblworkcat


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
		replace metcode2 = 413 if metcode2 == 412

	* Individual identifier *
	
		gen id = _n
		// Generate identifier for every observation

		label var id "Individual identifier"
		
	* Saving the dataset
	
	save "../temp/CPSASEC.dta", replace

  end

********************************************************************************  
