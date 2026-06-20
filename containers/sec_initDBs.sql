-- Security (pentest) environment — additional DB bootstrap.
-- Runs after containers/initDBs.sql (which creates the shared 'test' / 'moodle'
-- users) because MariaDB executes /docker-entrypoint-initdb.d/*.sql in
-- alphabetical order and this file is mounted as a later (zz-*) entry.
--
-- The production target connects as the dedicated 'prod' user defined here
-- (see DATABASE_URL in containers/sec_env/docker-compose.yml).  Credentials are
-- intentionally weak/known: this is a throwaway, network-isolated sandbox whose
-- whole purpose is to be attacked.  Do NOT reuse this pattern outside the sandbox.

CREATE DATABASE IF NOT EXISTS `colab_prod`;

CREATE USER IF NOT EXISTS 'prod'@'%' IDENTIFIED BY 'prod';
GRANT ALL PRIVILEGES ON `colab_prod`.* TO 'prod'@'%';

-- Allow the shared 'test' account (created by initDBs.sql) to reach the prod DB
-- too, so the host helper script can load/dump snapshots with one credential.
GRANT ALL PRIVILEGES ON `colab_prod`.* TO 'test'@'%';

FLUSH PRIVILEGES;
