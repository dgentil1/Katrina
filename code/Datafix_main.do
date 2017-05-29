 
 *---------------------------- Fixing the Dataset -----------------------------*

  ***** Define Program 

  program define datafix

  ***** Program starts

	di " "
	di "     Cleaning the data and creating new variables for the analysis", as text
	di "---------------------------------------------------------------------------"
	
	di "     Preparing the dataset ASEC (1994-2016)", as text
	d_precleaning 
	
	di "     Identifying Katrina evacuees and affected areas", as text
	d_idkatrina 
	
	di "     Descriptive statistics", as text
	d_descriptive

	di "     Controlling against endogeneity in relocation", as text
	d_endogeneity 
	
  end
  
********************************************************************************  
