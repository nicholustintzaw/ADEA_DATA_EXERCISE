/*******************************************************************************

Project Name		: 	Data Exercise (ADEA)
Purpose				:	Perform data cleaning and reponding the test question 			
Author				:	Nicholus Tint Zaw
Date				: 	6/27/2023
Modified by			:


*******************************************************************************/

	* dir setting *
	
	do "00_dir_setting.do"
	
	
	
	
	/* Test - 1
	a 5-year trend (2017-18 through 2021-22 academic years) of the number of historically underrepresented racial and ethnic (HURE) first-year enrollees at U.S. dental schools by U.S. dental school and by gender. You need to complete the "School List" worksheet in the attached "HURE enrollment" Excel file with the additional years and validate the 2020-21 data that is already in the worksheet. Feel free to format this worksheet in the best way that you think you could present the information accurately and clearly.
	*/
	
	
	use "$dta/sde1_2017_18_to_2021_22.dta", clear 
	
	* keep only school included in "School List" sheet 
	preserve 
		* use the "HURE_Enrollment_Raw.dta"
		use "$dta/HURE_Enrollment_Raw.dta", clear 
		
		* keep only required vars
		keep	school_id founded_year name_short name_long school_type city state zip_code country ///
				enroll_male_2020_21 enroll_female_2020_21 enroll_oth_2020_21
				
		* rename var to perform data validataion 
		foreach var of varlist enroll_male_2020_21 enroll_female_2020_21 enroll_oth_2020_21 {
		    
			rename `var' `var'_pvd
		}
		
		rename name_short school 
		
		tempfile rawprovided
		save `rawprovided', replace 
	
	restore 
	
	
	/*
	Some school name from web data were not identical with test provided data
	perform data cleaning on school names
	*/
	
	replace school = "Midwestern University - IL" 					if school == "Midwestern University - IL2"
	replace school = "Missouri School of Dentistry & Oral Health" 	if school == "Missouri School of Dentistry & Oral Health2"
	replace school = "Roseman University of Health Sciences" 		if school == "Roseman University of Health Sciences2"
	replace school = "Touro College of Dental Medicine" 			if school == "Touro College of Dental Medicine2"
	replace school = "University of New England" 					if school == "University of New England2"
	replace school = "University of Tennessee College of Dentistry" if school == "University of Tennessee"
	replace school = "University of Utah" 							if school == "University of Utah2"

	merge 1:1 school using `rawprovided'
	
	/*
	one school from the web data was not found in test provided data 
	keep only matched observation 
	*/
	
	keep if _merge == 3
	drop _merge 
	
	* order variable 
	order school_id school name_long founded_year school_type state city zip_code country
	drop institution_type // duplicate with school type var 
	
	* validate 2020-21 data 
	
	
	gen validate_check = 0 
	
	local items male female oth 
	
	foreach v in `items' {
	    
		replace validate_check =  enroll_num_`v'_2020_21 - enroll_`v'_2020_21_pvd
	}
	
	lab var validate_check "2020-21 data validation check (web data - test provided data)"
	tab validate_check, m 
	
	tab school validate_check if validate_check != 0 
	
	/*
	
	two data points from test provided dataset were not unidentical to web dataset
	variation -1 for Harvard University and -5 Tufts University
	took web data as validate data 
	*/
	
	
	* Reshape dataset for Final Data 
	/*
	rationale: the current format is wide format and not tidy one
	reshape into long format where one obs will represent 
		- the one school 
		- per academic year 
		- per gender category information
	that one is easy to process data and perform analysis
	*/
	
	// drop un-necessary var 
	drop enroll_male_2020_21_pvd enroll_female_2020_21_pvd enroll_oth_2020_21_pvd validate_check

	local stub 	enroll_num_male enroll_share_male enroll_num_female ///
				enroll_share_female enroll_num_oth enroll_share_oth
	
	
	reshape long `stub', i(school_id) j(academic_year) string
	
	order academic_year, after(country)
	replace academic_year = subinstr(academic_year, "_", "", 1)
	
	
	local stub	enroll_num enroll_share
	reshape long `stub', i(school_id academic_year) j(gender) string 
	
	order academic_year gender, after(country)
	replace gender = subinstr(gender, "_", "", 1)

	* variable labeling 
	* iecodebook template using "$dta/sde1_2017_18_to_2021_22 codebook raw.xlsx", replace 
	iecodebook apply using "$dta/sde1_2017_18_to_2021_22 codebook raw.xlsx"
	
	
	* add State vs Region data 
	// using csv file from this 
	// https://github.com/cphalpert/census-regions/blob/master/us%20census%20bureau%20regions%20and%20divisions.csv
	
	preserve
		
		import delimited using "$raw/us census bureau regions and divisions.csv", varnames(1) clear 
	
		tempfile censuscode 
		save `censuscode', replace 
		
	restore 
	
	rename state statecode
	merge m:1 statecode using `censuscode'
	
	drop if _merge == 2
	drop _merge 
	
	// note : Include Puerto Rico in the South U.S. Census region
	order state statecode region division, after(zip_code)
	
	replace region = "South" if statecode == "PR"
	
	* Final Codebook and Dataset 
	iecodebook template using "$out/sde1_2017_18_to_2021_22 codebook FINAL.xlsx", replace 
	save "$out/sde1_2017_18_to_2021_22_FINAL.dta", replace 
	export delimited using "$out/sde1_2017_18_to_2021_22_FINAL.csv", replace 
	
	clear
	
	
	/* Test - 2
a 5-year trend (2017-18 through 2021-22 academic years) of the aggregates of the first-year HURE dental enrollees at U.S. dental schools, broken out by gender and by the U.S. census region of the dental school. Please, also include the national aggregate beyond the data by U.S. census region. You need to complete the "HURE Enrollment 2020-21" worksheet in the attached "HURE enrollment" Excel file and validate the 2020-21 data that is already in the worksheet. Feel free to format this worksheet in the best way that you think you could present the information accurately and clearly.
	*/
	
	* use clean dataset from test - 1
	use "$dta/sde1_2017_18_to_2021_22_FINAL.dta", clear 
	
	* keep required variable 
	keep region gender academic_year enroll_num
	bysort region gender academic_year: egen enroll_tot = total(enroll_num)
	
	* reshape into the format use for test 2 final dataset 
	drop enroll_num
	bysort region gender academic_year: keep if _n == 1
	reshape wide enroll_tot, i(region academic_year) j(gender) string
	
	* generate total var for all gender category 
	egen enroll_overall_tot = rowtotal(enroll_totfemale enroll_totmale enroll_tototh)
	
	foreach var of varlist enroll_totfemale enroll_totmale enroll_tototh enroll_overall_tot {
	    
		bysort academic_year: egen grand_`var' = total(`var')
		
	}
	
	sort academic_year region 
	
	* variable labeling 
	* iecodebook template using "$dta/test_2 codebook raw.xlsx", replace 
	iecodebook apply using "$dta/test_2 codebook raw.xlsx"
	
	
	* Final Codebook and Dataset 
	iecodebook template using "$out/Test 2 enrollment by region per academic year codebook FINAL.xlsx", replace 
	save "$out/Test_2_enrollment_per_region_per_academicyear.dta", replace 
	export delimited using "$out/Test_2_enrollment_per_region_per_academicyear.csv", replace 

	
	****************************************************************************
	* end of dofile 