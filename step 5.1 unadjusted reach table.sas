libname in "C:\Users\sachi\Box Sync\data\cipher\processed data\";
libname out "C:\Users\sachi\Box Sync\data\cipher\processed data\";

** adjusted analysis done in STATA;

data analysis; set in.ctop_apex_first_20200605;
run;

proc freq;
tables reached * EP / norow nofreq nopercent chisq exact;

run;
