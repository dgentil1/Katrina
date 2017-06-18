 
 *---------- Identifying Katrina evacuees and affected areas (MORG) -----------*

 ***** Define Program 

  program define d_idkatrina_morg

  use "../temp/MORG.dta", clear
  
 ***** Adding metcode2
 
    merge m:1 metarea using "../derived_morg/xwalk_msafips_cbsa.dta", ///
		  keepusing(metcode2) nogen keep(3)
  
 ***** Identifying Katrina affected areas 

	gen kat_affected=0
	replace kat_affected=1 if inlist(metcode2,516,76,388,396,335,556,92,268, ///
		  275,500,534,601,608,896)
	// Katrina affected areas (kat_affected==1) and areas with large inflow of 
	// evacuees to take out of the control group (kat_affected==0)
	
	gen evac = (purkat1 == 1)
	// Katrina evacuees

 ***** Flagging treated cities and creating diff-in-diff variables
 
	gen houston = (metcode2==336)
	gen dallas = (metcode2==192)
	gen fayetteville = (metcode2==258)
	// Generating variables for treated metropolitan areas
	
	gen postkat = year>=2006
	gen did_houston = postkat*houston
	// Identifying pre/post treatment periods	
		
 ***** Save temporary dataset
	
	save "../temp/MORG.dta", replace
	
	*** Computing the share of evacuees

	keep if year == 2006
	bysort metcode2: gen num_obs=_N
	keep if num_obs > 250
	// Keeping year 2006 (Hurricane Katrina), counting the number of obs. in each 
	// metropolitan area and keeping the ones with more than 250 obs
	
	collapse (mean) share_evac = evac kat_affected (sd) share_evac_sd = evac ///
	         (count) obs = id [aw=weight], by(metcode2)
	sort share_evac
	
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
	
	save "../derived_morg/lot_evac_list.dta", replace
	
	use "../temp/MORG.dta", clear
	
	merge m:1 metcode2 using "../derived_morg/lot_evac_list.dta", nogen
	sort metcode2 year
	// Merging the new variables to the dataset
	
 ***** Save the dataset for SCM

	save "../derived_morg/MORGfinal.dta", replace

	
  end

********************************************************************************  
