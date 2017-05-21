 
 *------------------ Creating McIntosh control and tables ---------------------*

  ***** Define Program 

  program define mcintosh

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

	capture set matsize 11000

	`sil' use "${work_asec}CPSASECfinal.dta", clear
	
	local outcome_vars = "lr_w_wage emplyd inactive"
	local stub_list = "Log-wage Employment Inactivity" // NOT USED???
	
	mcintosh_tables	
	mcintosh_control, outcomes(`outcome_vars') city(houston)

  end
  
*------------------- Replicating McIntosh methodology -------------------------*

  ***** Define Program 

  program define mcintosh_control

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

	syntax, outcomes(string) city(string)

	`sil' use "${work_asec}CPSASECfinal.dta", clear

	`sil' drop if kat_affected==1
	`sil' drop if (control == 0 & `city'==0)
	`sil' drop if katevac2==1

	`sil' collapse (mean) `outcomes' `city' control kat_affected [aw=wtsupp], by(year metcode2)
	`sil' save "${temp}mcintosh_donorpool.dta", replace
	cap saveold "${temp}mcintosh_donorpool.dta", v(12) replace
	
	keep `outcomes' year `city' kat_affected control
	`sil' collapse (mean) `outcomes' if `city'==0 & control == 1 & kat_affected==0 , by(year)

	rename (`outcomes') =_unaffected
	rename (`outcomes') `city'_=

	`sil' save "${temp}mcintoshcontrol.dta", replace
	cap saveold "${temp}mcintoshcontrol.dta", v(12) replace
	
  end
  
*------------------------ Build McIntosh tables -------------------------------*

  ***** Define Program 

  program define mcintosh_tables

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

	`sil' use "${work_asec}CPSASECfinal.dta", clear

	label variable houston "Houston"
	label variable postkat "Post-Katrina"
	label variable did_houston "Post-Katrina x Houston"
	`sil' drop if kat_affected==1
	`sil' drop if control == 0 & houston==0
	`sil' drop if katevac2==1

	eststo clear
	foreach var in lr_w_wage emplyd {
		`sil' eststo: reg `var' houston postkat did_houston c.age c.age#c.age i.marst i.sex i.marst#i.sex i.educat ///
			  i.ethnic i.workcat i.occ2010 i.metcode2 i.year [aw=wtsupp], r cluster(metcode2)
	}

	`sil' esttab using "${tables}mcintosh_replication.tex", label se ar2 compress replace nonotes ///
	title(Replication of McIntosh with CPS March ASEC Sample \label{tab5}) keep(houston postkat did_houston) ///
	mtitles("Log Wage" "Employment Rate")   ///
	addnote("{it:Note:} Observations are weighted using CPS Supplement weights, robust standard errors in parentheses are clustered""at the metropolitan area level. We include individual level covariates (age, age-squared, sex,""marital status, the interaction of sex and marital status, education, ethnicity, industry and occupation).""We also use year and metropolitan area fixed effects." "∗ p<0.05,∗∗ p<0.01,∗∗∗ p<0.001" "Source: CPS March Supplement 1996 - 2014.")

  end

********************************************************************************
