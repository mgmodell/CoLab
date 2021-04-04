CREATE USER IF NOT EXISTS 'test'@'localhost' IDENTIFIED BY 'test';

GRANT ALL PRIVILEGES ON colab_dev.* TO 'test'@'localhost';
GRANT ALL PRIVILEGES ON colab_test_.* TO 'test'@'localhost';
GRANT ALL PRIVILEGES ON colab_test_1.* TO 'test'@'localhost';

FLUSH PRIVILEGES;
