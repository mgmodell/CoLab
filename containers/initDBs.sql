CREATE USER IF NOT EXISTS 'test'@'%' IDENTIFIED BY 'test';
CREATE USER IF NOT EXISTS 'moodle'@'%' IDENTIFIED BY 'moodle';

GRANT ALL PRIVILEGES ON `colab_dev`.* TO 'test'@'%';
GRANT ALL PRIVILEGES ON `colab_test\_%`.* TO 'test'@'%';
GRANT ALL PRIVILEGES ON `moodle`.* TO 'moodle'@'%';

FLUSH PRIVILEGES;
