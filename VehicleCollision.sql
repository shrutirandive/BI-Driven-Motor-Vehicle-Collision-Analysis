/*
 * ER/Studio Data Architect SQL Code Generation
 * Project :      DimensionalModel.DM1
 *
 * Date Created : Saturday, April 13, 2024 20:03:48
 * Target DBMS : Microsoft SQL Server 2019
 */

/* 
 * TABLE: dim_Contributing_Fator 
 */

CREATE TABLE dim_Contributing_Fator(
    crash_sk                    varchar(10)    NOT NULL,
    contributing_factor_code    varchar(10)    NULL,
    contributing_fator_name     varchar(10)    NULL,
    start_date                  datetime       NULL,
    end_date                    datetime       NULL,
    is_active                   binary(10)     NULL,
    version                     varchar(10)    NULL,
    DI_create_date              datetime       NULL,
    DI_process_id               varchar(10)    NULL,
    DI_workflow_name            varchar(10)    NULL,
    CONSTRAINT PK3 PRIMARY KEY NONCLUSTERED (crash_sk)
)

go


IF OBJECT_ID('dim_Contributing_Fator') IS NOT NULL
    PRINT '<<< CREATED TABLE dim_Contributing_Fator >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE dim_Contributing_Fator >>>'
go

/* 
 * TABLE: dim_Date 
 */

CREATE TABLE dim_Date(
    date_sk             varchar(10)    NOT NULL,
    date                datetime       NULL,
    day                 int            NULL,
    day_str             varchar(10)    NULL,
    day_of_week         varchar(10)    NULL,
    month               int            NULL,
    month_str           varchar(10)    NULL,
    quater              varchar(10)    NULL,
    year                varchar(18)    NULL,
    is_weekend          varchar(10)    NULL,
    season              varchar(10)    NULL,
    DI_create_date      datetime       NULL,
    DI_process_id       varchar(10)    NULL,
    DI_workflow_name    varchar(10)    NULL,
    CONSTRAINT PK1 PRIMARY KEY NONCLUSTERED (date_sk)
)

go


IF OBJECT_ID('dim_Date') IS NOT NULL
    PRINT '<<< CREATED TABLE dim_Date >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE dim_Date >>>'
go

/* 
 * TABLE: dim_Location 
 */

CREATE TABLE dim_Location(
    street_sk           varchar(10)    NOT NULL,
    latitude            varchar(10)    NULL,
    longitude           varchar(10)    NULL,
    street_number       int            NULL,
    street_name         varchar(10)    NULL,
    DI_create_date      datetime       NULL,
    DI_ProcessID        varchar(10)    NULL,
    DI_workflow_name    varchar(10)    NULL,
    CONSTRAINT PK2 PRIMARY KEY NONCLUSTERED (street_sk)
)

go


IF OBJECT_ID('dim_Location') IS NOT NULL
    PRINT '<<< CREATED TABLE dim_Location >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE dim_Location >>>'
go

/* 
 * TABLE: dim_Source 
 */

CREATE TABLE dim_Source(
    source_sk           varchar(10)    NOT NULL,
    source_name         varchar(10)    NULL,
    DI_create_date      datetime       NULL,
    DI_process_id       varchar(10)    NULL,
    DI_workflow_name    varchar(10)    NULL,
    CONSTRAINT PK12 PRIMARY KEY NONCLUSTERED (source_sk)
)

go


IF OBJECT_ID('dim_Source') IS NOT NULL
    PRINT '<<< CREATED TABLE dim_Source >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE dim_Source >>>'
go

/* 
 * TABLE: dim_Time 
 */

CREATE TABLE dim_Time(
    time_sk           varchar(10)    NOT NULL,
    time_value        varchar(10)    NULL,
    [12_hr]           varchar(18)    NULL,
    DI_create_date    datetime       NULL,
    DI_process_id     varchar(10)    NULL,
    CONSTRAINT PK9 PRIMARY KEY NONCLUSTERED (time_sk)
)

go


IF OBJECT_ID('dim_Time') IS NOT NULL
    PRINT '<<< CREATED TABLE dim_Time >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE dim_Time >>>'
go

/* 
 * TABLE: dim_Units 
 */

CREATE TABLE dim_Units(
    units_sk            varchar(10)    NOT NULL,
    units_involved      varchar(10)    NULL,
    DI_create_date      datetime       NULL,
    DI_process_id       varchar(10)    NULL,
    DI_workflow_name    varchar(10)    NULL,
    CONSTRAINT PK5 PRIMARY KEY NONCLUSTERED (units_sk)
)

go


IF OBJECT_ID('dim_Units') IS NOT NULL
    PRINT '<<< CREATED TABLE dim_Units >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE dim_Units >>>'
go

/* 
 * TABLE: fct_Collision_Contributing_Fator 
 */

CREATE TABLE fct_Collision_Contributing_Fator(
    collision_contrib_fctr_sk    varchar(10)    NOT NULL,
    crash_sk                     varchar(10)    NOT NULL,
    vehicle_collision_sk         varchar(10)    NOT NULL,
    DI_create_date               datetime       NULL,
    DI_process_id                varchar(10)    NULL,
    CONSTRAINT PK7 PRIMARY KEY NONCLUSTERED (collision_contrib_fctr_sk, crash_sk, vehicle_collision_sk)
)

go


IF OBJECT_ID('fct_Collision_Contributing_Fator') IS NOT NULL
    PRINT '<<< CREATED TABLE fct_Collision_Contributing_Fator >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE fct_Collision_Contributing_Fator >>>'
go

/* 
 * TABLE: fct_Collision_Units 
 */

CREATE TABLE fct_Collision_Units(
    collision_units_sk      varchar(10)    NOT NULL,
    units_sk                varchar(10)    NOT NULL,
    vehicle_collision_sk    varchar(10)    NOT NULL,
    unit_count              int            NULL,
    DI_create_date          datetime       NULL,
    DI_process_id           varchar(10)    NULL,
    CONSTRAINT PK11 PRIMARY KEY NONCLUSTERED (collision_units_sk, units_sk, vehicle_collision_sk)
)

go


IF OBJECT_ID('fct_Collision_Units') IS NOT NULL
    PRINT '<<< CREATED TABLE fct_Collision_Units >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE fct_Collision_Units >>>'
go

/* 
 * TABLE: fct_Vehicle_Collision 
 */

CREATE TABLE fct_Vehicle_Collision(
    vehicle_collision_sk    varchar(10)    NOT NULL,
    source_sk               varchar(10)    NOT NULL,
    street_sk               varchar(10)    NULL,
    date_sk                 varchar(10)    NOT NULL,
    time_sk                 varchar(10)    NOT NULL,
    crash_id                varchar(10)    NOT NULL,
    pedestrians_injured     int            NULL,
    pedestrians_killed      int            NULL,
    motorist_injured        int            NULL,
    mototrist_killed        int            NULL,
    cyclist_injured         int            NULL,
    cyclist_killed          int            NULL,
    fatal_count             int            NULL,
    injury_count            int            NULL,
    unknow_injury_count     varchar(10)    NULL,
    DI_create_date          datetime       NULL,
    DI_process_id           varchar(10)    NULL,
    CONSTRAINT PK4 PRIMARY KEY NONCLUSTERED (vehicle_collision_sk)
)

go


IF OBJECT_ID('fct_Vehicle_Collision') IS NOT NULL
    PRINT '<<< CREATED TABLE fct_Vehicle_Collision >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE fct_Vehicle_Collision >>>'
go

/* 
 * TABLE: fct_Collision_Contributing_Fator 
 */

ALTER TABLE fct_Collision_Contributing_Fator ADD CONSTRAINT Refdim_Contributing_Fator36 
    FOREIGN KEY (crash_sk)
    REFERENCES dim_Contributing_Fator(crash_sk)
go

ALTER TABLE fct_Collision_Contributing_Fator ADD CONSTRAINT Reffct_Vehicle_Collision37 
    FOREIGN KEY (vehicle_collision_sk)
    REFERENCES fct_Vehicle_Collision(vehicle_collision_sk)
go


/* 
 * TABLE: fct_Collision_Units 
 */

ALTER TABLE fct_Collision_Units ADD CONSTRAINT Refdim_Units34 
    FOREIGN KEY (units_sk)
    REFERENCES dim_Units(units_sk)
go

ALTER TABLE fct_Collision_Units ADD CONSTRAINT Reffct_Vehicle_Collision35 
    FOREIGN KEY (vehicle_collision_sk)
    REFERENCES fct_Vehicle_Collision(vehicle_collision_sk)
go


/* 
 * TABLE: fct_Vehicle_Collision 
 */

ALTER TABLE fct_Vehicle_Collision ADD CONSTRAINT Refdim_Date5 
    FOREIGN KEY (date_sk)
    REFERENCES dim_Date(date_sk)
go

ALTER TABLE fct_Vehicle_Collision ADD CONSTRAINT Refdim_Location22 
    FOREIGN KEY (street_sk)
    REFERENCES dim_Location(street_sk)
go

ALTER TABLE fct_Vehicle_Collision ADD CONSTRAINT Refdim_Time29 
    FOREIGN KEY (time_sk)
    REFERENCES dim_Time(time_sk)
go

ALTER TABLE fct_Vehicle_Collision ADD CONSTRAINT Refdim_Source38 
    FOREIGN KEY (source_sk)
    REFERENCES dim_Source(source_sk)
go


 
TRUNCATE TABLE [Vehicle Collision].[dbo].[stg_austin_collision]
TRUNCATE TABLE [Vehicle Collision].[dbo].[stg_chicago_collision]
TRUNCATE TABLE [Vehicle Collision].[dbo].[stg_newyork_collision]

--transformation table
TRUNCATE TABLE [Vehicle Collision].[dbo].[austin_transformation]
TRUNCATE TABLE [Vehicle Collision].[dbo].[chicago_transformation]
TRUNCATE TABLE [Vehicle Collision].[dbo].[newyork_transformation]

--contributing factor transformation
TRUNCATE TABLE [Vehicle Collision].[dbo].[austin_contribution_factor]
TRUNCATE TABLE [Vehicle Collision].[dbo].[chicago_contribution_factor]
TRUNCATE TABLE [Vehicle Collision].[dbo].[newyork_contribution_factor]

-- dimension tables
TRUNCATE TABLE [Vehicle Collision].[dbo].[dim_Location]
TRUNCATE TABLE [Vehicle Collision].[dbo].[dim_Units]
TRUNCATE TABLE [Vehicle Collision].[dbo].[dim_Date]
TRUNCATE TABLE [Vehicle Collision].[dbo].[dim_Time]
TRUNCATE TABLE [Vehicle Collision].[dbo].[dim_Source]

--fact tables
TRUNCATE TABLE [Vehicle Collision].[dbo].[fct_Vehicle_Collision]
TRUNCATE TABLE [Vehicle Collision].[dbo].[fct_Collision_Units]
TRUNCATE TABLE [Vehicle Collision].[dbo].[fct_Collision_Contributing_Factor]