use insurance

INSERT INTO dbo.JUNK
SELECT k 
FROM 
	  (
		VALUES 
			  ('yes')
			, ('no')
	  )
	AS IsAccepted(k);

SELECT * FROM JUNK;
