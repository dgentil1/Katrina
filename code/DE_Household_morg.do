 *------------------------- Household shares (MORG) --------------------------*

 ***** Define Program 

  program define de_household_morg
  
 ***** Program starts 
  
	use "../temp/MORG.dta", clear
	
	keep if year==2006

	bysort serial: egen hh_evac=max(evac)
	// Flagging households with at least one evacuee
	
	keep if hh_evac==1

 ***** (1) Share of evacuees among households with evacuees
	
	* Creating the share (share_evac_hh)
		
	preserve		
		egen id_hh=group(serial)
		egen hh_obs=max(id_hh)
		
		collapse (mean) share_hh_evac = evac hh_obs (sd) share_hh_evac_sd = evac (count) obs = id [aw=weight]
		order share_hh_evac share_hh_evac_sd obs hh_obs
				
		mkmat share_hh_evac share_hh_evac_sd obs hh_obs, matrix(output)
		matrix output = output'
		
		esttab matrix(output) using "../tables/share_hh_morg.tex", replace
		*esttab matrix(output) using "../tables/share_hh_evac_morg.tex", replace
		
	restore
	
 ***** (2.a) Share of people with the same race as the evacuee among households with some evacuees
		
	preserve
		bysort serial: egen av_evac = mean(evac) 
		keep if av_evac!=1
		
		// The reason why we keep this is not to have "false 0", i.e. the case of an evacuee living
		// alone and therefore having a share of people with the same race=0. The real zeros
		// are the ones in which there are at least two people in the household (with evacuees)
		// and none of them have the same race as the evacuee/s.
		
		gen ethnic_head = ethnic if relate==1
		bysort serial: egen hh_ethnic_head=mode(ethnic_head)

		gen ethnic_evac = ethnic if evac==1
		bysort serial: egen hh_ethnic_evac=mode(ethnic_evac)
		
		keep if evac==0
		gen samerace = 1*(hh_ethnic_evac==ethnic)
		keep if samerace==1
		bysort serial: keep if _n==1
		save "../temp/ethnic_someevac_morg.dta", replace
	restore	
	
	* Creating the share (share_evac_hhrace)
	
	preserve
		merge m:1 serial using "../temp/ethnic_someevac_morg.dta", nogen keepusing(samerace)
	
		egen id_hh=group(serial)
		egen hh_obs=max(id_hh)
		
		collapse (mean) share_hh_evac_race = samerace hh_obs (sd) share_hh_evac_race_sd = samerace (count) obs = id [aw=weight]
		order share_hh_evac_race share_hh_evac_race_sd obs hh_obs
	
		mkmat share_hh_evac_race share_hh_evac_race_sd obs hh_obs, matrix(output)
		matrix output = output'
		
		esttab matrix(output) using "../tables/share_hh_morg.tex", append
		*esttab matrix(output) using "../tables/share_hh_someevac_race_morg.tex", replace
	restore
	
 ***** (2.b) Share of people with the same race as the evacuee among households with all evacuees
		
	preserve
		bysort serial: egen av_evac = mean(evac)
		keep if av_evac==1
		
		// The reason why we keep this is not to have "false 0", i.e. the case of an evacuee living
		// alone and therefore having a share of people with the same race=0. The real zeros
		// are the ones in which there are at least two people in the household (with evacuees)
		// and none of them have the same race as the evacuee/s.
		
		gen ethnic_head = ethnic if relate==1 & evac==1
		bysort serial: egen hh_ethnic_head=mode(ethnic_head)

		gen ethnic_evac = ethnic if evac==1
		bysort serial: egen hh_ethnic_evac=mode(ethnic_evac)
		replace hh_ethnic_evac = hh_ethnic_head if hh_ethnic_evac==.
		
		gen samerace = 1*(hh_ethnic_evac==ethnic)
		keep if samerace==1
		bysort serial: keep if _n==1
		save "../temp/ethnic_allevac_morg.dta", replace
	restore	
	
	* Creating the share (share_evac_hhrace)
	
	preserve
		merge m:1 serial using "../temp/ethnic_allevac_morg.dta", nogen keepusing(samerace)
				
		egen id_hh=group(serial)
		egen hh_obs=max(id_hh)
		
		collapse (mean) share_hh_evac_race = samerace hh_obs (sd) share_hh_evac_race_sd = samerace (count) obs = id [aw=weight]
		order share_hh_evac_race share_hh_evac_race_sd obs hh_obs
	
		mkmat share_hh_evac_race share_hh_evac_race_sd obs hh_obs, matrix(output)
		matrix output = output'
		
		esttab matrix(output) using "../tables/share_hh_morg.tex", append
		*esttab matrix(output) using "../tables/share_hh_allevac_race_morg.tex", replace
	restore
	
 ***** (3) Share of evacuees that are not head of households
  
	* Creating the share (share_evac_nothead)
  
	preserve
		egen id_hh=group(serial)
		egen hh_obs=max(id_hh)

		gen evac_nohead = 1*(evac==1 & relate!=1)
		
		collapse (mean) share_nohead_evac = evac_nohead hh_obs (sd) share_nohead_evac_sd = evac_nohead (count) obs = id [aw=weight]
		order share_nohead_evac share_nohead_evac_sd obs hh_obs
	
		mkmat share_nohead_evac share_nohead_evac_sd obs hh_obs, matrix(output)
		matrix output = output'
		
		esttab matrix(output) using "../tables/share_hh_morg.tex", append
		*esttab matrix(output) using "../tables/share_nohead_evac_morg.tex", replace
	restore
	
 ***** (5) Share of evacuees with family relationship in households with evacuees	
	
	gen hh_rel = 1*(famrel<=9)
	// Flagging individuals related to the household they are living in
	
	preserve
		egen id_hh=group(serial)
		egen hh_obs=max(id_hh)
		
		gen evac_rel = 1*(evac==1 & hh_rel==1)
		
		collapse (mean) share_evac_hh_rel = evac_rel hh_obs (sd) share_evac_hh_rel_sd = evac_rel (count) obs=id [aw=weight]
		order share_evac_hh_rel share_evac_hh_rel_sd obs hh_obs
		
		mkmat share_evac_hh_rel share_evac_hh_rel_sd obs hh_obs, matrix(output)
		matrix output = output'
		
		esttab matrix(output) using "../tables/share_hh_morg.tex", append
		*esttab matrix(output) using "../tables/share_evac_hh_rel_morg.tex", replace
	restore
	
  end  

********************************************************************************
