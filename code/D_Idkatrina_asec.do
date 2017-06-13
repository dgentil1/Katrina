 
 *---------- Identifying Katrina evacuees and affected areas (ASEC) -----------*

 ***** Define Program 

  program define d_idkatrina_asec

  use "../temp/CPSASEC.dta", clear

 ***** Identifying Katrina affected areas 

	gen kat_affected=0
	replace kat_affected=1 if inlist(metcode2,516,76,388,396,335,556,92,268, ///
		  275,500,534,601,608,896)
	// Katrina affected areas (kat_affected==1) and areas with large inflow of 
	// evacuees to take out of the control group (kat_affected==0)
	
	gen evac = (katevac2 == 1)
	// Katrina evacuees

 ***** Flagging treated cities and creating diff-in-diff variables
 
	gen houston = (metcode2==336)

	// Generating variables for treated metropolitan areas
	
	gen postkat = year>=2006
	gen did_houston = postkat*houston
	// Identifying pre/post treatment periods	
		
 ***** Save temporary dataset
	
	save "../temp/CPSASEC.dta", replace
	
	
	*** Computing the share of evacuees

	keep if year == 2006
	bysort metcode2: gen num_obs=_N
	// Keeping year 2006 (Hurricane Katrina) and counting the number of obs. in each 
	// metropolitan area.
	 
	 ***** Creating the GIS matchable MSA's list and the share of evacuees in 2006
	 
	collapse (mean) share_evac = evac kat_affected num_obs (sd) share_evac_sd = evac ///
	    (count) obs = id [aw=weight], by(metcode2)
	sort share_evac

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
	
	use "../temp/CPSASEC.dta", clear
	
	merge m:1 metcode2 using "../derived_asec/lot_evac_list.dta", nogen
		
 ***** Save the dataset for SCM

	save "../derived_asec/CPSASECfinal.dta", replace

	
  end

********************************************************************************  
