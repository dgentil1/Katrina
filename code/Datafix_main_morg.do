 
 *------------------------- Fixing the MORG Dataset ---------------------------*

  ***** Define Program 

  program define datafix_morg

  ***** Program starts

	di " "
	di "     Cleaning the data and creating new variables for the analysis (MORG)", as text
	di "---------------------------------------------------------------------------"
	
	di "     Creating CPI for MORG", as text
	d_create_cpi

	di "     Preparing MORG Dataset (1996-2016)", as text
	d_precleaning_morg

	di "     Identifying Katrina evacuees and affected areas (MORG)", as text
	d_idkatrina_morg

	di "     Getting treated and control list (MORG)", as text
	d_get_treat_control_morg

	
  end
  
********************************************************************************  
