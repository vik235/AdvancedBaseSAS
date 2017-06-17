*STEP 0 ;
/****************************************************************************************************************************/
/*1. Program Name:Vivek235_HW08_Program.sas																						*/
/* Program Location: C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment08\Vivek235_HW08_Program.sas		*/
/* Date Created: 3/18/17																									*/							
/* Author: Vivek Kumar Gupta																								*/
/* Purpose:The objective of this assignment is to practice using outer joins and creating SQL views. It will also
reinforce the concepts of subqueries and inline views to create a complex query. All of the
information necessary to complete this assignment was covered by the end of Lecture 11.				*/
/****************************************************************************************************************************/

*STEP 0 - Setup of libraries and filerefs.  Use a filename statement to define the path to the PDF output file.;

*1.Create the necessary library references for data sources and destination and file references for output.;
libname mydata  'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment08\mydata' ;
filename pdfdev 'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment08\Vivek235_HW08_Output.pdf';

* Turn off page numbering and date printing to match the output formatting;
option nonumber nodate;

/*Open destination device, set no bookmarks to be generated per the output*/
ods pdf file=pdfdev bookmarkgen=no ;

/*STEP 1. Use a single PROC SQL statement to create a permanent and portable view in the library as directed in the instructions*/

proc sql ;
create view mydata.femdonors
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
where ep.employee_gender='F' 
		and not ep.employee_term_date
		and ep.employee_hire_date between '01Jan2006'd and '31Dec2006'd
order by employee_id
using libname orion 'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\SQL Files';
quit;

/*STEP 2. Use the CONTENTS procedure to display the contents of your permanent library without
showing the descriptor portion of each data set*/
proc contents data=mydata._all_ nods;
run; 

/*STEP 3. Run a second CONTENTS procedure to show the “descriptor portion” of the view created above.*/
proc contents data=mydata.femdonors;
run;

/*Add appropriate title*/
title "Donations by Active Female Employees Hired in 2006";

/*STEP 4. Run a SQL statement that writes the definition of the view to the SAS Log*/
proc sql ; 
describe view mydata.femdonors;
quit;

/*STEP 5. Use a SQL statement to access the view and print all the data returned by the view. Create a
footnote indicating the source as SQL.*/
footnote "Output from SQL";
proc sql ;
select  aed.employee_id
		,aed.employee_name
		,aed.salary
		,aed.qtr1
		,aed.qtr2 
		,aed.qtr3
		,aed.qtr4
		,aed.tot_donation
from mydata.femdonors as aed;

quit;

/*STEP 6.Use Proc Print to print the data returned by the view. Use a footnote to indicate source as Proc
Print.*/
footnote "Output from Proc Print";
proc print data=mydata.femdonors label noobs;
run;



/*Hosuse keeping. Resetting defaults*/
title;
footnote;
option number date; 

/**Close the device*/
ods pdf close; 
