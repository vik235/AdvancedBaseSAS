*STEP 0 ;
/*1. Program Name:Vivek235_HW11_Program.sas.																						*/
/* Program Location: C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment11\Vivek235_HW11_Program.sas		*/
/* Date Created: 4/10/17																									*/							
/* Author: Vivek Kumar Gupta																								*/
/* Purpose:This assignment uses macro and SQL techniques covered through Lecture 18.;			*/
/****************************************************************************************************************************/

libname orion 'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\SQL Files' access=readonly;
libname srcdata 'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment04\SourceData' access=readonly;
filename pdfdev 'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment11\Vivek235_HW11_Output.pdf';

/*STEP 1. Use all three system options that will cause macro resolution, macro code and macro execution
information to be written to the log.*/
option mprint symbolgen mlogic mcompilenote=all date; 

/*STEP 2. Copy the donations macro code created in step 4 of Assignment 9 and paste it into your new
SAS program for this assignment*/
/*STEP 3. Change the macro definition so that the start date and end date are positional parameters and
the library and gender are keyword parameters. Specify Female as the default gender and
WORK as the default output library.*/

%macro donate(startdate,enddate,library=WORK,gender=Female);
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
/*STEP 4. Add macro logic to your macro so that if the end date parameter is null, the macro will ignore
the end date and return employees hired on or after the start date.*/

%if &enddate = %then %do;
where ep.employee_gender="%upcase(%substr(&gender,1,1))"
		and not ep.employee_term_date and ep.employee_hire_date >= "&startdate"d 
		order by employee_id;
/*STEP 5. Use macro logic to display the appropriate title depending on whether there is an end date*/
title "Donations of %sysfunc(propcase(&gender)) Employees Hired on or after &startdate ";
%end;
%else %do ;
where ep.employee_gender="%upcase(%substr(&gender,1,1))"
		and not ep.employee_term_date  and ep.employee_hire_date between "&startdate"d and "&enddate"d
		order by employee_id;
/*STEP 5. Use macro logic to display the appropriate title depending on whether there is an end date*/

title "Donations of %sysfunc(propcase(&gender)) Employees Hired between &startdate and &enddate";
%end ;

footnote %upcase(&syslast);
select * from &library..%sysfunc(propcase(&gender))%substr(&startdate,6);


quit;
title;
footnote;
%mend donate;


/*Open destination device, set no bookmarks to be generated per the output*/
ods pdf file=pdfdev bookmarkgen=no ;

/*STEP 6. Call your new donations macro specifying only January 1, 2004 as the start date.*/
%donate(01Jan2004); 

/*STEP 7. Call the macro again specifying parameters to produce a report for Male employees hired
between January 1, 2000 and December 31, 2006.*/
%donate(01Jan2000, 31Dec2006,gender=Male);

/*STEP 8. Use PROC SQL to create a table with columns seed, school,
region, player, ppg, and rpg from ncaam06 with only schools that have 5 or more players listed
in the dataset.*/

proc sql; 

create table ncaam06temp 
as
select seed, school,
region, player, ppg,rpg from 
srcdata.ncaam06 
where school in (select school from srcdata.ncaam06 
group by school 
having count(*) >=5 )
;
quit;

/* STEP 9. Create a data driven macro to print the report */

%macro printrep(dsname);

/*STEP 9a. Create a data set containing an unduplicated list of the regions.*/

proc sort data= &dsname
out=work.dregions nodupkey;
by region;
run;

/*STEP 9b Use a data step to create macro variables for each region and the total number of
regions.*/
data _null_ ; 
set work.dregions end=eof;
call symputx(cats('region',_n_),region);
if eof then do; 
 call symputx(cats('tregion'),_n_);
end;
run;

/*STEP 9c. use a loop to iteratively process the report procedure once for each of
the regions in the data.*/

%do i=1 %to &tregion;

proc report data=&dsname nowd;
where region="&&Region&i";
columns ("Region = %upcase(&&Region&i)" seed school ppg rpg);
define seed /group 'Seed';
define school /group 'Team';
define ppg /mean format=8.1 'Average Points';
define rpg /mean format=8.1 'Average Rebounds';
run;

%end;

%mend printrep;

/*Invoke the macro*/
%printrep(ncaam06temp);

/*House keeping. Resetting defaults*/
title;
footnote;
option nomprint nosymbolgen nomlogic mcompilenote=none nodate;

/**Close the device*/
ods pdf close; 


