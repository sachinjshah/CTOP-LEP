libname out "C:\data\cipher\processed data\";

/*

Table 1 data from YAJ

*/

PROC IMPORT OUT= WORK.TT 
            DATAFILE= "C:\data\cipher\original data\Table1_Sachin_2019-08-01.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
	 GUESSINGROWS = 1000; 
RUN;

proc contents order = varnum;
run;

data tt2; set tt;
length Ethnicity $22.;
length martial_status $18.;

drop name Hosp_Acct_ DOB Principal_MD;

** coding based on feedback from LK:
use the most inclusive definition of LEP
Interpreter needed OR primary language listed as not english;

** 11/25/19 changed baesd on conversation with Lev to 
use the more specific defination of LEP;
LEP = 0;
if INTRPTR_NEEDED_YN = "Y" AND Language ne "English" then LEP = 1;

*very few ICU days, recode to any ICU y/n;
ICU = 0;
if ICU_days > 0 then ICU = 1;

Ethnicity = Ethnic_Grp;
if Ethnic_Grp = "Unknown" then Ethnicity = "Unknown or decline";
if Ethnic_Grp = "Declined" then Ethnicity = "Unknown or decline";
if Ethnic_Grp = "Unknown/Declined" then Ethnicity = "Unknown or decline";

if Marital_Status = "RDP-Widow" then Marital_Status = "Widowed";
if Marital_Status in ("Married", "Significant Other") then Marital_Status = "Married/Partnered";
if Marital_Status in( "Divorced", "Legally Separated", "RDP-LG SEP") then Marital_Status = "Divorced/Separated";
if Marital_Status in( "", "Regdompart") then Marital_Status = "Unknown/Declined";

if Primary_Race in ("Declined", "Unknown") then Primary_Race = "Unknown/Declined";

if Language not in ("English", "Spanish", "Cantonese - Chinese", "Russian", "Mandarin - Chinese", "Unknown/Declined") 
	then Language = "Other";

Coverage_Type = SUBSTR(Coverage_Type, 5);

if Admit_Svc in ("Electrophysiology", "Congestive Heart Failure", "Congestive Heart Failure")
	then Admit_Svc ="Cardiology";

if Admit_Svc in ("Kidney Transplant", "Liver Transplant", "Transplant Surgery")
	then Admit_Svc ="Transplant";

if Admit_Svc in ("Otolaryngology, Head & Neck Surgery")
	then Admit_Svc ="Otolaryngology";

if Admit_Svc in ("Oral & Maxillofacial Surgery")
	then Admit_Svc ="Oral Maxillofacial Surgery";

if Admit_Svc in ("EMU Epilepsy Monitoring")
	then Admit_Svc ="Neurology";

if Admit_Svc in ("Cardiac Surgery", "Thoracic Surgery")
	then Admit_Svc ="Cardiothoracic Surgery";

if Admit_Svc in ("Gynecologic Oncology", "Gynecology", "Obstetrics")
	then Admit_Svc ="Obstetrics and Gynecology";

if Admit_Svc in ("Pediatric Surgery", "Pediatric Hospital Medici", "Pediatric Gastroenterology", "Pediatric Dialysis & Organ Transplant", "Pediatric Hospital", "Pediatric Hematology/Oncology", "Pediatric BMT", "Adolescent Medicine", "Pediatric Transitional Care", "Pediatric Critical Care", "Pediatric Hospital Medicine")
	then Admit_Svc ="Pediatrics and Pediatric speciality";

drop ICU_days Ethnic_Grp;

run;

data out.apex_t1; set tt2;
run;

/*

Data from YAJ: Elixhauser score

*/


PROC IMPORT OUT= WORK.E 
            DATAFILE= "C:\data\cipher\original data\SHAH_Sachin_Cipher_Elixhauser.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
	 GUESSINGROWS = 1000; 
RUN;

data out.apex_elix; set e;
run;

PROC IMPORT OUT= WORK.EE 
            DATAFILE= "C:\data\cipher\original data\SHAH_Sachin_Cipher_Elixhauser_binary.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
	 GUESSINGROWS = 1000; 
RUN;

data out.apex_elix_bin; set ee;
run;

/*

Data from YAJ: Dx and Procedure codes

*/


PROC IMPORT OUT= WORK.a 
            DATAFILE= "C:\data\cipher\original data\Cipher_Diagnosis_ICDs.tsv" 
            DBMS=DLM REPLACE;
     DELIMITER='09'x; 
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=2000; 
RUN;

data out.apex_icd_dx; set a;
run;

PROC IMPORT OUT= WORK.b 
            DATAFILE= "C:\data\cipher\original data\Cipher_Procedure_ICD10_Codes.tsv" 
            DBMS=DLM REPLACE;
     DELIMITER='09'x; 
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=2000; 
RUN;

data out.apex_icd_proc; set b;
run;


/*

Data from YAJ: Original note data 

*/


PROC IMPORT OUT= WORK._t
            DATAFILE= "C:\data\cipher\original data\SHAH_Followup_Call_Data_Req_2019-09-27.txt.txt" 
            DBMS=DLM REPLACE;
     DELIMITER='09'x; 
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=22000; 
RUN;

data _t2; set _t;
length note_2 $8000.;
note_2=prxchange('s/(\^| ){2,}/~/',-1,note_text);
run;

proc sql noprint;
  select max(count(note_2,"~"))+1 into :maxelements from _t2;
quit;

data _t3 (drop=i); set _t2;
	if note_text = "NULL" then delete;
	array parsed_vars $ 1000 note_line1-note_line%eval(&maxelements);
	do i = 1 to &maxelements;
  parsed_vars{i} = scan(note_2,i,"~");
  end;
run;

/*data out.apex_note_first; set _t3;*/
/*drop note_text note_2;*/
/*run;*/


PROC IMPORT OUT= WORK._t4
            DATAFILE= "C:\data\cipher\original data\SHAH_Followup_Calls_2019-09-27_sheet_2.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
	 GUESSINGROWS = 1000; 
RUN;

/*data out.apex_note_dates; set _t4;*/
/*run;*/

/*

Updated note data

*/


PROC IMPORT OUT= WORK._z
            DATAFILE= "C:\data\cipher\original data\All_Calls_within_14d_of_DC_Corrected_Last_Edit_DTTM.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
	 GUESSINGROWS = 1000; 
RUN;

proc sql noprint;
	select max(length(note_text)) into :maxlength from work._z ;
quit;

data _z2; set _z;
length note_2 $%eval(&maxlength).;
note_2=prxchange('s/(\^| ){2,}/~/',-1,note_text);
run;

proc sql noprint;
  select max(count(note_2,"~"))+1 into :maxelements from _z2;
quit;

data _z3 (drop=i); set _z2;
	if note_text = "NULL" then delete;
	array parsed_vars $ 1100 note_line1-note_line%eval(&maxelements);
	do i = 1 to &maxelements;
  parsed_vars{i} = scan(note_2,i,"~");
  end;
  drop note_text;
run;

data out.apex_note_all_14d; set _z3;
run;

data _z4; set _z3;
drop note_2 note_line:;
run;

data out.apex_note_times_14d; set _z4;
run;

proc datasets library = work;
  delete _z: _t: tt: a b e ee;
run;
quit;
