*STEP 0 ;
/*1. Program Name:donate.sas																						*/
/* Program Location: C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment10\donate.sas		*/
/* Date Created: 4/2/17																									*/							
/* Author: Vivek Kumar Gupta																								*/
/* Purpose:To list out donors based on input parameters	library,gender,startdate,enddate, Sample call: %donate(work, female, 01Jan1996, 31Dec2005);			*/
/****************************************************************************************************************************/
libname orion 'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\SQL Files' access=readonly;
libname srcdate 'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment04\SourceData' access=readonly;
filename pdfdev 'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment11\Vivek235_STATS657_HW11.pdf';

/*STEP 1. Create the macro as instructed*/
option mprint symbolgen mlogic mcompilenote=all date; 

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

%if &enddate = %then %do;
where ep.employee_gender="%upcase(%substr(&gender,1,1))"
		and not ep.employee_term_date and ep.employee_hire_date >= "&startdate"d 
		order by employee_id;
title "Donations of %sysfunc(propcase(&gender)) Employees Hired on or after &startdate ";
%end;
%else %do ;
where ep.employee_gender="%upcase(%substr(&gender,1,1))"
		and not ep.employee_term_date  and ep.employee_hire_date between "&startdate"d and "&enddate"d
		order by employee_id;
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

%donate(01Jan2004); 

%donate(01Jan2000, 31Dec2006,gender=Male);

proc sql; 

create table ncaam06temp 
as
select seed, school,
region, player, ppg,rpg from 
srcdate.ncaam06 
where school in (select school from srcdate.ncaam06 
group by school 
having count(*) >=5 )
;
quit;

proc sql ;

select count(distinct region) into:cregions 
from work.ncaam06temp;

select distinct region into:region1-:region%sysfunc(strip(&cregions))
from work.ncaam06temp;
quit ;


/*House keeping. Resetting defaults*/
title;
footnote;

/**Close the device*/
ods pdf close; 


