CREATE DATABASE IF NOT EXISTS listening_data;
use database listening_data;

CREATE or replace STAGE listening_stage
URL = 's3://sportifydata123'
CREDENTIALS = (AWS_KEY_ID = 'AKIA2CQ223ZV4IUU754T' AWS_SECRET_KEY = 'mLvmCkNI7CbY1Q1u0C5Tu5IPC4xjiAF0fXb/6mv7');
list @listening_stage;


CREATE FILE FORMAT my_csv_format
  TYPE = 'CSV';

CREATE SCHEMA staging_layer;
  
CREATE OR REPLACE TABLE staging_layer.main_table (
  Age VARCHAR(10),
    Gender VARCHAR(10),
    spotify_usage_period VARCHAR(50),
    spotify_listening_device VARCHAR(50),
    spotify_subscription_plan VARCHAR(50),
    premium_sub_willingness VARCHAR(30),
    preffered_premium_plan VARCHAR(50),
    preferred_listening_content VARCHAR(50),
    fav_music_genre VARCHAR(50),
    music_time_slot VARCHAR(20),
    music_Influencial_mood VARCHAR(50),
    music_lis_frequency VARCHAR(20),
    music_expl_method VARCHAR(50),
    music_recc_rating INT,
    pod_lis_frequency VARCHAR(20),
    fav_pod_genre VARCHAR(50),
    preffered_pod_format VARCHAR(20),
    pod_host_preference VARCHAR(50),
    preffered_pod_duration VARCHAR(50),
    pod_variety_satisfaction VARCHAR(50)
);
COPY INTO staging_layer.main_table
FROM @listening_stage
FILE_FORMAT = (TYPE = CSV)
ON_ERROR = 'CONTINUE'; 
SELECT * FROM staging_layer.main_table;