USE master;
GO

-- Zmienna dla docelowej bazy danych
DECLARE @DatabaseName NVARCHAR(100) = 'insurance';

-- Deklaracja zmiennej dla dynamicznego SQL
DECLARE @Sql NVARCHAR(MAX) = '';

-- Budowanie polecenia KILL dla każdego SPID związanego z bazą danych
SELECT @Sql = @Sql + 'KILL ' + CAST(spid AS NVARCHAR) + '; '
FROM sys.sysprocesses
WHERE dbid = DB_ID(@DatabaseName);

-- Wyświetlenie dynamicznego SQL do weryfikacji (opcjonalne)
PRINT @Sql;

-- Wykonanie dynamicznego SQL
EXEC sp_executesql @Sql;
GO
