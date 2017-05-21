 
 *----------------------- Identifying Katrina Evacuees ------------------------*

 ***** Define Program 

  program define d_idkatrina

 ***** Silent local

	local silent `1'
	
 	* Codebook for Silent *
		* 1 -> Nice stata output display
		* 0 -> Display everything 

	* Local variables to run the stuff quietly or noisily *
  
	if `silent'==1 {
		local sil "qui"
	}
	
	else {
		local sil " "
	}

********************************************************************************

 ***** Identifying Katrina affected areas 

	`sil' gen kat_affected=0
	`sil' replace kat_affected=1 if inlist(metcode2,516,76,388,396,335,556,92,268, ///
		  275,500,534,601,608,896)
	// Katrina affected areas (kat_affected==1) and areas with large inflow of 
	// evacuees to take out of the control group (kat_affected==0)
	
	`sil' gen evac = (katevac2 == 1)
	// Katrina evacuees

 ***** Flagging treated cities and creating diff-in-diff variables
 
	`sil' gen houston = (metcode2==336)
	`sil' gen dallas = (metcode2==192)
	`sil' gen fayetteville = (metcode2==258)
	// Generating variables for treated metropolitan areas
	
	`sil' gen postkat = year>=2006
	`sil' gen did_houston = postkat*houston
	// Identifying pre/post treatment periods	
	
 ***** Computing decriptives: evacuees vs nonevacuees
 
	preserve
		`sil' keep if year==2006

		clear matrix 
		`sil' tabstat age nohighsch highsch somecollege college black mexican ///
					   nmhispan white other poor if evac == 1 [aw=wtsupp], c(s) stat(mean semean) save
		`sil' matrix pre_output = r(StatTotal)'
		
		`sil' tabstat age nohighsch highsch somecollege college black mexican ///
					   nmhispan white other poor if evac == 0 [aw=wtsupp], c(s) stat(mean semean) save
		`sil' matrix pre_output = (pre_output , r(StatTotal)')

		`sil' svmat pre_output

		`sil' drop if missing(pre_output1)
		keep pre_output*
		rename (pre_output1 pre_output2 pre_output3 pre_output4) (evac_mean evac_semean nevac_mean nevac_semean)
		`sil' gen diff_mean = evac_mean - nevac_mean
		`sil' gen se_diff_mean = sqrt(evac_semean^2 + nevac_semean^2)

		`sil' mkmat evac_mean nevac_mean diff_mean se_diff_mean, matrix(output)

		`sil' mat2txt, matrix(output) saving("${tables}descriptive_evac_vs_nevac.txt") replace ///
			  format(%20.5f) title(<tab:descriptive>)
	restore
	// Computing decriptives: evacuees vs nonevacuees
	
 ***** Save temporary dataset
	
	`sil' save "${temp}CPSASEC.dta", replace
	cap saveold "${temp}CPSASEC.dta", v(12) replace
	
 ***** Creating the share of evacuees in 2006

	`sil' keep if year == 2006
	`sil' bysort metcode2: gen num_obs=_N
	`sil' keep if num_obs > 100
	// Keeping year 2006 (Hurricane Katrina), counting the number of obs. in each 
	// metropolitan area and keeping the ones with more than 100 obs.
	
	`sil' collapse (mean) share_evac = evac kat_affected num_obs (sd) share_evac_sd = evac ///
		  (count) obs = id [aw=wtsupp], by(metcode2)
	sort share_evac
	// Computing the share of evacuees
	  // ASK DIEGO A FULL EXPLANATION
	
	local upper_threshold = 0.005
	local lower_threshold = 0.0005
	local significance_10 = 1.285
	// Creating "arbitrary" upper and lower thresholds for the share of evacuees, 
	// and significance level 10%
	
	`sil' gen t_stat_bigger = (share_evac-`upper_threshold')/(share_evac_sd/sqrt(obs))
	`sil' gen t_stat_lower = (share_evac-`lower_threshold')/(share_evac_sd/sqrt(obs))
	// Generating t-statistics for the share of evacuees in each metropolitan area
	
	`sil' gen treat = (share_evac>`upper_threshold' & kat_affected==0 & t_stat_bigger>`significance_10') /* One tail test (bigger than 1%) */
	// Generating treatment variable that flags metropolitan areas not affected by Katrina, 
	// with a share of evacuees higher than the upper threshold and received an inflow of evacuees
	// that is statistically significant
	
	`sil' gen control = (kat_affected == 0 & (t_stat_lower < - `significance_10' | missing(t_stat_lower)))
	// Generating control variable that flags metropolitan areas not affected by Katrina,
	// that received an inflow of evacuees that is not statistically significant
	
	`sil' save "${work_asec}lot_evac_list.dta", replace
	cap saveold "${work_asec}lot_evac_list.dta", v(12) replace
	
 ***** Adding in-sample pre-treatment labor outcomes

	`sil' use "${temp}CPSASEC.dta", clear

	preserve
		`sil' keep if year==2005
		`sil' collapse (mean) lr_w_wage_1 = lr_w_wage hourwage_1 = hourwage unem_1 = unem [aw=wtsupp], by(metcode2)

		`sil' merge 1:1 metcode2 using "${work_asec}lot_evac_list.dta", nogen

		`sil' save "${work_asec}lot_evac_list.dta", replace
	restore
	// Creating the labor outcome variables for the year before Katrina Hurricane
	
	`sil' keep if (year==2001 | year==2002 | year==2003 | year==2004 | year==2005)
	`sil' collapse (mean) lr_w_wage_5 = lr_w_wage hourwage_5 = hourwage unem_5 = unem [aw=wtsupp], by(metcode2)

	`sil' merge 1:1 metcode2 using "${work_asec}lot_evac_list.dta", nogen

	`sil' save "${work_asec}lot_evac_list.dta", replace
	cap saveold "${work_asec}lot_evac_list.dta", v(12) replace 
	// Creating the labor outcome variables for the 5-years before Katrina Hurricane
	
	`sil' merge 1:m metcode2 using "${temp}CPSASEC.dta", nogen
	sort metcode2 year
	// Merging the new variables to the dataset
	
 ***** Save the dataset

	`sil' save "${work_asec}CPSASECfinal.dta", replace
	cap saveold "${work_asec}CPSASECfinal.dta", v(12) replace
	
 ***** Computing table of labor status of evacuees
	
	`sil' keep if year==2006
	
	clear matrix 
	`sil' tabstat emplyd inactive unem hours_worked [aw=wtsupp], c(s) stat(mean semean) save
	`sil' matrix output = r(StatTotal)
	
	`sil' tabstat emplyd inactive unem hours_worked if treat==1 [aw=wtsupp], c(s) stat(mean semean) save
	`sil' matrix output = (output\r(StatTotal))
	
	`sil' tabstat emplyd inactive unem hours_worked if control==1 [aw=wtsupp], c(s) stat(mean semean) save
	`sil' matrix output = (output\r(StatTotal))
	
	`sil' tabstat emplyd inactive unem hours_worked if evac==1 [aw=wtsupp], c(s) stat(mean semean) save
	`sil' matrix output = (output\r(StatTotal))
	
	`sil' tabstat emplyd inactive unem hours_worked if (treat==1 & evac==1) [aw=wtsupp], c(s) stat(mean semean) save
	`sil' matrix output = (output\r(StatTotal))

	`sil' mat2txt, matrix(output) saving("${tables}labor_status_sample.txt") replace ///
		  format(%20.5f) title(<tab:labor_status_sample>)
	
 ***** Erasing temporary files
 
	`sil' erase "${temp}CPSASEC.dta"
	
  end

********************************************************************************  
