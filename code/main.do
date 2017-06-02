
 ***********************************************************************************  
 *     T H I S  P R O G R A M    C O M P U T E S   F I N A L    R E S U L T S      *
 ***********************************************************************************

 ///////////////////////////////////////////////////////////////////////////////////
 ///                                                                             ///
 ///  This main program and all its subordinated files include all the code      ///
 ///  that is needed to replicate the results in "The effects of a labor supply  ///
 ///  shock: evidence from Hurricane Katrina evacuees using the Synthetic        ///
 ///  Control Method by D. Alimonti, M. Bosque Mercader, D. Gentile Passaro      ///
 ///                                                                             ///
 ///  HOW TO USE: The following are the main instructions to use this program.   ///
 ///                                                                             ///
 ///  1) Set the relevant paths in your computer. You need to provide:		 	 ///
 ///	project           -> folder where all the other folders are stored         ///
 ///										 									 ///
 ///	code     	      -> subfolder containing all dofiles		 ///
 ///																			 ///
 ///	raw     	      -> subfolder where data sets are stored              	 ///
 ///     	      		 
 ///										 									 ///
 ///    gis				  -> subfolder where gis data sets are stored				 ///
 ///     layers			  -> subfolder where layers data are stored				 ///
 ///   																			 ///
 ///    derived_asec      -> subfolder where worked data are stored    			 ///
 ///           
 ///                                                                          	 ///
 ///    figures           -> subfolder where figures are stored					 ///
 ///										 									 ///
 ///    tables            -> subfolder where tables are stored					 ///
 ///																			 ///
 ///    temp              -> subfolder where temporary files are stored			 ///
 ///                                                                             ///
 ///  2) After reading the global variable with the path to code, and the programs in  ///
 ///     each of the subordinate files, you need to run each of the programs     ///
 ///	 for the pieces you would like to replicate. These calls are included    ///
 ///     at the end of this main file. You can comment or uncomment as needed.   ///
 ///                                                                             ///
 ///  3) The programs are:                                                       ///
 ///	datafix   -> ***							     						 ///  
 ///    synth     -> *** 													     ///
 ///    did       -> ***						 								 ///
 ///                                                                             ///
 ///  4) There are also auxiliary programs called by the four above:             /// // check this number at the end!!!
 ///   a) Called by datafix                                                      ///
 ///      d_precleaning														     ///
 ///      d_idkatrina										 					 /// 
 ///      d_descriptive										 					 /// 
 ///      d_endogeneity															 ///
 ///   b) Called by synth	                                                     ///
 ///      s_scm																     ///
 ///      s_pretrends										 					 /// 
 ///      s_placebos															 ///

 ///  This version:                                                              ///
 ///  May 2017. @ D. Alimonti, M. Bosque Mercader, D. Gentile Passaro, 2017.     ///
 ///                                                                             ///
 ///////////////////////////////////////////////////////////////////////////////////


	version 12.1
	
	clear all
	clear matrix
	clear mata
	capture log close
	capture program drop _all
	capture label drop _all
	capture set more off, permanently
	capture set matsize 11000
	capture set maxvar 32767
	capture set linesize 255
	pause on

  ***** Paths
  
  *global code "Please insert here you working directory for project folder"
  *global code "C:\Users\dgentil1\Documents\Katrina\Katrina\code" 
  global code "/Users/marinabosque/Desktop/working_paper/code"
  *global code "/Users/Daniele/Desktop/working_paper/code"
	
   cd ${code}	
 ****************************     M A I N   P R O G R A M    ***********************
	
  **** Read programs
 
	capture program drop _all
	quietly {	
		do "Datafix_main_asec.do"
		do "D_Precleaning_asec.do"
		do "D_Idkatrina_asec.do"
		do "D_Get_treat_control_asec.do"
		do "D_Descriptive_asec.do"
		do "D_Endogeneity_asec.do"
		do "D_Household_asec.do"

		do "Datafix_main_morg.do"
		do "D_cpi_morg.do"
		do "D_Precleaning_morg.do"
		do "D_Idkatrina_morg.do"

		do "Synthetic_main_asec.do"
		do "S_SCM_asec.do"
		do "S_Pretrends_asec.do"
		do "S_Placebos_asec.do"
		
		do "DiffinDiff_asec.do"
	}

  **** Execute programs
		
		datafix_asec
		
		synth_control_asec
		
		did_asec
		
		datafix_morg
		
************************************************************************************
