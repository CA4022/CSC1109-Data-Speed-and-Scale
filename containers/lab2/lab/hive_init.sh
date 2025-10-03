#!/bin/bash
set -e

sleep 5

# --- Metastore Schema Initialization ---
echo "--- Metastore Schema Initialization ---"

if ! $HIVE_HOME/bin/schematool -info -dbType postgres >/dev/null 2>&1; then
  echo "Metastore schema not found or in an inconsistent state. Initializing..."
  $HIVE_HOME/bin/schematool -initSchema -dbType postgres
  echo "Metastore schema initialization successful."
else
  echo "Metastore schema already initialized. Skipping."
fi

echo "--- HDFS Initialization ---"

# --- Create HDFS directories idempotently ---
if ! hdfs dfs -test -d hdfs://namenode/tmp; then
  echo "Directory hdfs://namenode/tmp not found, creating..."
  hdfs dfs -mkdir -p hdfs://namenode/tmp
else
  echo "Directory hdfs://namenode/tmp already exists."
fi
hdfs dfs -chmod -R 777 hdfs://namenode/tmp

if ! hdfs dfs -test -d hdfs://namenode/tmp/hive; then
  echo "Directory hdfs://namenode/tmp/hive not found, creating..."
  hdfs dfs -mkdir -p hdfs://namenode/tmp/hive
else
  echo "Directory hdfs://namenode/tmp/hive already exists."
fi
hdfs dfs -chmod -R 777 hdfs://namenode/tmp/hive

if ! hdfs dfs -test -d hdfs://namenode/tmp/yarn; then
  echo "Directory hdfs://namenode/tmp/yarn not found, creating..."
  hdfs dfs -mkdir -p hdfs://namenode/tmp/yarn
else
  echo "Directory hdfs://namenode/tmp/yarn already exists."
fi
hdfs dfs -chmod -R 777 hdfs://namenode/tmp/yarn

if ! hdfs dfs -test -d hdfs://namenode/user/$HIVE_USER_NAME/warehouse; then
  echo "Directory hdfs://namenode/user/$HIVE_USER_NAME/warehouse not found, creating..."
  hdfs dfs -mkdir -p hdfs://namenode/user/$HIVE_USER_NAME/warehouse
else
  echo "Directory hdfs://namenode/user/$HIVE_USER_NAME/warehouse already exists."
fi
hdfs dfs -chmod -R 777 hdfs://namenode/user/$HIVE_USER_NAME/warehouse

# --- Set ownership ---
echo "Ensuring '$HIVE_USER_NAME' user owns hdfs://namenode/user/$HIVE_USER_NAME..."
hdfs dfs -chown -R $HIVE_USER_NAME:$HIVE_USER_NAME hdfs://namenode/user/$HIVE_USER_NAME

echo "Initialization complete."
