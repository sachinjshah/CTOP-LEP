/*

9/12/19
- need to re-run the count of issues table
b/c there was an error in how count of issues was coded


** CTOP Response Data 12.28.18_1.1.19.csv is an old file;
*/


libname out "C:\data\cipher\processed data\";


        data WORK.CTOP    ;
      %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
      infile 'C:\data\cipher\original data\CTOP_Extract_5.1.18_4.30.19.csv' delimiter = ','  MISSOVER DSD lrecl=32767 firstobs=2 ;
         informat Name $21. ;
         informat MRN best32. ;
         informat Date_of_Birth mmddyy10. ;
         informat Gender $6. ;
         informat Primary_Language $19. ;
         informat Discharge_Date $10. ;
         informat Hospital_Service $37. ;
         informat Encounter_ID $14. ;
         informat Primary_Care_Physician $36. ;
         informat Payor_Status $38. ;
         informat Call_Date $10. ;
         informat Program $24. ;
         informat Reached $3. ;
         informat Issue_Names $15. ;
         informat First_Attempt_At $10. ;
         informat Intervention_Time $11. ;
         informat Issue_Status $6. ;
         informat Closed_At $19. ;
         informat Inbound $2. ;
         informat Interaction_Date mmddyy10. ;
         informat Interaction_Start_Time $10. ;
         informat Interaction_End_Time $10. ;
         informat Interaction_Hour $12. ;
         informat Interaction_Time $10. ;
         informat Question_Reached $31. ;
         informat Issue_Questions $100. ;
         informat Who_Answered $31. ;
         informat Discharge_Instructions $3. ;
         informat Prescriptions $14. ;
         informat Medications $3. ;
         informat Follow_Up_Help $3. ;
         informat Satisfaction $20. ;
         informat Clinical_Disclaimer___Goodbye $1. ;
         informat Other_Clinical_Issues $3. ;
         informat Language $9. ;
         informat C_Goodbye $1. ;
         informat Symptoms $3. ;
         informat Prescriptions_2 $3. ;
         informat Home_Health $1. ;
         informat No_Discharge_Summary $1. ;
         informat Interpreter_Used $1. ;
         informat Call_Status $1. ;
         informat Call_Status $200. ;
         informat Action_Taken $1. ;
         informat Action_Taken $230. ;
         informat Reached_by_Manual_Call_No_Issues $3. ;
         informat Reached_by_Manual_Call_Issues $3. ;
         informat Unable_to_Reach_by_Manual_Call__ $3. ;
         informat Not_Called $3. ;
         informat Please_select_the_reason_ $52. ;
         informat Call_Status $1. ;
         informat Call_Status $200. ;
         informat Action_Taken $1. ;
         informat Action_Taken $230. ;
         informat No_Discharge_Summary $50. ;
         informat Interpreter_Used $3. ;
         informat No_Discharge_Summary $1. ;
         informat Interpreter_Used $1. ;
         format Name $21. ;
         format MRN best12. ;
         format Date_of_Birth mmddyy10. ;
         format Gender $6. ;
         format Primary_Language $19. ;
         format Discharge_Date $10. ;
         format Hospital_Service $37. ;
         format Encounter_ID $14. ;
         format Primary_Care_Physician $36. ;
         format Payor_Status $38. ;
         format Call_Date $10. ;
         format Program $24. ;
         format Reached $3. ;
         format Issue_Names $15. ;
         format First_Attempt_At $10. ;
         format Intervention_Time $11. ;
         format Issue_Status $6. ;
         format Closed_At $19. ;
         format Inbound $2. ;
         format Interaction_Date mmddyy10. ;
         format Interaction_Start_Time $10. ;
         format Interaction_End_Time $10. ;
         format Interaction_Hour $12. ;
         format Interaction_Time $10. ;
         format Question_Reached $31. ;
         format Issue_Questions $100. ;
         format Who_Answered $31. ;
         format Discharge_Instructions $3. ;
         format Prescriptions $14. ;
         format Medications $3. ;
         format Follow_Up_Help $3. ;
         format Satisfaction $20. ;
         format Clinical_Disclaimer___Goodbye $1. ;
         format Other_Clinical_Issues $3. ;
         format Language $9. ;
         format C_Goodbye $1. ;
         format Symptoms $3. ;
         format Prescriptions_2 $3. ;
         format Home_Health $1. ;
         format No_Discharge_Summary $1. ;
         format Interpreter_Used $1. ;
         format Call_Status $1. ;
         format Call_Status2 $200. ;
         format Action_Taken $1. ;
         format Action_Taken2 $230. ;
         format Reached_by_Manual_Call_No_Issues $3. ;
         format Reached_by_Manual_Call_Issues $3. ;
         format Unable_to_Reach_by_Manual_Call__ $3. ;
         format Not_Called $3. ;
         format Please_select_the_reason_ $52. ;
         format Call_Status3 $1. ;
         format Call_Status4 $200. ;
         format Action_Taken3 $1. ;
         format Action_Taken4 $230. ;
         format No_Discharge_Summary2 $50. ;
         format Interpreter_Used2 $3. ;
         format No_Discharge_Summary3 $1. ;
         format Interpreter_Used3 $1. ;
      input
                  Name $
                  MRN
                  Date_of_Birth
                  Gender $
                  Primary_Language $
                  Discharge_Date
                  Hospital_Service $
                  Encounter_ID $
                  Primary_Care_Physician $
                  Payor_Status $
                  Call_Date
                  Program $
                  Reached $
                  Issue_Names $
                  First_Attempt_At
                  Intervention_Time
                  Issue_Status $
                  Closed_At $
                  Inbound $
                  Interaction_Date
                  Interaction_Start_Time
                  Interaction_End_Time
                  Interaction_Hour $
                  Interaction_Time $
                  Question_Reached $
                  Issue_Questions $
                  Who_Answered $
                  Discharge_Instructions $
                  Prescriptions $
                  Medications $
                  Follow_Up_Help $
                  Satisfaction $
                  Clinical_Disclaimer___Goodbye $
                  Other_Clinical_Issues $
                  Language $
                  C_Goodbye $
                  Symptoms $
                  Prescriptions_2 $
                  Home_Health $
                  No_Discharge_Summary $
                  Interpreter_Used $
                  Call_Status $
                  Call_Status2 $
                  Action_Taken $
                  Action_Taken2 $
                  Reached_by_Manual_Call_No_Issues $
                  Reached_by_Manual_Call_Issues $
                  Unable_to_Reach_by_Manual_Call__ $
                  Not_Called $
                  Please_select_the_reason_ $
                  Call_Status3 $
                  Call_Status4 $
                  Action_Taken3 $
                  Action_Taken4 $
                  No_Discharge_Summary2 $
                  Interpreter_Used2 $
                  No_Discharge_Summary3 $
                  Interpreter_Used3 $
      ;
      if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */

      run;


data ctop2
(drop = Date_of_Birth /*Primary_Language*/ ); 
set ctop;
format dc_date mmddyy10.;
length apex_lang_cat $12.;

drop 
name 
mrn
Primary_Care_Physician
Clinical_Disclaimer___Goodbye
Program
C_Goodbye
reached
Issue_names
Intervention_Time
Inbound
Interaction_Start_Time
Interaction_End_Time
Interaction_Time
Who_Answered
Home_Health
No_Discharge_Summary
Interpreter_Used
Interpreter_Used3
Call_Status
Call_Status3
Action_Taken
Action_Taken3
No_Discharge_Summary3
;

Primary_Language = UPCASE(Primary_language);

dc_date = input(Discharge_Date, mmddyy10.);
age = (dc_date - Date_of_Birth)/365;

if Primary_Language in ("E", "UNKNOWN/DECLINED","")
then Primary_Language = "UNKNOWN";

if Primary_Language = "CANTONESE - CHINESE" 
then Primary_Language = "CANTONESE";

if Primary_Language = "CANTONESE" then apex_lang_cat = "3. Cantonese";
	else if Primary_Language =   "ENGLISH" then apex_lang_cat = "1. English";
		else if Primary_Language = "SPANISH" then apex_lang_cat = "2. Spanish";
			else apex_lang_cat = "4. Other";

* Reponse_Language = Language;

run;

data ctop3; set ctop2;
run;

%macro actions(var,full);
data ctop3; set ctop3;
&var = (index(Action_Taken2, &full) > 0);
if &var = 0 then &var = (index(Action_Taken4, &full) > 0);
run;
%mend;

%actions(Helped_schedule_appointment, "Helped schedule appointment")
%actions(Notified_Inpatient_provider, "Notified Inpatient provider")
%actions(Notified_Midlevel_provider, "Notified Mid-level provider")
%actions(Notified_PCP, "Notified PCP")
%actions(Notified_Specialist, "Notified Specialist")
%actions(Provided_Correct_Contact_Info, "Provided Correct Contact Info")
%actions(Requested_Action_from_Provider, "Requested Action from Clinic/Provider")
%actions(Reviewed_Chart_Clinical_Info, "Reviewed Chart/Clinical Info")
%actions(Reviewed_DC_Instructions, "Reviewed D/C Instructions")
%actions(Reviewed_Medications, "Reviewed Medications")
%actions(Reviewed_Warning_Signs, "Reviewed Warning Signs of Health Problems")
%actions(Helped_coordinate_home_services, "Helped coordinate home/OP services")
%actions(Helped_obtain_prescriptions, "Helped obtain prescriptions")


data ctop4
(
drop = 
Please_select_the_reason_
Call_Status4
Call_Status2
Action_Taken2
Action_Taken4
No_Discharge_Summary2
Interpreter_Used2
Discharge_Date
Call_Date
rename = 
(call_date_ = call_date)
)
; 
set ctop3;

length call_status $200.;
length Issues $22.;
format call_date_ mmddyy10.;
format reply_to_any_q $3.;


call_date_ = input(trim(Call_Date),MMDDYY10.);
Reason_not_called = Please_select_the_reason_;
Call_status = Call_Status4;
if call_status = "" then call_status = Call_Status2;

Direct_Pharmacist_Escalation = (index(No_Discharge_Summary2, "Direct Pharmacist Escalation") > 0 );
Interpreter = (index(No_Discharge_Summary2, "Interpreter Used") > 0);
No_DC_Summary = (index(No_Discharge_Summary2, "No Discharge Summary") > 0);
if Interpreter = 0 then Interpreter = (Interpreter_Used2 = "Yes");

reply_to_any_q = "No";
if (Symptoms ne "") then reply_to_any_q = "Yes";

count_of_issues = 
	(Discharge_Instructions = "Yes") +
	(Medications = "Yes") +
	(Follow_Up_Help = "Yes") + 
	(Symptoms = "Yes") + /*changed from Satisfaction to Symptoms on 9/12, believe this is a coding error*/
	(Other_Clinical_Issues = "Yes") +
	(Prescriptions_2 = "Yes") ;

if count_of_issues = 0 then Issues = "0. No issues";
else if count_of_issues = 1 then Issues = "1. One issue";
else Issues = "2. More than one issue";

response_lep = 0;
if Interpreter = 1 OR Language in ("Cantonese", "Spanish") then response_lep = 1;

run;

data out.ctop_clean; set work.ctop4; run;

