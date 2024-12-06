use insurance

INSERT INTO dbo.JUNK
SELECT k 
FROM 
	  (
		VALUES 
			  ('yes')
			, ('no')
			, ('pending')
	  )
	AS IsAccepted(k);