
libname in "C:\Users\sachi\Box Sync\data\cipher\processed data\";
libname out "C:\Users\sachi\Box Sync\data\cipher\processed data\";

data analysis; set in.ctop_apex;
run;

proc sort data = analysis;
by UCSF_MRN disch_dt;
run;

proc sort data = analysis nodupkey;
by UCSF_MRN;
run;

proc contents; run;

proc means median p25 p75;
class EP;
var age LOS Elixhauser DRG_Wt;
run;

proc npar1way wilcoxon;
class EP;
var age LOS Elixhauser DRG_Wt;
run;


proc freq;
tables (sex recode_race Ethnicity Marital_Status
ins Top3_service ICU Disposition)
* EP /nopercent norow  chisq; 
run;

/*
Update on 10/6/20 adding in new languages for 
Appendix-4: Languages of Patients with limited English proficiency and English proficiency

*/


proc freq order=freq data = analysis;
tables Primary_Language *EP / norow nopercent out=test;
run;

PROC EXPORT DATA= WORK.test 
            OUTFILE= "C:\Users\sachi\Box Sync\CTOP\Results for paper\all languages 2020-10-19.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
