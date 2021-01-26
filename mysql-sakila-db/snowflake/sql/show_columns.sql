SELECT table_schema
	,table_name
	,ordinal_position AS position
	,column_name
	,data_type
	,CASE 
		WHEN character_maximum_length IS NOT NULL
			THEN character_maximum_length
		ELSE numeric_precision
		END AS max_length
	,is_nullable
	,column_default AS default_value
FROM information_schema.columns
WHERE table_schema IN ('RAW') -- put your schema name here
	AND table_name LIKE 'SAKILA_%' -- put your table name here
ORDER BY table_schema, table_name, ordinal_position;
