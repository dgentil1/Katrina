 
 *------------------- Descriptive statistics ASEC - MORG ---------------------*

  ***** Define Program 

  program define descriptives

  ***** Program starts

	di " "
	di "     Descriptive statistics ASEC - MORG", as text
	di "---------------------------------------------------------------------------"
		
	di "     Descriptive statistics (ASEC)", as text
	de_descriptive_asec

	di "     Descriptive statistics (MORG)", as text
	de_descriptive_morg
	
	di "     Household shares (ASEC)", as text
	de_hhshares_asec
	
	di "     Descriptive statistics (ASEC-MORG)", as text
	de_endogeneity

  end
  
********************************************************************************
