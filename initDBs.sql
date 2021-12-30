CREATE USER IF NOT EXISTS 'test'@'localhost' IDENTIFIED BY 'test';

GRANT ALL PRIVILEGES ON colab_dev.* TO 'test'@'localhost';
GRANT ALL PRIVILEGES ON colab_test_.* TO 'test'@'localhost';
GRANT ALL PRIVILEGES ON colab_test_1.* TO 'test'@'localhost';
GRANT ALL PRIVILEGES ON colab_test_2.* TO 'test'@'localhost';
GRANT ALL PRIVILEGES ON colab_test_3.* TO 'test'@'localhost';
GRANT ALL PRIVILEGES ON colab_test_4.* TO 'test'@'localhost';
GRANT ALL PRIVILEGES ON colab_test_5.* TO 'test'@'localhost';
GRANT ALL PRIVILEGES ON colab_test_6.* TO 'test'@'localhost';
GRANT ALL PRIVILEGES ON colab_test_7.* TO 'test'@'localhost';
GRANT ALL PRIVILEGES ON colab_test_8.* TO 'test'@'localhost';

FLUSH PRIVILEGES;
