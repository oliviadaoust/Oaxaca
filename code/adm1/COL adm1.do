set scheme plottig 
global user "C:\Users\wb486315\OneDrive - WBG/Inequality/LAC"


global demographics gender age agesq casado hhsize hh_size_02  hh_size_311  hh_size_1217  hh_size_1859  hh_size_60 
global labor i.relab // 5
global educ  i.edattain i.hh_max_edattain //8
	
// Dep IDs for shapefile	
	
use "$user/_OaxacaBlinder_replication/inputs/COL_SEDLACsmall.dta", clear

keep if period == 4
keep if cohh == 1 & cohi == 1
keep if age >= 15

gen dep = real(region_est21)

gen DPTO_CCDGO = "0" + region_est21 if dep < 10
	replace DPTO_CCDGO = region_est21 if dep >= 10
	
	gen nobs = pondera 

	sum year, d 
	egen nryear = group(year)


gen ID_1 = .	
replace ID_1 = 1 if dep == 5
replace ID_1 = 2 if dep == 8
replace ID_1 = 3 if dep == 11
replace ID_1 = 4 if dep == 13
replace ID_1 = 5 if dep == 15
replace ID_1 = 6 if dep == 17
replace ID_1 = 7 if dep == 18
replace ID_1 = 8 if dep == 19
replace ID_1 = 9 if dep == 20
replace ID_1 = 10 if dep == 23
replace ID_1 = 11 if dep == 25
replace ID_1 = 12 if dep == 27
replace ID_1 = 13 if dep == 41
replace ID_1 = 14 if dep == 44
replace ID_1 = 15 if dep == 47
replace ID_1 = 16 if dep == 50
replace ID_1 = 17 if dep == 52
replace ID_1 = 18 if dep == 54
replace ID_1 = 19 if dep == 63
replace ID_1 = 20 if dep == 66
replace ID_1 = 21 if dep == 68
replace ID_1 = 22 if dep == 70
replace ID_1 = 23 if dep == 73
replace ID_1 = 24 if dep == 76

		
	sum nryear
	local nyear = r(max)
	dis `nyear'

	collapse (mean) b40d skilled pondera (count) nobs [w=pondera], by(ID_1 region_est22 dep DPTO_CCDGO leading1)

	gen pop = nobs*pondera/`nyear'
	egen totalpop = sum(pop)
	
	gen poor = b40d*pop
	egen totpoor = sum(poor)
	gen shpoor = 100*poor/totpoor
	
	gen unskilled = (1-skilled)*pop
	egen totunskilled = sum(poor)
	gen shunskilled = 100*unskilled/totunskilled
		gen shpop = 100*pop/totalpop

		drop if leading1 == 1 
		
save "$user/_OaxacaBlinder_replication/outputs/COL/adm1/COL_adm1.dta", replace		
tab dep, nola
		
// Dep regressions		
		
forvalues period = 4/4{
use "$user/_OaxacaBlinder_replication/inputs/COL_SEDLACsmall.dta", clear

keep if period ==	`period'

	keep if cohh == 1
	keep if age >= 15
	keep if jefe == 1


gen dep = real(region_est21)

gen ID_1 = .	
replace ID_1 = 1 if dep == 5
replace ID_1 = 2 if dep == 8
replace ID_1 = 3 if dep == 11
replace ID_1 = 4 if dep == 13
replace ID_1 = 5 if dep == 15
replace ID_1 = 6 if dep == 17
replace ID_1 = 7 if dep == 18
replace ID_1 = 8 if dep == 19
replace ID_1 = 9 if dep == 20
replace ID_1 = 10 if dep == 23
replace ID_1 = 11 if dep == 25
replace ID_1 = 12 if dep == 27
replace ID_1 = 13 if dep == 41
replace ID_1 = 14 if dep == 44
replace ID_1 = 15 if dep == 47
replace ID_1 = 16 if dep == 50
replace ID_1 = 17 if dep == 52
replace ID_1 = 18 if dep == 54
replace ID_1 = 19 if dep == 63
replace ID_1 = 20 if dep == 66
replace ID_1 = 21 if dep == 68
replace ID_1 = 22 if dep == 70
replace ID_1 = 23 if dep == 73
replace ID_1 = 24 if dep == 76

	
	sum ID_1
	local max = r(max)
	
forvalues r = 1/`max'{
		gen reg`r' = .
		replace reg`r' = 1 if ID_1 == `r'
		replace reg`r'  = 0 if leading1 == 1

xi: oaxaca lhh_labinc_pc_ppp11  $demographics $labor $educ i.year [aw=pondera], by(reg`r') vce(robust) weight(1) relax
						matrix b_`period'_`r' = e(b)
						matrix v_`period'_`r' = e(V)
						matrix N_`period'_`r' = e(N)
							
					preserve

					matsave b_`period'_`r', p("$user/_OaxacaBlinder_replication/outputs/COL/adm1/") dropall replace
					
					restore
					
					preserve

					matsave v_`period'_`r', p("$user/_OaxacaBlinder_replication/outputs/COL/adm1/") dropall replace
					
					restore
				
					preserve

					matsave N_`period'_`r', p("$user/_OaxacaBlinder_replication/outputs/COL/adm1/") dropall replace
					
					restore 	
			
			
qui: xi: oaxaca lhh_labinc_pc_ppp11  $demographics $labor $educ i.year [aw=pondera], by(reg`r') vce(robust) weight(1) relax				

capture oaxaca, eform 							

			matrix eform_`period'_`r' = r(table)				
				
				preserve
				
				matsave eform_`period'_`r', p("$user/_OaxacaBlinder_replication/outputs/COL/adm1/") dropall replace
										
				restore			
			}
}					
	
					
forvalues period = 4/4{	
	forvalues r = 1/24{
		
		*** OBS
		use "$user/_OaxacaBlinder_replication/outputs/COL/adm1/N_`period'_`r'", clear
			gen period = "`period'"
			gen ID_1 = `r'
			gen df = c1 - 2*23 - 2
			
		save "$user/_OaxacaBlinder_replication/outputs/COL/adm1/tmp_N_`r'_`period'", replace
		
		*** VARIANCE
		use "$user/_OaxacaBlinder_replication/outputs/COL/adm1/v_`period'_`r'", clear
					gen period = "`period'"
					gen ID_1 = `r'

					gen line = _n
					keep if line == 3 | line == 4 | line == 5

					gen var_ = .

					replace var_ = overall_difference if line == 3
					replace var_ = overall_explained if line == 4
					replace var_ = overall_unexplained if line == 5
					
					gen se_ = sqrt(var)
					
					replace _rowname = "overall_difference" if _rowname == "overall:difference"
					replace _rowname = "overall_explained" if _rowname == "overall:explained"
					replace _rowname = "overall_unexplained" if _rowname == "overall:unexplained"
					
					keep var_ se_ _rowname period ID_1
					reshape wide var_ se_, i(period) j(_rowname) string 
		
					rename *overall_explained *overall_endowments
					rename *overall_unexplained *overall_coefficients
					
					save "$user/_OaxacaBlinder_replication/outputs/COL/adm1/tmp_v_`r'_`period'", replace

	
					*** COEF	
					use "$user/_OaxacaBlinder_replication/outputs/COL/adm1/b_`period'_`r'", clear
					gen period = "`period'"
					gen ID_1 = `r'
					rename overall_explained overall_endowments
					rename overall_unexplained overall_coefficients
					keep  overall_difference overall_endowments overall_coefficients period ID_1
					rename (overall_difference overall_endowments overall_coefficients) b_=

					merge 1:1 ID_1 period using "$user/_OaxacaBlinder_replication/outputs/COL/adm1/tmp_v_`r'_`period'", nogen
					merge 1:1 ID_1 period using "$user/_OaxacaBlinder_replication/outputs/COL/adm1/tmp_N_`r'_`period'", nogen
					save "$user/_OaxacaBlinder_replication/outputs/COL/adm1/tmp_`r'_`period'", replace
				}	
}		
	

** Append period files, gen CI and p values and graph/export to map
 
use "$user/_OaxacaBlinder_replication/outputs/COL/adm1/tmp_1_4", clear
forvalues period = 4/4{		
		forvalues r = 1/24{
	capture	append using "$user/_OaxacaBlinder_replication/outputs/COL/adm1/tmp_`r'_`period'"
		}
		}
	
		duplicates drop
		
		
		foreach var in overall_difference overall_endowments overall_coefficients{
			gen lo_`var' = b_`var'-1.96*se_`var'
			gen hi_`var' = b_`var'+1.96*se_`var'
			gen t_`var' = b_`var'/se_`var'
			gen p_`var' = 2*ttail(df,abs(t_`var'))
		}
		
		sum p_overall_difference
		
		** keep only the diff who are significant
		
		*replace b_overall_endowments = . if p_overall_endowments > .05 | p_overall_difference > .05
		*replace b_overall_coefficients = . if p_overall_coefficients > .05 | p_overall_difference > .05
		 
		*replace b_overall_difference = . if p_overall_difference > .05
		
		gen shend = b_overall_endowments/b_overall_difference //if b_overall_difference != .
		gen shret = b_overall_coefficients/b_overall_difference //if b_overall_difference != .			

		
merge m:1 ID_1 using "$user/_OaxacaBlinder_replication/outputs/COL/adm1/COL_adm1.dta", nogen

gen periodn = real(period)
drop period 
rename periodn period 

*replace b_overall_endowments = b_overall_endowments*100
*replace b_overall_coefficients = b_overall_coefficients*100

replace region_est22 = "Atlantico" if dep == 2
replace region_est22 = "Bolivar" if dep == 4
replace region_est22 = "Boyaca" if dep == 5
replace region_est22 = "Caqueta" if dep == 7
replace region_est22 = "Cordoba" if dep == 10
replace region_est22 = "Choca" if dep == 12
replace region_est22 = "Narino" if dep == 17
replace region_est22 = "Quindio" if dep == 19
replace region_est22 = "Rural Bogota" if dep == 3


save "$user/_OaxacaBlinder_replication/outputs/COL/adm1/Oaxaca_COL.dta", replace


use "$user/_OaxacaBlinder_replication/outputs/COL/adm1/eform_4_1", clear
gen ID_1 = 1
forvalues r = 2/24{
	capture	append using "$user/_OaxacaBlinder_replication/outputs/COL/adm1/eform_4_`r'"
	replace ID_1 = `r' if ID_1 == .
		}
	
	keep overall_difference overall_explained overall_unexplained _rowname ID_1
	
	reshape wide overall_difference overall_explained overall_unexplained, i(ID_1) j(_rowname) string 
	
	foreach var in overall_differenceb overall_explainedb overall_unexplainedb overall_differencell overall_explainedll overall_unexplainedll overall_differenceul overall_explainedul overall_unexplainedul{
    replace `var' = 100*(`var' - 1)
}
		
	merge 1:1 ID_1 using "$user/_OaxacaBlinder_replication/outputs/COL/adm1/Oaxaca_COL.dta", nogen 

	
	gen diff_end = shend*overall_differenceb
	gen diff_ret = shret*overall_differenceb
	
	gen totdiff = diff_end + diff_ret
	
	
save "$user/_OaxacaBlinder_replication/outputs/COL/adm1/Oaxaca_COL_eform.dta", replace

use "$user/_OaxacaBlinder_replication/outputs/COL/adm1/Oaxaca_COL_eform.dta", clear

gen y = 0

twoway (bar overall_differenceb ID_1, horizontal barwidth(0.9) color(edkblue) sort) (rcap overall_differenceul overall_differencell ID_1, horizontal color(edkblue) sort),  xtitle("") ytitle(Individual Labor Income Gap (%), size(*1.4)) legend(off) ylabel(1 "Antioquia" 2 "Atlántico" 3 "Bogotá" 4 "Bolívar" 5 "Boyacá" 6 "Caldas" 7 "Caquetá" 8 "Cauca" 9 "Cesar" 10 "Córdoba" 11 "Cundinamarca" 12 "Chocá" 13 "Huila" 14 "La Guajira" 15 "Magdalena" 16 "Meta" 17 "Nariño" 18 "Norte de Santander" 19 "Quindáo" 20 "Risaralda" 21 "Santander" 22 "Sucre" 23 "Tolima" 24 "Valle")


sort overall_differenceb

graph twoway (rbar y diff_end ID_1 if diff_end > 0 & diff_ret < 0, horizontal color(eltblue) barwidth(0.9)) (rbar diff_ret y ID_1 if diff_end > 0 & diff_ret < 0, horizontal color(orange) barwidth(0.9)) (bar overall_differenceb ID_1 if diff_end > 0 & diff_ret > 0, horizontal barwidth(0.9) color(eltblue)) (rbar overall_differenceb diff_end ID_1 if diff_end > 0 & diff_ret > 0, horizontal color(orange) barwidth(0.9))(rbar y diff_end ID_1 if diff_end < 0 & diff_ret > 0, horizontal color(eltblue) barwidth(0.9)) (rbar diff_ret y ID_1 if diff_end < 0 & diff_ret > 0, horizontal color(orange) barwidth(0.9)) (rbar overall_differenceb diff_end ID_1 if diff_end < 0 & diff_ret < 0, horizontal color(orange) barwidth(0.9)) (rbar y diff_end ID_1 if diff_end < 0 & diff_ret < 0, horizontal color(eltblue) barwidth(0.9)) (bar overall_differenceb ID_1, horizontal barwidth(0.9) fcolor(none) lcolor(edkblue))(rcap overall_differenceul overall_differencell ID_1, horizontal color(edkblue)), legend(label(1 "Endowments") label(2 "Returns to endowments") label(7 "Income gap") position(12) row(1) order(1 2 7) region(lwidth(none)))  xtitle("") xtitle(Individual Labor Income Gap (%), size(*1.2)) ytitle("") ylabel(1 "Antioquia" 2 "Atlántico" 3 "Bogotá" 4 "Bolívar" 5 "Boyacá" 6 "Caldas" 7 "Caquetá" 8 "Cauca" 9 "Cesar" 10 "Córdoba" 11 "Cundinamarca" 12 "Chocó" 13 "Huila" 14 "La Guajira" 15 "Magdalena" 16 "Meta" 17 "Nariño" 18 "Norte de Santander" 19 "Quindáo" 20 "Risaralda" 21 "Santander" 22 "Sucre" 23 "Tolima" 24 "Valle", labsize(*0.9))

	*	graph display, ysize(8) xsize(8)
		
			drop if ID_1 == 3 // rural bogota 

// sorting by overall gap 
sort overall_differenceb
gen sorted = _n		
		sum sorted
	
graph twoway (rbar y diff_end sorted if diff_end > 0 & diff_ret < 0, horizontal color(eltblue) barwidth(0.9)) (rbar diff_ret y sorted if diff_end > 0 & diff_ret < 0, horizontal color(orange) barwidth(0.9)) (bar overall_differenceb sorted if diff_end > 0 & diff_ret > 0, horizontal barwidth(0.9) color(eltblue)) (rbar overall_differenceb diff_end sorted if diff_end > 0 & diff_ret > 0, horizontal color(orange) barwidth(0.9))(rbar y diff_end sorted if diff_end < 0 & diff_ret > 0, horizontal color(eltblue) barwidth(0.9)) (rbar diff_ret y sorted if diff_end < 0 & diff_ret > 0, horizontal color(orange) barwidth(0.9)) (rbar overall_differenceb diff_end sorted if diff_end < 0 & diff_ret < 0, horizontal color(orange) barwidth(0.9)) (rbar y diff_end sorted if diff_end < 0 & diff_ret < 0, horizontal color(eltblue) barwidth(0.9)) (bar overall_differenceb sorted, horizontal barwidth(0.9) fcolor(none) lcolor(edkblue))(rcap overall_differenceul overall_differencell sorted, horizontal color(edkblue)), legend(label(1 "Endowments") label(2 "Returns to endowments") label(9 "Income gap") position(12) row(1) order(9 1 2) region(lwidth(none)))  xtitle("") xtitle("Per Capita Labor Income Gap (%)" "Relative to Bogotá", size(*1.2)) ytitle("") ylabel(1 "Antioquia" 8 "Atlántico" 13 "Bolívar" 10 "Boyacá" 9 "Caldas" 12 "Caquetá" 21 "Cauca" 16 "Cesar" 19 "Córdoba" 2 "Cundinamarca" 23 "Chocá" 14 "Huila" 22 "La Guajira" 18 "Magdalena" 5 "Meta" 15 "Nariño" 17 "Norte de Santander" 7 "Quindáo" 4 "Risaralda" 6 "Santander" 20 "Sucre" 11 "Tolima" 3 "Valle", labsize(*0.9))			

		graph display, ysize(8) xsize(10)
		
