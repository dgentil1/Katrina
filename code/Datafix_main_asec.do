 
 *------------------------- Fixing the ASEC Dataset ---------------------------*

  ***** Define Program 

  program define datafix_asec

  ***** Program starts

	di " "
	di "     Cleaning the data and creating new variables for the analysis (ASEC)", as text
	di "---------------------------------------------------------------------------"
	
	di "     Preparing ASEC Dataset (1996-2016)", as text
	d_precleaning_asec
	
	di "     Identifying Katrina evacuees and affected areas (ASEC)", as text
	d_idkatrina_asec

	di "     Getting treated and control list (ASEC)", as text
	d_get_treat_control_asec
	
	di "     Descriptive statistics (ASEC)", as text
	d_descriptive_asec

	di "     Controlling against endogeneity in relocation (ASEC)", as text
	d_endogeneity_asec

	di "     Household shares (ASEC)", as text
	d_hhshares_asec

  end
  
********************************************************************************  
