** in ver 2 we are creating adjusted analyses;
** ver 2.2 limit the analysi to the first observation of each patient 
to make the stats easier;
** ver 2.3 swaps out lsmeans for the margins macro to calculate predicted
rates and AME - relative risk output deleted; 

libname in "C:\Users\sachi\Box Sync\data\cipher\processed data\";
libname out "C:\Users\sachi\Box Sync\data\cipher\processed data\";

data analysis; set in.ctop_apex_first_20200605;
run;

/* ---------------------------------------------
OUTCOME: ISSUE COUNT  - not in final ms
------------------------------------------------*/

/* ---------------------------------------------
OUTCOME: INDIVIDUAL ISSUES - done
------------------------------------------------*/

** adjusted and unadjusted analyses below;

proc freq;
tables Discharge_Instructions Prescriptions_2 Medications Follow_Up_Help Symptoms Other_Clinical_Issues;
run;

%LET cat_vars = recode_race ins Disposition 
Top3_service Ethnicity Marital_Status;
%LET cont_vars = age LOS Elixhauser;

%include "C:\Users\sachi\Box Sync\data\!Macros\MARGINS.sas";

%macro calcmarg(y,name);
data _t; set analysis;
if &y = "Yes" then i_&y = 1;
if &y = "No" then i_&y = 0;
if i_&y = . then delete;
run;


** unadjusted marginal effects;
%Margins(	data      	= _t,
            response  	= i_&y,
			class 		= EP UCSF_mrn,
            model     	= EP,
			geesubject 	= UCSF_mrn,
			geecorr		= unstr,
            dist      	= poisson,
			link 	  	= log,
			margins    	= EP,
			options   	= cl desc diff nomodel);

data _m_un_&y
(rename = (_mu = freq Lower=LL Upper=UL));
set _margins;
adjusted = "Unadjusted";
issue = &name;
keep adjusted issue _mu EP Lower Upper adjusted;
run;

data _d_un_&y;
set _diffs;
issue = &name;
adjusted = "Unadjusted";
keep diff issue Lower Upper Pr adjusted;
run;


** marginal effects;
%Margins(	data      	= _t,
            response  	= i_&y,
			class 		= EP &cat_vars UCSF_mrn,
            model     	= EP &cont_vars &cat_vars,
			geesubject 	= UCSF_mrn,
			geecorr		= unstr,
            dist      	= poisson,
			link 	  	= log,
			margins    	= EP,
			options   	= cl desc diff nomodel);

data _m_adj_&y
(rename = (_mu = freq Lower=LL Upper=UL));
set _margins;
adjusted = "Adjusted";
issue = &name;
keep adjusted issue _mu EP Lower Upper;
run;

data _d_&y;
set _diffs;
issue = &name;
adjusted = "Adjusted";
keep diff issue Lower Upper Pr adjusted;
run;

%mend;
%calcmarg(Medications, "Medications");
%calcmarg(Symptoms, "Symptoms");
%calcmarg(Other_Clinical_Issues, "Other clinical issues");
%calcmarg(Follow_Up_Help, "Follow up help");
%calcmarg(Discharge_Instructions, "Discharge instructions");
%calcmarg(Prescriptions_2, "Prescriptions");

data _m; 
length issue $21.;
length adjusted $10.;
set _m_:;
run;

data _d;
length issue $21.;
length adjusted $10.;
set _d_:;
run;

proc datasets lib=work nolist;
	delete _m_: _d_: _covmarg _t;
run;
quit;

PROC EXPORT DATA= WORK._m 
            OUTFILE= "C:\Users\sachi\Box Sync\CTOP\Results for paper\CTOP LEP issue rates 2020-06-05.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

PROC EXPORT DATA= WORK._d 
            OUTFILE= "C:\Users\sachi\Box Sync\CTOP\Results for paper\CTOP LEP issue rate differences 2020-06-05.csv" 
            DBMS=CSV 
			/*REPLACE*/; *will not replace the new file since I made edits;
     PUTNAMES=YES;
RUN;

** output not used in the final analysis;
/*
PROC EXPORT DATA= WORK.relative_risks 
            OUTFILE= "C:\Users\sachi\Box Sync\CTOP\Results for paper\CTOP LEP relative risks.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
*/



/* ------------------------------------------------------------------------------
OUTCOME: RN note outcome among those with identited issue by English profciency - 

MOVED TO STATA for easier calculation of marginal values
---------------------------------------------------------------------------------*/


/* ---------------------------------------------
OUTCOME: ESCALATION 
------------------------------------------------*/

%LET cat_vars = recode_race ins Disposition 
Top3_service Ethnicity Marital_Status;
%LET cont_vars = age LOS Elixhauser;

%include "C:\Users\sachi\Box Sync\data\!Macros\MARGINS.sas";

data _t; set analysis;
where count_of_issues > 0 ;
if count_of_issues > 0 then do;
	if Involved_pharmacist = . then Involved_pharmacist = 0;
	if Involved_clinician = . then Involved_clinician = 0;
	if Involved_allied = . then Involved_allied = 0;
end;

Involved = sum(Involved_pharmacist, Involved_clinician, Involved_allied);
Involved = min(1, Involved);
run;

%macro involve(y, name);

%Margins(	data      	= _t,
            response  	= &y,
			class 		= EP,
            model     	= EP,
			dist      	= binomial,
			link 	  	= logit,
			margins    	= EP,
			options   	= cl desc diff nomodel);

data _m_un_&y
(rename = (_mu = freq Lower=LL Upper=UL));
set _margins;
adjusted = "Unadjusted";
involved = "&name";
keep adjusted involved _mu EP Lower Upper;
run;

data _d_un_&y;
set _diffs;
involved = "&name";
adjusted = "Unadjusted";
keep diff involved Lower Upper Pr adjusted;
run;

%Margins(	data      	= _t,
            response  	= &y,
			class 		= EP &cat_vars,
            model     	= EP &cont_vars &cat_vars,
			dist      	= binomial,
			link 	  	= logit,
			margins    	= EP,
			options   	= cl desc diff nomodel);

data _m_adj_&y
(rename = (_mu = freq Lower=LL Upper=UL));
set _margins;
adjusted = "Adjusted";
involved = "&name";
keep adjusted involved _mu EP Lower Upper;
run;

data _d_adj_&y;
set _diffs;
involved = "&name";
adjusted = "Adjusted";
keep diff involved Lower Upper Pr adjusted;
run;

%mend;
%involve(Involved_pharmacist, Pharmacist);
%involve(Involved_clinician, Clinician);
%involve(Involved_allied, Nonclinical health staff);
*%involve(involved, involved);

data _m;
length adjusted $10.;
length involved $24.;
set _m_:;
run;

data _d;
length adjusted $10.;
length involved $24.;
set _d_:;
run;

proc print data = _d;
run;

PROC EXPORT DATA= work._m 
            OUTFILE= "C:\Users\sachi\Box Sync\CTOP\Results for paper\CTOP clinician involvement rates 2020-06-05.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

PROC EXPORT DATA= work._d
            OUTFILE= "C:\Users\sachi\Box Sync\CTOP\Results for paper\CTOP clinician involvement diff 2020-06-05.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

proc freq data = analysis;
tables count_of_issue:;
run;

proc datasets lib=work nolist;
	delete _m: _d: _covmarg _t;
run;
quit;

