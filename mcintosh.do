clear all
set more off, permanently
set matsize 800

cd "C:\Users\dgentil1\Desktop\Master Project\Build\code" 

program main
	use "../derived/CPSASECfinal.dta", clear
	
	local outcome_vars	= "lr_w_wage emplyd inactive"
	local stub_list = "Log-wage Employment Inactivity"
		
	build_mcintosh_rep_tab	
	build_mcintosh_control, outcomes(`outcome_vars') city(houston)
end

program build_mcintosh_control
	syntax, outcomes(string) city(string)

	use "..\derived\CPSASECfinal.dta", clear

	drop if kat_affected==1
	drop if (control == 0 & `city'==0)
	drop if katevac2==1

	collapse (mean) `outcomes' `city' control kat_affected [aw=wtsupp], by(year metcode2)
	save "../temp/mcintosh_donorpool.dta", replace

	keep `outcomes' year `city' kat_affected control
	collapse (mean) `outcomes' if `city'==0 & control == 1 & kat_affected==0 , by(year)

	rename (`outcomes') =_unaffected
	rename (`outcomes') `city'_=

	save "../temp/mcintoshcontrol.dta", replace
end

program build_mcintosh_rep_tab
	use "../derived/CPSASECfinal.dta", clear

	label variable houston "Houston"
	label variable postkat "Post-Katrina"
	label variable did_houston "Post-Katrina x Houston"
	drop if kat_affected==1
	drop if control == 0 & houston==0
	drop if katevac2==1

	eststo clear
	foreach var in lr_w_wage emplyd {
		eststo: reg `var' houston postkat did_houston c.age c.age#c.age i.marst i.sex i.marst#i.sex i.educat ///
		i.ethnic i.workcat i.occ2010 i.metcode2 i.year [aw=wtsupp], r cluster(metcode2)
	}

	esttab using "../tables/mcintosh_replication.tex", label se ar2 compress replace nonotes ///
	title(Replication of McIntosh with CPS March ASEC Sample \label{tab5}) keep(houston postkat did_houston) ///
	mtitles("Log Wage" "Employment Rate")   ///
	addnote("{it:Note:} Observations are weighted using CPS Supplement weights, robust standard errors in parentheses are clustered""at the metropolitan area level. We include individual level covariates (age, age-squared, sex,""marital status, the interaction of sex and marital status, education, ethnicity, industry and occupation).""We also use year and metropolitan area fixed effects." "∗ p<0.05,∗∗ p<0.01,∗∗∗ p<0.001" "Source: CPS March Supplement 1996 - 2014.")
end

*Execute
main
