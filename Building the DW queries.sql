--MovieDB to MovieCopyDim
Select G.MOVIE_GENRE_CODE
		,MOVIE_GENRE_DESCRIPTION
		,MOVIE_TITLE
		,YEAR_PRODUCED
		,MPAA_RATING_CODE
		,MOVIE_ID 
From dbo.MOVIE_GENRE As G
Join dbo.MOVIE As M
On G.MOVIE_GENRE_CODE = M.MOVIE_GENRE_CODE;

--Sakila to MovieCopyDim
Select name
		,title
		,release_year
		,rating
		,F.film_id
		,'sakila' As GenreDesc
From dbo.category As C
Join dbo.film_category As FC
On C.category_id = FC.category_id
Join dbo.film As F
on FC.film_id = F.film_id

--Update GenreCodes, random on some of these
Use MoviesSalesDW;
Go

Update dbo.MovieCopyDim
	Set GenreCode = 'ActAd'
	Where GenreCode is null And GenreName = 'Action';
Update dbo.MovieCopyDim
	Set GenreCode = 'Anime'
	Where GenreCode is null And GenreName = 'Animation';
Update dbo.MovieCopyDim
	Set GenreCode = 'ChFam'
	Where GenreCode is null And GenreName = 'Children' Or GenreName = 'Family';
Update dbo.MovieCopyDim
	Set GenreCode = 'Class'
	Where GenreCode is null And GenreName = 'Classics';
Update dbo.MovieCopyDim
	Set GenreCode = 'Comdy'
	Where GenreCode is null And GenreName = 'Comedy';
Update dbo.MovieCopyDim
	Set GenreCode = 'Doc'
	Where GenreCode is null And GenreName = 'Documentary';
Update dbo.MovieCopyDim
	Set GenreCode = 'Drama'
	Where GenreCode is null And GenreName = 'Drama';
Update dbo.MovieCopyDim
	Set GenreCode = 'Forgn'
	Where GenreCode is null And GenreName = 'Foreign';
Update dbo.MovieCopyDim
	Set GenreCode = 'Hor'
	Where GenreCode is null And GenreName = 'Horror';
Update dbo.MovieCopyDim
	Set GenreCode = 'Indep'
	Where GenreCode is null And GenreName = 'New';
Update dbo.MovieCopyDim
	Set GenreCode = 'Music'
	Where GenreCode is null And GenreName = 'Music';
Update dbo.MovieCopyDim
	Set GenreCode = 'SciFi'
	Where GenreCode is null And GenreName = 'Sci-Fi';
Update dbo.MovieCopyDim
	Set GenreCode = 'Specl'
	Where GenreCode is null And GenreName = 'Games' Or GenreName = 'Travel';
Update dbo.MovieCopyDim
	Set GenreCode = 'Sport'
	Where GenreCode is null And GenreName = 'Sports';

--MovieDB to the CustomerDim
Use Movie_Project;
Go

Select	P.PERSON_ID
		,PERSON_GIVEN_NAME
		,PERSON_MIDDLE_NAME
		,PERSON_FAMILY_NAME
		,PERSON_ADDRESS_1
		,PERSON_ADDRESS_2
		,PERSON_ADDRESS_CITY
		,PERSON_ADDRESS_STATE_PROV
		,PERSON_ADDRESS_POSTAL_CODE
		,PERSON_ADDRESS_COUNTRY
		,PERSON_PHONE
		,BIRTH_DATE
		,CUSTOMER_ACCOUNT_ID
From dbo.PERSON As P
Join dbo.CUSTOMER_ACCOUNT_PERSON As C
On P.PERSON_ID = C.PERSON_ID

--Remove duplicate persons
With D As (
	Select *
			,Row_Number() Over(Partition By Person_ID Order By Person_ID) As Row
	From dbo.CustomerDim
)

Delete From D
	Where Row > 1;

Go
	--Had to look this up, my solutions would delete all the rows that were duplicated.
	--https://www.sqlservertutorial.net/sql-server-basics/delete-duplicates-sql-server/

--Sakila to the CustomerDim

Select customer_id
		,first_name
		,last_name
		,address
		,address2
		,city
		,postal_code
		,phone
		,country

From dbo.customer As C
Join dbo.address As A
On C.address_id = A.address_id
Join dbo.city As Ct
On Ct.city_id = A.city_id
Join dbo.country As Cy
On Cy.country_id = Ct.country_id

--MovieDB to EmployeeDim
	Select HIRE_DATE
			,TERMINATION_DATE
			,P.PERSON_ID
			,PERSON_GIVEN_NAME
			,PERSON_MIDDLE_NAME
			,PERSON_FAMILY_NAME
			,PERSON_ADDRESS_1
			,PERSON_ADDRESS_2
			,PERSON_ADDRESS_CITY
			,PERSON_ADDRESS_STATE_PROV
			,PERSON_ADDRESS_POSTAL_CODE
			,PERSON_ADDRESS_COUNTRY
			,PERSON_PHONE
	From dbo.EMPLOYEE As E
	Join dbo.PERSON As P
	On E.Person_ID = P.PERSON_ID

--Update Active field

Update dbo.EmployeeDim Set Active = 1 Where TerminationDate is null;
Update dbo.EmployeeDim Set Active = 0 Where TerminationDate is not null;

--sakila to EmployeeDim
Select staff_id
		,first_name
		,last_name
		,active
		,address
		,address2
		,city
		,postal_code
		,phone
		,country

From dbo.staff As S
Join dbo.address As A
On S.address_id = A.address_id
Join dbo.city As Ct
Join dbo.country As Cy
On Cy.country_id = Ct.country_id
On Ct.city_id = A.city_id

--MovieDB to LanguageDim
Select MOVIE_ID
		,ML.LANGUAGE_CODE
		,LANGUAGE_NAME
From dbo.MOVIE_LANGUAGE As ML
Join dbo.LANGUAGE As L
On ML.LANGUAGE_CODE = L.LANGUAGE_CODE;
Go

--Sakila to LanguageDim
Select name
		,film_id
		,Case
			When name = 'English' Then 'en'
			Else 'na'
		End As LanguageCode
From dbo.language As L
Join dbo.film As F
On L.language_id = F.language_id;
Go

--English was the only language in the sakila DB, so didn't bother with the other cases.

--Populating the dbo.MovieLanguageDim table
Use MoviesSalesDW;
Go

Insert Into dbo.MovieLanguageDim (LanguageID, MovieCopyID)
	Select LanguageID
			,MovieCopyID
	From dbo.LanguageDim As LD
	Join dbo.MovieCopyDim As MD
	On LD.MOVIE_ID = MD.MOVIE_ID;
Go

Insert Into dbo.MovieLanguageDim (LanguageID, MovieCopyID)
	Select LanguageID
			,MovieCopyID
	From dbo.LanguageDim As LD
	Join dbo.MovieCopyDim As MD
	On LD.film_id = MD.film_id;
Go

--MovieDB to Fact

Select MOVIE_ID
		,Coalesce(RENTAL_FEE + LATE_OR_LOSS_FEE, Rental_Fee) As TotalFee
		,CUSTOMER_ACCOUNT_ID
		,EMPLOYEE_PERSON_ID As Emp_ID
		,TRANSACTION_DATE As RentalDate
		,Cast(format(TRANSACTION_DATE, 'yyyyMMdd') As Int) as castedRentalDate
From dbo.MOVIE_RENTAL As MR
Join dbo.CUSTOMER_TRANSACTION As CT
On MR.TRANSACTION_ID = CT.TRANSACTION_ID

Alter Table dbo.MovieRentalTransactionFact
	Alter column MovieCopyID int null;
Alter Table dbo.MovieRentalTransactionFact
	Alter column RentalDateID int null;
Alter Table dbo.MovieRentalTransactionFact
	Alter column CustomerID int null;
Alter Table dbo.MovieRentalTransactionFact
	Alter column EmployeeID int null;



--Populate Fact from MovieDB source with FK

Update dbo.MovieRentalTransactionFact
	Set MovieCopyID = MC.MovieCopyID
	,CustomerID = C.CustomerID
	,EmployeeID = E.EmployeeID

	From dbo.MovieCopyDim As MC
	Join dbo.MovieRentalTransactionFact As F
	On F.MOVIE_ID = MC.MOVIE_ID
	Join dbo.CustomerDim As C
	On F.CUSTOMER_ACCOUNT_ID = C.CUSTOMER_ACCOUNT_ID
	Join dbo.EmployeeDim As E
	On	F.PERSON_ID = E.PERSON_ID
Go

--sakila to Fact
--create temp table
Select	F.film_id
		,R.staff_id
		,amount As TotalFee
		,rental_date
		,R.customer_id As Customer_Account_ID
		,Cast(format(rental_date, 'yyyyMMdd') As Int) As RentalDateID
		,R.rental_id
Into ##sakilaFact
From dbo.film As F
Left Join dbo.inventory As I
On F.film_id = I.film_id
Left Join dbo.rental As R
On I.inventory_id = R.inventory_id
Left Join dbo.payment As P
On P.rental_id = R.rental_id

--Query for SSIS
Select MovieCopyID
		,RentalDateID
		,CustomerID
		,EmployeeID
		,TotalFee
		,s.Customer_Account_ID
		,s.film_id
		,s.staff_id
From ##sakilaFact As s
Left Join dbo.MovieCopyDim As MD
On s.film_id = MD.film_id
Left Join dbo.CustomerDim As CD
On s.Customer_Account_ID = CD.customer_id
Left Join dbo.EmployeeDim As ED
On s.staff_id = ED.staff_id;

--Update US to United States and CA to Canada
Update dbo.CustomerDim
Set CountryName = 'United States'
Where CountryName = 'US';
Go

Update dbo.CustomerDim
Set CountryName = 'Canada'
Where CountryName = 'CA';
Go


