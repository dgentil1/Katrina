 
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

	
	
/* STILL TO BE CHECKED!	
	
	
***** Creating the GIS matchable MSA's list	and the share of evacuees in 2006

	keep if year == 2006
	bysort metcode2: gen num_obs=_N
	keep if num_obs > 100
	// Keeping year 2006 (Hurricane Katrina), counting the number of obs. in each 
	// metropolitan area and keeping the ones with more than 100 obs.

	collapse (mean) share_evac = evac kat_affected num_obs (sd) share_evac_sd = evac ///
	    (count) obs = id [aw=wtsupp], by(metcode2)
	sort share_evac
	// Computing the share of evacuees

	save "../derived_asec/lot_evac_list_to_match.dta", replace

	local upper_thresholds  "5 1"
	local significance_10 = 1.285
	// Creating "arbitrary" upper and lower thresholds for the share of evacuees, 
	// and significance level 10%
	
	local number_thresholds: word count `upper_thresholds'
	forval i= 1/`number_thresholds' {
	    local threshold: word `i' of `upper_thresholds'
		local threshold = (`threshold'/1000)

	    gen t_stat_bigger_`i' = (share_evac-`threshold')/(share_evac_sd/sqrt(obs))
		// Generating t-statistics for the share of evacuees in each metropolitan area
		
		gen treat_`i' = (share_evac>`threshold' & kat_affected==0 & t_stat_bigger_`i'>`significance_10') /* One tail test (bigger than 1%) */
		// Generating treatment variable that flags metropolitan areas not affected by Katrina, 
		// with a share of evacuees higher than the upper threshold and received an inflow of evacuees
		// that is statistically significant
	}
	
	rename (treat_1 treat_2) (treat treat_expanded)

	gen control = (kat_affected == 0 & share_evac == 0)
	// Generating control variable that flags metropolitan areas not affected by Katrina,
	// that received an inflow of evacuees that is not statistically significant
	
	save "../derived_asec/lot_evac_list.dta", replace
	
 ***** Adding in-sample pre-treatment labor outcomes

	use "../temp/MORG.dta", clear

	preserve
		keep if year==2005
		collapse (mean) lr_w_wage_1 = lr_w_wage hourwage_1 = hourwage unem_1 = unem [aw=wtsupp], by(metcode2)

		merge 1:1 metcode2 using "../derived_asec/lot_evac_list.dta", nogen

		save "../derived_asec/lot_evac_list.dta", replace
	restore
	// Creating the labor outcome variables for the year before Katrina Hurricane
	
	keep if (year==2001 | year==2002 | year==2003 | year==2004 | year==2005)
	collapse (mean) lr_w_wage_5 = lr_w_wage hourwage_5 = hourwage unem_5 = unem [aw=wtsupp], by(metcode2)

	merge 1:1 metcode2 using "../derived_asec/lot_evac_list.dta", nogen

	save "../derived_asec/lot_evac_list.dta", replace
	// Creating the labor outcome variables for the 5-years before Katrina Hurricane
	
	merge 1:m metcode2 using "../temp/MORG.dta", nogen
	sort metcode2 year
	// Merging the new variables to the dataset
	
 ***** Save the dataset for SCM

	save "../derived_asec/MORGfinal.dta", replace

	
 ***** Save the dataset for diff-in-diff	
	keep if inlist(year,1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, ///
		2008, 2009, 2010, 2011)
	
	save "../derived_asec/MORGfinal_did.dta", replace
*/	
  end

********************************************************************************  
