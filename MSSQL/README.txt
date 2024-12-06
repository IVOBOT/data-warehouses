# How to run
Run generator.py and put results in ./data
Run `docker compose up`
Run SQL scripts

# Requirements
Python
Docker

# Useful
SQL Server for VS Code

# Running /scripts/<script_name>.sql

docker exec -it hd-mssql /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U SA -P 'YourStrong!Passw0rd' \
  -i /scripts/<script_name>.sql


# macOS/linus
run.bat <name>.sql

# Windows
sh run.sh <name>.sql