
 *------------------------- Creating CPI for MORG ----------------------------*

  ***** Define Program 

  program d_create_cpi

	import delimited "../raw/CPIAUCSL.csv", clear

	gen date2 = date(date, "YMD")
	format date2 %td

	gen year = yofd(date2)
	gen month = month(date2)
	keep if (year >= 1996 & year <= 2014)

	rename cpiaucsl cpi
	sum cpi if (year == 1999 & month == 12)
	local base99 = r(mean)
	gen cpi99_index = (cpi/`base99')*100
	gen cpi99 = 100/cpi99_index

	keep if month == 5

	save "../derived_morg/CPI99morg.dta", replace

  end

********************************************************************************

