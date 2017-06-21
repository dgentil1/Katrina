
 *---------- Reconciliating treatment assignment between MORG and ASEC -------*

 ***** Define Program 
  
  program d_treatment_reconciliation
  
 *** Prepare ASEC and MORG
  
    use "../derived_asec/CPSASECfinal.dta", clear
	collapse share_evac share_evac_sd obs treat treat_expanded control kat_affected, by(metcode2)
	gen share_evac_se = share_evac_sd / obs
	rename (share_evac share_evac_sd share_evac_se obs treat treat_expanded control) =_asec
	save "../derived_asec/metarea_list_asec.dta", replace

	use "../derived_morg/MORGfinal.dta", clear
	keep if cities_in_sample == 1 
	collapse share_evac share_evac_sd obs treat treat_expanded control cities_in_sample, by(metcode2)
	gen share_evac_se = share_evac_sd / obs
	rename (share_evac share_evac_sd share_evac_se obs treat treat_expanded control) =_morg
	save "../derived_morg/metarea_list_morg.dta", replace
	
 *** Put treat information together and assign treatment
	
	merge 1:1 metcode2 using "../derived_asec/metarea_list_asec.dta", nogen
	
	gen treat = 1 if treat_asec == 1 & treat_morg == 1
	replace treat = 0 if treat_asec == 0 & treat_morg == 0
	gen treat_expanded = 1 if treat_expanded_asec == 1 & treat_expanded_morg == 1
	replace treat_expanded = 0 if treat_expanded_asec == 0 & treat_expanded_morg == 0
	gen control = 1 if control_asec == 1 & control_morg == 1
	replace control = 0 if control_asec == 0 & control_morg == 0
	
	
	*** We should create table 3 here ****
	
	save "../temp/treat_reconciliation.dta", replace
	
 *** Merge back to full dataset
	
	use "../derived_asec/CPSASECfinal.dta", clear
		
	merge m:1 metcode2 using "../temp/treat_reconciliation.dta", nogen ///
	    keepusing(treat treat_expanded control cities_in_sample) keep(3)
	
	drop if missing(cities_in_sample)
	
	save "../derived_asec/CPSASECfinal.dta", replace
	
    use "../derived_morg/MORGfinal.dta", clear
		
	merge m:1 metcode2 using "../temp/treat_reconciliation.dta", nogen ///
	    keepusing(treat treat_expanded control cities_in_sample) keep(3)
	
	save "../derived_morg/MORGfinal.dta", replace

  end

********************************************************************************
