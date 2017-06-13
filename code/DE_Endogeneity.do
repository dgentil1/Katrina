*-------------------------- Endogeneity (ASEC-MORG) --------------------------*

 ***** Define Program 

program define de_endogeneity
	  	
	* Matching metcodes
	
    import delimited "../GIS/Layers/cb_2016_us_cbsa_5m.csv", encoding(ISO-8859-1) clear
	
	rename cbsafp cbsafips
	
    drop if missing(cbsafips) 
	merge 1:m cbsafips using "../derived_morg/xwalk_msafips_cbsa.dta", nogen keep(3)
	
	merge m:1 metcode2 using "../temp/treat_reconciliation.dta", nogen

	keep geoid metcode2 share_evac_asec share_evac_morg treat treat_expanded control kat_affected

	export delimited using "../GIS/Layers/cbsa_metcode_matched.csv", replace
	
    * Importing distance_matrix 
	
	import delimited "../GIS/Layers/MSA_distance.csv", clear
	
	drop if missing(metcode2)
	save "../temp/msa_distance.dta", replace

 ***** Adding in-sample pre-treatment labor outcomes

    * ASEC
	
	use "../derived_asec/CPSASECfinal.dta", clear
	
    preserve
		keep if year==2005
		collapse (mean) lr_w_wage_1 = lr_w_wage lr_h_wage_1 = lr_h_wage unem_1 = unem [pw=weight], by(metcode2)

		merge 1:m metcode2 using "../temp/msa_distance.dta", nogen
		
	    collapse distance lr_w_wage_1 lr_h_wage_1 unem_1 treat treat_expanded control kat_affected share_evac_asec, by(metcode2)
				
		save "../temp/endogeneity_1year.dta", replace
	restore
	
	keep if (year==2001 | year==2002 | year==2003 | year==2004 | year==2005)
	collapse (mean) lr_w_wage_5 = lr_w_wage lr_h_wage_5 = lr_h_wage unem_5 = unem [pw=weight], by(metcode2)

	merge 1:m metcode2 using "../temp/msa_distance.dta", nogen
	
	collapse lr_w_wage_5 lr_h_wage_5 unem_5, by(metcode2)
		
	save "../temp/endogeneity_5year.dta", replace
	
	merge 1:1 metcode2 using "../temp/endogeneity_1year.dta", nogen
	
	rename (lr_w_wage_1 lr_w_wage_5 unem_1 unem_5) =_asec

	save "../derived_asec/endogeneity.dta", replace

	* MORG
	
    use "../derived_morg/MORGfinal.dta", clear
	
    preserve
		keep if year==2005
		collapse (mean) lr_w_wage_1 = lr_w_wage lr_h_wage_1 = lr_h_wage unem_1 = unem [pw=weight], by(metcode2)

		merge 1:m metcode2 using "../temp/msa_distance.dta", nogen
		
	    collapse distance lr_w_wage_1 lr_h_wage_1 unem_1 treat treat_expanded control kat_affected share_evac_morg, by(metcode2)
				
		save "../temp/endogeneity_1year.dta", replace
	restore
	
	keep if (year==2001 | year==2002 | year==2003 | year==2004 | year==2005)
	collapse (mean) lr_w_wage_5 = lr_w_wage lr_h_wage_5 = lr_h_wage unem_5 = unem [pw=weight], by(metcode2)

	merge 1:m metcode2 using "../temp/msa_distance.dta", nogen
	
	collapse lr_w_wage_5 lr_h_wage_5 unem_5, by(metcode2)
		
	save "../temp/endogeneity_5year.dta", replace
	
	merge 1:1 metcode2 using "../temp/endogeneity_1year.dta", nogen
	
	rename (lr_w_wage_1 lr_w_wage_5 unem_1 unem_5) =_morg
	
	save "../derived_morg/endogeneity.dta", replace
	
	* Merge ASEC and MORG
	
	merge 1:1 metcode2 using "../derived_asec/endogeneity.dta", nogen
	drop if missing(share_evac_morg)
	
	save "../temp/endogeneity.dta", replace
		
	* Compute regressions
			
	label var distance "Distance to New Orleans"
	label var unem_1_asec "Average unemployment rate, last year"
	label var unem_5_asec "Average unemployment rate, last 5 years"
	label var lr_w_wage_1_asec "Average log-weekly wage, last year"
	label var lr_w_wage_5_asec "Average log-weekly wage, last 5 years"
	label var unem_1_morg "Average unemployment rate, last year"
	label var unem_5_morg "Average unemployment rate, last 5 years"
	label var lr_w_wage_1_morg "Average log-weekly wage, last year"
	label var lr_w_wage_5_morg "Average log-weekly wage, last 5 years"
	label var share_evac_asec "Evacuees share (ASEC)"
	label var share_evac_morg "Evacuees share (MORG)"
	label var treat_expanded "Treatment"
	
	eststo clear

	eststo: reg share_evac_asec distance unem_1_asec lr_w_wage_1_asec
	eststo: reg share_evac_asec distance unem_5_asec lr_w_wage_5_asec
	
	eststo: reg share_evac_morg distance unem_1_morg lr_w_wage_1_morg
	eststo: reg share_evac_morg distance unem_5_morg lr_w_wage_5_morg
	
 	esttab using "../tables/endogeneity.tex", r2 se nocons ///
		   label compress replace width(2\hsize) title(Endogeneity of the treatment assignment)

  end  

********************************************************************************		   
