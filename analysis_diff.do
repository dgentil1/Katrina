clear all
set more off, permanently
set matsize 800

cd "C:\Users\dgentil1\Desktop\Master Project\Build\code" 

program main 
    foreach city in houston dallas fayetteville {
		use "../derived/controltrends_`city'.dta", clear 
		local outcome_vars	= "lr_w_wage emplyd inactive"
		local stub_list = "Log-wage Employment Inactivity"
		reshape_and_label, outcomes(`outcome_vars') city(`city')
        
		local number_outcomes: word count `outcome_vars'
		forval i = 1/`number_outcomes' {
			local var: word `i' of `outcome_vars'
			local stub: word `i' of `stub_list'
			build_did_synth_tab, var(`var') stub(`stub') city(`city')
		}
	}
	
	local education_levels = "nohighsch highsch somecollege college"
	local number_education: word count `education_levels'

	forval i = 1/`number_education' {
	    local education: word `i' of `education_levels'
		foreach city in houston dallas fayetteville {
			use "../derived/controltrends_`city'_`education'.dta", clear 
			local outcome_vars	= "lr_w_wage emplyd inactive"
			local stub_list = "Log-wage Employment Inactivity"
			reshape_and_label, outcomes(`outcome_vars') city(`city')
			
			local number_outcomes: word count `outcome_vars'
			forval i = 1/`number_outcomes' {
				local var: word `i' of `outcome_vars'
				local stub: word `i' of `stub_list'
				build_did_synth_tab, var(`var') stub(`stub') city(`city') educ_level(`education')
			}
		}
		}
		local outcome_vars	= "lr_w_wage emplyd inactive"
		local stub_list = "Log-wage Employment Inactivity"	
	build_pre_trends_did, outcomes(`outcome_vars') stub(`stub_list')
    local control_vars = "c.age c.age#c.age i.marst#i.sex i.marst i.sex i.educat " + ///
		                 "i.ethnic i.workcat i.occ2010 i.metcode2 i.year"
	build_did_tab, outcomes(`outcome_vars') controls(`control_vars')
	
	local education_titles = "High-School-Dropouts High-School Incomplete-College College"
	local control_vars = "c.age c.age#c.age i.marst#i.sex i.marst i.sex i.educat " + ///
					 "i.ethnic i.workcat i.occ2010 i.metcode2 i.year"
	
	forval i = 1/`number_education' {
	    local education: word `i' of `education_levels'
		local education_title: word `i' of `education_titles'
		build_pre_trends_did, outcomes(`outcome_vars') stub(`stub_list') educ_level(`education') educ_stub(`education_title')
		build_did_tab, outcomes(`outcome_vars') controls(`control_vars') educ_level(`education') educ_stub(`education_title')
	}
end 

program reshape_and_label
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
end	

program build_did_synth_tab
	syntax, var(string) stub(string) city(string) [educ_level(string)]

	eststo clear
	eststo: reg `var' `city' postkat did_`city' if synth_sample==1, r 
	
	esttab using "../tables/did_synth_`var'_`city'`educ_level'.tex", label se ar2 compress replace nonotes ///
		title(Diff in Diff for `stub'\label{tab1}) ///
		mtitles("Synthetic Control") ///
		addnote("{it:Note:} Robust standard errors in parentheses.")
end
	
program build_pre_trends_did
    syntax, outcomes(string) stub(string) [educ_level(string) educ_stub(string)]
	
	foreach sample in treat control {
		use "../derived/CPSASECfinal.dta", clear

		drop if kat_affected == 1
		drop if evac == 1
		
		if "`educ_level'" != "" {
		    keep if `educ_level' == 1
		}
			
		collapse `outcomes' if `sample'==1 [aw=wtsupp], by(year) 
		gen `sample' = 1
		save "../temp/trend_`sample'`educ_level'.dta", replace 
	}
	
	append using "../temp/trend_treat`educ_level'.dta"
	replace treat=0 if treat ==.
	replace control=0 if control==.
	
	local number_outcomes: word count `outcomes'
	forval i = 1/`number_outcomes' {
		local var: word `i' of `outcomes'
		local stub_var: word `i' of `stub'

		twoway (line `var' year if treat == 1) ///
	        (line `var' year if control == 1), legend(label(1 "Treatment") label(2 "Control")) ///
			xtitle("Year") ytitle("`stub_var'") title("`stub_var'", color(black) size(medium)) graphregion(color(white)) bgcolor(white) name(check_`var'`educ_level',replace) ///
			xline(2005, lcolor(black) lpattern(dot)) xtitle("Year") ylabel(#3) ///
			xlabel(1996 "96" 1998 "98" 2000 "00" 2002 "02" 2004 "04" 2006 "06" 2008 "08" 2010 "10" 2012 "12" 2014 "14") xscale(range(1996 2014))
			local plots = "`plots' " + "check_`var'`educ_level'"
	}
	
	local outcome1: word 1 of `outcomes' 	
	grc1leg `plots', rows(3) legendfrom(check_`outcome1'`educ_level') position(6) /// 
	graphregion(color(white)) title({bf:`educ_stub' Outcome time trends for treatment and control}, color(black) size(small)) ///
	note("{it:Note:} Each graph shows the trend of the outcome variables for both treatment (blue line)""and control group (red line) across time. The vertical line, representing the beginning of the""post-treatment period, is depicted for the year 2005. The top figure shows the graph for the logarithm of""weekly wages, the figure in the middle shows it for the employment and the bottom figure for inactivity.", size(vsmall)) ///
	caption("{it:Source:} CPS March Supplement 1996 - 2014.", size(vsmall))
	graph display, ysize(8.5) xsize(6.5)
	graph export "../figures/checkslong`educ_level'.png", replace
end

program build_did_tab
    syntax, outcomes(string) controls(string) [educ_level(string) educ_stub(string)]

	use "../derived/CPSASECfinal.dta", clear

	drop if kat_affected==1
	drop if evac==1
	label variable treat "Treatment"
	
	if "`educ_level'" != "" {
	    keep if `educ_level' == 1
	} 

	gen did_treat=postkat*treat
	label variable postkat "Post"
	label variable did_treat "Post x Treatment"
	
	eststo clear
	local number_outcomes: word count `outcomes'
	forval i = 1/`number_outcomes' {
		local var: word `i' of `outcomes'
		eststo: reg `var' treat postkat did_treat `controls' ///
			if (treat ==1 | control==1) [aw=wtsupp], r cluster(metcode2) 
	}

	esttab using "../tables/diffindiff`educ_level'.tex", label se ar2 compress replace nonotes ///
		title(`educ_stub' Differences in Differences for Treatment vs Control Group, CPS March ASEC Sample \label{tab5}) keep(treat postkat did_treat) ///
		mtitles("Log Wage" "Employment Rate" "Inactivity")   ///
		addnote("{Note:} Observations are weighted using CPS Supplement weights, robust standard errors in parentheses" "are clustered at the metropolitan area level. We include individual level covariates (age," "age-squared, sex,marital status, the interaction of sex and marital status, education, ethnicity, industry and occupation)." "We also use year and metropolitan area fixed effects." "Source: CPS March Supplement 1996 - 2014.")
end 

*Execute
main



