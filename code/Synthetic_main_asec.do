 
 *------------------------- Synthetic Control Method --------------------------*

  ***** Define Program 

  program synth_control_asec

  ***** Program starts

	di " "
	di "      		Synthetic Control Method", as text
	di "---------------------------------------------------------------------------"
	
	di "     Building Synthetic Control Method", as text
	s_scm_asec 
	
	di "     Constructing pre-trends of the outcome variables", as text
	s_pretrends_asec
	
	di "     Building placebo tests", as text
	*s_placebos_asec
	
  end
  
********************************************************************************  
