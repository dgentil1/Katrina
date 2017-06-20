
 ***********************************************************************************  
 *     T H I S  P R O G R A M    C O M P U T E S   F I N A L    R E S U L T S      *
 ***********************************************************************************

 ///////////////////////////////////////////////////////////////////////////////////
 ///                                                                             ///
 ///  This main program and all its subordinated files include all the code      ///
 ///  that is needed to replicate the results in "The effects of a labor supply  ///  
 ///  shock: \\ evidence from Hurricane Katrina evacuees" by D. Alimonti,        ///
 ///  D. Gentile Passaro, and M. Bosque Mercader.								 ///
 ///  HOW TO USE: The following are the main instructions to use this program.   ///
 ///                                                                             ///
 ///  1) Set the directory in your computer. You need to provide the path where	 ///
 ///	 the folder code is going to be located:		 	 	 				 ///
 ///		code  -> working directory for code folder			 			 	 ///
 ///  																			 ///
 ///  2) Folders to create at the same level as the code folder:				 ///
 ///		code  -> folder where the dofiles are stored			 			 ///
 ///		raw  -> folder where the raw datasets are stored			 		 ///
 ///		gis  -> folder where gis data is stored			 					 ///
 ///		derived_asec  -> folder where the derived files from ASEC code are	 ///
 ///						 stored												 ///
 ///		derived_asec  -> folder where the derived files from MORG code are	 ///
 ///						 stored												 ///
 ///		temp  -> folder where the temporary files form ASEC and MORG are 	 ///
 ///				 stored														 ///
 ///		figures  -> folder where figures are stored			 			 	 ///
 ///		tables  -> folder where tables are stored			 			 	 ///
 ///  																			 ///
 ///  2) Reading the global variable with the path to code and the dofiles		 /// 
 ///     that contain all the programs. Then, execute the programs.     		 ///
 ///                                                                             ///
 ///  This version:                                                              ///
 ///  June 2017. @ D. Alimonti, M. Bosque Mercader, D. Gentile Passaro, 2017.    ///
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
  
  *global code "Please insert here you working directory for code folder"
  *global code "C:\Users\dgentil1\Desktop\Katrina\code" 
  global code "/Users/marinabosque/Desktop/working_paper/code"
  *global code "/Users/Daniele/Desktop/working_paper/code"
	
   cd ${code}	
 ****************************     M A I N   P R O G R A M    ***********************
	
  **** Read programs
 
	capture program drop _all
	quietly {	
	 
	 *** Datafix ASEC
		do "D_Precleaning_asec.do"
		do "D_Idkatrina_asec.do"
		
	***Unifying metarea codes
	    do "D_metarea_xwalk.do"

	 *** Datafix MORG
		do "D_cpi_morg.do"
		do "D_Precleaning_morg.do"
		do "D_Idkatrina_morg.do"

	 *** Descriptives ASEC/MORG
		do "DE_Descriptive_asec.do"
		do "DE_Descriptive_morg.do"
		do "DE_Endogeneity.do"
		do "DE_Household_asec.do"
		do "DE_Household_morg.do"
		
	 *** Treatment assignment reconciliation ASEC/MORG
		do "D_Treatment_reconciliation.do"
		
	 *** SCM
		do "S_SCM.do"
		do "S_Pretrends.do"
		do "S_Placebos.do"

	 *** DID
		do "DiffinDiff.do"
	}

  **** Execute programs
  
	*** Precleaning
		
		d_precleaning_asec
		
		d_create_cpi
		
		d_precleaning_morg
		
	*** Treatment assignment and reconciliation
	    
		d_idkatrina_asec
		
		d_metarea_xwalk
		
		d_idkatrina_morg
		
		d_treatment_reconciliation
		
    *** Descriptives
	
		de_descriptive_asec
		
		de_descriptive_morg
				
		de_endogeneity
		
		de_household_asec
		
		de_household_morg
		
	*** Analysis
		
		scm
		
		placebos
		
		pretrends
		
		did	
		
************************************************************************************
