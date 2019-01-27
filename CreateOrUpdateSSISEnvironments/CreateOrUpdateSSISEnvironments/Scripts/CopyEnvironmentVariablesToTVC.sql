-- SCRIPT NAME: CopyEnvironmentVariablesToTVC
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
