CREATE USER IF NOT EXISTS 'test'@'%' IDENTIFIED BY 'test';

GRANT ALL PRIVILEGES ON `colab_dev`.* TO 'test'@'%';
GRANT ALL PRIVILEGES ON `colab_test\_%`.* TO 'test'@'%';

FLUSH PRIVILEGES;
