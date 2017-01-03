#!/bin/bash

# Run the tests in all the databases
# The script is designed for a Trusty environment.

set -e

dbname=psycopg2_test
dbport=15432

printf "\n\nRunning tests against PostgreSQL $PGVERSION\n\n"
export PSYCOPG2_TESTDB=$dbname
export PSYCOPG2_TESTDB_PORT=$dbport
export PSYCOPG2_TESTDB_USER=travis
export PSYCOPG2_TEST_REPL_DSN=
unset PSYCOPG2_TEST_GREEN
python -c "from psycopg2 import tests; tests.unittest.main(defaultTest='tests.test_suite')"

printf "\n\nRunning tests against PostgreSQL $PGVERSION (green mode)\n\n"
export PSYCOPG2_TEST_GREEN=1
python -c "from psycopg2 import tests; tests.unittest.main(defaultTest='tests.test_suite')"
