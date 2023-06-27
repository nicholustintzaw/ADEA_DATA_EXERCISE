/*******************************************************************************

Project Name		: 	Data Exercise (ADEA)
Purpose				:	data exercise				
Author				:	Nicholus Tint Zaw
Date				: 	6/27/2023
Modified by			:


*******************************************************************************/

** Settings for stata ** 
clear all
label drop _all

set more off
set mem 100m
set matsize 11000
set maxvar 32767


********************************************************************************
***SET ROOT DIRECTORY HERE AND ONLY HERE***

// create a local to identify current user
local user = c(username)
di "`user'"

// Set root directory depending on current user
if "`user'" == "Nicholus Tint Zaw" {
    * Nicholus Directory
	
	global dir		"C:\Users\Nicholus Tint Zaw\Documents\GitHub\ADEA_DATA_EXERCISE"
	
}

// other user please update your machine directory 
else if "`user'" == "XX" {
    * add Directory

}

	****************************************************************************
	
	* data directory  
	global  raw	 			"$dir/01_raw"
	global 	dta				"$dir/03_dta"
	global 	out				"$dir/04_outputs"
	global 	do 				"$dir/02_do"

	****************************************************************************

	* end of dofile 