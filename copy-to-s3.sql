-- prefrence table
CREATE SCHEMA tos3;
CREATE or replace STAGE tos3.preferences
URL = 's3://sportifydata123'
CREDENTIALS = (AWS_KEY_ID = '' AWS_SECRET_KEY = '');

COPY INTO @preferences/preferences.csv
FROM publish_layer.preference_table
FILE_FORMAT = (TYPE = 'CSV')
OVERWRITE = TRUE;

-- listening trends table
COPY INTO @preferences/listening_trends.csv
FROM publish_layer.listening_trend
FILE_FORMAT = (TYPE = 'CSV')
OVERWRITE = TRUE;

-- listening frequency table
COPY INTO @preferences/listening_frequency.csv
FROM publish_layer.musiclisteningfrequency
FILE_FORMAT = (TYPE = 'CSV')
OVERWRITE = TRUE;
