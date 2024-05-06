--stage table
SELECT * FROM [Vehicle Collision].[dbo].[stg_austin_collision]
SELECT * FROM [Vehicle Collision].[dbo].[stg_chicago_collision]
SELECT count(*) FROM [Vehicle Collision].[dbo].[stg_newyork_collision]

--transformation table
SELECT * FROM [Vehicle Collision].[dbo].[austin_transformation]
SELECT * FROM [Vehicle Collision].[dbo].[chicago_transformation]
SELECT * FROM [Vehicle Collision].[dbo].[newyork_transformation]

--contributing factor transformation
SELECT * FROM [Vehicle Collision].[dbo].[austin_contribution_factor]
SELECT * FROM [Vehicle Collision].[dbo].[chicago_contribution_factor]
where crash_id='10'
SELECT * FROM [Vehicle Collision].[dbo].[newyork_contribution_factor]
where crash_id = '1'

-- dimension tables
SELECT * FROM [Vehicle Collision].[dbo].[dim_Location]
SELECT * FROM [Vehicle Collision].[dbo].[dim_Units]
SELECT * FROM [Vehicle Collision].[dbo].[dim_Date]
SELECT * FROM [Vehicle Collision].[dbo].[dim_Time]
SELECT * FROM [Vehicle Collision].[dbo].[dim_Source]

CREATE TABLE [Vehicle Collision].[dbo].[dim_Contributing_Factor](
	[contributing_factor_sk] [int] IDENTITY(1,1) NOT NULL,
	[contributing_factor_code] [varchar](150) NULL,
	[contributing_factor_name] [varchar](61) NULL,
	[scd_start] [datetime] NOT NULL,
	[scd_end] [datetime] NULL,
	[scd_version] [int] NOT NULL,
	[scd_active] [int] NOT NULL,
	[DI_create_date] [date] NOT NULL DEFAULT getdate(),
	[DI_process_id] [varchar](20) NULL,
	[DI_workflow_name] [varchar](8000) NULL,
) ON [PRIMARY]
GO

SELECT * FROM [Vehicle Collision].[dbo].[dim_Contributing_Factor]
where contributing_factor_code = 73
--fact tables
SELECT * FROM [Vehicle Collision].[dbo].[fct_Vehicle_Collision] where source_sk=3
SELECT * FROM [Vehicle Collision].[dbo].[fct_Collision_Units]

SELECT count(distinct fctCon.vehicle_collision_sk) FROM [Vehicle Collision].[dbo].[fct_Collision_Contributing_Factor] fctCon 
inner join [Vehicle Collision].[dbo].[fct_Vehicle_Collision] fctVeh
on fctCon.vehicle_collision_sk = fctVeh.vehicle_collision_sk
where fctVeh.source_sk=3


--sample queries
SELECT * FROM [Vehicle Collision].[dbo].[stg_austin_collision]
where crash_id = 18171935;
SELECT * FROM [Vehicle Collision].[dbo].[austin_transformation]
where crash_id = 14585261;
SELECT * FROM [Vehicle Collision].[dbo].[austin_contribution_factor]
where crash_id = 13823575;

SELECT * FROM [Vehicle Collision].[dbo].[stg_newyork_collision]
where collision_id = 3891214;
SELECT * FROM [Vehicle Collision].[dbo].[newyork_transformation]
where crash_id = 3986736;
SELECT * FROM [Vehicle Collision].[dbo].[newyork_contribution_factor]
where contributing_factor_name = 80
where crash_id = 3891214;

SELECT * FROM [Vehicle Collision].[dbo].[stg_chicago_collision]
where CRASH_RECORD_ID='060d8d00497f986f7184becaaf7d7012a9a10593aa55caaf318ce0f08e609a4ad9fe1f5b1585e1c00f4f3710a92acfe6e4ddd3b2e22bf1519131718fd876ff89';
SELECT * FROM [Vehicle Collision].[dbo].[chicago_transformation]
where crash_id='060d8d00497f986f7184becaaf7d7012a9a10593aa55caaf318ce0f08e609a4ad9fe1f5b1585e1c00f4f3710a92acfe6e4ddd3b2e22bf1519131718fd876ff89';

SELECT * FROM [Vehicle Collision].[dbo].[dim_Location]
where latitude='40.60352';
SELECT * FROM [Vehicle Collision].[dbo].[stg_newyork_collision]
where LATITUDE='4.060.352';


SELECT * FROM [Vehicle Collision].[dbo].[stg_austin_collision]
where crash_id = 18171935;

SELECT * FROM [Vehicle Collision].[dbo].[fct_Vehicle_Collision]
where crash_id='18171935'
SELECT * FROM [Vehicle Collision].[dbo].[fct_Collision_Units]
where vehicle_collision_sk=11579
SELECT * FROM [Vehicle Collision].[dbo].[fct_Collision_Contributing_Factor]
where vehicle_collision_sk=20

-------- BUSINESS REQUIREMENTS -------
--How many accidents occurred in NYC, Austin and Chicago
SELECT dSource.source_name, count(crash_id) as NumberOfAccidents
FROM 
	[Vehicle Collision].[dbo].[fct_Vehicle_Collision] fctVeh 
inner join 
	[Vehicle Collision].[dbo].[dim_Source] dSource
on 
	fctVeh.source_sk = dSource.source_sk
group by 
	dSource.source_name

--Which areas in the 3 cities had the greatest number of accidents
WITH AccidentRank AS (
    SELECT 
        dLocation.street_name, dLocation.latitude, dLocation.longitude,
        fctVeh.source_sk,
        COUNT(fctVeh.crash_id) AS accidents,
        ROW_NUMBER() OVER (PARTITION BY fctVeh.source_sk ORDER BY COUNT(fctVeh.crash_id) DESC) AS Rank
    FROM 
        [Vehicle Collision].[dbo].[fct_Vehicle_Collision] fctVeh
    INNER JOIN 
        [Vehicle Collision].[dbo].[dim_Location] dLocation
    ON 
        fctVeh.location_sk = dLocation.location_sk
    WHERE 
        dLocation.street_name IS NOT NULL 
        AND dLocation.street_name <> ''
    GROUP BY 
        dLocation.street_name, fctVeh.source_sk, dLocation.latitude, dLocation.longitude
)
SELECT 
    street_name, latitude, longitude,
    source_sk, 
    accidents
FROM 
    AccidentRank
WHERE 
    Rank <= 3
ORDER BY 
    source_sk, accidents DESC;

--How many accidents resulted in just injuries?
--overall
SELECT 
  COUNT(crash_id) AS AccidentsWithInjuries
FROM 
 [Vehicle Collision].[dbo].[fct_Vehicle_Collision]
WHERE 
  injury_count > 0 AND fatal_count = 0

--by city
WITH RankedAccidents AS (
    SELECT
        dSource.source_name,
        COUNT(fctVeh.crash_id) AS AccidentsWithInjuries,
        ROW_NUMBER() OVER (ORDER BY COUNT(fctVeh.crash_id) DESC) AS Rank
    FROM 
        [Vehicle Collision].[dbo].[fct_Vehicle_Collision] fctVeh
    INNER JOIN 
        [Vehicle Collision].[dbo].[dim_Source] dSource
    ON 
        fctVeh.source_sk = dSource.source_sk
    WHERE 
        fctVeh.injury_count > 0 
        AND fctVeh.fatal_count = 0
    GROUP BY 
        dSource.source_name
)
SELECT 
    source_name,
    AccidentsWithInjuries
FROM 
    RankedAccidents
ORDER BY 
    AccidentsWithInjuries DESC;

--How often are pedestrians involved in accidents
--by city
SELECT 
	dSource.source_name, COUNT(crash_id) AS PedestrainsInvolvedAccidents
FROM 
	[Vehicle Collision].[dbo].[fct_Vehicle_Collision] fctVeh 
INNER JOIN 
	[Vehicle Collision].[dbo].[dim_Source] dSource
ON 
	fctVeh.source_sk = dSource.source_sk
WHERE 
	fctVeh.pedestrians_injured > 0 OR fctVeh.pedestrians_killed > 0
GROUP BY 
	dSource.source_name;

		--overall
SELECT 
    COUNT(crash_id) AS TotalAccidents,
    SUM(pedestrians_injured) AS TotalPedestriansInjured,
    SUM(pedestrians_killed) AS TotalPedestriansKilled,
    (SUM(pedestrians_injured) + SUM(pedestrians_killed)) AS TotalPedestriansInvolved,
    CAST((SUM(pedestrians_injured) + SUM(pedestrians_killed)) AS DECIMAL) / COUNT(crash_id) AS PedestriansInvolvedPerAccident
FROM 
    [Vehicle Collision].[dbo].[fct_Vehicle_Collision]
WHERE 
    pedestrians_injured > 0 OR pedestrians_killed > 0;

	--by city
SELECT 
    dSource.source_sk,
    COUNT(fctVeh.crash_id) AS TotalAccidents,
    SUM(fctVeh.pedestrians_injured) AS TotalPedestriansInjured,
    SUM(fctVeh.pedestrians_killed) AS TotalPedestriansKilled,
    (SUM(fctVeh.pedestrians_injured) + SUM(fctVeh.pedestrians_killed)) AS TotalPedestriansInvolved,
    CAST((SUM(fctVeh.pedestrians_injured) + SUM(fctVeh.pedestrians_killed)) AS DECIMAL) / COUNT(fctVeh.crash_id) AS PedestriansInvolvedPerAccident
FROM 
    [Vehicle Collision].[dbo].[fct_Vehicle_Collision] fctVeh
INNER JOIN 
    [Vehicle Collision].[dbo].[dim_Source] dSource
ON 
    fctVeh.source_sk = dSource.source_sk
WHERE 
    fctVeh.pedestrians_injured > 0 OR fctVeh.pedestrians_killed > 0
GROUP BY 
    dSource.source_sk
ORDER BY
	TotalAccidents desc

--When do most accidents happen
SELECT dDate.season, count(crash_id) as accidents
FROM [Vehicle Collision].[dbo].[fct_Vehicle_Collision] fctVeh 
INNER JOIN [Vehicle Collision].[dbo].[dim_Date] dDate on fctVeh.date_sk=dDate.date_sk
group by dDate.season
order by accidents desc

--• How many motorists are injured or killed in accidents?
SELECT dSource.source_name, COUNT(crash_id) AS accidents
FROM [Vehicle Collision].[dbo].[fct_Vehicle_Collision] fctVeh 
INNER JOIN [Vehicle Collision].[dbo].[dim_Source] dSource
ON fctVeh.source_sk = dSource.source_sk
WHERE fctVeh.motorist_injured > 0 OR fctVeh.motorist_killed > 0
GROUP BY dSource.source_name;

--Which top 5 areas in 3 cities have the most fatal number of accidents?
WITH RankedFatalAccidents AS (
    SELECT
        dSource.source_name AS City,
		dLocation.street_name AS Area,
        SUM(fctVeh.fatal_count) AS TotalFatalAccidents,
        ROW_NUMBER() OVER (PARTITION BY dSource.source_name ORDER BY SUM(fctVeh.fatal_count) DESC) AS Rank
    FROM 
        [Vehicle Collision].[dbo].[fct_Vehicle_Collision] fctVeh 
    INNER JOIN 
        [Vehicle Collision].[dbo].[dim_Source] dSource ON fctVeh.source_sk = dSource.source_sk
    INNER JOIN 
        [Vehicle Collision].[dbo].[dim_Location] dLocation ON fctVeh.location_sk = dLocation.location_sk
	WHERE 
       LEN(LTRIM(RTRIM(dLocation.street_name))) > 0 
    GROUP BY 
        dSource.source_name, dLocation.street_name
)
SELECT 
    City,
	Area,
    TotalFatalAccidents
FROM 
    RankedFatalAccidents
WHERE 
    Rank <= 5
ORDER BY 
    City,
    TotalFatalAccidents DESC;

--Time based analysis of accidents
SELECT
	DS.source_name,
	DD.month_str,
	COUNT(*) AS NumberOfAccidents
FROM 
  [Vehicle Collision].[dbo].[fct_Vehicle_Collision] AS FVC
INNER JOIN 
	Dim_Time AS DT 
ON 
	FVC.time_sk = DT.Time_sk
INNER JOIN 
	Dim_Date AS DD 
ON 
	FVC.date_sk = DD.Date_sk
INNER JOIN
	dim_Source as DS
ON
	FVC.source_sk = DS.source_sk
GROUP BY
	DS.source_name, DD.month_str
ORDER BY
	DS.source_name, DD.month_str

--Time based analysis of accidents
SELECT
  DT.time_of_day,
  DT.time_of_period,
  DD.Day_str,
  CASE WHEN DD.is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS DayType,
  COUNT(*) AS NumberOfAccidents
FROM 
  [Vehicle Collision].[dbo].[fct_Vehicle_Collision] AS FVC
INNER JOIN Dim_Time AS DT ON FVC.time_sk = DT.Time_sk
INNER JOIN Dim_Date AS DD ON FVC.date_sk = DD.Date_sk
GROUP BY
  DT.time_of_day,
  DT.time_of_period,
  DD.Day_str,
  DD.is_weekend
ORDER BY
  NumberOfAccidents DESC;

--• Fatality analysis --Are pedestrians killed more often than road users?
SELECT 
  SUM(FVC.pedestrians_killed) AS TotalPedestrianFatalities,
  SUM(FVC.motorist_killed + FVC.cyclist_killed) AS TotalRoadUserFatalities
FROM 
  Fct_vehicle_collision AS FVC;

--common factors involved in accidents
SELECT 
	dim.contributing_factor_code, dim.contributing_factor_name, count(fct.vehicle_collision_sk) as accidents 
FROM 
	[Vehicle Collision].[dbo].[fct_Collision_Contributing_Factor] fct 
inner join 
	[Vehicle Collision].[dbo].[dim_Contributing_Factor] dim 
on
	fct.contributing_factor_sk =dim.contributing_factor_sk
group by dim.contributing_factor_code,dim.contributing_factor_name
order by accidents desc

--Vehicle involved in accidents
SELECT COUNT(*) AS Number_of_Vehicles_Greater_Than_2
FROM (
    SELECT
        vehicle_collision_sk,
        COUNT(vehicle_collision_sk) AS Number_of_Vehicles
    FROM 
        [Vehicle Collision].[dbo].[fct_Collision_Units]
    GROUP BY 
        vehicle_collision_sk
) AS CollisionCounts
WHERE Number_of_Vehicles > 2;


--vehicle count
SELECT dim.units_involved,  count(fctVeh.vehicle_collision_sk) as NumberOfVehicles
FROM
	[Vehicle Collision].[dbo].[fct_Vehicle_Collision] fctVeh
INNER JOIN 
	[Vehicle Collision].[dbo].[fct_Collision_Units] fctUnits 
ON 
	fctVeh.vehicle_collision_sk = fctUnits.vehicle_collision_sk
INNER JOIN 
	[Vehicle Collision].[dbo].[dim_Units] dim
on
	fctUnits.collision_units_sk = dim.units_sk
group by
	dim.units_involved
order by NumberOfVehicles desc

