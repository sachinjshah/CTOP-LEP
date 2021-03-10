
libname in "C:\Users\sachi\Box Sync\data\cipher\processed data\";
libname out "C:\Users\sachi\Box Sync\data\cipher\processed data\";

data analysis; set in.ctop_apex;
run;

PROC IMPORT OUT= WORK.m 
            DATAFILE= "C:\Users\sachi\Box Sync\data\cipher\original data\CTOPChartAbstraction_DATA_2020-05-23_1207.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

PROC IMPORT OUT= WORK.m_ej 
            DATAFILE= "C:\Users\sachi\Box Sync\data\cipher\original data\CTOP-James.Elaine.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

data m1; set m;
drop redcap_survey_identifier  reviewer ctop_chart_abstraction_complete;
run;


proc sort data = m nodupkey ;
by csn issues:;
run;

data m1;
set m1;

if issues___1 = 1 then Symptoms = "Yes";
	else Symptoms = "No";

if issues___2 = 1 then Discharge_Instructions = "Yes";
	else Discharge_Instructions = "No";

if issues___3 = 1 then Medications = "Yes";
	else Medications = "No";

if issues___4 = 1 then Follow_Up_Help = "Yes";
	else Follow_Up_Help = "No";

if issues___5 = 1 then Prescriptions_2 = "Yes";
	else Prescriptions_2 = "No";

if issues___6 = 1 then Other_Clinical_Issues = "Yes";
	else Other_Clinical_Issues = "No";

drop issues:;

run;

proc contents data = m_ej;
run;

data m_ej1
(rename = (_Follow_up_Help = Follow_up_Help
			_Other_clinical_issues = Other_clinical_issues));
set m_ej;
if record_id = . then delete;

if New_or_worsening = 1 then Symptoms = "Yes";
	else Symptoms = "No";

if Prescription = 1 then Prescriptions_2 = "Yes";
	else Prescriptions_2 = "No";

if Questions_DC = 1 then Discharge_Instructions = "Yes";
	else Discharge_Instructions = "No";

if Questions_Med_Use = 1 then Medications = "Yes";
	else Medications = "No";

if Follow_up_Help = 1 then _Follow_up_Help = "Yes";
	else _Follow_up_Help = "No";

if Other_clinical_issues = 1 then _Other_clinical_issues = "Yes";
	else _Other_clinical_issues = "No";

drop Other_clinical_issues Follow_up_Help Questions_Med_Use
Questions_DC Prescription New_or_worsening;
run;

proc sort data = m_ej1;
by record_id;
run;

proc sort data = m_ej1 nodupkey ;
by csn Medications Symptoms Other_Clinical_Issues
	Follow_Up_Help Discharge_Instructions Prescriptions_2;
run;

proc print;
where csn =99275869;
run;

data m_ej2; 
set m_ej1;
if CSN = 99275869 then Medications = "Yes";
if CSN = 99600649 then Other_Clinical_Issues = "No";
if CSN = 97975610 then Other_Clinical_Issues = "No";
if CSN = 97311317 then do;
	Other_Clinical_Issues = "Yes";
	Symptoms = "Yes";
	end;
if CSN = 97105315  then do;
	Prescriptions_2 = "Yes";
	Discharge_Instructions = "Yes";
	end;
if CSN = 97952528 then do;
	Other_Clinical_Issues = "No";
	Symptoms = "Yes";
	end;
if CSN = 102465904 then Follow_Up_Help = "Yes";
if CSN = 102768757 then Symptoms = "Yes";
if CSN = 102847880 then Follow_Up_Help = "Yes";
if CSN = 102984468 then Other_Clinical_Issues = "Yes";
if CSN = 103449381 then do;
	Prescriptions_2 = "Yes";
	Other_clinical_issues = "No";
	end;
if CSN in (103579757, 103584439) then do;
	Symptoms = "Yes";
	Other_clinical_issues = "No";
	end;
if CSN = 103850384 then Follow_up_Help = "Yes";
if CSN in (96367053, 97436004) then delete;

run;

proc sort data = m_ej2 nodupkey ;
by csn Medications Symptoms Other_Clinical_Issues
	Follow_Up_Help Discharge_Instructions Prescriptions_2
	;
run;

proc freq nlevels;
tables csn / noprint;
run;

data m_ej2;
set m_ej2;
drop record_id redcap_survey_identifier ctop_chart_abstraction_timestamp dcdate
		other_support_counseling no_issues reviewer;
count_of_issues = (Medications = "Yes") + (Symptoms = "Yes") + (Other_Clinical_Issues = "Yes") + 
					(Follow_Up_Help = "Yes") + (Discharge_Instructions = "Yes") + (Prescriptions_2 = "Yes");
run;
proc sort;
by csn;
run;

data analysis2; set analysis;
if CSN in (96367053, 97436004) then reached = "4. Not reached";
run;

proc sort;
by csn;
run;

data analysis3(index=(CSN));
	update analysis2(in=o)
			m_ej2(in=r);
	by CSN;
	if(o);
run;

proc print data = analysis3;
where CSN in (95665108, 103449381, 95018468);
var CSN Medications Symptoms Other_Clinical_Issues
	Follow_Up_Help Discharge_Instructions Prescriptions_2 count_of_issues;
run; 


/*save data*/
data in.ctop_apex_20200605; set work.analysis3;
run;

proc sort data = analysis3 force;
by UCSF_MRN disch_dt;
run;

data analysis4; set analysis3;
by UCSF_MRN disch_dt;
if first.UCSF_MRN = 1;
run;

data in.ctop_apex_first_20200605; set analysis4;
run;
