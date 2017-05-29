 program d_get_treat_control_asec

	use "../derived_asec/CPSASECfinal.dta", clear
	collapse treat treat_expanded control, by(metcode2)
	save "../derived_asec/treat_and_control_list.dta", replace
 end
