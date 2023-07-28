-- Create a task for data copying from S3 to Snowflake
CREATE OR REPLACE TASK copy_data_to_snowflake
WAREHOUSE = COMPUTE_WH
SCHEDULE = '1 minute'
AS

BEGIN
   COPY INTO staging_layer.main_table
   FROM @listening_data.public.listening_stage
   FILE_FORMAT = (TYPE = 'CSV')
   ON_ERROR = 'CONTINUE'; 
END;

-- TASK FOR TRANSFORMING THE DATA
CREATE OR REPLACE TASK transform_data_layers
WAREHOUSE = COMPUTE_WH
SCHEDULE = '1 minute'
AS

BEGIN
    TRUNCATE TABLE publish_layer.preference_table;
   TRUNCATE TABLE publish_layer.listening_trend; 
   TRUNCATE TABLE publish_layer.musiclisteningfrequency;
   INSERT INTO publish_layer.preference_table (age, preferred_listening_content, fav_music_genre)
   SELECT 
     age, 
     preferred_listening_content,
     fav_music_genre
   FROM staging_layer.main_table
   WHERE spotify_subscription_plan LIKE '%Premium%';

   INSERT INTO publish_layer.listening_trend (age, spotify_listening_device, device_count)
   SELECT 
     age,
     spotify_listening_device,
     COUNT(*) AS device_count
   FROM staging_layer.main_table
   GROUP BY age, spotify_listening_device
   ORDER BY age, device_count DESC;

   INSERT INTO publish_layer.musiclisteningfrequency (spotify_listening_device, music_lis_frequency, count)
   SELECT 
     spotify_listening_device,
     music_lis_frequency,
     COUNT(*) AS count
   FROM staging_layer.main_table
   WHERE Gender = 'Female'
   GROUP BY spotify_listening_device, music_lis_frequency
   ORDER BY spotify_listening_device;
END;

-- Create a task for data loading from Snowflake back to S3
CREATE OR REPLACE TASK load_data_to_s3
WAREHOUSE = COMPUTE_WH
SCHEDULE = '1 minute'
AS
-- Place your COPY INTO statements here to load data back to S3
BEGIN
   COPY INTO @preferences/preferences.csv
   FROM publish_layer.preference_table
   FILE_FORMAT = (TYPE = 'CSV')
   OVERWRITE = TRUE;

   COPY INTO @preferences/listening_trends.csv
   FROM publish_layer.listening_trend
   FILE_FORMAT = (TYPE = 'CSV')
   OVERWRITE = TRUE;

   COPY INTO @preferences/listening_frequency.csv
   FROM publish_layer.musiclisteningfrequency
   FILE_FORMAT = (TYPE = 'CSV')
   OVERWRITE = TRUE;
END;



ALTER TASK copy_data_to_snowflake RESUME;
ALTER TASK transform_data_layers RESUME;
ALTER TASK load_data_to_s3 RESUME;


ALTER TASK copy_data_to_snowflake SUSPEND;
ALTER TASK transform_data_layers SUSPEND;
ALTER TASK load_data_to_s3 SUSPEND;