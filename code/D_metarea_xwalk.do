
*------------------- Reconciliating treatment assignment between MORG and ASEC ----------------*

  ***** Define Program 
  
  program d_metarea_xwalk
  
    use "../temp/CPSASEC.dta", clear
	collapse metcode2, by(metarea)
	
	decode metarea, gen(metarea_string)
	replace metarea_string = "Appleton-Oshkosh-Neenah, WI" if metarea == 460
	split metarea_string, p(",")
	drop metarea_string3
	rename metarea_string1 city
	split metarea_string2, p(" ")
	drop metarea_string2
	drop metarea_string22
	split metarea_string21, p("/" "-")
    drop metarea_string21
	
	rename (metarea_string211 metarea_string212 metarea_string213) ///
	    (state1 state2 state3)
	
    gen city_id_asec = _n
	
	save "../temp/metarea_list_asec.dta", replace

	use "../temp/MORG.dta", clear
	collapse metarea msafips cbsafips, by(metarea_string)
	
    split  metarea_string, p("(")
	drop metarea_string2
	replace metarea_string1 = "Minneapolis-St.Paul, MN-WI" if metarea == 5120
	replace metarea_string1 = "Bloomington-Normal, IL" if metarea == 14060	
	split  metarea_string1, p(",")
	drop metarea_string1
	replace metarea_string12 = metarea_string13 if metarea_string12 == ""
    drop metarea_string13
    rename metarea_string11 city
	split metarea_string12, p(" ")
	drop metarea_string12
	drop metarea_string122
	split metarea_string121, p("/" "-")
    drop metarea_string121
	
	rename (metarea_string1211 metarea_string1212 metarea_string1213 metarea_string1214) ///
	    (state1 state2 state3 state4)
		
	drop metarea
	gen city_id_morg = _n
	
	save "../derived_morg/metarea_list_morg.dta", replace

 ***** Match records
	
	use "../derived_morg/metarea_list_morg.dta", clear
	
	reclink city state1 state2 using "../temp/metarea_list_asec.dta", ///
	        idmaster(city_id_morg) idusing(city_id_asec) gen(match_score) ///
		    minscore(.6) _merge(match) uprefix(asec_)
		
    replace metcode2 = 244 if city_id_morg == 147
	replace metcode2 = 612 if city_id_morg == 362
	replace metcode2 = 648 if city_id_morg == 379
	replace metcode2 = 489 if city_id_morg == 290
	replace metcode2 = 24 if city_id_morg == 9
	replace metcode2 = 524 if city_id_morg == 314
	replace metcode2 = 524 if city_id_morg == 313
	replace metcode2 = 410 if city_id_morg == 258
	replace metcode2 = 415 if city_id_morg == 262
	replace metcode2 = 552 if city_id_morg == 338
	replace metcode2 = 162 if city_id_morg == 92
	replace metcode2 = 812 if city_id_morg == 461
	replace metcode2 = 203 if city_id_morg == 121
	replace metcode2 = 428 if city_id_morg == 265
	replace metcode2 = 270 if city_id_morg == 77
	replace metcode2 = 76 if city_id_morg == 39
	replace metcode2 = 884 if city_id_morg == 498
	replace metcode2 = 751 if city_id_morg == 434
	replace metcode2 = 413 if city_id_morg == 260
	replace metcode2 = 492 if city_id_morg == 293
	
	drop if missing(metcode2)
	
	drop metarea
	gen metarea = .
	replace metarea = msafips
	replace metarea = cbsafips if missing(metarea)
	
	keep metcode2 metarea cbsafips city state1 state2 state3 state4
	
	bysort metarea: keep if _n==1
	
	save "../derived_morg/xwalk_msafips_cbsa.dta", replace

  end

********************************************************************************
