 
 *----------------------- Identifying Katrina Evacuees ------------------------*

 ***** Define Program 

  program define d_idkatrina_morg

  use "../temp/MORG.dta", clear
  
 ***** Identifying Katrina affected areas 

	gen kat_affected=0
	replace kat_affected=1 if inlist(metcode2,516,76,388,396,335,556,92,268, ///
		  275,500,534,601,608,896)
	// Katrina affected areas (kat_affected==1) and areas with large inflow of 
	// evacuees to take out of the control group (kat_affected==0)
	
	gen evac = (purkat1 == 1)
	// Katrina evacuees

 ***** Flagging treated cities and creating diff-in-diff variables
 
 	merge m:1 metcode2 using "../derived_asec/treat_and_control_list.dta", nogen keep(3)

	gen houston = (metcode2==336)
	gen dallas = (metcode2==192)
	gen fayetteville = (metcode2==258)
	// Generating variables for treated metropolitan areas
	
	gen postkat = year>=2006
	gen did_houston = postkat*houston
	// Identifying pre/post treatment periods	
		
 ***** Save temporary dataset
	
	save "../temp/MORG.dta", replace
	
		
 ***** Adding in-sample pre-treatment labor outcomes

	use "../temp/MORG.dta", clear

	preserve
		keep if year==2005
		collapse (mean) lr_w_wage_1 = lr_w_wage lr_h_wage_1 = lr_h_wage unem_1 = unem [aw=wtsupp], by(metcode2)

		save "../derived_morg/pre_laboroutcomes.dta", replace
	restore
	// Creating the labor outcome variables for the year before Katrina Hurricane
	
	keep if (year==2001 | year==2002 | year==2003 | year==2004 | year==2005)
	collapse (mean) lr_w_wage_5 = lr_w_wage lr_h_wage_5 = lr_h_wage unem_5 = unem [aw=wtsupp], by(metcode2)

	merge 1:1 metcode2 using "../derived_morg/pre_laboroutcomes.dta", nogen

	save "../derived_morg/pre_laboroutcomes.dta", replace
	// Creating the labor outcome variables for the 5-years before Katrina Hurricane
	
	merge 1:m metcode2 using "../temp/MORG.dta", nogen
	sort metcode2 year
	// Merging the new variables to the dataset
	
 ***** Save the dataset for SCM

	save "../derived_morg/MORGfinal.dta", replace

	
 ***** Save the dataset for diff-in-diff	
	keep if inlist(year,1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, ///
		2008, 2009, 2010, 2011)
	
	save "../derived_morg/MORGfinal_did.dta", replace
	
  end

********************************************************************************  
