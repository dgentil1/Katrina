 
 *------------------------ Constructing pre-trends ----------------------------*

  ***** Define Program 

  program define s_pretrends

	use "../derived_asec/CPSASECfinal.dta", clear

	local control_vars = "unem wksunem1 hours_worked poor " + ///
		"sex white other black manuf bluecol whitecol " + ///
		"age nohighsch highsch somecollege college nmhispan " + ///
		"mexican"
		
	local outcome_vars	= "lr_w_wage emplyd inactive"
	
	local stub_list = "Log-wage Employment Inactivity"
	
	s_pre_scm, outcomes(`outcome_vars') controls(`control_vars') ///
			city(houston) tr_period(2006) stub(`stub_list')	
	s_pre_scm, outcomes(`outcome_vars') controls(`control_vars') ///
			city(dallas) tr_period(2006) stub(`stub_list')
	s_pre_scm, outcomes(`outcome_vars') controls(`control_vars') ///
			city(fayetteville) tr_period(2006) stub(`stub_list')
		
	local education_levels = "nohighsch highsch somecollege college"
	
	local education_titles = "High-School-Dropouts High-School Incomplete-College College"
	
	local number_educations: word count `education_levels'
	
	forval i = 1/`number_educations' {
		local education: word `i' of `education_levels'
		local education_title: word `i' of `education_titles'
		s_pre_scmedu, outcomes(`outcome_vars') controls(`control_vars') ///
		    city(houston) tr_period(2006) stub(`stub_list') level(_`education') title(`education_title')
		s_pre_scmedu, outcomes(`outcome_vars') controls(`control_vars') ///
		    city(dallas) tr_period(2006) stub(`stub_list') level(_`education') title(`education_title')
		s_pre_scmedu, outcomes(`outcome_vars') controls(`control_vars') ///
		    city(fayetteville) tr_period(2006) stub(`stub_list') level(_`education') title(`education_title')
	}
	
  end

*-------------------------------- Pretrends SCM -------------------------------*

  ***** Define Program 

  program define s_pre_scm
  
	syntax [if], outcomes(string) controls(string) city(string) tr_period(int) stub(string)

	use "../derived_asec/controltrends_`city'.dta", clear

	local number_outcomes: word count `outcomes'
	
	forval i = 1/`number_outcomes' {
		local outcome_var: word `i' of `outcomes'
		local stub_var: word `i' of `stub'
		local vertical = `tr_period' - 1
		local city_legend = proper("`city'")
		
		twoway (line `city'_`outcome_var' year, lcolor(navy) lwidth(thick)) ///
			   (line synthetic_`city'_`outcome_var' year, lpattern(dash) lcolor(black)), xtitle("Year") ///
			   ytitle("`stub_var'") xline(`vertical', lcolor(black) lpattern(dot)) ///
			   legend(label(1 `city_legend') label(2 "Synthetic `city_legend'")) ///
			   title(`stub_var', color(black) size(medium)) ///
			   xlabel(1996 "96" 1998 "98" 2000 "00" 2002 "02" 2004 "04" 2006 "06" 2008 "08" 2010 "10" 2012 "12" 2014 "14") ///
			   xscale(range(1996 2014)) ylabel(#3) graphregion(color(white)) bgcolor(white) name(trend_`outcome_var',replace)
	}
	
	local number_outcomes: word count `outcomes'
	
	forval i = 1/`number_outcomes' {
		local outcome_var: word `i' of `outcomes'
		local plots = "`plots' " + "trend_`outcome_var'"
	}
	
	local city_legend = proper("`city'")
	
	local outcome1: word 1 of `outcomes' 	
	
	grc1leg `plots', rows(3) legendfrom(trend_`outcome1') position(6) /// /* cols(1) or cols(3) */
		   graphregion(color(white)) title({bf: Outcome time trends}, color(black) size(small)) ///
		   note("{it:Note:} Each figure shows the outcome variable for `city_legend' (blue solid line)and Synthetic""control (dashed line) in the period 1994-2014. The top figure shows the""graph for the logarithm of weekly wages, the figure in the middle shows it for""employment and the bottom figure for inactivity. The vertical line is depicted for year 2005.", ///
		   size(vsmall)) caption("{it:Source:} CPS March Supplement 1996 - 2014.", size(vsmall))
	graph display, ysize(8.5) xsize(6.5)
	graph export "../figures/alltrends_`city'.png", replace

  end	
  
*------------------------ Pretrends SCM (Education) ---------------------------*

  ***** Define Program 

  program define s_pre_scmedu

	syntax, outcomes(string) controls(string) city(string) tr_period(int) stub(string) level(string) title(string)

	use "../derived_asec/controltrends_`city'`level'.dta", clear

	local number_outcomes: word count `outcomes'
	forval i = 1/`number_outcomes' {
		local outcome_var: word `i' of `outcomes'
		local stub_var: word `i' of `stub'
		local vertical = `tr_period' - 1
		local city_legend = proper("`city'")
		
		twoway (line `city'_`outcome_var' year, lcolor(navy) lwidth(thick)) ///
			   (line synthetic_`city'_`outcome_var' year, lpattern(dash) lcolor(black)), ///
			   ytitle("`stub_var'") xline(`vertical', lcolor(black) lpattern(dot)) ///
			   xtitle("Year") legend(label(1 `city_legend') label(2 "Synthetic `city_legend'")) ///
			   title(`stub_var', color(black) size(medium)) ///
			   xlabel(1996 "96" 1998 "98" 2000 "00" 2002 "02" 2004 "04" 2006 "06" 2008 "08" 2010 "10" 2012 "12" 2014 "14") ///
			   xscale(range(1996 2014)) ylabel(#3) graphregion(color(white)) bgcolor(white) name(trend_`outcome_var'`level',replace)
    }
	
	local number_outcomes: word count `outcomes'
	
	forval i = 1/`number_outcomes' {
		local outcome_var: word `i' of `outcomes'
		local plots = "`plots' " + "trend_`outcome_var'`level'"
	}
	
	local plot1: word 1 of `plots' 	
	
	grc1leg `plots', rows(3) legendfrom(`plot1') position(6) /// /* cols(1) or cols(3) */
		   graphregion(color(white)) title({bf:`title' - Outcome time trends}, color(black) size(small)) ///
		   note("{it:Note:} Each figure shows the outcome variable for `city_legend' (blue solid line)and Synthetic control (dashed line)"" in the period 1994-2014. The top figure shows the graph for the""logarithm of weekly wages, the figure in the middle shows it for employment and the bottom figure for""inactivity. The vertical line is depicted for year 2005.", ///
		   size(vsmall)) caption("{it:Source:} CPS March Supplement 1996 - 2014.", size(vsmall))
	graph display, ysize(8.5) xsize(6.5)
	graph export "../figures/alltrends_`city'`level'.png", replace
	
  end

********************************************************************************     
