 
 *------------------------- Synthetic Control Method --------------------------*

  ***** Define Program 

  program define synth

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
	di "      				Synthetic Control Method", as text
	di "---------------------------------------------------------------------------"
	
	di "     Building Synthetic Control Method", as text
	s_scm "`silent'"
	
	di "     Constructing pre-trends of the outcome variables", as text
	s_pretrends "`silent'"
	
	di "     Building placebo tests", as text
	*s_placebos "`silent'"
	
  end
  
********************************************************************************  
