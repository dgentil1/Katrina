 
 *------------------------- Fixing the MORG Dataset ---------------------------*

  ***** Define Program 

  program define datafix_morg

  ***** Program starts

	di " "
	di "     Cleaning the data and creating new variables for the analysis", as text
	di "---------------------------------------------------------------------------"
	
	di "     Creating the CPI for MORG data", as text
	d_create_cpi

	di "     Preparing the dataset MORG (1994-2016)", as text
	d_precleaning_morg

	di "     Identifying Katrina Evacuees", as text
	*d_idkatrina_morg

	
  end
  
********************************************************************************  
