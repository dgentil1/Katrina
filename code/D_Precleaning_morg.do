
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
		 ownchild chldpres unionmme marital prunedur ftpt94 pfamrel relref95
	rename (hhid pfamrel relref95) (serial relate famrel)
	
  ***** Adding CPI base 99 index (source FED data)
	
	merge m:1 year using "../derived_morg/CPI99morg.dta", nogen keep(3) assert(3) keepusing(cpi99)

  ***** Generate the same labor and demographic variables that in our March ASEC

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
	
		gen white = (race==1 & ethnic==8) | (race==1 & ethnic==9) | (race==1 & ethnic==.)
		gen black = (race==2 & ethnic==8) | (race==2 & ethnic==9) | (race==2 & ethnic==.)		
		gen mexican = (ethnic==1) | (ethnic==2) | (ethnic==3)
		gen nmhispan = (ethnic!=1 & ethnic!=2 & ethnic!=3 & ethnic!=8 & ethnic!=9 & ethnic!=.)
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
	
	* Occupation *
		
		preserve
			keep if year>=2000 & year<=2002
			keep occ80 occ00
			
			bysort occ80: keep if _n==1
			
			rename occ00 occ2010
			
			save "../derived_morg/xwalk_occ.dta", replace
			
		restore
		
		merge m:1 occ80 using "../derived_morg/xwalk_occ.dta", nogen
		
		replace occ2010 = occ00 if year>=2003
		replace occ2010 = occ2011 if year==2011
		replace occ2010 = occ2012 if year>=2012
		
		replace occ2010=430  if occ2010==320	 	 
		* Funeral directors --> Managers, nec
		replace occ2010=1240 if occ2010==1230		 
		* Statisticians --> Mathematical science occupations, nec
		replace occ2010=3240 if occ2010==3120		 
		* Podiatrists --> Therapists, nec
		replace occ2010=6765 if occ2010==6430		 
		* Paperhangers --> Construction workers, nec
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
		replace occ2010=9920 if occ2010==.
		* Unemployed
		
		
		gen kindocc = .
		
		replace kindocc = 1 if occ2010>=10 & occ2010<=430
		replace kindocc = 2 if occ2010>=500 & occ2010<=740
		replace kindocc = 3 if occ2010>=800 & occ2010<=950
		replace kindocc = 4 if occ2010>=1000 & occ2010<=1240
		replace kindocc = 5 if occ2010>=1300 & occ2010<=1540
		replace kindocc = 6 if occ2010>=1550 & occ2010<=1560
		replace kindocc = 7 if occ2010>=1600 & occ2010<=1980
		replace kindocc = 8 if occ2010>=2000 & occ2010<=2060
		replace kindocc = 9 if occ2010>=2100 & occ2010<=2160
		replace kindocc = 10 if occ2010>=2200 & occ2010<=2550
		replace kindocc = 11 if occ2010>=2600 & occ2010<=2960
		replace kindocc = 12 if occ2010>=3000 & occ2010<=3540
		replace kindocc = 13 if occ2010>=3600 & occ2010<=3655
		replace kindocc = 14 if occ2010>=3700 & occ2010<=3955
		replace kindocc = 15 if occ2010>=4000 & occ2010<=4160
		replace kindocc = 16 if occ2010>=4200 & occ2010<=4250
		replace kindocc = 17 if occ2010>=4300 & occ2010<=4650
		replace kindocc = 18 if occ2010>=4700 & occ2010<=4965
		replace kindocc = 19 if occ2010>=5000 & occ2010<=5940
		replace kindocc = 20 if occ2010>=6000 & occ2010<=6130
		replace kindocc = 21 if occ2010>=6200 & occ2010<=6765
		replace kindocc = 22 if occ2010>=6800 & occ2010<=6940
		replace kindocc = 23 if occ2010>=7000 & occ2010<=7630
		replace kindocc = 24 if occ2010>=7700 & occ2010<=8965
		replace kindocc = 25 if occ2010>=9000 & occ2010<=9750
		replace kindocc = 26 if occ2010>=9800
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
		drop occ2010 
		// Generating occupation categories


		gen bluecol = .	
		replace bluecol = 1 if (occ2010>=6000&occ2010<=9840)
		replace bluecol = 1 if (occ2010>=3600&occ2010<=4690)

		gen whitecol = .	
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
	    
		drop if (missing(msafips) & missing(cbsafips))
		gen metarea = .
		replace metarea = msafips
		replace metarea = cbsafips if missing(metarea)
		drop if metarea == 0
		
		gen metarea_string = ""
		decode msafips, gen(msafips_string)
		decode cbsafips, gen(cbsafips_string)
		replace metarea_string = msafips_string if msafips_string != ""
		replace metarea_string = cbsafips_string if cbsafips_string != ""
	
	* Individual identifier *
	
		gen id = _n
		// Generate identifier for every observation

		label var id "Individual identifier"

		
	* Saving the dataset
	
	save "../temp/MORG.dta", replace
		 	 
		 
  end

********************************************************************************



