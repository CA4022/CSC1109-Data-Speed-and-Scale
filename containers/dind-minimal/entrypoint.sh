#!/bin/bash

printenv > /env
exec /sbin/init
