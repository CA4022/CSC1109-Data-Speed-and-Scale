#!/bin/bash

printenv > /opt/container_env
exec /sbin/init
