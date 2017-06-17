*STEP 1 ;
/****************************************************************************************************************************/
/*1. Program Name:Vivek235_HW05_Program.sas																						*/
/* Program Location: C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment05\Assignment\Vivek235_HW05_Program.sas		*/
/* Date Created: 2/8/17																									*/							
/* Author: Vivek Kumar Gupta																								*/
/* Purpose:	This assignment will primarily utilize, but is not limited to, techniques covered in the lectures 5 to 7.						*/
/****************************************************************************************************************************/

*STEP 1 ;
*1.Create the necessary library references for data sources and destination and file references for output. Turn off page numbering ;
libname ncaa  'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment05\SourceData' access=readonly;
filename pdfdev 'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment05\Vivek235_HW05_Output.pdf';

/*Add neccessary ODS statements and change options as needed by the program*/
option nonumber; 
ods pdf file= pdfdev startpage=no style =minimal;
ods escapechar= '^'; 

/* STEP 2. Write a complete PROC SQL step that will create a table, scoring04 as directed in substeps a,b,c */

proc sql ; 
	create table work.scoring03 as 
	select  player,team,region,ppg,avg(ppg) as avg_PPG_all label "Overall Average PPG"
	from ncaa.scholarship03
	where Seed_ not in (15, 16);

quit;

/*STEP 3.Use a SINGLE proc sql step to create the two reports shown in the output PDF posted on
eCampus. Please note ODS statements are declared at the beginning of the program*/	

/* STEP 3a,b,c,d :First part of the report*/
proc sql  ; 

title"Average Scholarships for State Schools";
select player, team  
		,sum(amt1,amt2,amt3,amt4,amt5,amt6,amt7,amt8,amt9,amt10) as Total_Scholarship label 'Total Scholarship' format dollar10.
		,max(amt1,amt2,amt3,amt4,amt5,amt6,amt7,amt8,amt9,amt10)as Max_Scholarship label 'Maximum Scholarship' format dollar10.
		,N(amt1,amt2,amt3,amt4,amt5,amt6,amt7,amt8,amt9,amt10)as Freq_Scholarship label 'Scholarships'
from ncaa.scholarship03
where find(team,'St',2)>0
group by player, team
having Freq_Scholarship>1
order by team,Total_Scholarship desc ;

/*Use the appropriate styles to align the text center to the report and rest the title for the second report*/
ods pdf text="^{style [textalign=c]}^{newline 2}2003 NCAA Team Scoring Analysis" ;
title"2003 NCAA Team Scoring Analysis";

/* STEP 4a,b,c,d,e :Second part of the report based on scoring03 dataset*/
select team
		, count(*) as Players
		, avg(ppg) as avg_ppg label 'Average PPG' format 5.1
		, avg(ppg)/avg_PPG_all as overall_avg label 'Team vs. Overall' format percent8.1
		, case 
			when  avg(ppg) > avg_PPG_all then 'Above Avg.'
			else 'Avg. or Below'
			end as ppg_level label 'PPG Level'
from work.scoring03
group by team,avg_PPG_all
having players >= 5
order by avg_ppg desc;
quit;

/*House keeping*/
title;
option number;

/*Close the ODS destination*/
ods pdf close;
