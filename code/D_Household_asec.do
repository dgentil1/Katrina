 
 *------------------------- Household shares (ASEC) --------------------------*

 ***** Define Program 

  program define d_hhshares_asec
  
 ***** Program starts 
  
	use "../temp/CPSASEC.dta", clear
	
	keep if year==2006

	preserve
		gen hh_evac = 1*(evac==1)
		// Flagging households with at least one evacuee
		
		bysort serial: keep if _n==1
		
		save "../temp/hh_evac.dta", replace
	restore
	
	merge m:1 serial using "../temp/hh_evac.dta", keepusing(hh_evac)
	replace hh_evac=0 if _merge==1
	drop _merge
		
 ***** (1) Share of evacuees among households with evacuees
	
	* Creating the share (share_evac_hh)
		
	preserve
		collapse (mean) share_evac_hh = evac (count) obs_hh = id [aw=wtsupp], by(serial)
		sort share_evac_hh serial
				
		save "../temp/share_hh.dta", replace
	restore
	
	* Merging to the full dataset

	merge m:1 serial using "../temp/share_hh.dta", nogen keepusing(share_evac_hh)

 ***** (2) Share of people with the same race as the evacuee among households with evacuees
		
	preserve
		bysort serial: egen av_evac = mean(evac) 
		keep if hh_evac==1 & av_evac!=1
		
		// The reason why we keep this is not to have "false 0". The case of an evacuee living
		// alone and therefore having a share of people with the same race=0. The real zeros
		// are the ones in which there are at least two people in the household (with evacuees)
		// and none of them have the same race as the evacuee/s.
		
		gen ethnic_head = ethnic if relate==101 & evac==1
		bysort serial: egen hh_ethnic_head=mode(ethnic_head)

		gen ethnic_evac = ethnic if evac==1
		bysort serial: egen hh_ethnic_evac=mode(ethnic_evac)
		replace hh_ethnic_evac = hh_ethnic_head if hh_ethnic_evac==.
		
		keep if evac==0
		gen samerace = 1*(hh_ethnic_evac==ethnic)
		keep if samerace==1
		bysort serial: keep if _n==1
		save "../temp/ethnic_evac.dta", replace
	restore	
	
	* Creating the share (share_evac_hhrace)
	
	preserve
		merge m:1 serial using "../temp/ethnic_evac.dta", nogen keepusing(samerace)
	
		collapse (mean) share_evac_hhrace = samerace (count) obs_nh = id [aw=wtsupp], by(serial)
		sort share_evac_hhrace
	
		save "../temp/share_evac_hhrace.dta", replace
	restore
	
	* Merging to the full dataset

	merge m:1 serial using "../temp/share_evac_hhrace.dta", nogen keepusing(share_evac_hhrace)
	
 ***** (3) Share of evacuees that are not head of households
  
	* Creating the share (share_evac_nothead)
  
	preserve
		gen evac_nothead = 1*(evac==1 & relate!=101)
		
		collapse (mean) share_evac_nothead = evac_nothead (count) obs_nh = id [aw=wtsupp], by(serial)
		sort share_evac_nothead

		save "../temp/share_evac_nothead.dta", replace
	restore
	
	* Merging to the full dataset
	
	merge m:1 serial using "../temp/share_evac_nothead.dta", nogen keepusing(share_evac_nothead)
		
 ***** (4) Share of non-evacuees that are head of households, in households with evacuees that
 *****	were living in the current location in the last year
  
	gen ind_sameplace = 1*(hh_evac==1 & migrate1==1)
	// Flagging households with at least one evacuee living in the same location of last year
  
	* Creating the share (share_nonevac_head)
	
	preserve
		gen nonevac_head = 1*(evac==0 & relate==101 & hh_evac==1 & migrate1==1)
		
		collapse (mean) share_nonevac_head = nonevac_head (count) obs_ne = id [aw=wtsupp], by(serial)
		sort share_nonevac_head
		
		save "../temp/share_nonevac_head.dta", replace
	restore
	
	* Merging to the full dataset
	
	merge m:1 serial using "../temp/share_nonevac_head.dta", nogen keepusing(share_nonevac_head)
	

 ***** Save the dataset
  
	save "../temp/CPSASEC_hh.dta", replace
	
  end  

********************************************************************************
