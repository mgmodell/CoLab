FROM mariadb

COPY initDBs.sql /docker-entrypoint-initdb.d/init-privs.sql

ENV MYSQL_ROOT_PASSWORD test

EXPOSE 3306

CMD ["mysqld"]

