 
 *---------------------------- Fixing the Dataset -----------------------------*

  ***** Define Program 

  program define datafix

  ***** Silent local

	local silent `1'
	
 	* Codebook for Silent *
		* 1 -> Nice stata output display
		* 0 -> Display everything 

	* Local variables to run the stuff quietly or noisily *
  
	if `silent'==1 {
		local sil "qui"
	}
	
	else {
		local sil " "
	}

********************************************************************************

  ***** Program starts

	di " "
	di "     Cleaning the data and creating new variables for the analysis", as text
	di "---------------------------------------------------------------------------"
	
	di "     Preparing the dataset ASEC (1994-2016)", as text
	d_precleaning "`silent'"
	
	di "     Identifying Katrina evacuees and affected areas", as text
	d_idkatrina "`silent'"
	
	di "     Controlling against endogeneity in relocation", as text
	d_endogeneity "`silent'"
	
  end
  
********************************************************************************  
