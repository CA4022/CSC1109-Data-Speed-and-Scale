#!/bin/bash
set -e

HIVE_USER_NAME="${HIVE_USER_NAME:-hive}"
HADOOP_SUPERUSER_NAME="${HADOOP_SUPERUSER_NAME:-hadoop}"

# Wait for PostgreSQL to become reachable
echo "Waiting for postgres:5432..."
until (echo > /dev/tcp/postgres/5432) >/dev/null 2>&1 || nc -z postgres 5432 >/dev/null 2>&1 || (exec 3<>/dev/tcp/postgres/5432) >/dev/null 2>&1; do
  sleep 2
done
sleep 3

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

echo "Waiting for namenode:9870..."
until (echo > /dev/tcp/namenode/9870) >/dev/null 2>&1 || curl -s -f http://namenode:9870/ >/dev/null 2>&1; do
  sleep 2
done

ORIGINAL_HADOOP_USER_NAME="${HADOOP_USER_NAME:-$HIVE_USER_NAME}"
export HADOOP_USER_NAME="$HADOOP_SUPERUSER_NAME"

hdfs dfsadmin -safemode wait >/dev/null 2>&1 || true

echo "Waiting for live datanodes..."
until hdfs dfsadmin -report -live 2>/dev/null | grep -qE "^Live datanodes \([1-9]"; do
  sleep 2
done
echo "Live datanode(s) available."

# --- Create HDFS directories idempotently ---
if ! hdfs dfs -test -d hdfs://namenode/tmp; then
  echo "Directory hdfs://namenode/tmp not found, creating..."
  hdfs dfs -mkdir -p hdfs://namenode/tmp
else
  echo "Directory hdfs://namenode/tmp already exists."
fi
hdfs dfs -chmod -R 1777 hdfs://namenode/tmp

if ! hdfs dfs -test -d hdfs://namenode/tmp/hive; then
  echo "Directory hdfs://namenode/tmp/hive not found, creating..."
  hdfs dfs -mkdir -p hdfs://namenode/tmp/hive
else
  echo "Directory hdfs://namenode/tmp/hive already exists."
fi
hdfs dfs -chmod -R 1777 hdfs://namenode/tmp/hive

if ! hdfs dfs -test -d hdfs://namenode/tmp/yarn; then
  echo "Directory hdfs://namenode/tmp/yarn not found, creating..."
  hdfs dfs -mkdir -p hdfs://namenode/tmp/yarn
else
  echo "Directory hdfs://namenode/tmp/yarn already exists."
fi
hdfs dfs -chmod -R 1777 hdfs://namenode/tmp/yarn

if ! hdfs dfs -test -d hdfs://namenode/tmp/logs; then
  echo "Directory hdfs://namenode/tmp/logs not found, creating..."
  hdfs dfs -mkdir -p hdfs://namenode/tmp/logs
else
  echo "Directory hdfs://namenode/tmp/logs already exists."
fi
hdfs dfs -chmod -R 1777 hdfs://namenode/tmp/logs

if ! hdfs dfs -test -d hdfs://namenode/user/$HIVE_USER_NAME/warehouse; then
  echo "Directory hdfs://namenode/user/$HIVE_USER_NAME/warehouse not found, creating..."
  hdfs dfs -mkdir -p hdfs://namenode/user/$HIVE_USER_NAME/warehouse
else
  echo "Directory hdfs://namenode/user/$HIVE_USER_NAME/warehouse already exists."
fi
hdfs dfs -chmod -R 1777 hdfs://namenode/user/$HIVE_USER_NAME/warehouse

# --- Set ownership ---
echo "Ensuring '$HIVE_USER_NAME' user owns hdfs://namenode/user/$HIVE_USER_NAME..."
hdfs dfs -chown -R $HIVE_USER_NAME:$HIVE_USER_NAME hdfs://namenode/user/$HIVE_USER_NAME
echo "Ensuring '$HIVE_USER_NAME' user owns hdfs://namenode/tmp/hive..."
hdfs dfs -chown -R $HIVE_USER_NAME:$HIVE_USER_NAME hdfs://namenode/tmp/hive

# --- Upload Tez to HDFS ---
TEZ_HDFS_PATH="hdfs://namenode/apps/tez"
TEZ_TARBALL="/opt/tez/share/tez.tar.gz"

if [ -f "$TEZ_TARBALL" ]; then
  if ! hdfs dfs -test -d "$TEZ_HDFS_PATH"; then
    echo "Creating HDFS directory $TEZ_HDFS_PATH..."
    hdfs dfs -mkdir -p "$TEZ_HDFS_PATH"
  fi
  if ! hdfs dfs -test -f "${TEZ_HDFS_PATH}/tez.tar.gz"; then
    echo "Uploading Tez tarball to HDFS at ${TEZ_HDFS_PATH}/tez.tar.gz..."
    hdfs dfs -put -f "$TEZ_TARBALL" "${TEZ_HDFS_PATH}/tez.tar.gz"
    echo "Tez tarball uploaded successfully."
  else
    echo "Tez tarball already present in HDFS. Skipping upload."
  fi
  hdfs dfs -chmod -R 755 "$TEZ_HDFS_PATH"
else
  echo "WARNING: Tez tarball not found at $TEZ_TARBALL, skipping HDFS upload."
fi

export HADOOP_USER_NAME="$ORIGINAL_HADOOP_USER_NAME"
echo "Initialization complete."
