--
-- SCRIPT NAME: GenerateEnvironmentTVC
--
-- Generate the table value constructor (TVC) of name/value pairs for an SSIS environment
--
-- Open SSMS, connect to the SSISDB database, and open this script in a new query window
-- Set query results to text to facilitate copy/paste
--
--
-- Edit the values as necessary, then copy/paste into CreateOrUdateSSISEnvironmentVariables
-- to insert/update variables into an SSIS environment
--
-- @SOURCE_ENVIRONMENT is the source environment to copy environment variable values from
-- set to a non-existent environment to generate table with empty
-- values
--
--

DECLARE @SOURCE_ENVIRONMENT NVARCHAR(128) = N'QA';

-- this is the master list of environment variables and their description
;WITH CTE_VARIABLE_LIST AS (

SELECT [name], [description]
FROM (
  VALUES
    ('SSIS_DEMO_ConnectionString','SSIS_DEMO database connection string')
   ,('PARAMETER NAME GOES HERE','parameter description goes here')
  ) AS ENVIRONMENT_VARIABLES ([name], [description])
)
,
-- name/value pairs for the @SOURCE_ENVIRONMENT
CTE_ENVIRONMENT_NAME_VALUE_PAIRS AS (
	SELECT v.name, v.value
	FROM [SSISDB].[catalog].[environment_variables] v
	JOIN [SSISDB].[catalog].[environments] e ON e.environment_id = v.environment_id
	WHERE e.name =  @SOURCE_ENVIRONMENT
)
,
CTE_VARIABLES_TVC AS (
	SELECT t.name, t.description, v.value
	FROM CTE_VARIABLE_LIST t
	LEFT JOIN CTE_ENVIRONMENT_NAME_VALUE_PAIRS v ON t.name = v.name
)

-- generate table value constructor (TVC) for [CreateOrUdateSSISEnvironmentVariables]; 
-- update values as necessary
SELECT ',(' +
    '''' + [name] + '''' + ',' +
    '''' + CONVERT(NVARCHAR(1024),ISNULL([value], N'<VALUE GOES HERE>')) + ''''  + ',' +
    '''' + [description] + '''' +
    ')'
FROM CTE_VARIABLES_TVC
ORDER BY [name];

