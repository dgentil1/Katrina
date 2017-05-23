 
 *----- Geographical distance/Labor Market Outcomes on evacuees decision ------*

  ***** Define Program 

  program define d_endogeneity
	
	${qui} import delimited "${layers}distance_matrix.csv", encoding(ISO-8859-1) clear

	drop targetid
	rename msa metarea   
	${qui} drop if missing(metarea)

	${qui} tostring metarea, gen(metarea1)
	${qui} destring metarea1, gen(metarea2)

	${qui} gen metcode=substr(metarea1,1,1) if metarea2<100
	${qui} replace metcode=substr(metarea1,1,2) if (metarea2>=100 & metarea2<1000)
	${qui} replace metcode=substr(metarea1,1,3) if metarea2>=1000 

	${qui} destring metcode, gen(metcode2)

	${qui} collapse (mean) distance, by (metcode2)

	${qui} save "${temp}distance_matrix.dta", replace
	cap saveold "${temp}distance_matrix.dta", v(12) replace

	* Merge
	${qui} use "${work_asec}lot_evac_list_to_match.dta", clear

	${qui} merge 1:1 metcode2 using "${temp}distance_matrix.dta", nogen
	${qui} merge 1:1 metcode2 using "${work_asec}lot_evac_list.dta", nogen

	${qui} export delimited using "${layers}distance_matrix_matched.csv", replace

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

	${qui} eststo: reg share_evac distance unem_1 lr_w_wage_1
	${qui} eststo: reg share_evac distance unem_5 lr_w_wage_5

	${qui} esttab using "${tables}treatment_assignment.tex", r2 se nocons ///
		   label compress replace title(Treatment assignment)
		
  end
  
********************************************************************************
