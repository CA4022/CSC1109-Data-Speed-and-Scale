#!/bin/bash
set -e

# --- Metastore Schema Initialization ---
if schematool -info -dbType postgres 2>&1 | grep -q 'Metastore schema version'; then
  echo "Metastore schema already initialized."
else
  echo "Metastore schema not initialized; initializing..."
  schematool -initSchema -dbType postgres
fi

echo "--- HDFS Initialization ---"

# --- Create HDFS directories idempotently ---
if ! hdfs dfs -test -d hdfs://namenode/tmp; then
  echo "Directory hdfs://namenode/tmp not found, creating..."
  hdfs dfs -mkdir hdfs://namenode/tmp
else
  echo "Directory hdfs://namenode/tmp already exists."
fi
hdfs dfs -chmod 1777 hdfs://namenode//tmp

if ! hdfs dfs -test -d hdfs://namenode/user/$HIVE_USER_NAME/warehouse; then
  echo "Directory hdfs://namenode/user/$HIVE_USER_NAME/warehouse not found, creating..."
  hdfs dfs -mkdir -p hdfs://namenode/user/$HIVE_USER_NAME/warehouse
else
  echo "Directory hdfs://namenode/user/$HIVE_USER_NAME/warehouse already exists."
fi

# --- Set ownership ---
echo "Ensuring '$HIVE_USER_NAME' user owns hdfs://namenode/user/$HIVE_USER_NAME..."
hdfs dfs -chown -R $HIVE_USER_NAME:$HIVE_USER_NAME hdfs://namenode/user/$HIVE_USER_NAME

echo "HDFS initialization complete."
