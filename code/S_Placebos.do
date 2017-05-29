 
 *------------------------ Building placebo tests -----------------------------*

  ***** Define Program 

  program define s_placebos

	local control_vars = "unem wksunem1 hours_worked poor " + ///
		"sex white other black manuf bluecol whitecol " + ///
		"age nohighsch highsch somecollege college nmhispan " + ///
		"mexican"
	
	local outcome_vars	= "lr_w_wage emplyd inactive"
	
	local stub_list = "Log-wage Employment Inactivity"

	foreach city in houston dallas fayetteville {
		s_plac_inputs, outcomes(`outcome_vars') controls(`control_vars') tr_period(2006) city(`city')
		s_plac_plots, outcomes(`outcome_vars') controls(`control_vars') stub(`stub_list') city(`city')
	}
	
	local control_vars = "unem wksunem1 hours_worked poor " + ///
		"sex white other black manuf bluecol whitecol " + ///
		"age nmhispan mexican"
	
	local education_levels = "nohighsch highsch somecollege college"
    
	local education_titles = "High-School-Dropouts High-School Incomplete-College College"
    
	local number_educations: word count `education_levels'
    
	forval i = 1/`number_educations' {
		local education: word `i' of `education_levels'
		local education_title: word `i' of `education_titles'
		
		* Houston *
		s_plac_inputs, outcomes(`outcome_vars') controls(`control_vars') ///
		    tr_period(2006) city(houston) level(_`education')
		s_plac_plots, outcomes(`outcome_vars') controls(`control_vars') ///
		    stub(`stub_list') city(houston) level(_`education') title(`education_title')
		
		* Dallas *
		s_plac_inputs, outcomes(`outcome_vars') controls(`control_vars') ///
		    tr_period(2006) city(dallas) level(_`education')
		s_plac_plots, outcomes(`outcome_vars') controls(`control_vars') ///
		    stub(`stub_list') city(dallas) level(_`education') title(`education_title')
		
		* Fayetteville *
		s_plac_inputs, outcomes(`outcome_vars') controls(`control_vars') ///
		    tr_period(2006) city(fayetteville) level(_`education')
		s_plac_plots, outcomes(`outcome_vars') controls(`control_vars') ///
		    stub(`stub_list') city(fayetteville) level(_`education') title(`education_title')
	}
  
  end
  
*-------------------- Building placebo tests: inputs --------------------------*

  ***** Define Program 

  program define s_plac_inputs
  
    syntax [if], outcomes(string) controls(string) tr_period(string) city(string) [level(string)]

    use "../temp/donorpool_`city'`level'.dta", clear

	sum metcode2 if `city' == 1
	
	local trunit = r(mean)	
	 sum metcode2
	local min_unit = r(min)
	levelsof metcode2, local(groups)

	local number_outcomes: word count `outcomes'
	forval i = 1/`number_outcomes' {		
		local var: word `i' of `outcomes'
		local lag1 = `tr_period' - 9
		local lag2 = `tr_period' - 8
		local lag3 = `tr_period' - 7
		local lag4 = `tr_period' - 5
		local lag5 = `tr_period' - 4
		local lag6 = `tr_period'
		local lags = "`var'(`lag1') `var'(`lag2') `var'(`lag3') `var'(`lag4') `var'(`lag5') `var'(`lag6')"

		foreach i of local groups {
	        use "../temp/donorpool_`city'`level'.dta", clear
			xtset metcode2 year
			
			synth `var' `controls' `lags', ///
				   trunit(`i') trperiod(`tr_period') ///
			       keep("../temp/synth_`var'`level'_`i'.dta", replace)
			
			use "../temp/synth_`var'`level'_`i'.dta", clear
			rename _time years
			gen tr_effect_`i' = _Y_treated - _Y_synthetic
			keep years tr_effect_`i'
			drop if missing(years)
			save "../temp/synth_`var'`level'_`i'.dta", replace
			cap saveold "../temp/synth_`var'`level'_`i'.dta", v(12) replace
		}
	}
	
	forval i = 1/`number_outcomes' {	
		local var: word `i' of `outcomes'
		use "../temp/synth_`var'`level'_`min_unit'.dta", clear
		foreach i of local groups {
			merge 1:1 years using "../temp/synth_`var'`level'_`i'.dta", nogen
	}
		
		save "../temp/allsynth_`var'_`city'`level'.dta", replace
		cap saveold "../temp/allsynth_`var'_`city'`level'.dta", v(12) replace
		
		rename tr_effect_`trunit' `city'
		keep year `city'
		
		save "../temp/`var'_`city'`level'.dta", replace
		cap saveold "../temp/`var'_`city'`level'.dta", v(12) replace
	}
	
  end

*-------------------- Building placebo tests: plots ---------------------------*

  ***** Define Program 

  program define s_plac_plots
	
    syntax, outcomes(string) controls(string) stub(string) city(string) [level(string) title(string)]
    
	use "../temp/donorpool_`city'`level'.dta", clear
    
	levelsof metcode2, local(groups)
	local number_outcomes: word count `outcomes'
	
	forval i = 1/`number_outcomes' {	
		local var: word `i' of `outcomes'
        local stub_var: word `i' of `stub'

	    use "../temp/allsynth_`var'_`city'`level'.dta", clear
        merge 1:1 year using "../temp/`var'_`city'`level'.dta", nogen
		sum `city' if years < 2006
		local bound = 5*(abs(r(max)) + abs(r(min)))
		local lp
	    foreach i of local groups {
		    sum tr_effect_`i' if years < 2006
			
			if r(max)< `bound' & r(min)>-`bound' {
				local lp `lp' line tr_effect_`i' years , lcolor(gs12) ||
			}
			
		}
		
		twoway `lp' || line `city' years, ///
			   lcolor(navy) lwidth(thick) legend(off) xline(2005, lcolor(black) lpattern(dot)) ///
			   title("`stub_var'", color(black) size(medium)) name(placebo_`var'`level',replace) ///
			   bgcolor(white) graphregion(color(white)) xtitle("Year") ///
			   xlabel(1996 "96" 1998 "98" 2000 "00" 2002 "02" 2004 "04" 2006 "06" 2008 "08" 2010 "10" 2012 "12" 2014 "14") ///
			   xscale(range(1996 2014)) ylabel(#3)
		graph export "../figures/placebo_`var'`level'", replace as(eps)
	}
	
	forval i = 1/`number_outcomes' {
	    local outcome_var: word `i' of `outcomes'
	    local plots = "`plots' " + "placebo_`outcome_var'`level'"
	}
	
	local city_stub = proper("`city'")
	
	graph combine `plots', rows(3) graphregion(color(white)) ysize(8) xsize(6.5) ///
	       title({bf: `city_stub': `title' Placebo Checks}, color(black) size(small)) ///
		   note("{it:Note:} Each graph reports the difference in the outcome variable between treated group and""synthetic control, assuming a treatment in 2005, for 86 metropolitan areas. The bold blue line""represents `city_stub' and the grey lines represent the other metropolitan areas in the control group.""The top figure shows the graph for the logarithm of weekly wages, the figure in the middle""shows it for the employment and the bottom figure for inactivity.", size(vsmall)) ///
		   caption("{it:Source:} CPS March Supplement 1996 - 2014.", size(vsmall))
	graph export "../figures/placebo`level'`city'", replace as(eps)
  
  end 

******************************************************************************** 
