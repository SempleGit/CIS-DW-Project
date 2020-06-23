--TotalFees Collected each year and quarterly totals.
Select	CalendarYear
		,CalendarQuarter
		,Sum(TotalFee) As TotalFees
From dbo.MovieRentalTransactionFact As F
Join dbo.TimeDim As T
On F.RentalDateID = T.TimeID
Group By Rollup(CalendarYear, CalendarQuarter);
Go

--TotalFees Collected each year and total for each quarter every year.
Select	CalendarYear
		,CalendarQuarter
		,Sum(TotalFee) As TotalFees
From dbo.MovieRentalTransactionFact As F
Join dbo.TimeDim As T
On F.RentalDateID = T.TimeID
where film_id is not null
Group By Cube(CalendarYear, CalendarQuarter);
Go

--Languages available
Select Distinct LanguageName
		,LanguageCode
From dbo.LanguageDim;
Go 

--Movies in the DW and their languages, total of movies in each language
Select M.MovieCopyID
		,Title
		,LanguageName
		,LanguageCode
		,Count(LanguageCode) Over(Partition By LanguageCode) As LanguageCount
From dbo.MovieCopyDim As M
Join dbo.MovieLanguageDim As ML
On M.MovieCopyID = ML.MovieCopyID
Join dbo.LanguageDim As L
On ML.LanguageID = L.LanguageID
--Where LanguageName = 'English'
--Where LanguageName = 'German'
--Where LanguageName = 'French'
--Where LanguageName = 'Spanish'
Order By M.MovieCopyID asc;
Go

--Most popular rentals (number of rentals) using Rank

With T As (
	Select 	
		Count(*) As NumberOfRentals
		,F.MovieCopyID
		,Title
	From dbo.MovieRentalTransactionFact As F
	Join dbo.MovieCopyDim As M
	On F.MovieCopyID = M.MovieCopyID
	Group By F.MovieCopyID, Title
	)

Select 	RANK() Over(Order By NumberOfRentals Desc) As Rank
		,DENSE_RANK() Over(Order By NumberOfRentals Desc) As DenseRank
		,NTILE(10) Over (Order By NumberOfRentals Desc) As Ntile
		,NumberOfRentals
		,MovieCopyID
		,Title
From T;
Go

--Json
With T As (
	Select 	
		Count(*) As NumberOfRentals
		,F.MovieCopyID
		,Title
	From dbo.MovieRentalTransactionFact As F
	Join dbo.MovieCopyDim As M
	On F.MovieCopyID = M.MovieCopyID
	Group By F.MovieCopyID, Title
	)

Select 	RANK() Over(Order By NumberOfRentals Desc) As Rank
		,DENSE_RANK() Over(Order By NumberOfRentals Desc) As DenseRank
		,NTILE(10) Over (Order By NumberOfRentals Desc) As Ntile
		,NumberOfRentals
		,MovieCopyID
		,Title
From T

For JSON Auto;
Go

--Ranked by highest sum total fees
Select	F.MovieCopyID	
		,MD.Title
		,Rank() Over(Order By Sum(TotalFee) Desc) As FeeRank
		,Sum(TotalFee) As SumTotalFee
		,Count(*) As TotalRentals
From dbo.MovieRentalTransactionFact As F
Join dbo.MovieCopyDim As MD
On F.MovieCopyID = MD.MovieCopyID
Group By F.MovieCopyID, MD.Title;
Go

--Ranked by highest sum total fees to XML with schema
Select	F.MovieCopyID	
		,MD.Title
		,Rank() Over(Order By Sum(TotalFee) Desc) As FeeRank
		,Sum(TotalFee) As SumTotalFee
		,Count(*) As TotalRentals
From dbo.MovieRentalTransactionFact As F
Join dbo.MovieCopyDim As MD
On F.MovieCopyID = MD.MovieCopyID
Group By F.MovieCopyID, MD.Title

For XML Auto, Elements, XMLSchema ('FeeRank');
Go
