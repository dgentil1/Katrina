 
 *---------------------- Descriptive statistics (ASEC) -----------------------*

 ***** Define Program 

  program define de_descriptive_asec
	
 ***** Computing descriptives: demographic characteristics evacuees vs nonevacuees
 
 	use "../temp/CPSASEC.dta", clear
 
	keep if year==2006

	clear matrix 
	tabstat age nohighsch highsch somecollege college black mexican ///
				   nmhispan white other if evac == 1 [aw=weight], c(s) stat(mean semean) save
	matrix pre_output = r(StatTotal)'
	
	tabstat age nohighsch highsch somecollege college black mexican ///
				   nmhispan white other if evac == 0 [aw=weight], c(s) stat(mean semean) save
	matrix pre_output = (pre_output , r(StatTotal)')

	svmat pre_output

	drop if missing(pre_output1)
	keep pre_output*
	rename (pre_output1 pre_output2 pre_output3 pre_output4) (evac_mean evac_semean nevac_mean nevac_semean)
	gen diff_mean = evac_mean - nevac_mean
	gen se_diff_mean = sqrt(evac_semean^2 + nevac_semean^2)

	mkmat evac_mean nevac_mean diff_mean se_diff_mean, matrix(output)

	mat2txt, matrix(output) saving("../tables/descriptive_evac_vs_nevac_asec.txt") replace ///
		  	 format(%20.5f) title(<tab:descriptive_asec>)
	

 ***** Computing descriptives: labor status of treatment group, control group, and evacuees
	
	use "../derived_asec/CPSASECfinal.dta", clear
	
	keep if year==2006
	
	clear matrix 
	tabstat emplyd inactive unem hours_worked [aw=weight], c(s) stat(mean semean) save
	matrix output = r(StatTotal)
	
	tabstat emplyd inactive unem hours_worked if treat==1 [aw=weight], c(s) stat(mean semean) save
	matrix output = (output\r(StatTotal))
	
	tabstat emplyd inactive unem hours_worked if control==1 [aw=weight], c(s) stat(mean semean) save
	matrix output = (output\r(StatTotal))
	
	tabstat emplyd inactive unem hours_worked if evac==1 [aw=weight], c(s) stat(mean semean) save
	matrix output = (output\r(StatTotal))
	
	tabstat emplyd inactive unem hours_worked if (treat==1 & evac==1) [aw=weight], c(s) stat(mean semean) save
	matrix output = (output\r(StatTotal))

	mat2txt, matrix(output) saving("../tables/labor_status_sample.txt") replace ///
		  	 format(%20.5f) title(<tab:labor_status_sample_asec>)
	
  end

********************************************************************************  

