FROM arm64v8/mariadb

COPY containers/initDBs.sql /docker-entrypoint-initdb.d/init-privs.sql

ENV MYSQL_ROOT_PASSWORD test

EXPOSE 3306

CMD ["mariadbd"]

