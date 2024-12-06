#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <script_name.sql>"
    exit 1
fi

SCRIPT_NAME=$1

if [ ! -f "./scripts/$SCRIPT_NAME" ]; then
    echo "Script './scripts/$SCRIPT_NAME' not found"
    exit 1
fi

docker exec -it hd-mssql /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U SA -P 'YourStrong!Passw0rd' \
  -i /scripts/$SCRIPT_NAME