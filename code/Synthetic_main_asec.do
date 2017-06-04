 
 *--------------------- Synthetic Control Method (ASEC) ----------------------*

  ***** Define Program 

  program synth_control_asec

  ***** Program starts

	di " "
	di "      		Synthetic Control Method (ASEC)", as text
	di "---------------------------------------------------------------------------"
	
	di "     Building Synthetic Control Method (ASEC)", as text
	s_scm_asec 
	
	di "     Constructing pre-trends of the outcome variables (ASEC)", as text
	s_pretrends_asec
	
	di "     Building placebo tests (ASEC)", as text
	*s_placebos_asec
	
  end
  
********************************************************************************  
