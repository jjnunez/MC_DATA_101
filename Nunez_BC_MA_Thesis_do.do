// SOCY 7706 data analysis

********************************************************************************
***********// ENTER PATH IN THIS SECTION \\**********
********************************************************************************
clear all
local path "/Users/XXXXXX/Documents/Thesis/Stata"
local pathdata "`path'/Data"
local pathresults "`path'/Results"
cd "`pathdata'/Raw"

********************************************************************************
********************************************************************************
********************************************************************************

use newwave3hes.dta

// I] Data Set up 
label drop AGE3
label drop SEEMON3
gen CESDTOT=CESDTOT3
gen TALK=TALK3
gen COUNTON=COUNTON3
gen AGE=AGE3
gen SEX=SEX3
gen MARSTAT=MARSTAT3
gen SEEKIDS=SEEMON3
gen MONEYBILLS=LL35A
gen MONEYLEFT=LL35B
gen RELIGPART=EE32
gen RELIGPRAY=EE37
gen RELIGDEAL=EE35
gen RELIGEXTE=EE36
gen TOTPOMA=TOTPOMA3
gen TOTMMSE=TOTMMSE3
gen POMACAT=POMACAT3
gen NKIDS= NKIDS3
tostring Q_NO, gen (RNO)
encode RNO, gen (id)
recode RELIG* (8=.) (9=.)
recode MONEY* (8=.) (9=.)
recode COUNTON (8=.) (9=.)
recode TALK (8=.) (9=.)
recode MARSTAT (8=.) (9=.)
tab MARSTAT
gen MARRIED=.
replace MARRIED=1 if MARSTAT==1 
replace MARRIED=0 if MARSTAT!=1
replace MARRIED=. if MARSTAT==.
label define marlabs 1"Married" 0"Not Married"
label values MARRIED marlabs
tab MARRIED
recode SEX (1=0) (2=1)
label define sexlabs 0"Male" 1"Female"
label values SEX sexlabs
keep Q_NO id PSU SEX CESDTOT TALK SEEKIDS NKIDS COUNTON AGE MARSTAT MONEYBILLS MONEYLEFT RELIG* TOTPOMA POMACAT TOTMMSE MARRIED

// Then I generate a new variable indicating the first wave.

gen wave=1
sort id
********************************************************************************
********************************************************************************
**********//SAVE TO PATH HERE\\***********
********************************************************************************
********************************************************************************
save "`pathdata'/SOCY7706_WAVE3.dta", replace

// Now I do the same for the second wave of the analysis.

clear

use newwave4hes.dta
label drop AGE4
label drop SEEMON4
gen CESDTOT=CESDTOT4
gen TALK=TALK4
gen COUNTON=COUNTON4
gen AGE=AGE4
gen SEX=SEX4
gen MARSTAT=MARSTAT4
gen SEEKIDS=SEEMON4
gen MONEYBILLS=LL45A
gen MONEYLEFT=LL45B
gen RELIGPART=EE42
gen RELIGPRAY=EE47
gen RELIGDEAL=EE45
gen RELIGEXTE=EE46
gen TOTPOMA=TOTPOMA4
gen TOTMMSE=TOTMMSE4
gen POMACAT=POMACAT4
gen NKIDS= NKIDS4
tostring Q_NO, gen (RNO)
encode RNO, gen (id)
recode RELIG* (8=.) (9=.)
recode MONEY* (8=.) (9=.)
recode COUNTON (8=.) (9=.)
recode TALK (8=.) (9=.)
recode MARSTAT (8=.) (9=.)
tab MARSTAT
gen MARRIED=.
replace MARRIED=1 if MARSTAT==1 
replace MARRIED=0 if MARSTAT==2
replace MARRIED=0 if MARSTAT==3
replace MARRIED=0 if MARSTAT==4
replace MARRIED=0 if MARSTAT==5
replace MARRIED=. if MARSTAT==.
label define marlabs1 1"Married" 0"Not Married"
label values MARRIED marlabs1
recode SEX (1=0) (2=1)
label define sexlabs1 0"Male" 1"Female"
label values SEX sexlabs1
keep Q_NO id PSU SEX CESDTOT TALK SEEKIDS NKIDS COUNTON AGE MARSTAT MONEYBILLS MONEYLEFT RELIG* TOTPOMA POMACAT TOTMMSE MARRIED
gen wave=2
sort id

********************************************************************************
********************************************************************************
**********//SAVE TO PATH HERE\\***********
********************************************************************************
********************************************************************************
save "`pathdata'/SOCY7706_WAVE4.dta", replace

// I now append the datasets and set the dataset to longitudinal format.

clear all

use "`pathdata'/SOCY7706_WAVE3.dta"
append using "`pathdata'/SOCY7706_WAVE4.dta"


// Data management

tab RELIGPART
gen RELPACAT= RELIGPART
recode RELPACAT (3=2)
recode RELPACAT (4=2)
recode RELPACAT (5=3)
tab RELPACAT
tab RELIGPART
label define relpalabs 1"Never or almost never" 2"² Once a week" 3"> Once a week"
label values RELPACAT relpalabs
tab RELPACAT


tab RELIGPRAY
gen RELPRAYCAT = RELIGPRAY
recode RELPRAYCAT (5=3)
recode RELPRAYCAT (4=3)
recode RELPRAYCAT (3=1) (1=3)
tab RELPRAYCAT
tab RELIGPRAY
label define religpraylabs 1"< Once a day" 2"About once a day" 3"Several times a day"
label values RELPRAYCAT religpraylabs
tab RELPRAYCAT


tab RELIGDEAL
gen RELDEALCAT = RELIGDEAL
recode RELDEALCAT (1=3) (3=1) (4=1)
label define religdeallabs 1"Not very or not at all" 2"Somewhat involved" 3"Very involved"
label values RELDEALCAT religdeallabs
tab RELDEALCAT
tab RELIGDEAL


tab RELIGEXTE
gen RELEXTECAT = RELIGEXTE
recode RELEXTECAT (1=3) (3=1) (4=1)
label define religextelabs 1"Not very or not at all" 2"Somewhat religious" 3"Very religious"
label values RELEXTECAT religextelabs
tab RELEXTECAT
tab RELIGEXTE


gen LOSS= 1 if TALK==3 & COUNTON==3
replace LOSS= 1 if TALK==1 & COUNTON==2
replace LOSS= 1 if TALK==1 & COUNTON==3
replace LOSS= 1 if TALK==2 & COUNTON==1
replace LOSS= 1 if TALK==2 & COUNTON==2
replace LOSS= 1 if TALK==2 & COUNTON==3
replace LOSS= 1 if TALK==3 & COUNTON==2
replace LOSS= 1 if TALK==3 & COUNTON==1
replace LOSS= 0 if TALK==1 & COUNTON==1
replace LOSS=. if TALK==. & COUNTON==.
label define suplabs 0"Strong social support" 1"Unstable social support"
label values LOSS suplabs
tab LOSS if wave==1

gen YESKIDS = (NKIDS>0) if NKIDS<.
tab YESKIDS



gen PERSKIDS = SEEKIDS/NKIDS*100
tab PERSKIDS
list Q_NO SEX AGE RELEXTECAT RELDEALCAT RELPACAT RELPRAYCAT if PERSKIDS >100 & PERSKIDS ~=.
replace PERSKIDS=. if PERSKIDS>100
replace PERSKIDS=0 if NKIDS==0
tab PERSKIDS



// 5 respondents had more than 100% on perskids so I changed their response to missing.


recode MONEYLEFT (1=3) (3=1)
tab MONEYLEFT
label define MONEYBILLSlabs 1"A great deal" 2"Some" 3"A little" 4"None" 
label values MONEYBILLS MONEYBILLSlabs
label define MONEYLEFTlabs 1"Not enough to make ends meet" 2"Just enough to make ends meet" 3"Some money left over"
label values MONEYLEFT MONEYLEFTlabs
gen FINANCIALSTRAIN= 1 if MONEYBILLS==1 & MONEYLEFT==1
replace FINANCIALSTRAIN= 0 if MONEYBILLS==1 & MONEYLEFT==2
replace FINANCIALSTRAIN= 0 if MONEYBILLS==1 & MONEYLEFT==3
replace FINANCIALSTRAIN= 0 if MONEYBILLS==2 & MONEYLEFT==1
replace FINANCIALSTRAIN= 0 if MONEYBILLS==2 & MONEYLEFT==2
replace FINANCIALSTRAIN= 0 if MONEYBILLS==2 & MONEYLEFT==3
replace FINANCIALSTRAIN= 0 if MONEYBILLS==3 & MONEYLEFT==1
replace FINANCIALSTRAIN= 0 if MONEYBILLS==3 & MONEYLEFT==2
replace FINANCIALSTRAIN= 0 if MONEYBILLS==3 & MONEYLEFT==3
replace FINANCIALSTRAIN= 0 if MONEYBILLS==4 & MONEYLEFT==1
replace FINANCIALSTRAIN= 0 if MONEYBILLS==4 & MONEYLEFT==2
replace FINANCIALSTRAIN= 0 if MONEYBILLS==4 & MONEYLEFT==3
replace FINANCIALSTRAIN=. if MONEYBILLS==. & MONEYLEFT==.
label define financelabs 0"No financial strain" 1"Financial strain"
label values FINANCIALSTRAIN financelabs
tab FINANCIALSTRAIN


gen POMADUM = POMACAT
recode POMADUM (0=1) (2=0) (3=0)
label define pomadumlabs 1"Disabled" 0"Not disabled"
label values POMADUM pomadumlabs
tab POMADUM
tab POMACAT


tab TOTMMSE
gen MMSECAT = TOTMMSE
recode MMSECAT (min/19=1) (20/max=0)
label define mmselabs 0"Questionable or mild" 1"Moderate to severe"
label values MMSECAT mmselabs
tab MMSECAT
tab TOTMMSE


// There are 80 cases that were added during the second wave used in the analyses. 
// They are removed because they do not have any longitudinal information on them.


keep CESDTOT RELPACAT RELPRAYCAT RELDEALCAT RELEXTECAT LOSS TALK COUNTON MARRIED PERSKIDS YESKIDS FINANCIALSTRAIN POMADUM MMSECAT AGE SEX Q_NO PSU wave
reshape wide CESDTOT RELPACAT RELPRAYCAT RELDEALCAT RELEXTECAT LOSS TALK COUNTON MARRIED PERSKIDS YESKIDS FINANCIALSTRAIN POMADUM MMSECAT AGE SEX, i(Q_NO PSU) j(wave)
list Q_NO if AGE1==.
drop if AGE1==.
reshape long CESDTOT RELPACAT RELPRAYCAT RELDEALCAT RELEXTECAT LOSS TALK COUNTON MARRIED PERSKIDS YESKIDS FINANCIALSTRAIN POMADUM MMSECAT AGE SEX, i(Q_NO PSU) j(wave)


// Now I set the data in longitudinal mode


xtset Q_NO wave
xtdes
xtsum CESDTOT
********************************************************************************
********************************************************************************
**********//SAVE TO PATH HERE\\***********
********************************************************************************
********************************************************************************
save "`pathdata'/SOCY7706_WAVES.dta", replace


// Now I reshape to wide format to find out why 80 cases have no information for time 1.


reshape wide CESDTOT RELPACAT RELPRAYCAT RELDEALCAT RELEXTECAT LOSS TALK COUNTON MARRIED PERSKIDS YESKIDS FINANCIALSTRAIN POMADUM MMSECAT AGE SEX, i(Q_NO PSU) j(wave)


********************************************************************************
********************************************************************************
**********//SAVE TO PATH HERE\\***********
********************************************************************************
********************************************************************************
save "`pathdata'/SOCY7706_WAVESWIDE.dta", replace

// Now I check for univariate normality

gen CESDTOT1C = CESDTOT1 + 1
gen CESDTOT2C = CESDTOT2 + 1
gen PERSKIDS1C = PERSKIDS1 + 1
gen PERSKIDS2C = PERSKIDS2 + 1


*hist CESDTOT1C, normal
ladder CESDTOT1C
*gladder CESDTOT1C
gen SQRTCESDTOT1 = sqrt(CESDTOT1C)
gen LOGCESDTOT1 = log(CESDTOT1C)
egen ZSQTCESD1 = std(SQRTCESDTOT1)
egen ZLOGCESD1 = std(LOGCESDTOT1)
*qnorm ZSQTCESD1
*pnorm ZSQTCESD1
*qnorm ZLOGCESD1
*pnorm ZLOGCESD1


*hist CESDTOT2C, normal
ladder CESDTOT2C
*gladder CESDTOT2C
gen SQRTCESDTOT2 = sqrt(CESDTOT2C)
gen LOGCESDTOT2 = log(CESDTOT2C)
egen ZSQTCESD2 = std(SQRTCESDTOT2)
egen ZLOGCESD2 = std(LOGCESDTOT2)
*qnorm ZSQTCESD2


*hist PERSKIDS1C, normal
ladder PERSKIDS1C
*gladder PERSKIDS1C
revrs PERSKIDS1C
*gladder revPERSKIDS1C
drop revPERSKIDS1C


*hist PERSKIDS2C, normal
ladder PERSKIDS2C
*gladder PERSKIDS2C
revrs PERSKIDS2C
*gladder revPERSKIDS2C
drop revPERSKIDS2C


*hist AGE1, normal
tab AGE1, nol
gen AGETP1 = AGE1 
replace AGETP1 = 95 if AGE1 >95 & AGE1<.
tab AGETP1
*gladder AGETP1


*hist AGE2, normal
tab AGE2, nol
gen AGETP2 = AGE2
replace AGETP2 = 98 if AGE2 >98 & AGE2<.
tab AGETP2
*gladder AGETP2


// Now I am going to check for bivariate linearity between the dependent variable and the predictors.


*scatter ZLOGCESD2 ZLOGCESD1, mlabel (Q_NO) || lowess ZLOGCESD2 ZLOGCESD1, lcolor(red) || lfit ZLOGCESD2 ZLOGCESD1, lcolor(blue)
*scatter ZLOGCESD2 RELIGPART1, mlabel (Q_NO) || lowess ZLOGCESD2 RELIGPART1, lcolor(red) || lfit ZLOGCESD2 RELIGPART1, lcolor(blue)
*scatter ZLOGCESD2 RELIGPRAY1, mlabel (Q_NO) || lowess ZLOGCESD2 RELIGPRAY1, lcolor(red) || lfit ZLOGCESD2 RELIGPRAY1, lcolor(blue)
*scatter ZLOGCESD2 RELIGDEAL1, mlabel (Q_NO) || lowess ZLOGCESD2 RELIGDEAL1, lcolor(red) || lfit ZLOGCESD2 RELIGDEAL1, lcolor(blue)
*scatter ZLOGCESD2 RELIGEXTE1, mlabel (Q_NO) || lowess ZLOGCESD2 RELIGEXTE1, lcolor(red) || lfit ZLOGCESD2 RELIGEXTE1, lcolor(blue)
*scatter ZLOGCESD2 PERSKIDS1, mlabel (Q_NO) || lowess ZLOGCESD2 PERSKIDS1, lcolor(red) || lfit ZLOGCESD2 PERKIDS1, lcolor(blue)
*scatter ZLOGCESD2 AGETP1, mlabel (Q_NO) || lowess ZLOGCESD2 AGETP1, lcolor(red) || lfit ZLOGCESD2 AGETP1, lcolor(blue)


sum AGETP1
gen MCAGETP1 = AGETP1 -r(mean)
gen AGESQ1 = MCAGETP1^2


sum AGETP2
gen MCAGETP2 = AGETP2 -r(mean)
gen AGESQ2 = MCAGETP2^2


// IV] Final Models


// 1) Multivariate normality and linearity


// Management of transition groups


egen RELIGPART_trans=group(RELPACAT1 RELPACAT2), label
tab  RELIGPART_trans


egen RELIGDEAL_trans=group(RELDEALCAT1 RELDEALCAT2), label
tab RELIGDEAL_trans


egen RELIGEXTE_trans=group(RELEXTECAT1 RELEXTECAT2), label
tab RELIGEXTE_trans


egen LOSS_trans=group(LOSS1 LOSS2), label
tab  LOSS_trans

egen YESKIDS_trans=group(YESKIDS1 YESKIDS2), label
tab YESKIDS_trans

egen POMA_trans=group(POMADUM1 POMADUM2), label
tab  POMA_trans


egen FINANCE_trans=group(FINANCIALSTRAIN1 FINANCIALSTRAIN2), label
tab FINANCE_trans


egen RELPRAYCAT_trans=group(RELPRAYCAT1 RELPRAYCAT2), label
tab RELPRAYCAT_trans


// RESIDIUALS 


xi: reg ZLOGCESD2 ZLOGCESD1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELPACAT1 i.RELPRAYCAT1 i.RELDEALCAT1 i.RELEXTECAT1, beta
predict resid1, resid
*pnorm resid1
*qnorm resid1
*hist resid1, normal
*mrunning ZLOGCESD2 ZLOGCESD1 AGETP1 PERSKIDS1 
qui xi: reg ZLOGCESD2 ZLOGCESD1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELPACAT1 i.RELPRAYCAT1 i.RELDEALCAT1 i.RELEXTECAT1, beta
*acprplot ZLOGCESD1, lowess mcolor(yellow)
*acprplot AGETP1, lowess mcolor(yellow)
*acprplot PERSKIDS1 , lowess mcolor(yellow)
xi: boxtid reg ZLOGCESD2 ZLOGCESD1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELPACAT1 i.RELPRAYCAT1 i.RELDEALCAT1 i.RELEXTECAT1, beta


//-->Based on these analyses, there are no non linearities in the variables in the above regression.


// 2) Interactions


for var ZLOGCESD* AGETP1 PERSKIDS1: sum X \ gen Xmean=X-r(mean)



//foreach X of varlist ZLOGCESD1mean AGETP1mean SEX1 MARRIED1 PERSKIDS1mean LOSS1 POMADUM1 FINANCIALSTRAIN1 MMSECAT1 RELPACAT1 RELPRAYCAT1 RELDEALCAT1 RELEXTECAT1 {
 //foreach Y of varlist ZLOGCESD1mean AGETP1mean SEX1 MARRIED1 PERSKIDS1mean LOSS1 POMADUM1 FINANCIALSTRAIN1 MMSECAT1 RELPACAT1 RELPRAYCAT1 RELDEALCAT1 RELEXTECAT1 {
	//fitint reg ZLOGCESD2mean ZLOGCESD1mean AGETP1mean SEX1 MARRIED1 PERSKIDS1mean LOSS1 POMADUM1 FINANCIALSTRAIN1 MMSECAT1 RELPACAT1 RELPRAYCAT1 RELDEALCAT1 RELEXTECAT1, twoway(`Y' `X') factor (LOSS1 MMSECAT1 SEX1 MARRIED1 POMADUM1 FINANCIALSTRAIN1 RELPACAT1 RELPRAYCAT1 RELDEALCAT1 RELEXTECAT1)
//}
//}


// Based on the output above, there are several interactions I should consider: RELPACAT1*RELEXTECAT1, PERSKIDS1*FINANCIALSTRAIN1, RELPACAT1*SEX1, SEX1*MARRIED1, and ZLOGCESD1*LOSS1.


gen socsupcesd1=ZLOGCESD1mean*LOSS1
gen sexmarried=SEX1*MARRIED1
gen partpray=RELPRAYCAT1*RELPACAT1
gen partexte=RELPACAT1*RELEXTECAT1


xi: reg ZLOGCESD2 ZLOGCESD1mean partexte partpray sexmarried socsupcesd1 AGETP1mean SEX1 MARRIED1 PERSKIDS1mean YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 MMSECAT1 i.RELPACAT1 i.RELPRAYCAT1 i.RELDEALCAT1 i.RELEXTECAT1, beta


reg ZLOGCESD2 ZLOGCESD1 AGETP1 i.SEX1##i.MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELPACAT1  i.RELPRAYCAT1 i.RELEXTECAT1 i.RELDEALCAT1, beta
fitstat, save
qui reg ZLOGCESD2 ZLOGCESD1 AGETP1 SEX1 MARRIED1 PERSKIDS1 LOSS1 YESKIDS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELPACAT1  i.RELPRAYCAT1 i.RELEXTECAT1 i.RELDEALCAT1, beta
fitstat, dif


reg ZLOGCESD2 c.ZLOGCESD1##i.LOSS1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELPACAT1  i.RELPRAYCAT1 i.RELEXTECAT1 i.RELDEALCAT1, beta
fitstat, save
qui xi: reg ZLOGCESD2 ZLOGCESD1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELPACAT1  i.RELPRAYCAT1 i.RELEXTECAT1 i.RELDEALCAT1, beta
fitstat, dif


reg ZLOGCESD2 ZLOGCESD1 LOSS1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELPACAT1##i.RELEXTECAT1  i.RELPRAYCAT1  i.RELDEALCAT1, beta
fitstat, save
qui xi: reg ZLOGCESD2 ZLOGCESD1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELPACAT1  i.RELPRAYCAT1 i.RELEXTECAT1 i.RELDEALCAT1, beta
fitstat, dif


reg ZLOGCESD2 ZLOGCESD1 LOSS1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELPACAT1##i.RELPRAYCAT1  i.RELEXTECAT1 i.RELDEALCAT1, beta
fitstat, save
qui xi: reg ZLOGCESD2 ZLOGCESD1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELPACAT1 i.RELPRAYCAT1 i.RELEXTECAT1 i.RELDEALCAT1, beta
fitstat, dif


// 3) Multicollinearity


qui xi: reg ZLOGCESD2 ZLOGCESD1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELPACAT1  i.RELPRAYCAT1 i.RELEXTECAT1 i.RELDEALCAT1, beta
vif
corr ZLOGCESD2 ZLOGCESD1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 MMSECAT1 RELPACAT1 RELPRAYCAT1 RELEXTECAT1 RELDEALCAT1


//--> Will look to fix multicollinearity later. 


// 4) Outliers


qui xi: reg ZLOGCESD2 ZLOGCESD1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELPACAT1 i.RELPRAYCAT1 i.RELEXTECAT1 i.RELDEALCAT1, beta
predict hats, lev
predict rstudent, rstudent


//HATS ARE TAKEN FROM LARGEST IN THE 75% PERCENTILE


sum hats if e(sample), det
sort hats
list Q_NO hats if hats>.033 & hats~=. & e(sample)


*lvr2plot, mlabel(Q_NO)


*avplots, mlabel (Q_NO)


//--> Based on the avplots I see that 10780, 11077, and 12392 are potential outliers.


predict cooksd if e(sample), cooksd
gsort -cooksd
list Q_NO CESDTOT2 CESDTOT1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 MMSECAT1 RELPACAT1 RELPRAYCAT1 RELDEALCAT1 RELEXTECAT1 if cooksd>=4/1120 & cooksd~=. in 1/5
sum CESDTOT2 CESDTOT1 AGETP1 PERSKIDS1 LOSS1 YESKIDS1


//--> The repospondent that is most problematic, 10780, unexplicably went from having the least amount of depression in the first wave, to being extremely depressed in the second wave.
// 10086 is also problematic


*scatter hats rstudent [w=cooksd] , mfc(white)  
*scatter hats rstudent [w=cooksd] , mlabel(Q_NO)


//--> Based on the student residuals and the hats I see that 10780 and 12500 are the most problematic observations.


dfbeta
di 2/sqrt(1120)


*scatter  _dfbeta_1 _dfbeta_2 _dfbeta_3 _dfbeta_4 _dfbeta_5 _dfbeta_6 _dfbeta_7 _dfbeta_8 _dfbeta_9 _dfbeta_10 _dfbeta_11 _dfbeta_12 _dfbeta_13 _dfbeta_14 _dfbeta_15 _dfbeta_16 _dfbeta_17 _dfbeta_18 _dfbeta_19 _dfbeta_20 _dfbeta_21 _dfbeta_22 _dfbeta_23 Q_NO, yline(.064 -.064) mlabel (Q_NO Q_NO Q_NO Q_NO Q_NO Q_NO Q_NO Q_NO Q_NO Q_NO Q_NO Q_NO Q_NO Q_NO Q_NO Q_NO Q_NO Q_NO Q_NO Q_NO Q_NO Q_NO Q_NO Q_NO Q_NO)


//--> Based on the scatter plots of the dfbetas, 12337, 12202, and 12349 all had abbormal dfbetas


list CESDTOT2 CESDTOT1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 MMSECAT1 RELPACAT1 RELPRAYCAT1 RELDEALCAT1 RELEXTECAT1 if Q_NO==10780
list CESDTOT2 CESDTOT1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 MMSECAT1 RELPACAT1 RELPRAYCAT1 RELDEALCAT1 RELEXTECAT1 if Q_NO==12349
list CESDTOT2 CESDTOT1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 MMSECAT1 RELPACAT1 RELPRAYCAT1 RELDEALCAT1 RELEXTECAT1 if Q_NO==12337
list CESDTOT2 CESDTOT1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 MMSECAT1 RELPACAT1 RELPRAYCAT1 RELDEALCAT1 RELEXTECAT1 if Q_NO==11027
list CESDTOT2 CESDTOT1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 MMSECAT1 RELPACAT1 RELPRAYCAT1 RELDEALCAT1 RELEXTECAT1 if Q_NO==20100


//--> It looks like 10780 is the only candidate to be removed.


xi: reg ZLOGCESD2 ZLOGCESD1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELPACAT1 i.RELPRAYCAT1 i.RELDEALCAT1 i.RELEXTECAT1 if Q_NO!=12337, beta
xi: reg ZLOGCESD2 ZLOGCESD1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELPACAT1 i.RELPRAYCAT1 i.RELDEALCAT1 i.RELEXTECAT1 if Q_NO!=11027, beta
xi: reg ZLOGCESD2 ZLOGCESD1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELPACAT1 i.RELPRAYCAT1 i.RELDEALCAT1 i.RELEXTECAT1 if Q_NO!=20100, beta
xi: reg ZLOGCESD2 ZLOGCESD1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELPACAT1 i.RELPRAYCAT1 i.RELDEALCAT1 i.RELEXTECAT1 if Q_NO!=12349, beta
xi: reg ZLOGCESD2 ZLOGCESD1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELPACAT1 i.RELPRAYCAT1 i.RELDEALCAT1 i.RELEXTECAT1 if Q_NO!=10780, beta
xi: reg ZLOGCESD2 ZLOGCESD1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELPACAT1 i.RELPRAYCAT1 i.RELDEALCAT1 i.RELEXTECAT1, beta


// 5) Heteroscedasticity


qui xi: reg ZLOGCESD2 ZLOGCESD1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELPACAT1 i.RELPRAYCAT1 i.RELDEALCAT1 i.RELEXTECAT1
hettest
hettest,rhs
ovtest
ovtest, rhs
vif


//--> All of the tests demonstrate that the error terms are not heteroscedastic and there no nonlinearities in this model, but there are multicollinearity problems.


predict SAMPLE1X if e(sample)


//---> The final regressions are coming up next.


//---> All of the VIF's are below 10, I am going to check the other regressions now.


qui xi: reg ZLOGCESD2 ZLOGCESD1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELPACAT1
hettest
hettest,rhs
ovtest
ovtest, rhs
qui xi: reg ZLOGCESD2 ZLOGCESD1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1  i.RELPRAYCAT1 
hettest
hettest,rhs
ovtest
ovtest, rhs
qui xi: reg ZLOGCESD2 ZLOGCESD1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELDEALCAT1 
hettest
hettest,rhs
ovtest
ovtest, rhs
qui xi: reg ZLOGCESD2 ZLOGCESD1 AGETP1 SEX1 MARRIED1 PERSKIDS1 YESKIDS1 LOSS1 POMADUM1 FINANCIALSTRAIN1 i.MMSECAT1 i.RELEXTECAT1
hettest
hettest,rhs
ovtest
ovtest, rhs


// Final models


//-> Model 1
reg ZLOGCESD2 i.RELPACAT1 AGETP1 SEX1 FINANCIALSTRAIN1 POMADUM1 MMSECAT1 ZLOGCESD1, beta


//--> Model 2
reg ZLOGCESD2 i.RELPACAT1 LOSS1 MARRIED1 PERSKIDS1 YESKIDS1 AGETP1 SEX1 FINANCIALSTRAIN1 POMADUM1 MMSECAT1 ZLOGCESD1, beta


//---> Model 3
reg ZLOGCESD2 i.RELPRAYCAT1 AGETP1 SEX1 FINANCIALSTRAIN1 POMADUM1 MMSECAT1 ZLOGCESD1, beta


//----> Model 4
reg ZLOGCESD2 i.RELPRAYCAT1 LOSS1 MARRIED1 PERSKIDS1 YESKIDS1 AGETP1 SEX1 FINANCIALSTRAIN1 POMADUM1 MMSECAT1 ZLOGCESD1, beta


//-----> Model 5
reg ZLOGCESD2 i.RELDEALCAT1 AGETP1 SEX1 FINANCIALSTRAIN1 POMADUM1 MMSECAT1 ZLOGCESD1, beta


//------> Model 6
reg ZLOGCESD2 i.RELDEALCAT1 LOSS1 MARRIED1 PERSKIDS1 YESKIDS1 AGETP1 SEX1 FINANCIALSTRAIN1 POMADUM1 MMSECAT1 ZLOGCESD1, beta


//-------> Model 7
reg ZLOGCESD2 i.RELEXTECAT1 AGETP1 SEX1 FINANCIALSTRAIN1 POMADUM1 MMSECAT1 ZLOGCESD1, beta


//--------> Model 8
reg ZLOGCESD2 i.RELEXTECAT1 LOSS1 MARRIED1 PERSKIDS1 YESKIDS1 AGETP1 SEX1 FINANCIALSTRAIN1 POMADUM1 MMSECAT1 ZLOGCESD1, beta


//---------> Model 9
reg ZLOGCESD2 i.RELPACAT1 i.RELPRAYCAT1 i.RELDEALCAT1 i.RELEXTECAT1 AGETP1 SEX1 FINANCIALSTRAIN1 POMADUM1 MMSECAT1 ZLOGCESD1, beta


//----------> Model 10
reg ZLOGCESD2 i.RELPACAT1 i.RELPRAYCAT1 i.RELDEALCAT1 i.RELEXTECAT1 LOSS1 MARRIED1 PERSKIDS1 YESKIDS1 AGETP1 SEX1 FINANCIALSTRAIN1 POMADUM1 MMSECAT1 ZLOGCESD1, beta


********************************************************************************
********************************************************************************
**********//SAVE TO PATH HERE\\***********
********************************************************************************
********************************************************************************

save "`pathdata'/SOCY7706_FINALDATA.dta", replace


// MULTIPLE IMPUTATION NECESSARY ANALYSES
//
//
//
//
 //
 //
 //
 //
 //
 //
 //
 //
 //
 //
 //
 //
 //
 //
 //
 //
//
//
//
//   
********************************************************************************
***********// ENTER PATH IN THIS SECTION \\**********
********************************************************************************
clear all
local path "/Users/XXXXXX/Documents/Thesis/Stata"
local pathdata "`path'/Data"
local pathresults "`path'/Results"
cd "`pathdata'/Raw"
********************************************************************************
********************************************************************************
********************************************************************************


// Multipicle imputation using chained equations


use "`pathdata'/SOCY7706_FINALDATA.dta", clear


// I'm going to do multiple imputation for the variables in the final regression.





 
gen PERSKIDSLL1=PERSKIDS1
gen PERSKIDSLL2=PERSKIDS2
gen PERSKIDSUL1=PERSKIDS1
gen PERSKIDSUL2=PERSKIDS2
replace PERSKIDSLL1=0 if PERSKIDS1==.
replace PERSKIDSLL2=0 if PERSKIDS2==.
replace PERSKIDSUL1=100 if PERSKIDS1==.
replace PERSKIDSUL2=100 if PERSKIDS2==.


gen CESDLL1=LOGCESDTOT1
gen CESDUL1=LOGCESDTOT1
gen CESDLL2=LOGCESDTOT2
gen CESDUL2=LOGCESDTOT2
replace CESDLL1=0  if LOGCESDTOT1==.
replace CESDUL1=3.951244 if LOGCESDTOT1==.
replace CESDLL2=0  if LOGCESDTOT2==.
replace CESDUL2=3.871201 if LOGCESDTOT2==.



// TRY

//ice ZLOGCESD* AGETP* SEX1 MARRIED* PERSKIDS* FINANCIALSTRAIN* LOSS* POMADUM* MMSECAT1 MMSECAT2 o.RELPACAT1 o.RELPACAT2 o.RELPRAYCAT1 o.RELPRAYCAT2 o.RELDEALCAT1 o.RELDEALCAT2 o.RELEXTECAT1 o.RELEXTECAT2 praypart1 praypart2 partexte1 partexte2 partdeal1 partdeal2 prayexte1 prayexte2 praydeal1 praydeal2 extedeal1 extedeal2, saving(/Users/XXXXXX/Documents/Thesis/Stata/Data/imputeddata.dta, replace) m(20) dryrun passive(praypart1: RELPACAT1*RELPRAYCAT1 \praypart2: RELPACAT2*RELPRAYCAT2 \partexte1: RELPACAT1*RELEXTECAT1 \partexte2: RELPACAT2*RELEXTECAT2 \partdeal1: RELPACAT1*RELDEALCAT1 \partdeal2: RELPACAT2*RELDEALCAT2 \prayexte1: RELPRAYCAT1*RELEXTECAT1 \prayexte2: RELPRAYCAT2*RELEXTECAT2 \praydeal1: RELPRAYCAT1*RELDEALCAT1 \praydeal2: RELPRAYCAT2*RELDEALCAT2 \extedeal1: RELEXTECAT1*RELDEALCAT1 \extedeal2:RELEXTECAT2*RELDEALCAT2) substitute(RELPRAYCAT1: i.RELPRAYCAT1, RELPRAYCAT2: i.RELPRAYCAT2, RELPACAT1: i.RELPACAT1, RELPACAT2: i.RELPACAT2, RELDEALCAT1: i.RELDEALCAT1, RELDEALCAT2: i.RELDEALCAT2, RELEXTECAT1: i.RELEXTECAT1, RELEXTECAT2: i.RELEXTECAT2)

// DO

keep Q_NO LOGCESDTOT2 LOGCESDTOT1 CESDLL1 CESDUL1 CESDLL2 CESDUL2 AGETP1 AGETP2 SEX1 MARRIED* PERSKIDS1 PERSKIDS2 PERSKIDSLL1 PERSKIDSLL2 PERSKIDSUL1 PERSKIDSUL2 YESKIDS1 YESKIDS2 FINANCIALSTRAIN1 FINANCIALSTRAIN2 LOSS1 LOSS2 POMADUM1 POMADUM2 MMSECAT1 MMSECAT2 RELPACAT1 RELPACAT2 RELPRAYCAT1 RELPRAYCAT2 RELDEALCAT1 RELDEALCAT2 RELEXTECAT1 RELEXTECAT2


//ice LOGCESDTOT2 LOGCESDTOT1 CESDLL1 CESDUL1 CESDLL2 CESDUL2 AGETP1 AGETP2 SEX1 MARRIED* PERSKIDS1 PERSKIDS2 PERSKIDSLL1 PERSKIDSLL2 PERSKIDSUL1 PERSKIDSUL2 YESKIDS1 YESKIDS2 FINANCIALSTRAIN* LOSS* POMADUM* MMSECAT1 MMSECAT2 o.RELPACAT1 o.RELPACAT2 o.RELPRAYCAT1 o.RELPRAYCAT2 o.RELDEALCAT1 o.RELDEALCAT2 o.RELEXTECAT1 o.RELEXTECAT2, saving(/Users/XXXXXX/Documents/Thesis/Stata/Data/imputeddata.dta, replace) m(20) interval(PERSKIDS1: PERSKIDSLL1 PERSKIDSUL1, PERSKIDS2: PERSKIDSLL2 PERSKIDSUL2, LOGCESDTOT1: CESDLL1 CESDUL1, LOGCESDTOT2: CESDLL2 CESDUL2) substitute(RELPRAYCAT1: i.RELPRAYCAT1, RELPRAYCAT2: i.RELPRAYCAT2, RELPACAT1: i.RELPACAT1, RELPACAT2: i.RELPACAT2, RELDEALCAT1: i.RELDEALCAT1, RELDEALCAT2: i.RELDEALCAT2, RELEXTECAT1: i.RELEXTECAT1, RELEXTECAT2: i.RELEXTECAT2)

clear all 

use "/Users/XXXXXX/Documents/Thesis/Stata/Data/imputeddata.dta"


tab _mj
mi import ice
tab  _mi_m
tab  _mi_miss
sum  _mi_id
mi reshape long LOGCESDTOT AGETP SEX MARRIED PERSKIDS YESKIDS FINANCIALSTRAIN LOSS POMADUM MMSECAT RELPACAT RELPRAYCAT RELDEALCAT RELEXTECAT, i(Q_NO) j(year)
tab _mi_m


gen LOGCESDTOT2cm=(LOGCESDTOT==. & year==2)
tab LOGCESDTOT2cm
tab LOGCESDTOT2cm if  _mi_m==0
bysort Q_NO year: egen LOGCESDTOT2cm_all=total(LOGCESDTOT2cm)
tab LOGCESDTOT2cm_all
for num 0/20: tab LOGCESDTOT2cm_all if  _mi_m==X
gen LOGCESDTOT2_dv=LOGCESDTOT if year==2
replace LOGCESDTOT2_dv=. if LOGCESDTOT2cm_all==1



mi reshape wide LOGCESDTOT* AGETP SEX MARRIED PERSKIDS YESKIDS FINANCIALSTRAIN LOSS POMADUM MMSECAT RELPACAT RELPRAYCAT RELDEALCAT RELEXTECAT , i(Q_NO) j(year)




mi xtset, clear



save "/Users/XXXXXX/Documents/Thesis/Stata/Data/imputeddata.dta", replace






//THESIS MODELS

clear all

use "/Users/XXXXXX/Documents/Thesis/Stata/Data/imputeddata.dta"

egen  ZLOGCESD2 = std(LOGCESDTOT2_dv2)
egen ZLOGCESD1 = std(LOGCESDTOT1)

//-> Model 1
mi estimate: reg ZLOGCESD2 i.RELPACAT1 AGETP1 SEX1 ZLOGCESD1, beta

//--> Model 2
mi estimate: reg ZLOGCESD2 i.RELPRAYCAT1 AGETP1 SEX1 ZLOGCESD1, beta

//---> Model 3
mi estimate: reg ZLOGCESD2 i.RELDEALCAT1 AGETP1 SEX1  ZLOGCESD1, beta

//----> Model 4
mi estimate: reg ZLOGCESD2 i.RELEXTECAT1 AGETP1 SEX1 ZLOGCESD1, beta

//-----> Model 5
mi estimate: reg ZLOGCESD2 i.RELPACAT1 i.RELPRAYCAT1 i.RELDEALCAT1 i.RELEXTECAT1 AGETP1 SEX1 ZLOGCESD1, beta

//------> Model 6
mi estimate: reg ZLOGCESD2 i.RELPACAT1 i.RELPRAYCAT1 i.RELDEALCAT1 i.RELEXTECAT1 LOSS1 MARRIED1 PERSKIDS1 YESKIDS1 FINANCIALSTRAIN1 POMADUM1 MMSECAT1 AGETP1 SEX1 ZLOGCESD1, beta



