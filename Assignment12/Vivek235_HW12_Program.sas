*STEP 0 ;
/*1. Program Name:Vivek235_HW12_Program.sas.																						*/
/* Program Location: C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment12\Vivek235_HW12_Program.sas		*/
/* Date Created: 4/17/17																									*/							
/* Author: Vivek Kumar Gupta																								*/
/* Purpose:This assignment covers concepts presented in all lectures through Lecture 20;			*/
/****************************************************************************************************************************/

libname orion 'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\SQL Files' access=readonly;
libname srcdata 'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment04\SourceData' access=readonly;
filename pdfdev 'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment12\Vivek235_HW12_Output.pdf';

/*STEP 1. Use PROC SQL to create a table with columns seed, school, region, player, ppg, and rpg from ncaam06 with
only schools that have 5 or more players listed in the dataset.*/
option mprint symbolgen mlogic mcompilenote=all date nonumber; 
ods escapechar ='^';

ods pdf file=pdfdev  bookmarkgen=no;

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

/* STEP 2. Create a data driven macro to print the report */

%macro printrep(dsname);

/*STEP 2a. Create a table containing an unduplicated list of the regions..*/

proc sql noprint ;

create table dregions
as 
select distinct region 
from work.ncaam06temp;

/*STEP 2b. Assign a macro variable containing the number of regions from the sqlobs macro value.*/
%let tregions=&sqlobs; 

/*STEP 2c. Create macro variables for each region.*/
select region into :region1-:region&tregions
from dregions;

reset print number;
/*STEP 2d. Replace the report procedure from the last assignment with an SQL statement that
outputs the data exactly as shown in the PDF posted on eCampus.*/

/*STEP 2e. Use a loop to iteratively process the SQL statement once for each of the regions in the
data. */

%do i=1 %to &tregions;
title "Team Statistics for the &&Region&i Region";
select school as Team, 
avg(ppg) as avgppg label 'Average Points' format 8.1,
avg(rpg) as avgrpg  label 'Average Rebounds' format 8.1
from &dsname 
where region="&&Region&i"
group by school,seed
order by seed;

%end;

quit;

title;
footnote;

%mend printrep;

/*STEP 2f. Call the macro supplying the name of the dataset created in step 1.*/
%printrep(ncaam06temp);


/*STEP 3. Use an SQL procedure to create a report of the top 20 players with the highest number of points
from the ncaam06 dataset as shown on page 5 of the posted output.*/

title "Top 20 Scorers";
proc sql outobs=20; 

select player as Name, 
	ppg label "Points", 
	school as Team, 
	Region, 
	seed as Seed
from srcdata.ncaam06 
order by ppg desc;
quit;


/*STEP 4. Create a macro to report on the rebounders from the ncaam06 dataset, subset by a selected
region and greater than or equal to a selected minimum number of rebounds per game (rpg).
This macro will have a positional parameter for the region and a keyword parameter for number
of rebounds with a default value of 7.*/

%macro rebounders(region, nrebounds=7);

/*STEP 4a. Use a macro function to transform the region parameter so that you can enter it in
upper, lower, or mixed case and still get the appropriate results.*/
%let region=%upcase(&region);

/*STEP 4b. Use a data step to create in the work library a table that is a subset of ncaam06 based
on the two macro parameters.*/
data rebounders ;
set srcdata.ncaam06;
where upcase(region)="&region" and rpg >=&nrebounds;


/*STEP 4c. Use an SQL statement to read the number of observations in your new table from the
appropriate SASHELP view and place this number in a macro variable.*/
proc sql noprint;

select nobs into :rebobs
from sashelp.vtable 
where libname='WORK'
and memname='REBOUNDERS'
and memtype='DATA' ;

/*STEP 4d. Use macro logic to print a line of text on a new page if there are no records found using
the parameters you supplied to the macro.*/

ods pdf startpage=now;
title "Players from the &region Region Averaging &nrebounds or More Rebounds Per Game";

%if &rebobs=0 %then %do;
ods pdf text="No players from &region average &nrebounds or more rebounds per game.";
%end;

/*STEP 4e. If records are found use an SQL statement to produce the output as shown on page 7 of
the posted output. Make sure all rebounds per game values display one decimal place.*/

%else %do;
reset print number;

select player label "Name",
	avg(rpg)as avgrpg format 5.1 label "Rebounds",
	school label "Team",
	seed label "Seed"
from rebounders
group by player, school, seed 
order by avgrpg desc;

%end;
quit; 

title;
footnote;

%mend rebounders;

/*STEP 4f. Call the macro using wdc as the region and 10 as the rebounding threshold.*/
%rebounders(wdc,nrebounds=10);

/*STEP 4g. Call the macro again specifying only ATL as the region.*/
%rebounders(ATL);

/*House keeping. Resetting defaults*/
title;
footnote;
option nomprint nosymbolgen nomlogic mcompilenote=none nodate;

/**Close the device*/
ods pdf close; 



proc sql;

select * from ncaam06temp;

quit;

