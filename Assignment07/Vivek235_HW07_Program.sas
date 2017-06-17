*STEP 0 ;
/****************************************************************************************************************************/
/*1. Program Name:Vivek235_HW07_Program.sas																						*/
/* Program Location: C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment07\Assignment\Vivek235_HW07_Program.sas		*/
/* Date Created: 2/20/17																									*/							
/* Author: Vivek Kumar Gupta																								*/
/* Purpose:	This assignment will primarily utilize, but is not limited to, techniques covered in lectures 5 through
10. You will practicing the use of the SQL set operators but may need to use joins, subqueries,
and/or inline views in conjunction with the set operators in each of your SQL procedures.					*/
/****************************************************************************************************************************/

*STEP 0 - Setup of libraries and filerefs. Librefs to homework data must be protected with readonly access. Use a filename 
statement to define the path to the PDF output file.;

*1.Create the necessary library references for data sources and destination and file references for output. Turn off page numbering to match the output formatting;
libname ncaa  'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment04\SourceData' access=readonly;
filename pdfdev 'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment07\Vivek235_HW07_Output.pdf';
option nonumber;

/*Open destination device, set no bookmarks to be generated*/
ods pdf file=pdfdev bookmarkgen=no ;

/*STEP 1. Create a report that combines the 2003 and 2004 statistics of only those players who played in
both the 2003 and 2004 NCAA Championship tournaments. Use other specifications per the instructions.
Set no date option to match output*/

title "Players in Both 2003 and 2004 NCAA Championship Tournaments";

option nodate;

proc sql ;
select  year, team , seed_, player, ppg  from 
(select team ,player, seed_ , ppg, "2003" as Year 
from ncaa.ncaam03
union 
select team ,player, seed_ , ppg, "2004" as Year 
from ncaa.ncaam04)as temp
where player  in 
select player from 
(
select nc03.player , nc03.team from 
		ncaa.ncaam03 as nc03,
		ncaa.ncaam04 as nc04
		where nc03.team=nc04.team 
		and nc03.player=nc04.player
) as players 
order by player , ppg desc
;
quit; 

/*STEP 2. Create a report of teams who played in all three of the tournaments for which data were
provided.Use other specifications per the instructions. Use Intersect operator explicitly.
Set date option to match output*/

title"Comparison of Teams from 2003, 2004, and 2006 NCAA Championship Tournaments";
option date;


proc sql; 

select team , seed_ , AvgPPG format 8.1, year 
from 
(select team , seed_ , avg(ppg) as AvgPPG label 'Average Player PPG', "2003" as Year 
from ncaa.ncaam03
group by team , seed_
union 
select team , seed_ , avg(ppg), "2004" as Year 
from ncaa.ncaam04
group by team , seed_ 
union 
select school as Team , seed , avg(ppg), "2006" as Year 
from ncaa.ncaam06
group by team , seed ) as temp
where team in 
(
select team from ncaa.ncaam03 
intersect 
select team from ncaa.ncaam04 
intersect
select school as team from ncaa.ncaam06 
) 
order by team, year
;
quit;

/*Hosuse keeping. Resetting defaults*/
title;
option number date; 

/**Close the device*/
ods pdf close; 
