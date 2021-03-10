libname in "C:\data\cipher\processed data\";
libname out "C:\data\cipher\processed data\";

data ctop4 (drop = encounter_id); set in.ctop_clean;
encounter_id = compress(encounter_id,'m');
csn = encounter_id + 0;
if csn = . then delete;
run;

proc sort data = ctop4 nodupkey;
by csn dc_date;
run;

data apex; set in.apex_t1;
run;

proc sql;
create table _t as 
select * from ctop4
left join apex
on ctop4.csn = apex.PAT_ENC_CSN_ID;
quit;

data _t; set _t;
if LEP = . then delete;
* removed 1 observation b/c we do not have LEP status;
run;

data _t; set _t;
length reached $32.;
reached = "4. Not reached";
if reply_to_any_q = "Yes" then reached = "1. Reached by automated call";
if reached = "4. Not reached" AND Reached_by_Manual_Call_No_Issues = "Yes" then reached = "2. Reached by manual call";
if reached = "4. Not reached" AND Reached_by_Manual_Call_Issues = "Yes" then reached = "2. Reached by manual call";
if reached = "4. Not reached" AND Reason_not_called ne "" then reached = "3. Not called after chart review";
run;


data _t; set _t;
length falloff $25.;
* where reply_to_any_q = "Yes";
	if Symptoms = "" then falloff = 						"1. Symptoms";
	else if Prescriptions = "" then falloff = 				"2. Prescriptions";
	else if Medications = "" then falloff = 				"3. Medications";
	else if Follow_Up_Help = "" then falloff = 				"4. Follow Up Help";
	else if Discharge_Instructions = "" then falloff = 		"5. Discharge Instructions";
	else if Satisfaction = "" then falloff = 				"6. Satisfaction";
	else if Other_Clinical_Issues = "" then falloff = 		"7. Other Clinical Issues";
	else falloff = 											"8. Completed";
run;

data _t2; set _t;
* where Reached_by_Manual_Call_Issues = "Yes" or count_of_issues ge 1 ;
length _t $8.;
close_date = input(closed_at, $10.);
_t = substrn(closed_at, 12, 8);
hours = (substrn(_t, 7, 2) = "PM")*12 + (substrn(_t, 1, 2) * 1) + (substrn(_t, 4, 2) / 60);
run;

data _t3
(rename = (close_date_ = close_date))
; set _t2;
format close_date_ mmddyy10.;
close_date_ = input(close_date, mmddyy10.);
time_to_close = close_date_ - dc_date + (hours/24) - 0.5 ;
** -0.5 for estimated noon discharge;
drop close_date;
run;

data _t4; set in.apex_note_times_14d;
drop enc_closed_by note_dttm_of_svc note_writer note_type note_id provider_type;
run;

proc sort data = _t4;
by index_csn last_edit_dttm enc_close_time;
run;

data _t4; set _t4;
format close_time_by_enc DATETIME16.;
by index_csn last_edit_dttm enc_close_time;
if (last.index_csn);
close_time_by_enc = enc_close_time;
if close_time_by_enc = . then close_time_by_enc = last_edit_dttm;
run;

data _t5; set _t4;
keep index_csn close_time_by_enc;
run;

proc sql;
create table _t6 as 
select * from _t3 
left join _t5
on _t3.csn = _t5.index_csn;
quit;

data _t6 (rename = (gender = sex)); set _t6;
if age < 18 then delete;

* udpate time to close from CIPHER discharge time from Apex;
time_to_close = close_date + (hours/24) - Disch_DT - hour(Disch_TM)/24 - minute(Disch_TM)/(24*60);
time_to_close_enc = datepart(close_time_by_enc) + hour(timepart(close_time_by_enc))/24 + minute(timepart(close_time_by_enc))/(24*60)
- Disch_DT - hour(Disch_TM)/24 - minute(Disch_TM)/(24*60);
max_close_time = max(time_to_close, time_to_close_enc);

Top10_service = Hospital_Service;
if Hospital_Service not in ("Gynecologic Oncology", "Otolaryngology, Head & Neck Surgery", "Liver Transplant", "Kidney Transplant", "Malignant Hematology", 
"Urology", "Cardiology", "Neurosurgery", "General Surgery", "Hospital Medicine") then Top10_service = "Other";

drop _t hours index_csn Payor_status pat_enc_csn_id dc_date;
run;

data _elix (rename =(index=Elixhauser)); set in.apex_elix;
keep PAT_ENC_CSN_ID index;
run;

data _severity; set in.apex_note_all_14d;
note_2 = upcase(note_2);
length Note_outcome $24.;

if (find(note_2, "FIRST ATTEMPT") + find(note_2, "SECOND ATTEMPT") + find(note_2, "THIRD ATTEMPT") 
		+ find(note_2, "LAST ATTEMPT") + find(note_2, "ATTEMPTED TO REACH")  )
	then delete;

if (find(note_2, "SPOKE WITH") + find(note_2, "PROVIDER FYI"))
	then Note_outcome = "1. RN spoke with patient";

if (find(note_2, "PROVIDER NOTIFICATION") + find(note_2, "PROVIDER FYI"))
	then Note_outcome = "2. Provider notification";

if (find(note_2, "PROVIDER ACTION REQUESTED") + find(note_2, "PROVIDER CALLBACK REQUESTED")) 
	then Note_outcome = "3. Action requested";

if (find(note_2, "PROVIDER ACTION NEEDED") + find(note_2, "PROVIDER CALLBACK NEEDED")) 
	then Note_outcome = "4. Action needed";

Involved_pharmacist = (Provider_Type in ("Pharmacy Student", "Pharmacist"));
Involved_clinician = (Provider_Type in ("Nurse Practitioner", "Physician", "Physician Assistant", "Resident", "APN Student")) ;
Involved_allied = (Provider_Type in ("Health Care Navigator", "Case Manager", "Hospital Assistant", "Medical Assistant", "Social Worker"));
drop Note_line: note_2;

run;

proc sort data = _severity;
by index_csn Note_outcome;
run;

data _s; set _severity;
by index_csn Note_outcome;
if last.index_csn ne 1 then delete;
keep note_outcome index_csn;
if note_outcome = "" then delete;
run;
/*
proc print data = _severity;
where index_Csn = 94065937;
run;
*/

data _ip; set _severity;
if Involved_pharmacist = 1;
keep index_csn Involved_pharmacist;
run;

proc sort noduprec;
by index_csn;
run;

data _ic; set _severity;
if Involved_clinician = 1;
keep index_csn Involved_clinician;
run;

proc sort noduprec;
by index_csn;
run;

data _ia; set _severity;
if Involved_allied = 1;
keep index_csn Involved_allied;
run;

proc sort noduprec;
by index_csn;
run;

proc sql;
create table _t7 as 
select * from _t6 
left join _elix on
_t6.csn = _elix.pat_enc_csn_id
left join _s on
_t6.csn = _s.index_csn
left join _ip on
_t6.csn = _ip.index_csn
left join _ic on
_t6.csn = _ic.index_csn
left join _ia on
_t6.csn = _ia.index_csn;
quit;

data _t7; set _t7;
length Disposition $17.;
length EP $3.;
length ins $10.;
if DC_Disposition in("Home or Self Care", "Against Medical Advice") 
	then Disposition = "Home";
if DC_Disposition in("Home Health Care (Non UCSF)","Hospice Home","Home Health Care (UCSF)", "Home Health - IV Drug TX (Non UCSF)") 
	then Disposition = "Home with service";
if DC_Disposition = "Residential Care (Foster Care,Group Home)" 
	then Disposition = "Residential care";
if DC_Disposition in ("Other Acute Care Hospital", "Skilled Nursing Facility", "Acute Rehabilitation Facility", "Assisted Living/Intermediate Care Facility", "Psychiatric Hospital")
	then Disposition = "Facility";
if DC_Disposition = "Deceased" then delete; * n=1;
drop index_csn pat_enc_csn_id;

if Coverage_Type = "-pay" then Coverage_Type = "Other Payer";
if INTRPTR_NEEDED_YN = "" then INTRPTR_NEEDED_YN = "N";

if sex = "Unknow" then delete; * n= 2;

* recode LEP;
* recoded on 11/25 based on Lev feedback for specific definition;
EP = "EP";
if INTRPTR_NEEDED_YN = "Y" and apex_lang_cat ne "1. English" then EP = "LEP";

if Primary_race = "Native Hawaiian or Other Pacific Islander" 
	then primary_race = "Hawaiian/Pacific Islander";
if primary_race = "American Indian or Alaska Native"
	then primary_race = "Native American";

recode_race = primary_race;
if primary_race in ("Hawaiian/Pacific Islander", "Native American")
	then recode_race = "Other";

if top10_service = "Otolaryngology, Head & Neck Surgery"
	then top10_service = "Otolaryngology";

any_issue = "N";
if Reached_by_Manual_Call_Issues = "Yes" 
	then any_issue = "Y";
if count_of_issues > 0 
	then any_issue = "Y";

Coverage_Type = compress(Coverage_Type);
ins = "Other";
if Coverage_Type = "Medi-Cal" then ins = "Medicaid";
if Coverage_Type = "Medicare" then ins = "Medicare";
if Coverage_Type = "PrivateCoverage" then ins = "Commercial";

* drop language;

if recode_race = "Unknown/Declined" then delete;
if ethnicity = "Unknown or decline" then delete;
if Marital_status = "Unknown/Declined" then delete;
if Disposition in ("Residential care", "Facility") then delete;
** n=595 people removed b/c they had missing predictors;

Top3_service = Hospital_Service;
if Hospital_Service not in ("Neurosurgery", "General Surgery", "Hospital Medicine") then Top3_service = "Other";

run;

proc contents data = _t7 order = varnum; run;

data out.ctop_apex; set _t7; run;

proc datasets library = work;
  delete _: apex ctop4;
run;
quit;
