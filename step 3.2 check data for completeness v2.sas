
** step 1: import the apex data of all encounter;

PROC IMPORT OUT= WORK.mssp 
            DATAFILE= "C:\Users\sachi\Box Sync\data\cipher\original data\MALEVANCHIK_SHAH_Rsrch_w_MSSP_2020-11.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
	 GUESSINGROWS = MAX;
RUN;

** step 2: apply inclusion criteria;

data mssp2; set mssp;
if Age_at_Disch < 18 then delete; *91111 -> 71855;

if Pat_Class not in ("Observation", "Inpatient") then delete; * 71855 -> 37056;

if DC_Disposition not in ("Home Health - IV Drug TX (Non UCSF)",
"Home Health Care (Non UCSF)",
"Home or Self Care", 
"Hospice Home") then delete; * 37056 ->30940;

if Disch_Svc not in (
"Adolescent Medicine",
"Advanced Heart Failure",
"Cardiac Surgery",
"Cardiology",
"Electrophysiology",
"EMU Epilepsy Monitoring",
"Gastroenterology",
"General Surgery",
"Gynecologic Oncology",
"Gynecology",
"Hepatobiliary Medicine",
"Hospital Medicine",
"Kidney Transplant",
"Liver Transplant",
"Malignant Hematology",
"Neurology",
"Neurosurgery",
"Neurovascular",
"Oral & Maxillofacial Surgery",
"Otolaryngology, Head & Neck Surgery",
"Pediatric BMT",
"Pediatric Critical Care",
"Pediatric Hospital Medicine",
"Pediatric Neurology",
"Pediatric Orthopaedics",
"Pediatric Transitional Care",
"Peds Otolaryngology, Head & Neck Surgery",
"Plastic Surgery",
"Thoracic Surgery",
"Transplant Surgery",
"Urology",
"Vascular Surgery")
then delete; * 30940 to 21637;

if MSSP = "Y" then delete; *21637 to 20169;

if LAST_Attending = "KUKREJA, JASLEEN" then delete; * 20169 to 20135;

run;


PROC IMPORT OUT= WORK.oth_bundle 
            DATAFILE= "C:\Users\sachi\Box Sync\data\cipher\original data\MBBP_5_1_2018__4_30_2019.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
	 GUESSINGROWS = MAX;
RUN;

data oth_bundle; set oth_bundle;
other_bundle_flag = 1;
keep encounter_id other_bundle_flag;
run;

proc sql;
create table mssp3
as select * from mssp2
left join oth_bundle
on mssp2.pat_enc_csn_ID = oth_bundle.encounter_id;
quit;

proc freq;
tables other_bundle_flag;
run;

data mssp3; set mssp3;
if other_bundle_flag = . then other_bundle_flag = 0;
if other_bundle_flag = 1 then delete; * 20222 to 20106;
run;

** step 3: apply exclusion criteria;

* readmits;
proc sort data = mssp;
by mrn HOSP_ADMSN_TIME;
run;

data mssp_re; set mssp;
by mrn;
if first.mrn = 1 and last.mrn = 1 then delete;
drop pat_name age_at_disch dc_disposition disch_dept last_attending phone_numbers mssp hsp_account_id;
run;



data mssp_t;
set mssp_re;
keep PAT_ENC_CSN_ID HOSP_ADMSN_TIME MRN;
run;

data mssp_re2;
merge mssp_re mssp_t
(firstobs = 2 
rename=(
pat_enc_csn_id = next_csn 
hosp_admsn_time = next_hosp_admsn_time
mrn = next_mrn
));
run; 

data mssp_re2; 
set mssp_re2;
if mrn ne next_mrn then do;
	next_csn = .;
	next_hosp_admsn_time = .;
end;
tt_re = (next_hosp_admsn_time - HOSP_DISCH_TIME)/(60*60*24);
re_3d = (0< tt_re < 4);
run;

data mssp_re3;
set mssp_re2;
where re_3d = 1;
keep PAT_ENC_CSN_ID tt_re re_3d;
run;

** end readmit;

proc sql;
create table mssp4 as 
select * from mssp3
left join mssp_re3 on
mssp3.pat_enc_csn_id = mssp_re3.pat_enc_csn_id;
quit;


data mssp5; set mssp4;
exclude = 0;
if DC_Disposition = "Hospice Home" then exclude = exclude + 1;
strip_phone = tranwrd(phone_numbers, strip('000-000-0000'),"");
strip_phone = tranwrd(strip_phone, strip('000-000-0001'),"");
strip_phone = tranwrd(strip_phone, strip('415-000-0000'),"");
strip_phone = tranwrd(strip_phone, strip('888-888-8888'),"");
strip_phone = tranwrd(strip_phone, strip('999-999-9999'),"");
strip_phone = tranwrd(strip_phone, strip('111-111-1111'),"");
strip_phone = tranwrd(strip_phone, strip('415-000-0001'),"");
strip_phone = tranwrd(strip_phone, strip('415-111-1111'),"");
strip_phone = tranwrd(strip_phone, strip('510-111-1111'),"");
if strip_phone = "" then exclude = exclude +10;
if LOS < 1 then exclude = 100+exclude;
if re_3d = 1 then exclude = 1000+exclude;
label exclude = "exclude b/c
				 1 = hospice
				 10 = no phone
				 100 = LOS <1 
				 1000 = readmit w/in 3d";
run;

proc freq;
tables exclude;
run;

proc sort data = mssp5;
by PAT_ENC_CSN_ID;
run;

** step 4: determine match;
libname in "C:\Users\sachi\Box Sync\data\cipher\processed data\";
data ctop; set in.ctop_apex_cohort_dev1; 
pat_ENC_CSN_ID = CSN;
exclude2 = 0;
if sex = "Unknow" OR recode_race = "Unknown/Declined"
OR ethnicity = "Unknown or decline" OR
Marital_status = "Unknown/Declined"
OR LEP = . then exclude2 = exclude2+10000;
run;

proc sort;
by PAT_ENC_CSN_ID;
run;

OPTIONS MERGENOBY=WARN;
     DATA m_ONEs m_TWOs m_inBOTH m_NOmatch1 m_NOmatch2 m_allRECS m_NOmatch;
      MERGE mssp5(IN=In1) ctop(IN=In2);
      BY PAT_ENC_CSN_ID;
      IF In1=1 then output m_ONEs;
      IF In2=1 then output m_TWOs;
      IF (In1=1 and In2=1) then output m_inBOTH;
      IF (In1=0 and In2=1) then output m_NOmatch1;
      IF (In1=1 and In2=0) then output m_NOmatch2;
      IF (In1=1 OR In2=1)  then output m_allRECS;
      IF (In1+In2)=1       then output m_NOmatch;
     RUN;

data m_allRECS;
set m_allRECS;
exclude_fin = sum(exclude, exclude2);
in_ctop = (exclude2 ne .);
label exclude_fin = "exclude b/c
				 1 = hospice
				 10 = no phone
				 100 = LOS <1 
				 1000 = readmit w/in 3d
				 10000 = missing data";
run;

proc freq data = m_allRECS;
tables exclude_fin* in_ctop /norow nocol nopercent;
run;

/*
proc print data = m_allRECs (obs = 40);
where in_ctop = 0 and exclude_fin = 0;
run;

data for_review; set m_allRECs;
where in_ctop = 0 and exclude_fin = 0;
run;

PROC EXPORT DATA= WORK.for_review
            OUTFILE= "C:\Users\sachi\Box Sync\data\cipher\processed data\missing exclusion 2020-12-10.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

PROC EXPORT DATA= WORK.m_NOmatch2
            OUTFILE= "C:\Users\sachi\Box Sync\data\cipher\processed data\in cipher data not in DC data.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;












proc print data = a;
where csn = 79896497;
run;





proc sql;
create table t
as select * from b 
left join a1
on b.PAT_ENC_CSN_ID = a1.csn;
quit;

** check to see the fidelity of the match;
proc freq data = a1;
tables flag / missing;
run;

proc freq data = t;
tables flag / missing;
run;


** of the 18436 records in our dataset 
108 fail to match with the APeX data (99.4% match);

data m ; set t;
where flag = 1;
run;

data t2; set t;
if flag =1  then delete;
if Disch_Svc in ("Emergency Medicine", "Pedi-Med Nursery", "Pediatric BMT", 
				"Pediatric Cardiolo", "Pediatric Cardioth", "Pediatric Critical"
				"Pediatric Dialysis", "Pediatric Gastroen", "Pediatric Hematolo",
				"Pediatric Hospital", "Pediatric Nephrolo", "Pediatric Neurolog", 
				"Pediatric Neurosur", "Pediatric Orthopae", "Pediatric Plastic", 
				"Pediatric Surgery", "Pediatric Transiti", "Pediatric Urology", 
				"Peds Otolaryngolog"	) then delete;
if DC_Disposition in ("Skilled Nursing Facility", "Acute Rehabilitation Facility (Other)", 
				"Other Acute Care Hospital", "Deceased", "Long Term Acute Care Facility", 
				"Psychiatric Hospital", "Elopement OR Left ED after Medical Screening",
				"Elopement OR Left ED after Medical Screening", "LWBS after Triage",
				"Jail/Prison", "Hospice Inpatient Facility", "LWBS before Triage",
				"VA Or Military Hospital", "LOA - Return to Psychiatric Hospital", 
				"Planned readmit --with discharge to Other Ac", "Critical Access Hospital (CAH)", 
				"Designated Cancer Center Or Children's Hospi", "Planned readmit --with discharge to a psychi")
				then delete;

if Age_at_Disch < 18 then delete;

run;

proc print data = t2;
where PAT_CLASS = "Outpatien";
run;

proc print data = a;
where PAT_CLASS = "Outpatien";
run;


proc freq data = m order = freq;
tables DC_disposition;
run;

proc freq data = t2 order = freq;
tables DC_disposition;
run;


