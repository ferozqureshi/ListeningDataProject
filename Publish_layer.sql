-- # a) What are the preferred "preferred_listening_content" and "fav_music_genre" for premium subscribers? 
CREATE SCHEMA publish_layer;
CREATE OR REPLACE TABLE publish_layer.preference_table(
age VARCHAR(10),
    preferred_listening_content VARCHAR(50),
    fav_music_genre VARCHAR(50)
);
INSERT INTO publish_layer.preference_table (age, preferred_listening_content, fav_music_genre)
SELECT 
  age, 
  preferred_listening_content,
  fav_music_genre
FROM staging_layer.main_table
WHERE spotify_subscription_plan LIKE '%Premium%';

SELECT * FROM publish_layer.preference_table;


-- b) Additionally, create a trend analysis for "spotify_listening_device" for each age group.
CREATE TABLE publish_layer.listening_trend (
    age VARCHAR(10),
    spotify_listening_device VARCHAR(50),
    device_count INT
);
INSERT INTO publish_layer.listening_trend (age, spotify_listening_device, device_count)
SELECT 
  age,
  spotify_listening_device,
  COUNT(*) AS device_count
FROM main_table
GROUP BY age, spotify_listening_device
ORDER BY age, device_count DESC;

SELECT * FROM publish_layer.listening_trend;

-- c) generate a report indicating the best "music_lis_frequency" for each "spotify_listening_device" based on gender 
CREATE TABLE musiclisteningfrequency (
    spotify_listening_device VARCHAR(50),
    music_lis_frequency VARCHAR(20),
    count INT
);
-- Assuming the 'main_table' is in the appropriate schema, you can switch to that schema if needed
-- USE SCHEMA your_main_table_schema;

-- Insert query results into the 'musiclisteningfrequency' table
INSERT INTO publish_layer.musiclisteningfrequency (spotify_listening_device, music_lis_frequency, count)
SELECT 
  spotify_listening_device,
  music_lis_frequency,
  COUNT(*) AS count
FROM main_table
WHERE Gender = 'Female'
GROUP BY spotify_listening_device, music_lis_frequency
ORDER BY spotify_listening_device;
