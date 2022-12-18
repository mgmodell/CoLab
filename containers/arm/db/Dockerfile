FROM arm64v8/mariadb

COPY ../../containers/initDBs.sql /docker-entrypoint-initdb.d/init-privs.sql

ENV MYSQL_ROOT_PASSWORD test
# ENV MYSQL_TCP_PORT 3137
# ENV MYSQL_UNIX_PORT 3137

EXPOSE 3306

CMD ["mysqld"]

