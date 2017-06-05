 
 *-------------------------- Endogeneity (ASEC-MORG) --------------------------*

 ***** Define Program 

  program define de_endogeneity
	
  ***** Create the distance to New Orleans dataset 
  	
	import delimited "../GIS/layers/distance_matrix.csv", encoding(ISO-8859-1) clear
	
	drop targetid
	rename msa metarea   
	drop if missing(metarea)

	tostring metarea, gen(metarea1)
	destring metarea1, gen(metarea2)

	gen metcode=substr(metarea1,1,1) if metarea2<100
	replace metcode=substr(metarea1,1,2) if (metarea2>=100 & metarea2<1000)
	replace metcode=substr(metarea1,1,3) if metarea2>=1000 

	destring metcode, gen(metcode2)

	collapse (mean) distance, by (metcode2)

	save "../temp/distance_matrix.dta", replace

	
  ***** Merge with ASEC and MORG
  
  *** Share of evacuees ASEC + Wages and Unemployment
  
	use "../derived_asec/lot_evac_list_to_match.dta", clear
	merge 1:1 metcode2 using "../derived_asec/lot_evac_list.dta", nogen
	
	gen sample = 0 					/*Identify the sample*/
	
	save "../temp/lot_evac_list_to_match_sample.dta", replace

	
  *** Share of evacuees MORG + Wages and Unemployment
  
	use "../derived_morg/lot_evac_list_to_match.dta", clear
	merge 1:1 metcode2 using "../derived_morg/lot_evac_list.dta", nogen
	
	gen sample = 1 					/*Identify the sample*/
	
	
  *** ASEC + MORG
	
	append using "../temp/lot_evac_list_to_match_sample.dta"
	

  *** ASEC and MORG + Distance
	
	merge m:1 metcode2 using "../temp/distance_matrix.dta", nogen
	
	gen share_evac_MORG = share_evac if sample==1
	
	rename share_evac share_evac_ASEC
	replace share_evac_ASEC = . if sample==1

	*export delimited using "../GIS/layers/distance_matrix_matched.csv", replace

	label var distance "Distance to New Orleans"
	label var unem_1 "Average unemployment rate, last year"
	label var unem_5 "Average unemployment rate, last 5 years"
	label var lr_w_wage_1 "Average log-weekly wage, last year"
	label var lr_w_wage_5 "Average log-weekly wage, last 5 years"
	label var lr_h_wage_1 "Average hourly wage, last year"
	label var lr_h_wage_5 "Average hourly wage, last 5 years"
	label var share_evac_ASEC "Evacuees share (ASEC)"
	label var share_evac_MORG "Evacuees share (MORG)"
	label var treat "Treatment"

	eststo clear

	eststo: reg share_evac_ASEC distance unem_1 lr_w_wage_1 if sample==0
	eststo: reg share_evac_ASEC distance unem_5 lr_w_wage_5 if sample==0

	eststo: reg share_evac_MORG distance unem_1 lr_w_wage_1 if sample==1
	eststo: reg share_evac_MORG distance unem_5 lr_w_wage_5 if sample==1
	
 	esttab using "../tables/endogeneity.tex", r2 se nocons ///
		   label compress replace width(2\hsize) title(Endogeneity of the treatment assignment)
	
  end

********************************************************************************  

