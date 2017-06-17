*STEP 0 ;
/****************************************************************************************************************************/
/*1. Program Name:Vivek235_HW09_Program.sas																						*/
/* Program Location: C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment09\Vivek235_HW09_Program.sas		*/
/* Date Created: 3/24/17																									*/							
/* Author: Vivek Kumar Gupta																								*/
/* Purpose:In this exercise practice transforming SAS code from traditional code to code with macro variables
then on to become a stored macro program.				*/
/****************************************************************************************************************************/

*STEP 1 - Setup of libraries and filerefs.  Use a filename statement to define the path to the PDF output file.;

*1.Create the necessary library references for data sources and destination and file references for output.;
libname mydata  'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment09\mydata' ; /*library storing the data*/
libname orion 'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\SQL Files' access=readonly;
filename pdfdev 'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment09\Vivek235_HW09_Output.pdf';

*STEP 1. Turn off page numbering and date printing to match the output formatting. Add an option to resolve macro variables in the log. 
Add options to permanently store the macros created in the library. For debug specify mprint option otherwise it can be taken off
Per assignment needs set mprint option;
option nonumber nodate symbolgen mprint mcompilenote=all mstored sasmstore=mydata;;

/*Open destination device, set no bookmarks to be generated per the output*/
ods pdf file=pdfdev bookmarkgen=no ;

/*STEP 2. Copy the PROC SQL code that was used to create the view in Assignment 8 and paste it into this
program. Generalize the code rather than using hardcoded values*/

%let gender=F; /*Values M or F*/
%let startdate=01Jan2006;
%let enddate=31Dec2006;
%let datalib=mydata;

proc sql ;
create table &datalib..donations
as
select ep.employee_id label ='ID'
		,edd.employee_name label ='Name'
		, ep.salary format dollar8.
		,ed.Qtr1
		,ed.Qtr2
		,ed.Qtr3
		,ed.Qtr4 
		,sum(ed.Qtr1,ed.Qtr2,ed.Qtr3,ed.Qtr4) as tot_donation label ='Ann. Donation'
from orion.employee_payroll as ep 
join orion.employee_addresses as edd 
		on ep.employee_id=edd.employee_id
left join orion.employee_donations as ed 
		on ep.employee_id=ed.employee_id
where ep.employee_gender="&gender" 
		and not ep.employee_term_date
		and ep.employee_hire_date between "&startdate"d and "&enddate"d
order by employee_id
;
quit;

/*STEP 3.Use a PROC PRINT to print the data portion of the data set by using the SYSLAST macro variable.*/
title 'Data Portion of the &SYSLAST Data Set';

proc print data=&syslast ;
run;

/*STEP 4. Create a macro with arguments and other changes as directed by instructions. Also add housekeeping in the macro itself*/
%macro donations(library,gender,startdate,enddate);
proc sql;
create table &library..%sysfunc(propcase(&gender))%substr(&startdate,6)
as
select ep.employee_id label ='ID'
		,edd.employee_name label ='Name'
		, ep.salary format dollar8.
		,ed.Qtr1
		,ed.Qtr2
		,ed.Qtr3
		,ed.Qtr4 
		,sum(ed.Qtr1,ed.Qtr2,ed.Qtr3,ed.Qtr4) as tot_donation label ='Ann. Donation'
from orion.employee_payroll as ep 
join orion.employee_addresses as edd 
		on ep.employee_id=edd.employee_id
left join orion.employee_donations as ed 
		on ep.employee_id=ed.employee_id
where ep.employee_gender="%upcase(%substr(&gender,1,1))"
		and not ep.employee_term_date
		and ep.employee_hire_date between "&startdate"d and "&enddate"d
order by employee_id
;
title "Donations of %sysfunc(propcase(&gender)) Employees Hired between &startdate and &enddate";
footnote %upcase(&syslast);
select * from &library..%sysfunc(propcase(&gender))%substr(&startdate,6);


quit;
title;
footnote;
%mend donations;

/*STEP 5. Call the macro*/
%donations(mydata, male, 01Jan1974, 30Jun1974);

/*STEP 6. Store the macro*/
%macro donations(library,gender,startdate,enddate)/ store ;
proc sql;
create table &library..%sysfunc(propcase(&gender))%substr(&startdate,6)
as
select ep.employee_id label ='ID'
		,edd.employee_name label ='Name'
		, ep.salary format dollar8.
		,ed.Qtr1
		,ed.Qtr2
		,ed.Qtr3
		,ed.Qtr4 
		,sum(ed.Qtr1,ed.Qtr2,ed.Qtr3,ed.Qtr4) as tot_donation label ='Ann. Donation'
from orion.employee_payroll as ep 
join orion.employee_addresses as edd 
		on ep.employee_id=edd.employee_id
left join orion.employee_donations as ed 
		on ep.employee_id=ed.employee_id
where ep.employee_gender="%upcase(%substr(&gender,1,1))"
		and not ep.employee_term_date
		and ep.employee_hire_date between "&startdate"d and "&enddate"d
order by employee_id
;
title "Donations of %sysfunc(propcase(&gender)) Employees Hired between &startdate and &enddate";
footnote %upcase(&syslast);
select * from &library..%sysfunc(propcase(&gender))%substr(&startdate,6);

quit;
title;
footnote;
%mend donations;

/*STEP 7. List all the macros created in permanent library*/
title "Compiled Macros in My Permanent Library";

proc catalog cat=mydata.sasmacr;
contents;
quit;

/*House keeping. Resetting defaults*/
title;
footnote;
option number date nosymbolgen nomprint mcompilenote=none; 

/**Close the device*/
ods pdf close; 

