-- Set query results to text


-- SCRIPT NAME: GetEnvironmentVariableListTVC.sql
-- Get the list of environment variables for an environment
-- in a particular folder in the format of a table value
-- constructor

DECLARE @FOLDER_NAME NVARCHAR(128) = N'CRM';
DECLARE @SOURCE_ENVIRONMENT NVARCHAR(128) = N'DEV';

SELECT ',(' +
    '''' + v.[name] + '''' + ',' +
    '''' + CONVERT(NVARCHAR(1024),ISNULL(v.[value], N'<VALUE GOES HERE>')) + 
	''''  + ',' +
    '''' + v.[description] + '''' +
    ')' ENVIRONMENT_VARIABLES
FROM [SSISDB].[catalog].[environments] e
JOIN [SSISDB].[catalog].[folders] f
	ON e.[folder_id] = f.[folder_id]
JOIN [SSISDB].[catalog].[environment_variables] v
	ON e.[environment_id] = v.[environment_id]
WHERE e.[name] = @SOURCE_ENVIRONMENT
AND f.[name] = @FOLDER_NAME
ORDER BY v.[name];

-- take the output from above and paste it into
-- the statement below
SELECT [name], [value], [description]
FROM (
  VALUES
  --
  -- PASTE the TVC from GetEnvironmentVariableListTVC.sql HERE
	('CRM_ExportPath','C:\OUTBOUND','Path to export CSV files')
  ,	('CRM_ServerName','localhost','CRM database server name')
  --
) AS v([name], [value], [description]);
