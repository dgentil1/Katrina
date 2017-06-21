 
 *---- Constructing pre-trends of the outcome variables (ASEC and MORG) -------*

  ***** Define Program 

  program define pretrends

	local outcome_vars	= "lr_w_wage emplyd inactive"
	
	local stub_list = "Log-wage Employment Inactivity"
	
	s_pre_scm, outcomes(`outcome_vars') sample(asec) city(houston) tr_period(2006) stub(`stub_list')	
	s_pre_scm, outcomes(`outcome_vars') sample(morg) city(houston) tr_period(2006) stub(`stub_list')
	
	grc1leg asec_alltrends_houston.gph morg_alltrends_houston.gph, ///
	       cols(2) legendfrom(asec_alltrends_houston.gph) position(6) /// 
		   graphregion(color(white))
	graph display, ysize(5) xsize(6.5)
	graph export "../figures/alltrends_houston.png", replace
	
	local education_levels = "nohighsch highsch somecollege college"
	
	local education_titles = "High-School-Dropouts High-School Incomplete-College College"
	
	local number_educations: word count `education_levels'
	
	forval i = 1/`number_educations' {
		local education: word `i' of `education_levels'
		local education_title: word `i' of `education_titles'
		s_pre_scmedu, outcomes(`outcome_vars') sample(asec) city(houston) tr_period(2006) ///
		    stub(`stub_list') level(_`education') title(`education_title')
		s_pre_scmedu, outcomes(`outcome_vars') sample(morg) city(houston) tr_period(2006) ///
		    stub(`stub_list') level(_`education') title(`education_title')	
	}
	
	forval i = 1/4 {
		local education_level: word `i' of `education_levels'
		local education_title: word `i' of `education_titles'
		grc1leg asec_alltrends_houston_`education_level'.gph morg_alltrends_houston_`education_level'.gph, ///
		    cols(2) legendfrom(asec_alltrends_houston_`education_level'.gph) position(6) ///
			graphregion(color(white))
		graph display, ysize(5) xsize(6.5)
		graph export "../figures/alltrends_houston_`education_level'.png", replace
		}
  end

*-------------------------------- Pretrends SCM -------------------------------*

  ***** Define Program 

  program define s_pre_scm
  
	syntax [if], outcomes(string) sample(string) city(string) tr_period(int) stub(string)

	use "../derived_`sample'/controltrends_`city'.dta", clear

	local number_outcomes: word count `outcomes'
	
	forval i = 1/`number_outcomes' {
		local outcome_var: word `i' of `outcomes'
		local stub_var: word `i' of `stub'
		local vertical = `tr_period' - 1
		local city_legend = proper("`city'")
		
		qui twoway (line `city'_`outcome_var' year, lcolor(navy) lwidth(thick)) ///
			   (line synthetic_`city'_`outcome_var' year, lpattern(dash) lcolor(black)), xtitle("Year") ///
			   ytitle("`stub_var'") xline(`vertical', lcolor(black) lpattern(dot)) ///
			   legend(label(1 `city_legend') label(2 "Synthetic `city_legend'")) ///
			   title(`stub_var', color(black) size(medium)) ///
			   xlabel(1996 "96" 1998 "98" 2000 "00" 2002 "02" 2004 "04" 2006 "06" 2008 "08" 2010 "10" 2012 "12" 2014 "14") ///
			   xscale(range(1996 2014)) ylabel(#2) graphregion(color(white)) bgcolor(white) name(`sample'_trend_`outcome_var',replace)
	}
	
	local number_outcomes: word count `outcomes'
	
	forval i = 1/`number_outcomes' {
		local outcome_var: word `i' of `outcomes'
		local plots = "`plots' " + "`sample'_trend_`outcome_var'"
	}
	
	local city_legend = proper("`city'")
	local sample_legend = upper("`sample'")
	
	local plot1: word 1 of `plots' 	
	
	grc1leg `plots', rows(3) legendfrom(`plot1') position(6) /// /* cols(1) or cols(3) */
		   graphregion(color(white)) title({bf: `sample_legend'}, color(black) size(small))
	graph display, ysize(8.5) xsize(6.5)
	graph save `sample'_alltrends_houston.gph, replace
  end	
  
*------------------------ Pretrends SCM (Education) ---------------------------*

  ***** Define Program 

  program define s_pre_scmedu

	syntax, outcomes(string) sample(string) city(string) tr_period(int) stub(string) level(string) title(string)

	use "../derived_`sample'/controltrends_`city'`level'.dta", clear

	local number_outcomes: word count `outcomes'
	forval i = 1/`number_outcomes' {
		local outcome_var: word `i' of `outcomes'
		local stub_var: word `i' of `stub'
		local vertical = `tr_period' - 1
		local city_legend = proper("`city'")
		
		qui twoway (line `city'_`outcome_var' year, lcolor(navy) lwidth(thick)) ///
			   (line synthetic_`city'_`outcome_var' year, lpattern(dash) lcolor(black)), ///
			   ytitle("`stub_var'") xline(`vertical', lcolor(black) lpattern(dot)) ///
			   xtitle("Year") legend(label(1 `city_legend') label(2 "Synthetic `city_legend'")) ///
			   title(`stub_var', color(black) size(medium)) ///
			   xlabel(1996 "96" 1998 "98" 2000 "00" 2002 "02" 2004 "04" 2006 "06" 2008 "08" 2010 "10" 2012 "12" 2014 "14") ///
			   xscale(range(1996 2014)) ylabel(#2) graphregion(color(white)) bgcolor(white) name(`sample'_trend_`outcome_var'`level',replace)
    }
	
	local number_outcomes: word count `outcomes'
	local sample_legend = upper("`sample'")

	forval i = 1/`number_outcomes' {
		local outcome_var: word `i' of `outcomes'
		local plots = "`plots' " + "`sample'_trend_`outcome_var'`level'"
	}
	
	local plot1: word 1 of `plots' 	
	
	grc1leg `plots', rows(3) legendfrom(`plot1') position(6) /// /* cols(1) or cols(3) */
		   graphregion(color(white)) title({bf: `sample_legend'}, color(black) size(small))
	graph display, ysize(8.5) xsize(6.5)
	graph save `sample'_alltrends_houston`level'.gph, replace	
  end

********************************************************************************     
