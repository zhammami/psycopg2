#!/bin/bash

set -e

# Prepare the test databases in Travis CI.
# The script should be run with sudo.
# The script is not idempotent: it assumes the machine in a clean state
# and is designed for a sudo-enabled Trusty environment.

set_param () {
    # Set a parameter in a postgresql.conf file
    param=$1
    value=$2

    sed -i "s/^\s*#\?\s*$param.*/$param = $value/" \
        "/etc/postgresql/$PGVERSION/psycopg/postgresql.conf"
}

dbname=psycopg2_test
dbport=15432

# Would give a permission denied error in the travis build dir
cd /

pg_createcluster -p $dbport --start-conf manual $PGVERSION psycopg

# for two-phase commit testing
set_param max_prepared_transactions 10

# for replication testing
set_param max_wal_senders 5
set_param max_replication_slots 5
if [ "$PGVERSION" == "9.2" -o "$PGVERSION" == "9.3" ]
then
    set_param wal_level hot_standby
else
    set_param wal_level logical
fi

echo "local replication travis trust" \
    >> "/etc/postgresql/$PGVERSION/psycopg/pg_hba.conf"


pg_ctlcluster "$PGVERSION" psycopg start

sudo -u postgres psql -c "create user travis replication" "port=$dbport"
sudo -u postgres psql -c "create database $dbname" "port=$dbport"
sudo -u postgres psql -c "grant create on database $dbname to travis" "port=$dbport"
sudo -u postgres psql -c "create extension hstore" "port=$dbport dbname=$dbname"
