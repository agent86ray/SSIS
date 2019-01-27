-- get the CRM folder details
SELECT [folder_id], [name], [description] 
FROM [catalog].[folders]
WHERE [name] = N'CRM';


-- what SSIS projects are in the CRM folder?
SELECT p.[project_id], p.[folder_id], p.[name] 
FROM [SSISDB].[catalog].[projects] p
JOIN [SSISDB].[catalog].[folders] f
	ON p.[folder_id] = f.[folder_id]
WHERE f.[name] = N'CRM';


-- what environments are referenced in the CRM folder?
SELECT e.[environment_id], e.[folder_id], e.[name] 
FROM [SSISDB].[catalog].[folders] f
JOIN [SSISDB].[catalog].[environments] e
	ON e.[folder_id] = f.[folder_id] 
WHERE f.[name] = N'CRM';


-- what environment variables are in the DEV environment?
SELECT v.[variable_id], v.[name], v.[type], v.[value], v.[description]
FROM [SSISDB].[catalog].[environments] e
JOIN [SSISDB].[catalog].[folders] f
	ON f.[folder_id] = e.[folder_id]
JOIN [SSISDB].[catalog].[environment_variables] v
	ON e.[environment_id] = v.[environment_id]
WHERE f.[name] = N'CRM'
AND e.[name] = N'DEV'




SELECT * FROM [catalog].[folders]

SELECT * FROM [SSISDB].[catalog].[projects]

SELECT * FROM [SSISDB].[catalog].[environments]

SELECT * FROM [SSISDB].[catalog].[environment_variables]


