clear
import delimited "C:\Users\sachi\Box Sync\data\cipher\processed data\ctop_apex_first_20200605.csv"

encode issues, generate(issues_e)
encode ep, generate(ep_e)
encode recode_race, generate(recode_race_e)
encode ins, generate(ins_e)
encode disposition, generate(disposition_e)
encode top3_service, generate(top3_service_e)
encode ethnicity, generate(ethnicity_e)
encode marital_status, generate(marital_status_e)
encode reached, generate(reached_e)

/* gen issues_n = .
replace issues_n = 0 if issues == "0. No issues"
replace issues_n = 1 if issues == "1. One issue"
replace issues_n = 2 if issues == "2. More than one issue"

gen ep_n = . 
replace ep_n = 0 if ep == "EP"
replace ep_n = 1 if ep == "LEP"
*/


** reach rate
ologit reached_e i.ep_e 
margins ep_e, post
estimates store reach_unadj
outreg2 [reach_unadj] using "C:\Users\sachi\Box Sync\CTOP\Results for paper\table 2 reach rate unadjusted 2020-06-05.xls", replace noaster nose

ologit reached_e i.ep_e i.recode_race_e i.ins_e i.disposition_e i.top3_service_e i.ethnicity_e i.marital_status_e age los elixhauser
margins ep_e, post
estimates store reach_adj
outreg2 [reach_adj] using "C:\Users\sachi\Box Sync\CTOP\Results for paper\table 2 reach rate adjusted 2020-06-05.xls", replace noaster nose


** issue count
/*
ologit issues_e i.ep_e if reply_to_any_q == "Yes";
margins ep_e, post
estimates store unadj
outreg2 [unadj] using "C:\Users\sachi\Box Sync\CTOP\Results for paper\issue_count_unadj.xls", replace noaster nose

ologit issues_e i.ep_e i.recode_race_e i.ins_e i.disposition_e i.top3_service_e i.ethnicity_e i.marital_status_e age los elixhauser if reply_to_any_q == "Yes";
margins ep_e, post
estimates store adj
outreg2 [adj] using "C:\Users\sachi\Box Sync\CTOP\Results for paper\issue_count_adj.xls", replace noaster nose
*/

** note outcome, also multinomial model
replace note_outcome = "5. No note" if count_of_issues > 0 & note_outcome == ""
encode note_outcome, generate(note_outcome_e)

ologit note_outcome_e i.ep_e if count_of_issues > 0
margins ep_e, post
estimates store unadj_notes
outreg2 [unadj_notes] using "C:\Users\sachi\Box Sync\CTOP\Results for paper\table 3 note outcome unadj 2020-06-05.xls", replace noaster nose

ologit note_outcome_e i.ep_e i.recode_race_e i.ins_e i.disposition_e i.top3_service_e i.ethnicity_e i.marital_status_e age los elixhauser if count_of_issues > 0
margins ep_e, post
estimates store adj_notes
outreg2 [adj_notes] using "C:\Users\sachi\Box Sync\CTOP\Results for paper\table 3 note outcome adj 2020-06-05.xls", replace noaster nose


** time to close
drop if count_of_issues < 1
gen issue_closed = 1
replace issue_close = 0 if max_close_time > 14
replace max_close_time = 14 if max_close_time > 14
stset max_close_time, failure(issue_closed)
// 
sts graph, by(ep_e) title("") legend(pos(12))
// 
stcox i.ep_e
stcurve, survival at1(ep_e = 1) at2(ep_e = 2) title("") legend(pos(12))

xi: stcox i.ep_e i.recode_race_e i.ins_e i.disposition_e i.top3_service_e i.ethnicity_e i.marital_status_e age los elixhauser

** from https://stats.idre.ucla.edu/stata/code/compute-adjusted-values-from-cox-model-using-mata/
stcox i.ep_e i.recode_race_e i.ins_e i.disposition_e i.top3_service_e i.ethnicity_e i.marital_status_e age los elixhauser,  nohr basesurv(km)
stcurve, survival at1(ep_e = 1) at2(ep_e = 2) title("") legend(pos(12))
/*
  use the margins command to get the linear predictions (xb)
  and post them to e(b), these are used by the mata function coxAdjust()
  note it is easist to get all margins of interest at once
*/
margins, dydx(ep_e)
margins, at(ep_e=(1 2)) predict(xb) post vsquish

/*
  create a mata function, coxAdjust()
  the first argument is the variable name with the baseline hazard function
  the second argument is the probablility cutoff, such as .5
  although valid values range from 0 to 1
  the third argument is optional and is the base variable name 
  used to store the adjusted hazard functions, if blank only the 
  values of interest are returned, not the entire adjusted hazard function
*/
mata
real matrix coxAdjust(string scalar baseline, real scalar p, | string scalar basevname)
{
  xb = exp(st_matrix("e(b)"))
  time = st_data(., "_t")
  lambda = log(st_data(., baseline))
  results = exp(lambda * xb)
  if (args()==3) {
    for (i=1; i<=cols(results); i++) {
	  newvar = basevname + strofreal(i)
	  index = st_addvar("double", newvar)
	  st_store((1, rows(results)), index, results[, i])
	}
  }
  
  tres = J(1, cols(results), .)
  for (i=1; i<=cols(results);i++) {
    tmp = select((time, results[, i]), results[, i] :< p)
	tres[i] = colmin(tmp[,1])
  }
  return(tres)
}
end
mata coxAdjust("km", .25)
mata coxAdjust("km", .5)
mata coxAdjust("km", .75)

*test the PH assumption using LEP x time
stcox i.ep_e i.recode_race_e i.ins_e i.disposition_e i.top3_service_e i.ethnicity_e i.marital_status_e age los elixhauser, tvc(ep_e) texp(ln(_t))
