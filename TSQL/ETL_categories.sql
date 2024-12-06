USE insurance
GO

If (object_id('vETLCategoriesData') is not null) Drop View vETLCategoriesData;
go
CREATE VIEW vETLCategoriesData
AS
SELECT DISTINCT
	PolicyType as CategoryName
FROM InsuranceDB.dbo.POLICY;
go

MERGE INTO Category as TT
	USING vETLCategoriesData as ST
		ON TT.CategoryName = ST.CategoryName
			WHEN Not Matched
				THEN
					INSERT
					Values (
					ST.CategoryName
					)
			WHEN Not Matched By Source
				Then
					DELETE
			;

Drop View vETLCategoriesData;