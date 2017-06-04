 
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

	di "     Descriptive statistics (ASEC-MORG)", as text
	*de_descriptive_asecmorg

  end
  
********************************************************************************  
