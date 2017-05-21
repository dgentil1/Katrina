 
 *----- Geographical distance/Labor Market Outcomes on evacuees decision ------*

  ***** Define Program 

  program define d_endogeneity

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
	
	`sil' import delimited "${layers}distance_matrix.csv", encoding(ISO-8859-1) clear
	
	drop targetid
	rename msa metarea   
	`sil' drop if missing(metarea)

	`sil' tostring metarea, gen(metarea1)
	`sil' destring metarea1, gen(metarea2)

	`sil' gen metcode=substr(metarea1,1,1) if metarea2<100
	`sil' replace metcode=substr(metarea1,1,2) if (metarea2>=100 & metarea2<1000)
	`sil' replace metcode=substr(metarea1,1,3) if metarea2>=1000 

	`sil' destring metcode, gen(metcode2)

	`sil' collapse (mean) distance, by (metcode2)

	`sil' save "${temp}distance_matrix.dta", replace
	cap saveold "${temp}distance_matrix.dta", v(12) replace

	* Merge
	`sil' use "${work_asec}lot_evac_list_to_match.dta", clear

	`sil' merge 1:1 metcode2 using "${temp}distance_matrix.dta", nogen
	`sil' merge 1:1 metcode2 using "${work_asec}lot_evac_list.dta", nogen

	`sil' export delimited using "${layers}distance_matrix_matched.csv", replace

	label var distance "Distance to New Orleans"
	label var unem_1 "Average unemployment rate, last year"
	label var unem_5 "Average unemployment rate, last 5 years"
	label var lr_w_wage_1 "Average log-weekly wage, last year"
	label var lr_w_wage_5 "Average log-weekly wage, last 5 years"
	label var hourwage_1 "Average hourly wage, last year"
	label var hourwage_5 "Average hourly wage, last 5 years"
	label var share_evac "Evacuees share"
	label var treat "Treatment"

	eststo clear

	`sil' eststo: reg share_evac distance unem_1 lr_w_wage_1
	`sil' eststo: reg share_evac distance unem_5 lr_w_wage_5

	`sil' esttab using "${tables}treatment_assignment.tex", r2 se nocons ///
		  label compress replace title(Treatment assignment)
		
  end
  
********************************************************************************
