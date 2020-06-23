Create Database MoviesSalesDW;
Go

Use MoviesSalesDW;
Go

Drop Table if exists LanguageDim;
Go

Create Table LanguageDim (
	LanguageID int not null Identity (1000, 1)
		Constraint PK_LanguageDim Primary Key (LanguageID)
	,LanguageName varchar(45) not null
	,LanguageCode varchar(5) null
	--Key from MovieDB
	,MOVIE_ID int null
	--Key from Sakila
	,film_id int null
	);
Go

Drop Table if exists MovieCopyDim;
Go

Create Table MovieCopyDim (
	MovieCopyID int not null Identity (1000, 1)
		Constraint PK_MovieCopyDim Primary Key (MovieCopyID)
	,Title varchar(100)
	,MovieYear varchar(4) null
	,GenreCode varchar(45) null
	,Genrename varchar(45) null
	,GenreDescription varchar(45) not null
	,MPAARating varchar(10) not null
	--Key from MovieDB
	,MOVIE_ID int null
	--Key from Sakila
	,film_id int null
	);
Go

Drop Table if exists MovieLanguageDim;
Go

Create Table MovieLanguageDim (
	LanguageID int
		Foreign Key (LanguageID) References LanguageDim
	,MovieCopyID int
		Foreign Key (MovieCopyID) References MovieCopyDim
	);
Go

Drop Table if exists TimeDim;
Go

Create Table TimeDim (
	TimeID int not null
		Constraint PK_TimeDim Primary Key (TimeID)
	,FullDate Date not null
	,DayNumberOfMonth int not null
	,DayName varchar(10) not null
	,MonthNumber int not null
	,MonthName varchar(25) not null
	,CalendarQuarter int not null
	,CalendarYear int not null
	,WeekendFlag varchar(1) not null
	);
Go

Drop Table if exists CustomerDim;
Go

Create Table CustomerDim (
	CustomerID int not null Identity (1000, 1)
		Constraint PK_CustomerDim Primary Key (CustomerID)
	,FirstName varchar(45) not null
	,MiddleName varchar(45) null
	,LastName varchar(45) not null
	,Address1 varchar(45) null
	,Address2 varchar(45) null
	,CityName varchar(45)
	,StateProvName varchar(45)
	,PostalCode varchar(10)
	,CountryName varchar(45)
	,Phone varchar(20)
	,BirthDate Date
	--Keys from MovieDB
	,CUSTOMER_ACCOUNT_ID int null
	,PERSON_ID int null
	--Keys from Sakila
	,customer_id int null
	);

Drop Table if exists EmployeeDim;
Go

Create Table EmployeeDim (
	EmployeeID int not null Identity (1000, 1)
		Constraint PK_EmployeeDim Primary Key (EmployeeID)
	,HireDate Date null
	,TerminationDate Date null
	,Active bit null
	,FirstName varchar(45) not null
	,MiddleName varchar(45) null
	,LastName varchar(45) not null
	,Address1 varchar(45) null
	,Address2 varchar(45) null
	,CityName varchar(45)
	,StateProvName varchar(45)
	,PostalCode varchar(10)
	,CountryName varchar(45)
	,Phone varchar(20)
	--Keys from MovieDB
	,PERSON_ID int null
	--Keys from Sakila
	,staff_id int null
	);
Go

Drop Table if exists MovieRentalTransactionFact;
Go

Create Table MovieRentalTransactionFact (
	TransactionID int not null Identity (1000, 1)
		Constraint PK_MovieRentalTransactionFact Primary Key (TransactionID)
	,MovieCopyID int not null
		Foreign Key (MovieCopyID) references MovieCopyDim
	,RentalDateID int not null
		Foreign Key (RentalDateID) references TimeDim(TimeID)
	,CustomerID int not null
		Foreign Key (CustomerID) references CustomerDim
	,EmployeeID int not null
		Foreign Key (EmployeeID) references EmployeeDim
	,TotalFee Decimal(5,2) null
	--Key from MovieDB
	,MOVIE_ID int null
	,CUSTOMER_ACCOUNT_ID int null
	,PERSON_ID int null
	--Key from Sakila
	,film_id int null
	,staff_id int null
	);
Go


