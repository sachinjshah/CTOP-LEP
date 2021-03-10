libname in "C:\Users\sachi\Box Sync\data\cipher\processed data\";
libname out "C:\Users\sachi\Box Sync\data\cipher\processed data\";

** adjusted analysis done in STATA;

data analysis; set in.ctop_apex_first_20200605;
if count_of_issues > 0 and note_outcome = "" then note_outcome = "5. No note";
run;

proc freq;
tables note_outcome * EP / norow nofreq nopercent chisq ;
where count_of_issues > 0;
run;
