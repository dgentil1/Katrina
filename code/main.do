
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
 ///	project         -> folder where all the other folders are stored         ///
 ///										 									 ///
 ///	code     	    -> subfolder where dofiles are stored            		 ///
 ///     dofiles         -> subfolder with do files for stata                    ///
 ///      datafix         -> subfolder with do files for preparing the data      ///
 ///      mcintosh        -> subfolder with do files for replicating mcintosh    ///
 ///      synthetic       -> subfolder with do files for scm	     		     ///
 ///      did             -> subfolder with do files for diff-in-diff			 ///
 ///																			 ///
 ///	rawdata     	-> subfolder where data sets are stored              	 ///
 ///     raw_asec	     -> subfolder where asec data sets are stored     		 ///
 ///										 									 ///
 ///    gis				-> subfolder where gis data sets are stored				 ///
 ///     layers			 -> subfolder where layers data are stored				 ///
 ///   																			 ///
 ///    workdata   		-> subfolder where worked data are stored    			 ///
 ///     work_asec       -> subfolder where asec worked data are stored          ///
 ///                                                                          	 ///
 ///    figures         -> subfolder where figures are stored					 ///
 ///										 									 ///
 ///    tables          -> subfolder where tables are stored					 ///
 ///																			 ///
 ///    temp            -> subfolder where temporary files are stored			 ///
 ///                                                                             ///
 ///  2) After reading the global variables with the paths, and the programs in  ///
 ///     each of the subordinate files, you need to run each of the programs     ///
 ///	 for the pieces you would like to replicate. These calls are included    ///
 ///     at the end of this main file. You can comment or uncomment as needed.   ///
 ///                                                                             ///
 ///  3) The programs are:                                                       ///
 ///	datafix   -> ***							     						 ///  
 ///    mcintosh  -> ***														 ///
 ///    synth     -> *** 													     ///
 ///    did       -> ***						 								 ///
 ///                                                                             ///
 ///  4) There are also auxiliary programs called by the four above:             /// // check this number at the end!!!
 ///   a) Called by datafix                                                      ///
 ///      d_precleaning														     ///
 ///      d_idkatrina										 					 /// 
 ///      d_endogeneity															 ///
 ///   b) Called by synth	                                                     ///
 ///      s_scm																     ///
 ///      s_pretrends										 					 /// 
 ///      s_placebos															 ///
 ///                                                                             ///
 ///  5) The last input for each program should equal 1 if you want nice stata   ///
 ///     output to be displayed (recommended), or anything else (e.g. 0) to      ///
 ///	 display all default stata output generated through the process.         ///
 ///                                                                             ///
 ///  This version:                                                              ///
 ///  May 2017. © D. Alimonti, M. Bosque Mercader, D. Gentile Passaro, 2017.     ///
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
	capture set more on
	pause on

  ***** Paths
  
  *global project "Please insert here you working directory for project folder"
  *global project "C:\Users\dgentil1\Desktop\Master Project\code" 
  global project "/Users/marinabosque/Desktop/working_paper/"
  *global project "/Users/Daniele/Desktop/working_paper/"
	
  global code "${project}Code/"
    global dofiles "${code}Dofiles/2017_05/"
	  global datafix "${dofiles}Datafix/"
	  global mcintosh "${dofiles}McIntosh/"
	  global synthetic "${dofiles}Synthetic/"
	  global did "${dofiles}DiffinDiff/"
	
  global rawdata "${project}Rawdata/"
	global raw_asec "${rawdata}Raw_asec/"
  
  global gis "${project}GIS/"
    global layers "${gis}Layers/"	
  
  global workdata "${project}Workdata/"
	global work_asec "${workdata}Work_asec/"
  
  global figures "${project}Figures/"			
  
  global tables "${project}Tables/"
  
  global temp "${project}Temp/"			
			
 ****************************     M A I N   P R O G R A M    ***********************
	
  **** Read programs
 
	capture program drop _all
	quietly {	
		do "${datafix}Datafix_main.do"
		do "${datafix}D_Precleaning.do"
		do "${datafix}D_Idkatrina.do"
		do "${datafix}D_Endogeneity.do"
		
		do "${mcintosh}McIntosh.do"

		do "${synthetic}Synthetic_main.do"
		do "${synthetic}S_SCM.do"
		do "${synthetic}S_Pretrends.do"
		do "${synthetic}S_Placebos.do"
		
		do "${did}DiffinDiff.do"
	}

  **** Execute programs

*	forvalues i=1/1 {
*		cap log close Main_log
*		log using "${logfiles}Main_log.smcl", replace name(Main_log)
		
		global qui "qui"  // Execute the programs silently
		
		datafix
		
		mcintosh 
		
		synth
		
		did 
		
*		di " "
*		di " "
*		log close Main_log
*	}

************************************************************************************
