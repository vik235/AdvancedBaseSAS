*STEP 1 ;
/****************************************************************************************************************************/
/*1. Program Name:Vivek235_HW03_Program.sas																						*/
/* Program Location: C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment03\Assignment\Vivek235_HW03_Program.sas		*/
/* Date Created: 1/23/17																									*/							
/* Author: Vivek Kumar Gupta																								*/
/* Purpose:	Utilize skills learnt through SATs 604 course/Base SAS Programmer and practice lectures 01-04 of STAT 657.						*/
/****************************************************************************************************************************/

*STEP 1 ;
*1.Create the necessary library references for data sources and destination and file references for output ;
libname orion  'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\SQL Files' access=readonly;
libname Unicorn  'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment03\SourceData' access=readonly;
libname output  'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment03\PermUserLibrary' ;

filename pdfdevA 'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment03\PermUserLibrary\Vivek235_HW03_OutputA.pdf';
filename pdfdevB 'C:\Users\vigupta\OneDrive\Learning\DataScience\Statistics Texas A&M University\657\Homework\Assignment03\PermUserLibrary\Vivek235_HW03_OutputB.pdf';

option date dtreset; 


/*STEP 2. Create two user-defined formats that can be used to enhance the way values are displayed.*/

proc format ;
value $gender 'm'='Male'
			  'M'='Male'
			  'f'='Female'
			  'F'='Female'
			  other='Unknown.';
run; 

proc format; 
value salary low-26000 ='Very Low'
			 26000<-50000='Low'	
			 50000<-75000='Medium'
			 75000<-100000='High'
			 100000<-high='Very High';
run; 

/* STEP 3. Write a PROC step that will send a listing of all the available styles to the default output destination.*/

proc template ;
list styles;
run;

/*STEP 4. Close all open ODS destinations*/
ods _ALL_ close; 



/*STEP 4. Open two PDF destinations to capture the output from the procedures that follow.
Do not apply a style to the first output destination and use an option that will prevent it from creating
the table of contents/bookmarks. Use a similar name for the second PDF file except end the name with
outputB. Apply the FancyPrinter style to the second ODS PDF output. Create the PDF bookmarks on the second
PDF file but do not show them by default.*/
ods pdf (ID=OutputA)file = pdfdevA  bookmarkgen=no; 
ods pdf (ID=OutputB)file = pdfdevB style=FancyPrinter  bookmarklist=hide ; 

/*STEP 5. Run a procedure to list all of the data sets in the Orion data library without showing the details of each data set.*/

title"Data Sets Available from Orion";
title3"For Use by Acquisition Group";
footnote"Note: This output is being sent to two separate documents.";

proc contents data=orion._all_ nods ;
run;

/*STEP 6. Turn off the printing of the date at the top of the page for the remainder of the output.*/
option nodate;

/*STEP 7. Run a procedure that will print the descriptor portion of the Unicornstaff data set downloaded from eCampus.*/
title"Analysis of Unicorn Athletics Staff List";
title2"Layout of Data Recovered from CEO's Laptop";
proc contents data=unicorn.unicornstaff ;
run;


/*STEP 8. Close the outputA destination so that it only contains the output of the two procedures executed above.*/
ods pdf (ID=OutputA) close ;

title"Analysis of Unicorn Athletics Staff List";
title3"Unicorn Employees Still Working";
footnote;

/*STEP 9. Print a subset of the data portion of the Unicornstaff as instructed*/
proc print data=unicorn.unicornstaff noobs ;
 var Emp_ID 
	Hire_dt 
	Job_Title 
	Salary
	Gender;
	where TrueUnicorn='Yes' and  missing(Term_Dt);
	format Gender $gender. 
			Salary salary.
			Hire_Dt ddmmyy10.; 
run;

/*STEP 10. Close second pdf and do regular houskeeping*/
ods pdf (ID=OutputB) close ;
title;
option date dtreset;



