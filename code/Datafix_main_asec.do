 
 *------------------------- Fixing the ASEC Dataset ---------------------------*

  ***** Define Program 

  program define datafix_asec

  ***** Program starts

	di " "
	di "     Cleaning the data and creating new variables for the analysis", as text
	di "---------------------------------------------------------------------------"
	
	di "     Preparing the dataset ASEC (1994-2016)", as text
	d_precleaning_asec
	
	di "     Identifying Katrina evacuees and affected areas", as text
	d_idkatrina_asec

	di "     Getting treated and control list", as text
	d_get_treat_control_asec
	
	di "     Descriptive statistics", as text
	d_descriptive_asec

	di "     Controlling against endogeneity in relocation", as text
	d_endogeneity_asec

	di "     Household shares", as text
	d_hhshares_asec

  end
  
********************************************************************************  
