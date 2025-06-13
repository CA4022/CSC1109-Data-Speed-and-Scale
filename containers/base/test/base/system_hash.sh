#! /usr/bin/env bash

if [ -z "$1" ]; then
  echo "Error: No output file specified."
  echo "Usage: ./base/system_hash.sh <output_file>"
  exit 1
fi

rm -rf /tmp/system_hash/
mkdir /tmp/system_hash/

hashdeep -r /bin > /tmp/system_hash/bin.txt
hashdeep -r /sbin > /tmp/system_hash/sbin.txt
hashdeep -r /etc > /tmp/system_hash/etc.txt
hashdeep -r /share > /tmp/system_hash/share.txt
hashdeep -r /root > /tmp/system_hash/root.txt
hashdeep -r /test > /tmp/system_hash/test.txt
hashdeep /entrypoint.sh > /tmp/system_hash/entrypoint.txt

cat /tmp/system_hash/* > "$1"
