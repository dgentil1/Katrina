 
 *------------------------- Synthetic Control Method --------------------------*

  ***** Define Program 

  program synth_control

  ***** Program starts

	di " "
	di "      		Synthetic Control Method", as text
	di "---------------------------------------------------------------------------"
	
	di "     Building Synthetic Control Method", as text
	s_scm 
	
	di "     Constructing pre-trends of the outcome variables", as text
	s_pretrends 
	
	di "     Building placebo tests", as text
	*s_placebos 
	
  end
  
********************************************************************************  
