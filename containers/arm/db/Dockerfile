FROM arm64v8/mariadb

RUN echo -e "CREATE USER IF NOT EXISTS 'test'@'%' IDENTIFIED BY 'test'; \
 GRANT ALL PRIVILEGES ON colab_test_.* TO 'test'@'%'; \
 FLUSH PRIVILEGES;" >> /docker-entrypoint-initdb.d/init-privs.sql

