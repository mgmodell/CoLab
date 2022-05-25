CREATE USER IF NOT EXISTS 'test'@'172.%' IDENTIFIED BY 'test';
CREATE USER IF NOT EXISTS 'test'@'localhost' IDENTIFIED BY 'test';

GRANT ALL PRIVILEGES ON colab_dev.* TO 'test'@'172.%';
GRANT ALL PRIVILEGES ON colab_dev.* TO 'test'@'localhost';
GRANT ALL PRIVILEGES ON `colab_test\_%`.* TO 'test'@'172.%';
GRANT ALL PRIVILEGES ON `colab_test\_%`.* TO 'test'@'localhost';

FLUSH PRIVILEGES;
