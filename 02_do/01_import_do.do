/*******************************************************************************

Project Name		: 	Data Exercise (ADEA)
Purpose				:	import raw data file				
Author				:	Nicholus Tint Zaw
Date				: 	6/27/2023
Modified by			:


*******************************************************************************/

	* dir setting *
	
	do "00_dir_setting.do"
	
	
	* import raw data file *
	* (1) a 5-year trend (2017-18 through 2021-22 academic years) 
	/*
	according to data structure, this file alone SDE1_2021-22-final.xlsx
	include all the require data for this exrcise
	*/
	
	import excel using "$raw/SDE1_2021-22-final.xlsx", sheet("Tab10") cellrange(A5:BM72) firstrow clear 
	
	// exclude International, CODA-Accredited Dental School, only use US schools
	
	* variable labeling 
	*iecodebook template using "$dta/SDE1_2021-22-final codebook raw.xlsx", replace 
	iecodebook apply using "$dta/SDE1_2021-22-final codebook raw.xlsx"
	
	* drop un-necessary variable 
	drop D-AI
	
	* save as dta format
	save "$dta/sde1_2017_18_to_2021_22.dta", replace 
	
	
	* (2) provided unfnished raw data (for data validation purpose) HURE Enrollment.xlsx
	import excel using "$raw/HURE Enrollment.xlsx", sheet("School List") cellrange(A2:AC78) firstrow clear

	* variable lablening 
	*iecodebook template using "$dta/HURE Enrollment codebook raw.xlsx", replace 
	iecodebook apply using "$dta/HURE Enrollment codebook raw.xlsx"
	
	* keep only US school - as question demanded for US schools
	drop if country == "Canada"
	
	* save as dta format 
	save "$dta/HURE_Enrollment_Raw.dta", replace 
	
