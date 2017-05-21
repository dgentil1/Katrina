 
 *------------------------- Synthetic Control Method --------------------------*

  ***** Define Program 

  program define s_scm

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

	local control_vars = "unem wksunem1 hours_worked poor " + ///
		"sex white other black manuf bluecol whitecol " + ///
		"age nohighsch highsch somecollege college nmhispan " + ///
		"mexican"
		
	local outcome_vars	= "lr_w_wage emplyd inactive"
		
	s_scm_build, outcomes(`outcome_vars') controls(`control_vars') city(houston) tr_period(2006)
	s_scm_build, outcomes(`outcome_vars') controls(`control_vars') city(dallas) tr_period(2006)
	s_scm_build, outcomes(`outcome_vars') controls(`control_vars') city(fayetteville) tr_period(2006)

	local control_vars = "unem wksunem1 hours_worked poor " + ///
		"sex white other black manuf bluecol whitecol " + ///
		"age nmhispan mexican"
		
	foreach education in nohighsch highsch somecollege college {
	
		s_scm_build if `education' == 1, outcomes(`outcome_vars') controls(`control_vars') city(houston) tr_period(2006) stub(_`education')
		s_scm_build if `education' == 1, outcomes(`outcome_vars') controls(`control_vars') city(dallas) tr_period(2006) stub(_`education')
		s_scm_build if `education' == 1, outcomes(`outcome_vars') controls(`control_vars') city(fayetteville) tr_period(2006) stub(_`education')
	
	}
	
  end

 *------------------- Build Synthetic Control Method --------------------------*

  ***** Define Program 

  program define s_scm_build

  ***** Silent local

	local silent "1" // Correct this!!!
	
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
	
	`sil' syntax [if], outcomes(string) controls(string) city(string) tr_period(int) [stub(string)]
    
	`sil' use "${work_asec}CPSASECfinal.dta", clear
	
	preserve
		`sil' drop if kat_affected==1
		`sil' drop if (control!=1 & `city'==0)
		`sil' drop if katevac2==1

		`sil' sum metcode2 if `city'==1
		local trunit = r(mean)

		`sil' collapse (mean) `controls' `outcomes' `city' kat_affected `if' [iw=wtsupp], by(year metcode2)

		`sil' xtset metcode2 year
		local num_years = r(tmax) - r(tmin) + 1
		`sil' bysort metcode2: gen num_year = _N
		`sil' keep if num_year == `num_years' /* to balance the panel, otherwise the synthetic control does not apply */

		local number_outcomes: word count `outcomes'
		
		forval i = 1/`number_outcomes' {
			local outcome_var: word `i' of `outcomes' 
			`sil' drop if `outcome_var'==.
		}
		
		`sil' bysort metcode2: replace num_year = _N
		`sil' keep if num_year == `num_years' /* to balance the panel against missing values */

		`sil' save "${temp}donorpool_`city'`stub'.dta", replace
		cap saveold "${temp}donorpool_`city'`stub'.dta", v(12) replace

		local number_outcomes: word count `outcomes'
		forval i = 1/`number_outcomes' {
			`sil' use "${temp}donorpool_`city'`stub'.dta", clear
			
			local var: word `i' of `outcomes'
			local lag1 = `tr_period' - 9
			local lag2 = `tr_period' - 8
			local lag3 = `tr_period' - 7
			local lag4 = `tr_period' - 6
			local lag5 = `tr_period' - 5
			local lag6 = `tr_period' - 4
			local lag7 = `tr_period' - 3
			local lag8 = `tr_period' - 2
			local lags = "`var'(`lag1') `var'(`lag2') `var'(`lag3') `var'(`lag4') `var'(`lag5') `var'(`lag6') `var'(`lag7') `var'(`lag8')"
			
			`sil' synth `var' `controls' `lags', ///
				  trunit(`trunit') trperiod(`tr_period') figure ///
				  keep("${temp}synth_`city'_`var'`stub'.dta", replace)

			`sil' use "${temp}synth_`city'_`var'`stub'.dta", clear
			rename (_Co_Number _time _Y_treated _Y_synthetic) ///
				(metcode2 year `city'_`var' synthetic_`city'_`var')

			`sil' drop if year==.
			drop metcode2 _W_Weight

			`sil' save "${temp}synth_`city'_`var'`stub'.dta", replace
			cap saveold "${temp}synth_`city'_`var'`stub'.dta", v(12) replace
		}

		local number_outcomes: word count `outcomes'
		local outcome_var: word 1 of `outcomes' 
		`sil' use "${temp}synth_`city'_`outcome_var'`stub'", clear

		forval i = 2/`number_outcomes' {
			local outcome_var: word `i' of `outcomes' 

			`sil' merge 1:1 year using "${temp}synth_`city'_`outcome_var'`stub'", nogen
		}
		
		`sil' save "${work_asec}controltrends_`city'`stub'.dta", replace
		cap saveold "${work_asec}controltrends_`city'`stub'.dta", v(12) replace	
	restore
  
  end
  
********************************************************************************
