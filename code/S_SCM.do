 
 *----------------- Building Synthetic Control Method (ASEC) -----------------*

  ***** Define Program 

program scm

    local control_vars = "unem hours_worked " + ///
		"sex white other black nmhispan mexican bluecol whitecol " + ///
		"age nohighsch highsch somecollege college"
	local outcome_vars	= "lr_w_wage emplyd inactive"
		
	build_synth_control, data("../derived_asec/CPSASECfinal.dta") sample(asec) ///
	    outcomes(`outcome_vars') controls(`control_vars') city(houston) tr_period(2006)
	build_synth_control, data("../derived_morg/MORGfinal.dta") sample(morg) ///
	    outcomes(`outcome_vars') controls(`control_vars') city(houston) tr_period(2006)

	local control_vars ="unem hours_worked " + ///
		"sex white other black nmhispan mexican bluecol whitecol " + ///
		"age"
	foreach education in nohighsch highsch somecollege college{
	    use "../derived_asec/CPSASECfinal.dta", clear
		build_synth_control if `education' == 1, data("../derived_asec/CPSASECfinal.dta") sample(asec) ///
		    outcomes(`outcome_vars') controls(`control_vars') city(houston) tr_period(2006) stub(_`education')
	}
	foreach education in nohighsch highsch somecollege college{
	    use "../derived_morg/MORGfinal.dta", clear
		build_synth_control if `education' == 1, data("../derived_morg/MORGfinal.dta") sample(morg) ///
		    outcomes(`outcome_vars') controls(`control_vars') city(houston) tr_period(2006) stub(_`education')
	}
end

 *------------------- Build Synthetic Control Method --------------------------*

  ***** Define Program 

program build_synth_control
	syntax [if], data(string) outcomes(string) controls(string) city(string) tr_period(int) sample(string) [stub(string)]
    
	use `data', clear
    
	preserve
	
		drop if kat_affected==1
		drop if (control!=1 & `city'==0)
		drop if evac==1

		qui sum metcode2 if `city'==1
		local trunit = r(mean)

		collapse (mean) `controls' `outcomes' `city' kat_affected `if' [iw=weight], by(year metcode2)

		xtset metcode2 year
		local num_years = r(tmax) - r(tmin) + 1
		bysort metcode2: gen num_year = _N
		keep if num_year == `num_years' /* to balance the panel, otherwise the synthetic control does not apply */

		local number_outcomes: word count `outcomes'
		forval i = 1/`number_outcomes' {
			local outcome_var: word `i' of `outcomes' 
			drop if `outcome_var'==.
		}
		bysort metcode2: replace num_year = _N
		keep if num_year == `num_years' /* to balance the panel against missing values */

		save "../temp/`sample'_donorpool_`city'`stub'.dta", replace
		
		local number_outcomes: word count `outcomes'
		forval i = 1/`number_outcomes' {
			use "../temp/`sample'_donorpool_`city'`stub'.dta", clear
			
			local var: word `i' of `outcomes'
			local lag1 = `tr_period' - 10
			local lag2 = `tr_period' - 8
			local lag3 = `tr_period' - 6
			local lag4 = `tr_period' - 4
			local lag5 = `tr_period' - 2
			local lags = "`var'(`lag1') `var'(`lag2') `var'(`lag3') `var'(`lag4') `var'(`lag5')"
			
			synth `var' `controls' `lags', ///
				trunit(`trunit') trperiod(`tr_period') figure ///
				keep("../temp/`sample'_synth_`city'_`var'`stub'.dta", replace)

			use "../temp/`sample'_synth_`city'_`var'`stub'.dta", clear
			rename (_Co_Number _time _Y_treated _Y_synthetic) ///
				(metcode2 year `city'_`var' synthetic_`city'_`var')

			drop if year==.
			drop metcode2 _W_Weight

			save "../temp/`sample'_synth_`city'_`var'`stub'.dta", replace
		}

		local number_outcomes: word count `outcomes'
		local outcome_var: word 1 of `outcomes' 
		use "../temp/`sample'_synth_`city'_`outcome_var'`stub'", clear

		forval i = 2/`number_outcomes' {
			local outcome_var: word `i' of `outcomes' 

			merge 1:1 year using "../temp/`sample'_synth_`city'_`outcome_var'`stub'", nogen
		}
		save "../derived_`sample'/controltrends_`city'`stub'.dta", replace
	restore
	
end
  
********************************************************************************
