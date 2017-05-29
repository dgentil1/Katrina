 
 *----- Geographical distance/Labor Market Outcomes on evacuees decision ------*

  ***** Define Program 

  program define d_endogeneity
  
  ***** Create the distance to New Orleans dataset 
  	
	import delimited "${layers}distance_matrix.csv", encoding(ISO-8859-1) clear
	
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

	save "${temp}distance_matrix.dta", replace
	cap saveold "${temp}distance_matrix.dta", v(12) replace

  ***** Merge
  
	use "${work_asec}lot_evac_list_to_match.dta", clear

	merge 1:1 metcode2 using "${temp}distance_matrix.dta", nogen
	merge 1:1 metcode2 using "${work_asec}lot_evac_list.dta", nogen

	export delimited using "${layers}distance_matrix_matched.csv", replace

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

	eststo: reg share_evac distance unem_1 lr_w_wage_1
	eststo: reg share_evac distance unem_5 lr_w_wage_5

	esttab using "${tables}treatment_assignment.tex", r2 se nocons ///
		   label compress replace title(Treatment assignment)
		
  end
  
********************************************************************************
