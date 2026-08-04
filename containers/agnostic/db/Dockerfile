FROM docker.io/mariadb

COPY containers/initDBs.sql /docker-entrypoint-initdb.d/init-privs.sql
RUN chown -R 999:999 /docker-entrypoint-initdb.d && \
    chmod -R 755 /docker-entrypoint-initdb.d

ENV MYSQL_ROOT_PASSWORD=test

EXPOSE 3306

CMD ["mariadbd"]

