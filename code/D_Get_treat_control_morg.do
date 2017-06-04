
 *------------------- Getting treated and control list (MORG) ----------------*

  ***** Define Program 
  
  program d_get_treat_control_morg

	use "../derived_morg/MORGfinal.dta", clear
	
	collapse treat treat_expanded control, by(metcode2)
	
	save "../derived_morg/treat_and_control_list.dta", replace
	
  end

********************************************************************************
