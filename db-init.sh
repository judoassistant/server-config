#!/bin/bash

echo "Creating judoassistant postgres user and database"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB"  <<EOF
    CREATE USER judoassistant WITH PASSWORD '${POSTGRES_JUDOASSISTANT_PASSWORD}';
    CREATE DATABASE judoassistant;
    GRANT ALL PRIVILEGES ON DATABASE "judoassistant" to judoassistant;
EOF

