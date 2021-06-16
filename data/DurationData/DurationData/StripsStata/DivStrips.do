


clear all
* cd "~/Dropbox/DurationBasedAP/Stata/Strips_eurex"



****************************************************************************************************************
*
*														README
*
****************************************************************************************************************;

/*

The following do-file handles two datasets prepared in SAS. The annual dataset contains observations for the end of December each year. 
It has the expected yield to maturity and the realized return over the next year, along with a series of characteristics of the firm and the 
particular strip. A few clarifications:

	- VID is the firm-level identifier, similar to GVKEY.
	- id3 is the firm-strip level identifier.
	- y1 to y5 are maturity dummies.
	- Eret_flag is a flag equal to one if expected returns are below -10% or above 30% (we consider these returns products of incorrect matching
      of IBES and Strip data).
	- Notional is the total value of all outstanding contracts on the strip.
	- Betas: Beta and beta_raw refers to the beta of the underlying firm (measured in xs-percent or actual units), beta_strip refers to the 
	  beta of the actual strip over the next year, and beta_yield is the average beta over the remaining life of the strip
	- Returns are measured in different currencies (although most are in Euros).

See SAS code for additional details on construction of the dataset. 

*/


****************************************************************************************************************
*
*												TABLE 7: EXPECTED RETURNS
*
****************************************************************************************************************;




use annual, clear
gen vid2 = vid + string(mat,"%02.0f")


egen id3 = group(vid2)

gen m = month(date)
gen y_m = ym(year(date),month(date))
format y_m %tm
tsset id3 y_m


reghdfe eret  beta_yield beta_raw dur		            	   if y5 ==0 & flag_eret ==0    , absorb(y_m currency) cluster(y_m vid) 
outreg2 using Tables/Strip1.tex,  replace ctitle(All firms) addtext(FE, Date/Cur, Cluster, Date/Firm) label auto(2) dec(2)  excel
reghdfe eret  y2 y3 y4         								   if y5 ==0   & flag_eret ==0  , absorb(y_m currency) cluster(y_m vid) 
outreg2 using Tables/Strip1.tex,  append ctitle(All firms) addtext(FE, Date/Cur,Cluster, Date/Firm, Weight, None) label auto(2) dec(2) excel
reghdfe eret  y2 y3 y4 beta_yield beta_raw dur	        	   if y5 ==0  & flag_eret ==0   , absorb(y_m currency) cluster(y_m vid) 
outreg2 using Tables/Strip1.tex,  append ctitle(All firms) addtext(FE, Date/Cur,Cluster, Date/Firm, Weight, None) label auto(2) dec(2) excel
 
reghdfe ealpha  y2 y3 y4 dur			        			   if y5 ==0  & flag_eret ==0  	, absorb(y_m currency) cluster(y_m vid) 
outreg2 using Tables/Strip1.tex,  append ctitle(All firms) addtext(FE, Date/Cur, Cluster, Date/Firm) label auto(2) dec(2) excel
reghdfe ealpha  y2 y3 y4 dur [aw=notional]     				   if y5 ==0  & flag_eret ==0  	, absorb(y_m currency) cluster(y_m vid) 
outreg2 using Tables/Strip1.tex,  append ctitle(All firms) addtext(FE, Date/Cur, Cluster, Date/Firm, Weight, Notional) label auto(2) dec(2) excel
reghdfe beta_strip  y2 y3 y4 beta_raw		     			   if y5 ==0 					, absorb(y_m currency) cluster(vid y_m) 
outreg2 using Tables/Strip1.tex,  append ctitle(All firms) addtext(FE, Date/Cur, Cluster, Date/Firm) label auto(2) dec(2) excel




****************************************************************************************************************
*
*												 TABLE 8: REALIZED RETURNS
*
****************************************************************************************************************;


clear all

use annual, clear
gen vid2 = vid + string(mat,"%02.0f")
egen id3 = group(vid2)


gen m = month(date)
gen y = year(date)
gen y_m = ym(year(date),month(date))
format y_m %tm
format y %ty
tsset id3 y

generate log_eret = log(1+eret)

**** RETURN PREDICTABILITY 

reghdfe ret eret        			    		    	          if  y5 == 0  & flag_eret ==0  , absorb(vid) cluster(y_m vid) 
outreg2 using Tables/Strip2.tex,  replace ctitle(All firms) addtext(FE, Firm, Cluster, Date/Firm) label auto(2) excel
reghdfe ret eret        			    		   		          if  y5 == 0  & flag_eret ==0   , absorb(y_m vid) cluster(y_m vid) 
outreg2 using Tables/Strip2.tex,  append ctitle(All firms) addtext(FE, Date/Firm, Cluster, Date/Firm) label auto(2) excel

reghdfe log_ret log_eret        			    			      if  y5 == 0   & flag_eret ==0  , absorb(vid) cluster(y_m vid) 
outreg2 using Tables/Strip2.tex,  append ctitle(All firms) addtext(FE, Firm, Cluster, Date/Firm) label auto(2) excel
reghdfe log_ret log_eret        			    			      if  y5 == 0   & flag_eret ==0  , absorb(y_m vid) cluster(y_m vid) 
outreg2 using Tables/Strip2.tex,  append ctitle(All firms) addtext(FE, Date/Firm, Cluster, Date/Firm) label auto(2) excel

reghdfe ret eret      		 [aw=notional]               		  if  y5 == 0   & flag_eret ==0  , absorb(vid) cluster(y_m vid) 
outreg2 using Tables/Strip2.tex,  append ctitle(All firms) addtext(FE, Firm, SE, Date/Firm, Weight, Notional) label auto(2) excel
reghdfe log_ret log_eret       [aw=notional]           		      if  y5 == 0   & flag_eret ==0  , absorb(y_m vid) cluster(y_m vid) 
outreg2 using Tables/Strip2.tex,  append ctitle(All firms) addtext(FE, Date/Firm, Cluster, Date/Firm, Weight, Notional) label auto(2) excel


**** REALIZED RETURNS AND ALPHAS

reghdfe ret       y2 y3 y4    			    		              if  y5 == 0    , absorb(y_m vid) cluster(y_m vid) 
outreg2 using Tables/Strip3.tex,  replace ctitle(All firms) addtext(FE, Date/Firm, Cluster, Date/Firm) label auto(2) excel
reghdfe log_ret   y2 y3 y4    		                              if  y5 == 0    , absorb(y_m vid) cluster(y_m vid) 
outreg2 using Tables/Strip3.tex,  append ctitle(All firms)  addtext(FE, Date/Firm, Cluster, Date/Firm) label auto(2) excel

reghdfe alpha        y2 y3 y4    	       						  if  y5 == 0    , absorb(y_m vid)  cluster(y_m vid) 
outreg2 using Tables/Strip3.tex,  append ctitle(All firms)  addtext(FE, Date/Firm, Cluster, Date/Firm) label auto(2) excel
reghdfe alpha        y2 y3 y4   	 		             if  y5 == 0    , absorb(y_m vid)  cluster(y_m id3) 
outreg2 using Tables/Strip3.tex,  append ctitle(All firms)  addtext(FE, Date/Firm, Cluster, Date/Strip, Weight, None) label auto(2) excel

reghdfe log_alpha    y2 y3 y4    	                             if  y5 == 0    , absorb(y_m vid)  cluster(y_m vid) 
outreg2 using Tables/Strip3.tex,  append ctitle(All firms)  addtext(FE, Date/Firm, Cluster, Date/Firm) label auto(2) excel
reghdfe log_alpha    y2 y3 y4    			         if  y5 == 0    , absorb(y_m vid)  cluster(y_m id3)
outreg2 using Tables/Strip3.tex,  append ctitle(All firms)  addtext(FE, Date/Firm, Cluster, Date/Strip, Weight, None) label auto(2) excel



**** CHARACTERISTICS ON RHS



reghdfe ret      	 y2 y3 y4 dur    			    		              if  y5 == 0    , absorb(y_m currency) cluster(y_m id3) 
outreg2 using Tables/Strip4.tex,  replace ctitle(All firms) addtext(FE, Date/currency,Cluster, Date/Firm) label auto(2) excel
reghdfe log_ret  	 y2 y3 y4 dur   		                              if  y5 == 0    , absorb(y_m currency) cluster(y_m id3) 
outreg2 using Tables/Strip4.tex,  append ctitle(All firms)  addtext(FE, Date/currency,Cluster, Date/Firm) label auto(2) excel

reghdfe alpha        y2 y3 y4 dur   	       						      if  y5 == 0    , absorb(y_m currency)  cluster(y_m vid) 
outreg2 using Tables/Strip4.tex,  append ctitle(All firms)  addtext(FE, Date/currency,Cluster, Date/Firm) label auto(2) excel
reghdfe log_alpha        y2 y3 y4 dur  	 		                          if  y5 == 0        , absorb(y_m currency)  cluster(y_m vid) 
outreg2 using Tables/Strip4.tex,  append ctitle(All firms)  addtext(FE, Date/currency,Cluster, Date/Firm, Weight, Notional) label auto(2) excel
reghdfe log_alpha    y2 y3 y4 dur   	       [aw=notional]              if  y5 == 0    , absorb(y_m currency)  cluster(y_m vid) 
outreg2 using Tables/Strip4.tex,  append ctitle(All firms)  addtext(FE, Date/currency,Cluster, Date/Firm) label auto(2) excel
reghdfe log_alpha    y2 y3 y4 dur 			   [aw=notional]              if  y5 == 0    , absorb(y_m currency)  cluster(y_m id3)
outreg2 using Tables/Strip4.tex,  append ctitle(All firms)  addtext(FE, Date/currency,Cluster, Date/Strip, Weight, Notional) label auto(2) excel


**** PREDICTING ERRORS

generate error = ret-eret 
generate log_error = log_ret - log_eret
generate dur_interact = dur * mat


reghdfe error      y2 y3 y4  dur 				              if  y5 == 0  & flag_eret == 0  , absorb(y_m currency) cluster(y_m vid) 
outreg2 using Tables/Strip5.tex,  replace ctitle(All firms) addtext(FE, Date/currency, Cluster, Date/Firm) label auto(2) excel
reghdfe error      y2 y3 y4  dur  [aw=notional]	              if  y5 == 0  & flag_eret == 0  , absorb(y_m currency) cluster(y_m vid) 
outreg2 using Tables/Strip5.tex,  append ctitle(All firms)  addtext(FE, Date/Currency,Cluster, Date/Firm, Weight, Notional) label auto(2) excel


reghdfe log_error      y2 y3 y4  dur 				              if  y5 == 0 & flag_eret == 0   , absorb(y_m currency) cluster(y_m vid) 
outreg2 using Tables/Strip5.tex,  append ctitle(All firms)  addtext(FE, Date/Currency,Cluster, Date/Firm) label auto(2) excel
reghdfe log_error      y2 y3 y4  dur 		[aw=notional]         if  y5 == 0 & flag_eret == 0   , absorb(y_m currency) cluster(y_m vid) 
outreg2 using Tables/Strip5.tex,  append ctitle(All firms)  addtext(FE, Date/Currency,Cluster, Date/Firm, Weight, Notional) label auto(2) excel


****************************************************************************************************************
*
*												 UNTABULATED ANALYSIS
*
****************************************************************************************************************;



**** CHARACTERISTICS WITHOUT CURRENCY FIXED-EFFECTS

reghdfe ret          y2 y3 y4  dur 				              if  y5 == 0    , absorb(y_m ) cluster(y_m vid) 
reghdfe log_ret      y2 y3 y4  dur 				              if  y5 == 0    , absorb(y_m ) cluster(y_m vid) 

reghdfe alpha        y2 y3 y4  dur 							  if  y5 == 0    , absorb(y_m )  cluster(y_m vid) 
reghdfe alpha        y2 y3 y4  dur 	  	   [aw=notional]      if  y5 == 0    , absorb(y_m )  cluster(y_m vid) 

reghdfe log_alpha    y2 y3 y4  dur                            if  y5 == 0    , absorb(y_m )  cluster(y_m vid) 
reghdfe log_alpha    y2 y3 y4  dur    	   [aw=notional]      if  y5 == 0    , absorb(y_m )  cluster(y_m vid)


reghdfe alpha        y2 y3 y4  dur bm op inv beta pay							  if  y5 == 0    , absorb(y_m )  cluster(y_m vid) 
reghdfe alpha        y2 y3 y4  dur bm op inv beta pay 	  	   [aw=notional]      if  y5 == 0    , absorb(y_m )  cluster(y_m vid) 

reghdfe eret        y2 y3 y4  dur bm op inv beta pay							  if  y5 == 0    , absorb(y_m )  cluster(y_m vid)
reghdfe eret 		y2 y3 y4 beta 												  if  y5 == 0    , absorb(y_m)  cluster(y_m vid)



**** CONSIDERING ONE MATURITY AT A TIME

reghdfe ret if  y1 == 1, noabsorb cluster(vid y_m) 
reghdfe ret if  y2 == 1, noabsorb cluster(vid y_m) 
reghdfe ret if  y3 == 1, noabsorb cluster(vid y_m) 
reghdfe ret if  y4 == 1, noabsorb cluster(vid y_m) 


reghdfe alpha if  y1 == 1, noabsorb cluster(vid y_m) 
reghdfe alpha if  y2 == 1, noabsorb cluster(vid y_m) 
reghdfe alpha if  y3 == 1, noabsorb cluster(vid y_m) 
reghdfe alpha if  y4 == 1, noabsorb cluster(vid y_m) 


reghdfe beta_strip if  y1 == 1, noabsorb cluster(vid y_m) 
reghdfe beta_strip if  y2 == 1, noabsorb cluster(vid y_m) 
reghdfe beta_strip if  y3 == 1, noabsorb cluster(vid y_m) 
reghdfe beta_strip if  y4 == 1, noabsorb cluster(vid y_m) 


reghdfe ret dur  				  if  y1 == 1, absorb(currency) cluster(vid y_m) 
reghdfe ret dur 				  if  y2 == 1, absorb(currency) cluster(vid y_m) 
reghdfe ret dur  				  if  y3 == 1, absorb(currency) cluster(vid y_m) 
reghdfe ret dur 				  if  y4 == 1, absorb(currency) cluster(vid y_m) 

reghdfe alpha dur  				  if  y1 == 1, absorb(currency) cluster(vid y_m) 
reghdfe alpha dur  				  if  y2 == 1, absorb(currency) cluster(vid y_m) 
reghdfe alpha dur 				  if  y3 == 1, absorb(currency) cluster(vid y_m) 
reghdfe alpha dur  				  if  y4 == 1, absorb(currency) cluster(vid y_m) 

reghdfe alpha dur [aw = notional] if  y1 == 1, absorb(currency) cluster(vid y_m) 
reghdfe alpha dur [aw = notional] if  y2 == 1, absorb(currency) cluster(vid y_m) 
reghdfe alpha dur [aw = notional] if  y3 == 1, absorb(currency) cluster(vid y_m) 
reghdfe alpha dur [aw = notional] if  y4 == 1, absorb(currency) cluster(vid y_m) 

reghdfe alpha bm  [aw = notional] if  y1 == 1, absorb(currency) cluster(vid y_m) 
reghdfe alpha bm  [aw = notional] if  y2 == 1, absorb(currency) cluster(vid y_m) 
reghdfe alpha bm  [aw = notional] if  y3 == 1, absorb(currency) cluster(vid y_m) 
reghdfe alpha bm  [aw = notional] if  y4 == 1, absorb(currency) cluster(vid y_m) 

reghdfe alpha bm   if  y1 == 1, absorb(currency) cluster(vid y_m) 
reghdfe alpha bm   if  y2 == 1, absorb(currency) cluster(vid y_m) 
reghdfe alpha bm   if  y3 == 1, absorb(currency) cluster(vid y_m) 
reghdfe alpha bm   if  y4 == 1, absorb(currency) cluster(vid y_m) 





****************************************************************************************************************
*
*												INPUT FOR FIGURE 1
*
****************************************************************************************************************;

drop flag_eret
generate flag_eret = 0
replace flag_eret = 1 if eret < 0 
replace flag_eret = 1 if eret > 0.15


reghdfe ealpha if  y1 == 1 & dur_pct > 50 & flag_eret ==0, noabsorb cluster(vid y_m) 
outreg2 using Tables/Figure1.tex,  replace ctitle(All firms) label auto(2) excel
reghdfe ealpha if  y2 == 1 & dur_pct > 50 & flag_eret ==0, noabsorb cluster(vid y_m) 
outreg2 using Tables/Figure1.tex,  append ctitle(All firms) label auto(2) excel
reghdfe ealpha if  y3 == 1 & dur_pct > 50 & flag_eret ==0, noabsorb cluster(vid y_m) 
outreg2 using Tables/Figure1.tex,  append ctitle(All firms) label auto(2) excel
reghdfe ealpha if  y4 == 1 & dur_pct > 50 & flag_eret ==0, noabsorb cluster(vid y_m) 
outreg2 using Tables/Figure1.tex,  append ctitle(All firms) label auto(2) excel

reghdfe ealpha if  y1 == 1 & dur_pct <= 50 & flag_eret ==0, noabsorb cluster(vid y_m) 
outreg2 using Tables/Figure1.tex,  append ctitle(All firms) label auto(2) excel
reghdfe ealpha if  y2 == 1 & dur_pct <= 50 & flag_eret ==0, noabsorb cluster(vid y_m) 
outreg2 using Tables/Figure1.tex,  append ctitle(All firms) label auto(2) excel
reghdfe ealpha if  y3 == 1 & dur_pct <= 50 & flag_eret ==0, noabsorb cluster(vid y_m) 
outreg2 using Tables/Figure1.tex,  append ctitle(All firms) label auto(2) excel
reghdfe ealpha if  y4 == 1 & dur_pct <= 50 & flag_eret ==0, noabsorb cluster(vid y_m) 
outreg2 using Tables/Figure1.tex,  append ctitle(All firms) label auto(2) excel



reghdfe alpha if  y1 == 1 & dur_pct > 50 & flag_eret >=0, noabsorb cluster(vid y_m) 
outreg2 using Tables/Figure1_alt.tex,  replace ctitle(All firms) label auto(2) excel
reghdfe alpha if  y2 == 1 & dur_pct > 50 & flag_eret >=0, noabsorb cluster(vid y_m) 
outreg2 using Tables/Figure1_alt.tex,  append ctitle(All firms) label auto(2) excel
reghdfe alpha if  y3 == 1 & dur_pct > 50 & flag_eret >=0, noabsorb cluster(vid y_m) 
outreg2 using Tables/Figure1_alt.tex,  append ctitle(All firms) label auto(2) excel
reghdfe alpha if  y4 == 1 & dur_pct > 50 & flag_eret >=0, noabsorb cluster(vid y_m) 
outreg2 using Tables/Figure1_alt.tex,  append ctitle(All firms) label auto(2) excel

reghdfe alpha if  y1 == 1 & dur_pct <= 50 & flag_eret >=0, noabsorb cluster(vid y_m) 
outreg2 using Tables/Figure1_alt.tex,  append ctitle(All firms) label auto(2) excel
reghdfe alpha if  y2 == 1 & dur_pct <= 50 & flag_eret >=0, noabsorb cluster(vid y_m) 
outreg2 using Tables/Figure1_alt.tex,  append ctitle(All firms) label auto(2) excel
reghdfe alpha if  y3 == 1 & dur_pct <= 50 & flag_eret >=0, noabsorb cluster(vid y_m) 
outreg2 using Tables/Figure1_alt.tex,  append ctitle(All firms) label auto(2) excel
reghdfe alpha if  y4 == 1 & dur_pct <= 50 & flag_eret >=0, noabsorb cluster(vid y_m) 
outreg2 using Tables/Figure1_alt.tex,  append ctitle(All firms) label auto(2) excel



****************************************************************************************************************
*
*												TABLE 6: SUMMARY STATS 
*
****************************************************************************************************************;


*** Returns and trading

clear all
use annual, clear
generate volume_annual = volume
generate open_int = open_interest
generate price_strip = price * 1000
generate notional_thousands = notional
keep ret ret_settle log_ret volume_annual open_int price_strip notional_thousands


outreg2 using Tables/Strip_summarize1.tex, replace sum(log) see label auto(2) excel



*** Maturity and betas

clear all
use annual, clear
generate strip_beta = beta_strip
generate strip_beta_untrimmed = beta_strip2
generate obs_beta = numobs_beta + 1
keep y1 y2 y3 y4  mat strip_beta strip_beta_untrimmed obs_beta 


outreg2 using Tables/Strip_summarize2.tex, replace sum(log) see label auto(2) excel


*** Representativeness

clear all
use annual, clear
keep dur dur_pct bm mep op inv beta pay


outreg2 using Tables/Strip_summarize3.tex, replace sum(log) see label auto(2) excel




*** Precise returns stats

clear all
use annual, clear

sum ret if y5 ==0 
summarize ret_settle if y5 ==0, detail
summarize ret_mkt if y5 ==0, detail



*** Returns and trading

clear all
use annual, clear
generate volume_annual = volume
generate open_int = open_interest
generate price_strip = price * 1000
generate notional_thousands = notional
keep ret date ret_settle log_ret volume_annual open_int price_strip notional_thousands

sum if year(date)==2018



clear all
use annual, clear
keep year eret
bysort year: outreg2 using Tables/temp.tex, replace sum(log) eqkeep(N mean sd) excel


****************************************************************************************************************
*
*												FIGURE: HISTROGRAM
*
****************************************************************************************************************;


clear all



use monthly, clear
gen vid2 = vid + string(mat,"%02.0f")
*destring vid2, generate(id2) ignore("W" "__")

egen id3 = group(vid2)

gen m = month(date)
gen y_m = ym(year(date),month(date))
format y_m %tm
tsset id3 y_m

histogram ret if y5 ==0 & ret !=0 & -0.3 < ret & ret < 0.3
graph export figures/Figure1b.pdf, as(pdf) replace 



****************************************************************************************************************
*
*										 MONTHLY RETURNS TEST AR(1)
*
****************************************************************************************************************;


clear all

use AR_test, clear
gen vid2 = vid + string(mat,"%02.0f")
*destring vid2, generate(id2) ignore("W" "__")

egen id3 = group(vid2)

gen m = month(date)
gen y_m = ym(year(date),month(date))
format y_m %tm
tsset id3 y_m


reghdfe lead_ret last_ret if lead_ret !=0, noabsorb cluster(y_m vid)
reghdfe lead_ret last_ret if lead_ret !=0, absorb(vid) cluster(y_m vid)
reghdfe lead_ret last_ret if lead_ret !=0, absorb(y_m) cluster(y_m vid)
reghdfe lead_ret last_ret if lead_ret !=0, noabsorb cluster(y_m)


reghdfe lead_ret last_ret [aw=notional] if lead_ret !=0, noabsorb cluster(y_m vid)
reghdfe lead_ret last_ret [aw=notional]  if lead_ret !=0, absorb(vid) cluster(y_m vid)
reghdfe lead_ret last_ret [aw=notional]  if lead_ret !=0, absorb(y_m) cluster(y_m vid)
reghdfe lead_ret last_ret [aw=notional]  if lead_ret !=0, noabsorb cluster(y_m)






