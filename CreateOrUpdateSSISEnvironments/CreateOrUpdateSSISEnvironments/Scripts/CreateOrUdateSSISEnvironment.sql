-- SCRIPT NAME: CreateOrUdateSSISEnvironmentVariables
--
-- Insert or update environment variables into target environment
--
--
-- STEP 1: run CopyEnvironmentVariablesToTVC.sql to create the table value constructor
--         of all envirnment variables with their name, description and value for the
--         source folder and environment 
--
-- STEP 2: edit TVC as necessary; e.g. change values for connection strings, 
--         folders, UNC paths, etc.
--
-- STEP 3: copy and paste the TVC underneath the comment 
--         "PASTE the TVC from CopyEnvironmentVariablesToTVC HERE"
--
-- STEP 4: set value for @FOLDER_NAME and @TARGET_ENVIRONMENT_NAME below
--
-- STEP 5: execute this script
--
-- STEP 6: review the environment variables and values in SSMS
--

-- SCRIPT NAME: CreateOrUpdateSSISEnvironment
DECLARE
 @FOLDER_NAME				NVARCHAR(128) = N'CRM'
,@FOLDER_ID					BIGINT
,@TARGET_ENVIRONMENT_NAME	NVARCHAR(128) = N'UAT'
,@ENVIRONMENT_ID			INT
,@VARIABLE_NAME				NVARCHAR(128)
,@VARIABLE_VALUE			NVARCHAR(1024)
,@VARIABLE_DESCRIPTION		NVARCHAR(1024)

DECLARE @ENVIRONMENT_VARIABLES TABLE (
  [name] NVARCHAR(128)
, [value] NVARCHAR(1024)
, [description] NVARCHAR(1024)
);

INSERT @ENVIRONMENT_VARIABLES
SELECT [name], [value], [description]
FROM (
  VALUES
  --
  -- PASTE the TVC from CopyEnvironmentVariablesToTVC HERE
  --
  	 ('CRM_ExportPath','C:\OUTBOUND','Path to export CSV files')
	,('CRM_ServerName','localhost','CRM database server name')
  --
  --
) AS v([name], [value], [description]);


SELECT * FROM @ENVIRONMENT_VARIABLES;

-- create folder if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM [SSISDB].[catalog].[folders] WHERE name = @FOLDER_NAME)
    EXEC [SSISDB].[catalog].[create_folder] @folder_name=@FOLDER_NAME, @folder_id=@FOLDER_ID OUTPUT
ELSE
    SET @FOLDER_ID = (SELECT folder_id FROM [SSISDB].[catalog].[folders] WHERE name = @FOLDER_NAME)

PRINT @FOLDER_ID

-- create environment if it doesn't exist

IF NOT EXISTS (SELECT 1 FROM [SSISDB].[catalog].[environments] WHERE folder_id = @FOLDER_ID AND name = @TARGET_ENVIRONMENT_NAME)
    EXEC [SSISDB].[catalog].[create_environment] @environment_name=@TARGET_ENVIRONMENT_NAME, @folder_name=@FOLDER_NAME

-- get the environment id
SET @ENVIRONMENT_ID = (SELECT environment_id FROM [SSISDB].[catalog].[environments] WHERE folder_id = @FOLDER_ID and name = @TARGET_ENVIRONMENT_NAME)

PRINT @ENVIRONMENT_ID

-- iterate through the @ENVIRONMENT_VARIABLES table and insert or update
-- the environment; e.g. do a "merge"
SELECT TOP 1
 @VARIABLE_NAME = [name]
,@VARIABLE_VALUE = [value]
,@VARIABLE_DESCRIPTION = [description]
FROM @ENVIRONMENT_VARIABLES

WHILE @VARIABLE_NAME IS NOT NULL
BEGIN
	PRINT @VARIABLE_NAME

	 -- create environment variable if it doesn't exist
	IF NOT EXISTS (
		SELECT 1 FROM [SSISDB].[catalog].[environment_variables] 
		WHERE environment_id = @ENVIRONMENT_ID AND name = @VARIABLE_NAME
	)
		EXEC [SSISDB].[catalog].[create_environment_variable]
		  @variable_name=@VARIABLE_NAME
		, @sensitive=0
		, @description=@VARIABLE_DESCRIPTION
		, @environment_name=@TARGET_ENVIRONMENT_NAME
		, @folder_name=@FOLDER_NAME
		, @value=@VARIABLE_VALUE
		, @data_type=N'String'
	ELSE
	 -- update environment variable value if it exists
		EXEC [SSISDB].[catalog].[set_environment_variable_value]
		  @folder_name = @FOLDER_NAME
		, @environment_name = @TARGET_ENVIRONMENT_NAME
		, @variable_name = @VARIABLE_NAME
		, @value = @VARIABLE_VALUE

	DELETE TOP (1) FROM @ENVIRONMENT_VARIABLES

	SET @VARIABLE_NAME = null

	SELECT TOP 1
	  @VARIABLE_NAME = [name]
	 ,@VARIABLE_VALUE = [value]
	 ,@VARIABLE_DESCRIPTION = [description]
	 FROM @ENVIRONMENT_VARIABLES
END

