CREATE EXTERNAL TABLE IF NOT EXISTS iris (
  sepal_length DOUBLE,
  sepal_width DOUBLE,
  petal_length DOUBLE,
  petal_width DOUBLE,
  species STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

LOAD DATA INPATH '/user/hive/data/iris.csv' INTO TABLE iris;
