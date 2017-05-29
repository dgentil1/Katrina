 
 *----------------------- Identifying Katrina Evacuees ------------------------*

 ***** Define Program 

  program define d_idkatrina

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
	gen dallas = (metcode2==192)
	gen fayetteville = (metcode2==258)
	// Generating variables for treated metropolitan areas
	
	gen postkat = year>=2006
	gen did_houston = postkat*houston
	// Identifying pre/post treatment periods	
		
 ***** Save temporary dataset
	
	save "${temp}CPSASEC.dta", replace
	cap saveold "${temp}CPSASEC.dta", v(12) replace
	
 ***** Creating the share of evacuees in 2006

	keep if year == 2006
	bysort metcode2: gen num_obs=_N
	keep if num_obs > 100
	// Keeping year 2006 (Hurricane Katrina), counting the number of obs. in each 
	// metropolitan area and keeping the ones with more than 100 obs.
	
	collapse (mean) share_evac = evac kat_affected num_obs (sd) share_evac_sd = evac ///
		  			(count) obs = id [aw=wtsupp], by(metcode2)
	sort share_evac
	// Computing the share of evacuees
	
	local upper_threshold = 0.005
	local lower_threshold = 0.0005
	local significance_10 = 1.285
	// Creating "arbitrary" upper and lower thresholds for the share of evacuees, 
	// and significance level 10%
	
	gen t_stat_bigger = (share_evac-`upper_threshold')/(share_evac_sd/sqrt(obs))
	gen t_stat_lower = (share_evac-`lower_threshold')/(share_evac_sd/sqrt(obs))
	// Generating t-statistics for the share of evacuees in each metropolitan area
	
	gen treat = (share_evac>`upper_threshold' & kat_affected==0 & t_stat_bigger>`significance_10') /* One tail test (bigger than 1%) */
	// Generating treatment variable that flags metropolitan areas not affected by Katrina, 
	// with a share of evacuees higher than the upper threshold and received an inflow of evacuees
	// that is statistically significant
	
	gen control = (kat_affected == 0 & (t_stat_lower < - `significance_10' | missing(t_stat_lower)))
	// Generating control variable that flags metropolitan areas not affected by Katrina,
	// that received an inflow of evacuees that is not statistically significant
	
	save "${work_asec}lot_evac_list.dta", replace
	cap saveold "${work_asec}lot_evac_list.dta", v(12) replace
	
 ***** Adding in-sample pre-treatment labor outcomes

	use "${temp}CPSASEC.dta", clear

	preserve
		keep if year==2005
		collapse (mean) lr_w_wage_1 = lr_w_wage hourwage_1 = hourwage unem_1 = unem [aw=wtsupp], by(metcode2)

		merge 1:1 metcode2 using "${work_asec}lot_evac_list.dta", nogen

		save "${work_asec}lot_evac_list.dta", replace
	restore
	// Creating the labor outcome variables for the year before Katrina Hurricane
	
	keep if (year==2001 | year==2002 | year==2003 | year==2004 | year==2005)
	collapse (mean) lr_w_wage_5 = lr_w_wage hourwage_5 = hourwage unem_5 = unem [aw=wtsupp], by(metcode2)

	merge 1:1 metcode2 using "${work_asec}lot_evac_list.dta", nogen

	save "${work_asec}lot_evac_list.dta", replace
	cap saveold "${work_asec}lot_evac_list.dta", v(12) replace 
	// Creating the labor outcome variables for the 5-years before Katrina Hurricane
	
	merge 1:m metcode2 using "${temp}CPSASEC.dta", nogen
	sort metcode2 year
	// Merging the new variables to the dataset
	
 ***** Save the dataset

	save "${work_asec}CPSASECfinal.dta", replace
	cap saveold "${work_asec}CPSASECfinal.dta", v(12) replace
		
 ***** Erasing temporary files
 
	erase "${temp}CPSASEC.dta"
	
  end

********************************************************************************  
