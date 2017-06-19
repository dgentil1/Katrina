 
 *-------------------- Difference-in-Differences (ASEC) ----------------------*

  ***** Define Program 
  
  program define did
  
    foreach samples in asec morg {
		use "../derived_`samples'/controltrends_houston.dta", clear 
		
		local outcome_vars	= "lr_w_wage emplyd inactive"
		local stub_list = "Log-wage Employment Inactivity"
		
		did_reshape_label, outcomes(`outcome_vars') city(houston)
        
		local number_outcomes: word count `outcome_vars'
		
		forval i = 1/`number_outcomes' {
			local var: word `i' of `outcome_vars'
			local stub: word `i' of `stub_list'
			
			did_scm_tables, sample(`samples') var(`var') stub(`stub') city(houston)
		}
	}
	
	local education_levels = "nohighsch highsch somecollege college"
	local number_education: word count `education_levels'

	forval i = 1/`number_education' {
	    local education: word `i' of `education_levels'
		
		foreach samples in asec morg {
			use "../derived_`samples'/controltrends_houston_`education'.dta", clear 
			
			local outcome_vars	= "lr_w_wage emplyd inactive"
			local stub_list = "Log-wage Employment Inactivity"
			
			did_reshape_label, outcomes(`outcome_vars') city(houston)
			
			local number_outcomes: word count `outcome_vars'
			
			forval i = 1/`number_outcomes' {
				local var: word `i' of `outcome_vars'
				local stub: word `i' of `stub_list'
				
				did_scm_tables, sample(`samples') var(`var') stub(`stub') city(houston) educ_level(`education')
			}
		}
	}
		
	local outcome_vars	= "lr_w_wage emplyd inactive"
	local stub_list = "Log-wage Employment Inactivity"	

	did_pretrends, data(../derived_asec/CPSASECfinal.dta) data_stub(asec) ///
	    outcomes(`outcome_vars') stub(`stub_list')
    did_pretrends, data(../derived_morg/MORGfinal.dta) data_stub(morg) ///
	    outcomes(`outcome_vars') stub(`stub_list')
	
	local control_vars = "c.age c.age#c.age i.marital#i.sex i.marital i.sex i.educat " + ///
		                   "i.ethnic i.workcat i.kindocc i.metcode2 i.year"

	did_tables, data(../derived_asec/CPSASECfinal.dta) data_stub(asec) outcomes(`outcome_vars') controls(`control_vars')
	did_tables, data(../derived_morg/MORGfinal.dta) data_stub(morg) outcomes(`outcome_vars') controls(`control_vars')

	local education_titles = "High-School-Dropouts High-School Incomplete-College College"
	local control_vars = "c.age c.age#c.age i.marital#i.sex i.marital i.sex " + ///
		                   "i.ethnic i.workcat i.kindocc i.metcode2 i.year"
	
	forval i = 1/`number_education' {
	    local education: word `i' of `education_levels'
		local education_title: word `i' of `education_titles'
		
		did_pretrends, data(../derived_asec/CPSASECfinal.dta) data_stub(asec) ///
		    outcomes(`outcome_vars') stub(`stub_list') educ_level(`education') educ_stub(`education_title')
		did_tables, data(../derived_asec/CPSASECfinal.dta) data_stub(asec) ///
		    outcomes(`outcome_vars') controls(`control_vars') educ_level(`education') educ_stub(`education_title')
		
		did_pretrends, data(../derived_morg/MORGfinal.dta) data_stub(morg) ///
		    outcomes(`outcome_vars') stub(`stub_list') educ_level(`education') educ_stub(`education_title')
		did_tables, data(../derived_morg/MORGfinal.dta) data_stub(morg) ///
		    outcomes(`outcome_vars') controls(`control_vars') educ_level(`education') educ_stub(`education_title')
	}

  end  

*--------------------------- DiD: Reshape and Label ---------------------------*

  ***** Define Program 

  program define did_reshape_label

    syntax, outcomes(string) city(string)
	
	local number_outcomes: word count `outcomes'
	
	forval i = 1/`number_outcomes' {
		local outcome_var: word `i' of `outcomes'
		rename (`city'_`outcome_var' synthetic_`city'_`outcome_var') ///
               (`outcome_var'0 `outcome_var'1)
	}
	
    reshape long  `outcomes', i(year) j(city)
	
	local label_city = proper("`city'")
    label define citylabel 0 "`label_city'"
	label define citylabel 1 "Synthetic `label_city'", add
	label values city citylabel

	gen `city'=city==0
	gen synth=city==1

	gen postkat = (year>=2006)
	gen synth_sample= (`city'==1 | synth==1)
	gen did_`city'=postkat*`city'
	
	label variable `city' "`label_city'"
	label variable postkat "Post-Katrina"
	label variable did_`city' "Post-Katrina x `label_city'"
	
	gen postkat_short = (year == 2006 | year == 2007 | year == 2008)
	replace postkat_short = . if year > 2008
	gen did_`city'_short = postkat_short*`city'
	label variable postkat_short "Post"
	label variable did_`city'_short "Post x `city_legend'"

  end	

*--------------------------- DiD: Synthetic Tables ----------------------------*

  ***** Define Program 

  program define did_scm_tables
  
	syntax, var(string) stub(string) city(string) sample(string) [educ_level(string)]

	local city_legend = upper("`city'")
	local sample_legend = upper("`sample'")
	
	eststo clear
	
	eststo: reg `var' `city' postkat did_`city' if synth_sample==1, r 
	
	esttab using "../tables/`sample'did_synth_`var'_`city'`educ_level'.tex", label se ar2 compress replace nonotes ///
		   title(`sample_legend' - Diff-in-Diff for `stub'\label{tab1}) ///
		   mtitles("Synthetic Control") ///
		   addnote("{it:Note:} Robust standard errors in parentheses.")
	
    eststo clear
	
	eststo: reg `var' `city' postkat_short did_`city'_short if synth_sample==1, r 
	
	esttab using "../tables/`sample'did_synth_`var'_`city'`educ_level'.tex", label se ar2 compress replace nonotes ///
		   title(`sample_legend' - Short term Diff-in-Diff for `stub'\label{tab1}) ///
		   mtitles("Synthetic Control") ///
		   addnote("{it:Note:} Robust standard errors in parentheses.")

  end

*------------------------------ DiD: Pre-trends -------------------------------*

  ***** Define Program 

  program define did_pretrends
  
    syntax, outcomes(string) data(string) data_stub(string) stub(string) [educ_level(string) educ_stub(string)]

	foreach sample in treat_expanded control {
		use `data', clear
		
		drop if kat_affected == 1
		drop if evac == 1
		
		if "`educ_level'" != "" {
		    keep if `educ_level' == 1
		}
			
		collapse `outcomes' if `sample'==1 [aw=weight], by(year) 
		gen `sample' = 1
		save "../temp/trend_`data_stub'_`sample'`educ_level'.dta", replace 
	}
	
	append using "../temp/trend_`data_stub'_treat_expanded`educ_level'.dta"
	replace treat_expanded=0 if treat_expanded ==.
	replace control=0 if control==.
	
	local number_outcomes: word count `outcomes'
	
	forval i = 1/`number_outcomes' {
		local var: word `i' of `outcomes'
		local stub_var: word `i' of `stub'

		qui twoway (line `var' year if treat_expanded == 1) ///
	           (line `var' year if control == 1), legend(label(1 "Treatment") label(2 "Control")) ///
			   xtitle("Year") ytitle("`stub_var'") title("`stub_var'", color(black) size(medium)) graphregion(color(white)) bgcolor(white) name(check_`var'`educ_level', replace) ///
			   xline(2006, lcolor(black) lpattern(dot)) xtitle("Year") ylabel(#3) ///
			   xlabel(1996 "96" 1998 "98" 2000 "00" 2002 "02" 2004 "04" 2006 "06" 2008 "08" 2010 "10" 2012 "12" 2014 "14") xscale(range(1996 2014))
		
		local plots = "`plots' " + "check_`var'`educ_level'"
	}
	
	local outcome1: word 1 of `outcomes' 	
	local data_legend = upper("`data_stub'")

	grc1leg `plots', rows(3) legendfrom(check_`outcome1'`educ_level') position(6) /// 
		   graphregion(color(white)) title({bf:`data_legend' `educ_stub' outcome time trends}, color(black) size(small)) ///
		   note("{it:Note:} Each graph shows the trend of the outcome variables for both treatment (blue line)""and control group (red line) across time. The vertical line, representing the beginning of the""post-treatment period, is depicted for the year 2005. The top figure shows the graph for the logarithm of""weekly wages, the figure in the middle shows it for the employment and the bottom figure for inactivity.", size(vsmall)) ///
		   caption("{it:Source:} CPS `data_legend' 1996 - 2014.", size(vsmall))
	graph display, ysize(8.5) xsize(6.5)
	graph export "../figures/checkslong`data_stub'_`educ_level'.png", replace

  end

*-------------------------------- DiD: Tables ---------------------------------*

  ***** Define Program 

  program define did_tables

    syntax, data(string) data_stub(string) outcomes(string) controls(string) [educ_level(string) educ_stub(string)]

	use `data', clear
	
	drop if kat_affected==1
	drop if evac==1
	
	label variable treat_expanded "Treatment"
	
	if "`educ_level'"!="" {
	    keep if `educ_level'==1
	} 
	
	gen did_treat=postkat*treat_expanded
	label variable postkat "Post"
	label variable did_treat "Post x Treatment"
	
	gen postkat_short = (year == 2006 | year == 2007 | year == 2008)
	replace postkat_short = . if year > 2008
	gen did_treat_short = postkat_short*treat_expanded
	label variable postkat_short "Post"
	label variable did_treat_short "Post x Treatment"
	
	eststo clear
	
	local number_outcomes: word count `outcomes'
	
	forval i = 1/`number_outcomes' {
		local var: word `i' of `outcomes'
		eststo: reg `var' treat_expanded postkat did_treat `controls' ///
			   if (treat_expanded ==1 | control==1) [aw=weight], r cluster(metcode2) 
	}
	local data_legend = upper("`data_stub'")

	esttab using "../tables/diffindiff`data_stub'`educ_level'.tex", label se ar2 compress replace nonotes ///
		   title(`data_legend' `educ_stub' Diff-in-Diff for Treatment vs Control Group, CPS `data_legend' Sample \label{tab5}) keep(treat_expanded postkat did_treat) ///
		   mtitles("Log Wage" "Employment Rate" "Inactivity")   ///
		   addnote("{Note:} Observations are weighted using CPS weights, robust standard errors in parentheses" "are clustered at the metropolitan area level. We include individual level covariates (age," "age-squared, sex,marital status, the interaction of sex and marital status, education, ethnicity, industry and occupation)." "We also use year and metropolitan area fixed effects." "Source: CPS March Supplement 1999 - 2011.")
	   
	eststo clear
		
	forval i = 1/`number_outcomes' {
		local var: word `i' of `outcomes'
		eststo: reg `var' treat_expanded postkat_short did_treat_short `controls' ///
			   if (treat_expanded ==1 | control==1) [aw=weight], r cluster(metcode2) 
	}
	local data_legend = upper("`data_stub'")

	esttab using "../tables/short_diffindiff`data_stub'`educ_level'.tex", label se ar2 compress replace nonotes ///
		   title(`data_legend' `educ_stub' Short term Diff-in-Diff for Treatment vs Control Group, CPS `data_legend' Sample \label{tab5}) keep(treat_expanded postkat_short did_treat_short) ///
		   mtitles("Log Wage" "Employment Rate" "Inactivity")   ///
		   addnote("{Note:} Observations are weighted using CPS weights, robust standard errors in parentheses" "are clustered at the metropolitan area level. We include individual level covariates (age," "age-squared, sex,marital status, the interaction of sex and marital status, education, ethnicity, industry and occupation)." "We also use year and metropolitan area fixed effects." "Source: CPS March Supplement 1999 - 2011.")
	   
  end

********************************************************************************
