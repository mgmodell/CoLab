-- MariaDB dump 10.19  Distrib 10.11.2-MariaDB, for osx10.18 (arm64)
--
-- Host: localhost    Database: colab_test_
-- ------------------------------------------------------
-- Server version	10.10.2-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `active_storage_attachments`
--

DROP TABLE IF EXISTS `active_storage_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `active_storage_attachments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `record_type` varchar(255) NOT NULL,
  `record_id` bigint(20) NOT NULL,
  `blob_id` bigint(20) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_active_storage_attachments_uniqueness` (`record_type`,`record_id`,`name`,`blob_id`),
  KEY `index_active_storage_attachments_on_blob_id` (`blob_id`),
  CONSTRAINT `fk_rails_c3b3935057` FOREIGN KEY (`blob_id`) REFERENCES `active_storage_blobs` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `active_storage_attachments`
--

LOCK TABLES `active_storage_attachments` WRITE;
/*!40000 ALTER TABLE `active_storage_attachments` DISABLE KEYS */;
/*!40000 ALTER TABLE `active_storage_attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `active_storage_blobs`
--

DROP TABLE IF EXISTS `active_storage_blobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `active_storage_blobs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `metadata` text DEFAULT NULL,
  `byte_size` bigint(20) NOT NULL,
  `checksum` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `service_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_active_storage_blobs_on_key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `active_storage_blobs`
--

LOCK TABLES `active_storage_blobs` WRITE;
/*!40000 ALTER TABLE `active_storage_blobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `active_storage_blobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `active_storage_variant_records`
--

DROP TABLE IF EXISTS `active_storage_variant_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `active_storage_variant_records` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `blob_id` bigint(20) NOT NULL,
  `variation_digest` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_active_storage_variant_records_uniqueness` (`blob_id`,`variation_digest`),
  CONSTRAINT `fk_rails_993965df05` FOREIGN KEY (`blob_id`) REFERENCES `active_storage_blobs` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `active_storage_variant_records`
--

LOCK TABLES `active_storage_variant_records` WRITE;
/*!40000 ALTER TABLE `active_storage_variant_records` DISABLE KEYS */;
/*!40000 ALTER TABLE `active_storage_variant_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ahoy_messages`
--

DROP TABLE IF EXISTS `ahoy_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ahoy_messages` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `token` varchar(255) DEFAULT NULL,
  `to` text DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_type` varchar(255) DEFAULT NULL,
  `mailer` varchar(255) DEFAULT NULL,
  `subject` text DEFAULT NULL,
  `sent_at` timestamp NULL DEFAULT NULL,
  `opened_at` timestamp NULL DEFAULT NULL,
  `clicked_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_ahoy_messages_on_token` (`token`),
  KEY `index_ahoy_messages_on_user_id_and_user_type` (`user_id`,`user_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ahoy_messages`
--

LOCK TABLES `ahoy_messages` WRITE;
/*!40000 ALTER TABLE `ahoy_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `ahoy_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ar_internal_metadata`
--

DROP TABLE IF EXISTS `ar_internal_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ar_internal_metadata` (
  `key` varchar(255) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ar_internal_metadata`
--

LOCK TABLES `ar_internal_metadata` WRITE;
/*!40000 ALTER TABLE `ar_internal_metadata` DISABLE KEYS */;
INSERT INTO `ar_internal_metadata` VALUES
('environment','test','2019-09-23 11:40:09.041237','2019-09-23 11:40:09.041237'),
('schema_sha1','20322dd1d0bd0b11663a6e1117d762c4eb418216','2019-09-23 11:40:09.067337','2019-09-23 11:40:09.067337');
/*!40000 ALTER TABLE `ar_internal_metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assessments`
--

DROP TABLE IF EXISTS `assessments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assessments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `end_date` datetime DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `project_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `instructor_updated` tinyint(1) NOT NULL DEFAULT 0,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `index_assessments_on_project_id` (`project_id`),
  CONSTRAINT `fk_rails_1acaaff98a` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assessments`
--

LOCK TABLES `assessments` WRITE;
/*!40000 ALTER TABLE `assessments` DISABLE KEYS */;
/*!40000 ALTER TABLE `assessments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assignments`
--

DROP TABLE IF EXISTS `assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assignments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `rubric_id` bigint(20) DEFAULT NULL,
  `group_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `course_id` int(11) NOT NULL,
  `project_id` int(11) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `passing` int(11) DEFAULT 65,
  `anon_name` varchar(255) DEFAULT NULL,
  `anon_description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_assignments_on_rubric_id` (`rubric_id`),
  KEY `index_assignments_on_course_id` (`course_id`),
  KEY `index_assignments_on_project_id` (`project_id`),
  CONSTRAINT `fk_rails_2194c084a6` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`),
  CONSTRAINT `fk_rails_4d3d2c839c` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`),
  CONSTRAINT `fk_rails_7efcd7af22` FOREIGN KEY (`rubric_id`) REFERENCES `rubrics` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assignments`
--

LOCK TABLES `assignments` WRITE;
/*!40000 ALTER TABLE `assignments` DISABLE KEYS */;
/*!40000 ALTER TABLE `assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `behaviors`
--

DROP TABLE IF EXISTS `behaviors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `behaviors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name_en` varchar(255) DEFAULT NULL,
  `description_en` text DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name_ko` varchar(255) DEFAULT NULL,
  `description_ko` text DEFAULT NULL,
  `needs_detail` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_behaviors_on_name_en` (`name_en`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `behaviors`
--

LOCK TABLES `behaviors` WRITE;
/*!40000 ALTER TABLE `behaviors` DISABLE KEYS */;
INSERT INTO `behaviors` VALUES
(1,'Equal participation','Each group member\'s contributions toward the group\'s effort are roughly equal. There will be variability in the types of contributions, and individuals may see ups and downs, but the overall responsibility is being fairly shared. <i>If no other behavior is clearly dominant, select this option</i>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL,NULL,0),
(2,'Ganging up on the task','This is when only one member of the group engages with the task at hand and the others actively avoid it.  The engaged member becomes overwhelmed, and joins the rest of the group in avoidance activities.\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL,NULL,0),
(3,'Group domination','This is when an individual asserts his or her authority through some combination of commanding other members and controlling conversation. This often involves the individual interrupting and otherwise devaluing the contributions of others.\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL,NULL,0),
(4,'Social loafing','This is when an individual consistently under-contributes to the efforts of the group to achieve its goals. This forces other group members to do extra work so the task can be completed successfully.\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL,NULL,0),
(5,'I don\'t know','I am not sure which group behavior dominates this entry, but it is not equal participation.\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL,NULL,0),
(6,'Other','This entry indicates a behavior that is not listed and I will enter it in myself.\n','2019-09-23 11:40:16','2020-06-21 03:46:02',NULL,NULL,1);
/*!40000 ALTER TABLE `behaviors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bingo_boards`
--

DROP TABLE IF EXISTS `bingo_boards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bingo_boards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bingo_game_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `winner` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `win_claimed` tinyint(1) DEFAULT NULL,
  `iteration` int(11) DEFAULT 0,
  `board_type` int(11) DEFAULT 0,
  `performance` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_bingo_boards_on_bingo_game_id` (`bingo_game_id`),
  KEY `index_bingo_boards_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_1575529b02` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_9eacbd2686` FOREIGN KEY (`bingo_game_id`) REFERENCES `bingo_games` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bingo_boards`
--

LOCK TABLES `bingo_boards` WRITE;
/*!40000 ALTER TABLE `bingo_boards` DISABLE KEYS */;
/*!40000 ALTER TABLE `bingo_boards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bingo_cells`
--

DROP TABLE IF EXISTS `bingo_cells`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bingo_cells` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bingo_board_id` int(11) DEFAULT NULL,
  `concept_id` int(11) DEFAULT NULL,
  `row` int(11) DEFAULT NULL,
  `column` int(11) DEFAULT NULL,
  `selected` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `indeks` int(11) DEFAULT NULL,
  `candidate_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_bingo_cells_on_bingo_board_id` (`bingo_board_id`),
  KEY `index_bingo_cells_on_candidate_id` (`candidate_id`),
  KEY `index_bingo_cells_on_concept_id` (`concept_id`),
  CONSTRAINT `fk_rails_146f272ed9` FOREIGN KEY (`bingo_board_id`) REFERENCES `bingo_boards` (`id`),
  CONSTRAINT `fk_rails_a288276ba8` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`),
  CONSTRAINT `fk_rails_e4577d19a4` FOREIGN KEY (`concept_id`) REFERENCES `concepts` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bingo_cells`
--

LOCK TABLES `bingo_cells` WRITE;
/*!40000 ALTER TABLE `bingo_cells` DISABLE KEYS */;
/*!40000 ALTER TABLE `bingo_cells` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bingo_games`
--

DROP TABLE IF EXISTS `bingo_games`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bingo_games` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `topic` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `link` varchar(255) DEFAULT NULL,
  `source` varchar(255) DEFAULT NULL,
  `group_option` tinyint(1) DEFAULT NULL,
  `individual_count` int(11) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `active` tinyint(1) DEFAULT 0,
  `course_id` int(11) DEFAULT NULL,
  `project_id` int(11) DEFAULT NULL,
  `lead_time` int(11) DEFAULT 3,
  `group_discount` int(11) DEFAULT NULL,
  `reviewed` tinyint(1) DEFAULT NULL,
  `instructor_notified` tinyint(1) NOT NULL DEFAULT 0,
  `students_notified` tinyint(1) NOT NULL DEFAULT 0,
  `anon_topic` varchar(255) DEFAULT NULL,
  `size` int(11) DEFAULT 5,
  PRIMARY KEY (`id`),
  KEY `index_bingo_games_on_course_id` (`course_id`),
  KEY `index_bingo_games_on_project_id` (`project_id`),
  CONSTRAINT `fk_rails_9b5d9b6428` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`),
  CONSTRAINT `fk_rails_d94c8b95ab` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bingo_games`
--

LOCK TABLES `bingo_games` WRITE;
/*!40000 ALTER TABLE `bingo_games` DISABLE KEYS */;
/*!40000 ALTER TABLE `bingo_games` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `candidate_feedbacks`
--

DROP TABLE IF EXISTS `candidate_feedbacks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `candidate_feedbacks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name_en` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name_ko` varchar(255) DEFAULT NULL,
  `definition_en` text DEFAULT NULL,
  `definition_ko` text DEFAULT NULL,
  `credit` int(11) DEFAULT NULL,
  `critique` int(11) NOT NULL DEFAULT 3,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_candidate_feedbacks_on_name_en` (`name_en`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `candidate_feedbacks`
--

LOCK TABLES `candidate_feedbacks` WRITE;
/*!40000 ALTER TABLE `candidate_feedbacks` DISABLE KEYS */;
INSERT INTO `candidate_feedbacks` VALUES
(1,'Acceptable','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL,'You\'ve accurately identified and defined an important term related  to the stated topic.\n',NULL,100,1),
(2,'Definition: Incorrect','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL,'You\'ve identified an important term related to the stated topic, but the definition is wrong.\n',NULL,50,2),
(3,'Definition: Almost correct','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL,'You\'ve identified an important term related to the stated topic and provided a definition that is close to complete, but is lacking in some crucial ways.\n',NULL,75,2),
(4,'Definition: Not Understood','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL,'You\'ve identified an important term related to the stated topic, but I was unable to understand the definition as you\'ve provided it.\n',NULL,50,2),
(5,'Definition: Borrowed Word-for-Word','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL,'You\'ve identified an important term related to the stated topic, but I recognize the definition provided as having been substantially copied directly from another source.\n',NULL,25,2),
(6,'Definition: Wrong Context','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL,'You\'ve identified an important term related to the stated topic, but the definition you\'ve provided, while correct for other uses, is not correct for this topic.\n',NULL,50,2),
(7,'Term: Too Generic','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL,'The term is not specific to the topic or the course.\n',NULL,10,3),
(8,'Term: Too Obvious','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL,'The term does not represent new learning or consideration relevant to the topic.\n',NULL,10,3),
(9,'Term: Invalid/Incorrect','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL,'The term is either not a real term or is being misused.\n',NULL,20,3),
(10,'Term: Not Relevant','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL,'The term may be interesting, but not relevant to the topic.\n',NULL,30,3),
(11,'Term: Doesn\'t match','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL,'The term does not match the definition.\n',NULL,40,3),
(12,'Term: Proper Name or Product Name','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL,'Proper names and products should not be used unless they are  dominant to the point of being synonymous with a class of activity or a household name.\n',NULL,30,3),
(13,'Term: Too specific','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL,'Terms ought to be at a conceptual level. Terms that are specific to a specific implementation should generally be avoided.\n',NULL,30,3),
(14,'Definition: Recursive','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL,'The term was used to define itself.\n',NULL,50,2);
/*!40000 ALTER TABLE `candidate_feedbacks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `candidate_lists`
--

DROP TABLE IF EXISTS `candidate_lists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `candidate_lists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `is_group` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `bingo_game_id` int(11) DEFAULT NULL,
  `group_requested` tinyint(1) DEFAULT NULL,
  `cached_performance` int(11) DEFAULT NULL,
  `archived` tinyint(1) NOT NULL DEFAULT 0,
  `contributor_count` int(11) NOT NULL DEFAULT 1,
  `current_candidate_list_id` int(11) DEFAULT NULL,
  `candidates_count` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `index_candidate_lists_on_bingo_game_id` (`bingo_game_id`),
  KEY `fk_rails_de17bb0877` (`current_candidate_list_id`),
  KEY `index_candidate_lists_on_group_id` (`group_id`),
  KEY `index_candidate_lists_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_070208024f` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_536301951c` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`),
  CONSTRAINT `fk_rails_de17bb0877` FOREIGN KEY (`current_candidate_list_id`) REFERENCES `candidate_lists` (`id`),
  CONSTRAINT `fk_rails_ef20e72a8a` FOREIGN KEY (`bingo_game_id`) REFERENCES `bingo_games` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `candidate_lists`
--

LOCK TABLES `candidate_lists` WRITE;
/*!40000 ALTER TABLE `candidate_lists` DISABLE KEYS */;
/*!40000 ALTER TABLE `candidate_lists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `candidates`
--

DROP TABLE IF EXISTS `candidates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `candidates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `definition` text DEFAULT NULL,
  `candidate_list_id` int(11) DEFAULT NULL,
  `candidate_feedback_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `concept_id` int(11) DEFAULT NULL,
  `term` varchar(255) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `filtered_consistent` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_candidates_on_candidate_feedback_id` (`candidate_feedback_id`),
  KEY `index_candidates_on_candidate_list_id` (`candidate_list_id`),
  KEY `index_candidates_on_concept_id` (`concept_id`),
  KEY `index_candidates_on_definition` (`definition`(2)),
  KEY `index_candidates_on_term` (`term`(2)),
  KEY `index_candidates_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_01dfdc3a16` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_51a1d34b91` FOREIGN KEY (`concept_id`) REFERENCES `concepts` (`id`),
  CONSTRAINT `fk_rails_c2902bce54` FOREIGN KEY (`candidate_list_id`) REFERENCES `candidate_lists` (`id`),
  CONSTRAINT `fk_rails_cf78a1bfc7` FOREIGN KEY (`candidate_feedback_id`) REFERENCES `candidate_feedbacks` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `candidates`
--

LOCK TABLES `candidates` WRITE;
/*!40000 ALTER TABLE `candidates` DISABLE KEYS */;
/*!40000 ALTER TABLE `candidates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cip_codes`
--

DROP TABLE IF EXISTS `cip_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cip_codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gov_code` int(11) DEFAULT NULL,
  `name_en` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name_ko` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_cip_codes_on_gov_code` (`gov_code`)
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cip_codes`
--

LOCK TABLES `cip_codes` WRITE;
/*!40000 ALTER TABLE `cip_codes` DISABLE KEYS */;
INSERT INTO `cip_codes` VALUES
(1,0,'I prefer not to answer','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(2,1,'Agriculture, agriculture operations, and related sciences','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(3,3,'Natural resources and conservation','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(4,4,'Architecture and related services','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(5,5,'Area, ethnic, cultural, gender, and group studies','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(6,9,'Communication, journalism, and related programs','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(7,10,'Communications technologies/technicians and support services','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(8,11,'Computer and information sciences and support services','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(9,12,'Personal and culinary services','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(10,13,'Education','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(11,14,'Engineering','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(12,15,'Engineering technologies and engineering-related fields','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(13,16,'Foreign languages, literatures, and linguistics','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(14,19,'Family and consumer sciences/human sciences','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(15,22,'Legal professions and studies','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(16,23,'English language and literature/letters','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(17,24,'Liberal arts and sciences, general studies and humanities','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(18,25,'Library science','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(19,26,'Biological and biomedical sciences','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(20,27,'Mathematics and statistics','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(21,28,'Military science, leadership and operational art','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(22,29,'Military technologies and applied sciences','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(23,30,'Multi/interdisciplinary studies','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(24,31,'Parks, recreation, leisure, and fitness studies','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(25,32,'Basic skills and developmental/remedial education','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(26,33,'Citizenship activities','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(27,34,'Health-related knowledge and skills','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(28,35,'Interpersonal and social skills','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(29,36,'Leisure and recreational activities','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(30,37,'Personal awareness and self-improvement','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(31,38,'Philosophy and religious studies','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(32,39,'Theology and religious vocations','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(33,40,'Physical sciences','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(34,41,'Science technologies/technicians','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(35,42,'Psychology','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(36,43,'Homeland security, law enforcement, firefighting and related protective services','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(37,44,'Public administration and social service professions','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(38,45,'Social sciences','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(39,46,'Construction trades','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(40,47,'Mechanic and repair technologies/technicians','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(41,48,'Precision production','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(42,49,'Transportation and materials moving','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(43,50,'Visual and performing arts','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(44,51,'Health professions and related programs','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(45,52,'Business, management, marketing, and related support services','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(46,53,'High school/secondary diplomas and certificates','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(47,54,'History','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(48,60,'Residency programs','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL),
(49,100,'Other','2019-09-23 11:40:09','2019-09-23 11:40:09',NULL);
/*!40000 ALTER TABLE `cip_codes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `concepts`
--

DROP TABLE IF EXISTS `concepts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `concepts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `candidates_count` int(11) NOT NULL DEFAULT 0,
  `courses_count` int(11) NOT NULL DEFAULT 0,
  `bingo_games_count` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_concepts_on_name` (`name`),
  FULLTEXT KEY `concept_fulltext` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `concepts`
--

LOCK TABLES `concepts` WRITE;
/*!40000 ALTER TABLE `concepts` DISABLE KEYS */;
INSERT INTO `concepts` VALUES
(0,'*','2019-09-23 11:40:17','2019-09-23 11:40:17',0,0,0);
/*!40000 ALTER TABLE `concepts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `consent_forms`
--

DROP TABLE IF EXISTS `consent_forms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `consent_forms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `form_text_en` text DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 0,
  `form_text_ko` text DEFAULT NULL,
  `courses_count` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `index_consent_forms_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_c31f002e28` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `consent_forms`
--

LOCK TABLES `consent_forms` WRITE;
/*!40000 ALTER TABLE `consent_forms` DISABLE KEYS */;
/*!40000 ALTER TABLE `consent_forms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `consent_logs`
--

DROP TABLE IF EXISTS `consent_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `consent_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `accepted` tinyint(1) DEFAULT NULL,
  `consent_form_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `presented` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_consent_logs_on_consent_form_id` (`consent_form_id`),
  KEY `index_consent_logs_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_19c9ce8688` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_acd74e70b7` FOREIGN KEY (`consent_form_id`) REFERENCES `consent_forms` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `consent_logs`
--

LOCK TABLES `consent_logs` WRITE;
/*!40000 ALTER TABLE `consent_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `consent_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `courses`
--

DROP TABLE IF EXISTS `courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `courses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `timezone` varchar(255) DEFAULT NULL,
  `school_id` int(11) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `number` varchar(255) DEFAULT NULL,
  `anon_name` varchar(255) DEFAULT NULL,
  `anon_number` varchar(255) DEFAULT NULL,
  `consent_form_id` int(11) DEFAULT NULL,
  `anon_offset` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `fk_rails_469f90a775` (`consent_form_id`),
  KEY `index_courses_on_school_id` (`school_id`),
  CONSTRAINT `fk_rails_469f90a775` FOREIGN KEY (`consent_form_id`) REFERENCES `consent_forms` (`id`),
  CONSTRAINT `fk_rails_adf7d91583` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `courses`
--

LOCK TABLES `courses` WRITE;
/*!40000 ALTER TABLE `courses` DISABLE KEYS */;
/*!40000 ALTER TABLE `courses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `criteria`
--

DROP TABLE IF EXISTS `criteria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `criteria` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `rubric_id` bigint(20) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `weight` int(11) NOT NULL DEFAULT 1,
  `sequence` int(11) NOT NULL,
  `l1_description` text DEFAULT NULL,
  `l2_description` text DEFAULT NULL,
  `l3_description` text DEFAULT NULL,
  `l4_description` text DEFAULT NULL,
  `l5_description` text DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_criteria_on_rubric_id_and_sequence` (`rubric_id`,`sequence`),
  KEY `index_criteria_on_rubric_id` (`rubric_id`),
  CONSTRAINT `fk_rails_1b5cbaf9f1` FOREIGN KEY (`rubric_id`) REFERENCES `rubrics` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `criteria`
--

LOCK TABLES `criteria` WRITE;
/*!40000 ALTER TABLE `criteria` DISABLE KEYS */;
/*!40000 ALTER TABLE `criteria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delayed_jobs`
--

DROP TABLE IF EXISTS `delayed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `delayed_jobs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `priority` int(11) NOT NULL DEFAULT 0,
  `attempts` int(11) NOT NULL DEFAULT 0,
  `handler` text NOT NULL,
  `last_error` text DEFAULT NULL,
  `run_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `locked_by` varchar(255) DEFAULT NULL,
  `queue` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `delayed_jobs_priority` (`priority`,`run_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delayed_jobs`
--

LOCK TABLES `delayed_jobs` WRITE;
/*!40000 ALTER TABLE `delayed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `delayed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `diagnoses`
--

DROP TABLE IF EXISTS `diagnoses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `diagnoses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `behavior_id` int(11) DEFAULT NULL,
  `reaction_id` int(11) DEFAULT NULL,
  `week_id` int(11) DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `other_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_diagnoses_on_behavior_id` (`behavior_id`),
  KEY `index_diagnoses_on_reaction_id` (`reaction_id`),
  KEY `index_diagnoses_on_week_id` (`week_id`),
  CONSTRAINT `fk_rails_4824fab681` FOREIGN KEY (`reaction_id`) REFERENCES `reactions` (`id`),
  CONSTRAINT `fk_rails_bd0a7bfb68` FOREIGN KEY (`week_id`) REFERENCES `weeks` (`id`),
  CONSTRAINT `fk_rails_fa8e1883d2` FOREIGN KEY (`behavior_id`) REFERENCES `behaviors` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `diagnoses`
--

LOCK TABLES `diagnoses` WRITE;
/*!40000 ALTER TABLE `diagnoses` DISABLE KEYS */;
/*!40000 ALTER TABLE `diagnoses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `emails`
--

DROP TABLE IF EXISTS `emails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `primary` tinyint(1) DEFAULT 0,
  `confirmation_token` varchar(255) DEFAULT NULL,
  `unconfirmed_email` varchar(255) DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `confirmation_sent_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_emails_on_email` (`email`),
  KEY `index_emails_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_214d0d0665` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `emails`
--

LOCK TABLES `emails` WRITE;
/*!40000 ALTER TABLE `emails` DISABLE KEYS */;
INSERT INTO `emails` VALUES
(1,1,'micah.modell@gmail.com',1,NULL,NULL,'2019-09-23 11:40:17',NULL,'2019-09-23 11:40:17','2019-09-23 11:40:17');
/*!40000 ALTER TABLE `emails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `experiences`
--

DROP TABLE IF EXISTS `experiences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `experiences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `active` tinyint(1) DEFAULT 0,
  `instructor_updated` tinyint(1) NOT NULL DEFAULT 0,
  `anon_name` varchar(255) DEFAULT NULL,
  `lead_time` int(11) NOT NULL DEFAULT 3,
  `student_end_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_experiences_on_course_id` (`course_id`),
  CONSTRAINT `fk_rails_23ce752422` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiences`
--

LOCK TABLES `experiences` WRITE;
/*!40000 ALTER TABLE `experiences` DISABLE KEYS */;
/*!40000 ALTER TABLE `experiences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `factor_packs`
--

DROP TABLE IF EXISTS `factor_packs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `factor_packs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name_en` varchar(255) DEFAULT NULL,
  `description_en` text DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name_ko` varchar(255) DEFAULT NULL,
  `description_ko` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_factor_packs_on_name_en` (`name_en`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `factor_packs`
--

LOCK TABLES `factor_packs` WRITE;
/*!40000 ALTER TABLE `factor_packs` DISABLE KEYS */;
INSERT INTO `factor_packs` VALUES
(1,'Simple','Borrowed from Goldfinch','2019-09-23 11:40:09','2019-09-23 11:40:09','단순한','Goldfinch에서 빌린'),
(2,'Original','My earliest formulation','2019-09-23 11:40:09','2019-09-23 11:40:09','실물','나의 가장 초기의 배합'),
(3,'Distilled I','Distillation of factors from 23 sources','2019-09-23 11:40:09','2019-09-23 11:40:09','증류 한','23 개 출처의 요인 증류');
/*!40000 ALTER TABLE `factor_packs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `factors`
--

DROP TABLE IF EXISTS `factors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `factors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description_en` text DEFAULT NULL,
  `name_en` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name_ko` varchar(255) DEFAULT NULL,
  `description_ko` text DEFAULT NULL,
  `factor_pack_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_factors_on_name_en` (`name_en`),
  KEY `index_factors_on_factor_pack_id` (`factor_pack_id`),
  CONSTRAINT `fk_rails_532f0f9a0e` FOREIGN KEY (`factor_pack_id`) REFERENCES `factor_packs` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `factors`
--

LOCK TABLES `factors` WRITE;
/*!40000 ALTER TABLE `factors` DISABLE KEYS */;
INSERT INTO `factors` VALUES
(1,'Helped to organize the group\'s members and activities.','Organizing','2019-09-23 11:40:16','2019-09-23 11:40:16','조직',NULL,1),
(2,'Understanding what was required of the group and of the individual group members.\n','Understanding requirements','2019-09-23 11:40:16','2019-09-23 11:40:16','요구 사항 이해',NULL,1),
(3,'Suggesting ideas upon which the group could act or continue to build productively.\n','Suggesting ideas','2019-09-23 11:40:16','2019-09-23 11:40:16','아이디어 제안',NULL,1),
(4,'Coming up with something useful to contribute to the group\'s efforts.\n','Producing','2019-09-23 11:40:16','2019-09-23 11:40:16','생산',NULL,1),
(5,'Performing tasks allocated by the group within the specified timeframe.\n','Performing tasks','2019-09-23 11:40:16','2019-09-23 11:40:16','작업 수행',NULL,1),
(6,'Performing tasks allocated by the group within the specified timeframe.\n','Work','2019-09-23 11:40:16','2019-09-23 11:40:16','일',NULL,2),
(7,'Suggesting ideas and alternative approaches.','Creativity','2019-09-23 11:40:16','2019-09-23 11:40:16','독창성',NULL,2),
(8,'Helping teammates to get along with one another effectively. Including (but not limited to) negotiating solutions to disagreements, introducing humour at appropriate times. Taking a personal interest in teammates\' wellbeing.\n','Group Dynamics','2019-09-23 11:40:16','2019-09-23 11:40:16','집단 역학',NULL,2),
(9,'Establishing standards for quality and evaluating group performance and decisions in relation to these standards.\n','Standards','2019-09-23 11:40:16','2019-09-23 11:40:16','표준',NULL,3),
(10,'Delivering constructive criticism.','Constructive criticism','2019-09-23 11:40:16','2019-09-23 11:40:16','건설적인 비판',NULL,3),
(11,'Valuing the contributions of teammates; maintaining a positive attitude and encouraging a positive attitude in teammates.\n','Valuing teammates','2019-09-23 11:40:16','2019-09-23 11:40:16','팀원을 가치있게 여기다',NULL,3),
(12,'Facilitating communications between teammates; helping members understand one another.\n','Facilitating communications','2019-09-23 11:40:16','2019-09-23 11:40:16','통신 촉진',NULL,3),
(13,'Contributing ideas and suggestions to the group.','Ideas and suggestions','2019-09-23 11:40:16','2019-09-23 11:40:16','아이디어 및 제안',NULL,3),
(14,'Bringing new and relevant information to the group.','New information','2019-09-23 11:40:16','2019-09-23 11:40:16','새로운 정보',NULL,3),
(15,'Interpreting, consolidating and integrating ideas and information into a useful result.\n','Integrating ideas','2019-09-23 11:40:16','2019-09-23 11:40:16','아이디어 통합',NULL,3),
(16,'Accepting suggested tasks and/or volunteering for new ones.\n','Accepting tasks','2019-09-23 11:40:16','2019-09-23 11:40:16','과제 수락',NULL,3),
(17,'Performing assigned tasks on time and/or notifying the group in a timely  fashion when assigned tasks cannot be completed for any reason (e.g. wrong task, insufficient information, insufficient time, etc.)\n','Time-sensitive','2019-09-23 11:40:16','2019-09-23 11:40:16','시간에 민감한',NULL,3),
(18,'Asking questions relevant to understanding the group\'s goals or how to achieve  them. This includes questions aimed at understanding teammates\' ideas and  suggestions.\n','Relevant questions','2019-09-23 11:40:16','2019-09-23 11:40:16','관련 질문',NULL,3),
(19,'Representing or demonstrating the group\'s progress, goals and/or positions  effectively and accurately to non-members (orally, visually or otherwise).\n','External communications','2019-09-23 11:40:16','2019-09-23 11:40:16','외부 커뮤니케이션',NULL,3),
(20,'Managing the development of, adherence to and revision of the group\'s specific timeline.\n','Timeline management','2019-09-23 11:40:16','2019-09-23 11:40:16','타임 라인 관리',NULL,3),
(21,'Suggesting allocation of resources (team members, materials, etc.) to individual task completions.\n','Allocating resources','2019-09-23 11:40:16','2019-09-23 11:40:16','자원 할당',NULL,3);
/*!40000 ALTER TABLE `factors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `genders`
--

DROP TABLE IF EXISTS `genders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `genders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name_en` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name_ko` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_genders_on_name_en` (`name_en`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `genders`
--

LOCK TABLES `genders` WRITE;
/*!40000 ALTER TABLE `genders` DISABLE KEYS */;
INSERT INTO `genders` VALUES
(1,'Male','2019-09-23 11:40:16','2019-09-23 11:40:16','남성','m'),
(2,'Female','2019-09-23 11:40:16','2019-09-23 11:40:16','여자','f'),
(3,'Non-binary','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL,'nb'),
(4,'I\'d prefer not to answer','2019-09-23 11:40:16','2019-09-23 11:40:16','나는 대답하지 않는 것을 좋아한다','__');
/*!40000 ALTER TABLE `genders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `group_revisions`
--

DROP TABLE IF EXISTS `group_revisions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_revisions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `members` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_group_revisions_on_group_id` (`group_id`),
  CONSTRAINT `fk_rails_11f61fffa5` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group_revisions`
--

LOCK TABLES `group_revisions` WRITE;
/*!40000 ALTER TABLE `group_revisions` DISABLE KEYS */;
/*!40000 ALTER TABLE `group_revisions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `groups`
--

DROP TABLE IF EXISTS `groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `project_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `anon_name` varchar(255) DEFAULT NULL,
  `diversity_score` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_groups_on_project_id` (`project_id`),
  CONSTRAINT `fk_rails_19a2103fc3` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `groups`
--

LOCK TABLES `groups` WRITE;
/*!40000 ALTER TABLE `groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `groups_users`
--

DROP TABLE IF EXISTS `groups_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `groups_users` (
  `user_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  UNIQUE KEY `index_groups_users_on_group_id_and_user_id` (`group_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `groups_users`
--

LOCK TABLES `groups_users` WRITE;
/*!40000 ALTER TABLE `groups_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `groups_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `home_countries`
--

DROP TABLE IF EXISTS `home_countries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `home_countries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `no_response` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_home_countries_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=250 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `home_countries`
--

LOCK TABLES `home_countries` WRITE;
/*!40000 ALTER TABLE `home_countries` DISABLE KEYS */;
INSERT INTO `home_countries` VALUES
(1,'Andorra','AD',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(2,'United Arab Emirates','AE',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(3,'Afghanistan','AF',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(4,'Antigua and Barbuda','AG',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(5,'Anguilla','AI',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(6,'Albania','AL',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(7,'Armenia','AM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(8,'Angola','AO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(9,'Antarctica','AQ',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(10,'Argentina','AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(11,'American Samoa','AS',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(12,'Austria','AT',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(13,'Australia','AU',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(14,'Aruba','AW',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(15,'Åland','AX',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(16,'Azerbaijan','AZ',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(17,'Bosnia and Herzegovina','BA',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(18,'Barbados','BB',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(19,'Bangladesh','BD',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(20,'Belgium','BE',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(21,'Burkina Faso','BF',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(22,'Bulgaria','BG',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(23,'Bahrain','BH',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(24,'Burundi','BI',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(25,'Benin','BJ',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(26,'Saint-Barthélemy','BL',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(27,'Bermuda','BM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(28,'Brunei','BN',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(29,'Bolivia','BO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(30,'Bonaire','BQ',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(31,'Brazil','BR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(32,'Bahamas','BS',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(33,'Bhutan','BT',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(34,'Botswana','BW',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(35,'Belarus','BY',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(36,'Belize','BZ',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(37,'Canada','CA',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(38,'Cocos [Keeling] Islands','CC',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(39,'Congo','CD',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(40,'Central African Republic','CF',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(41,'Republic of the Congo','CG',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(42,'Switzerland','CH',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(43,'Ivory Coast','CI',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(44,'Cook Islands','CK',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(45,'Chile','CL',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(46,'Cameroon','CM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(47,'China','CN',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(48,'Colombia','CO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(49,'country_name','COUNTRY_ISO_CODE',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(50,'Costa Rica','CR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(51,'Cuba','CU',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(52,'Cape Verde','CV',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(53,'Curaçao','CW',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(54,'Christmas Island','CX',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(55,'Cyprus','CY',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(56,'Czech Republic','CZ',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(57,'Germany','DE',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(58,'Djibouti','DJ',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(59,'Denmark','DK',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(60,'Dominica','DM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(61,'Dominican Republic','DO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(62,'Algeria','DZ',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(63,'Ecuador','EC',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(64,'Estonia','EE',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(65,'Egypt','EG',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(66,'Eritrea','ER',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(67,'Spain','ES',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(68,'Ethiopia','ET',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(69,'Finland','FI',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(70,'Fiji','FJ',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(71,'Falkland Islands','FK',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(72,'Federated States of Micronesia','FM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(73,'Faroe Islands','FO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(74,'France','FR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(75,'Gabon','GA',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(76,'United Kingdom','GB',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(77,'Grenada','GD',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(78,'Georgia','GE',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(79,'French Guiana','GF',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(80,'Guernsey','GG',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(81,'Ghana','GH',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(82,'Gibraltar','GI',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(83,'Greenland','GL',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(84,'Gambia','GM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(85,'Guinea','GN',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(86,'Guadeloupe','GP',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(87,'Equatorial Guinea','GQ',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(88,'Greece','GR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(89,'South Georgia and the South Sandwich Islands','GS',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(90,'Guatemala','GT',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(91,'Guam','GU',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(92,'Guinea-Bissau','GW',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(93,'Guyana','GY',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(94,'Hong Kong','HK',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(95,'Honduras','HN',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(96,'Croatia','HR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(97,'Haiti','HT',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(98,'Hungary','HU',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(99,'Indonesia','ID',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(100,'Ireland','IE',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(101,'Israel','IL',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(102,'Isle of Man','IM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(103,'India','IN',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(104,'British Indian Ocean Territory','IO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(105,'Iraq','IQ',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(106,'Iran','IR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(107,'Iceland','IS',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(108,'Italy','IT',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(109,'Jersey','JE',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(110,'Jamaica','JM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(111,'Hashemite Kingdom of Jordan','JO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(112,'Japan','JP',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(113,'Kenya','KE',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(114,'Kyrgyzstan','KG',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(115,'Cambodia','KH',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(116,'Kiribati','KI',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(117,'Comoros','KM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(118,'Saint Kitts and Nevis','KN',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(119,'North Korea','KP',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(120,'Republic of Korea','KR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(121,'Kuwait','KW',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(122,'Cayman Islands','KY',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(123,'Kazakhstan','KZ',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(124,'Laos','LA',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(125,'Lebanon','LB',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(126,'Saint Lucia','LC',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(127,'Liechtenstein','LI',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(128,'Sri Lanka','LK',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(129,'Liberia','LR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(130,'Lesotho','LS',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(131,'Republic of Lithuania','LT',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(132,'Luxembourg','LU',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(133,'Latvia','LV',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(134,'Libya','LY',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(135,'Morocco','MA',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(136,'Monaco','MC',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(137,'Republic of Moldova','MD',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(138,'Montenegro','ME',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(139,'Saint Martin','MF',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(140,'Madagascar','MG',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(141,'Marshall Islands','MH',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(142,'Macedonia','MK',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(143,'Mali','ML',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(144,'Myanmar [Burma]','MM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(145,'Mongolia','MN',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(146,'Macao','MO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(147,'Northern Mariana Islands','MP',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(148,'Martinique','MQ',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(149,'Mauritania','MR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(150,'Montserrat','MS',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(151,'Malta','MT',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(152,'Mauritius','MU',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(153,'Maldives','MV',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(154,'Malawi','MW',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(155,'Mexico','MX',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(156,'Malaysia','MY',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(157,'Mozambique','MZ',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(158,'Namibia','NA',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(159,'New Caledonia','NC',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(160,'Niger','NE',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(161,'Norfolk Island','NF',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(162,'Nigeria','NG',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(163,'Nicaragua','NI',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(164,'Netherlands','NL',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(165,'Norway','NO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(166,'Nepal','NP',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(167,'Nauru','NR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(168,'Niue','NU',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(169,'New Zealand','NZ',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(170,'Oman','OM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(171,'Panama','PA',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(172,'Peru','PE',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(173,'French Polynesia','PF',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(174,'Papua New Guinea','PG',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(175,'Philippines','PH',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(176,'Pakistan','PK',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(177,'Poland','PL',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(178,'Saint Pierre and Miquelon','PM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(179,'Pitcairn Islands','PN',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(180,'Puerto Rico','PR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(181,'Palestine','PS',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(182,'Portugal','PT',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(183,'Palau','PW',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(184,'Paraguay','PY',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(185,'Qatar','QA',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(186,'Réunion','RE',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(187,'Romania','RO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(188,'Serbia','RS',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(189,'Russia','RU',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(190,'Rwanda','RW',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(191,'Saudi Arabia','SA',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(192,'Solomon Islands','SB',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(193,'Seychelles','SC',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(194,'Sudan','SD',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(195,'Sweden','SE',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(196,'Singapore','SG',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(197,'Saint Helena','SH',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(198,'Slovenia','SI',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(199,'Svalbard and Jan Mayen','SJ',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(200,'Slovakia','SK',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(201,'Sierra Leone','SL',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(202,'San Marino','SM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(203,'Senegal','SN',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(204,'Somalia','SO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(205,'Suriname','SR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(206,'South Sudan','SS',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(207,'São Tomé and Príncipe','ST',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(208,'El Salvador','SV',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(209,'Sint Maarten','SX',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(210,'Syria','SY',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(211,'Swaziland','SZ',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(212,'Turks and Caicos Islands','TC',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(213,'Chad','TD',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(214,'French Southern Territories','TF',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(215,'Togo','TG',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(216,'Thailand','TH',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(217,'Tajikistan','TJ',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(218,'Tokelau','TK',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(219,'East Timor','TL',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(220,'Turkmenistan','TM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(221,'Tunisia','TN',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(222,'Tonga','TO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(223,'Turkey','TR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(224,'Trinidad and Tobago','TT',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(225,'Tuvalu','TV',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(226,'Taiwan','TW',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(227,'Tanzania','TZ',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(228,'Ukraine','UA',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(229,'Uganda','UG',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(230,'U.S. Minor Outlying Islands','UM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(231,'United States','US',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(232,'Uruguay','UY',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(233,'Uzbekistan','UZ',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(234,'Vatican City','VA',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(235,'Saint Vincent and the Grenadines','VC',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(236,'Venezuela','VE',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(237,'British Virgin Islands','VG',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(238,'U.S. Virgin Islands','VI',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(239,'Vietnam','VN',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(240,'Vanuatu','VU',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(241,'Wallis and Futuna','WF',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(242,'Samoa','WS',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(243,'Kosovo','XK',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(244,'Yemen','YE',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(245,'Mayotte','YT',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(246,'South Africa','ZA',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(247,'Zambia','ZM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(248,'Zimbabwe','ZW',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(249,'I prefer not to specify my country','__',1,'2019-09-23 11:40:09','2019-09-23 11:40:09');
/*!40000 ALTER TABLE `home_countries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `home_states`
--

DROP TABLE IF EXISTS `home_states`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `home_states` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `home_country_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `no_response` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_home_states_on_home_country_id_and_name` (`home_country_id`,`name`),
  KEY `index_home_states_on_home_country_id` (`home_country_id`),
  CONSTRAINT `fk_rails_222b6d20a6` FOREIGN KEY (`home_country_id`) REFERENCES `home_countries` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2735 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `home_states`
--

LOCK TABLES `home_states` WRITE;
/*!40000 ALTER TABLE `home_states` DISABLE KEYS */;
INSERT INTO `home_states` VALUES
(1,249,'not applicable','--:__',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(2,1,'Canillo','02:AD',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(3,1,'Encamp','03:AD',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(4,1,'La Massana','04:AD',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(5,1,'Ordino','05:AD',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(6,1,'Sant Julià de Loria','06:AD',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(7,1,'Andorra la Vella','07:AD',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(8,1,'Escaldes-Engordany','08:AD',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(9,1,'I prefer not to specify the state','__:AD',1,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(10,2,'Abu Dhabi','AZ:AE',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(11,2,'Dubai','DU:AE',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(12,2,'Al Fujayrah','FU:AE',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(13,2,'Ra\'s al Khaymah','RK:AE',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(14,2,'Ash Shariqah','SH:AE',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(15,2,'I prefer not to specify the state','__:AE',1,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(16,3,'Daykundi','DAY:AF',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(17,3,'Herat','HER:AF',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(18,3,'Kabul','KAB:AF',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(19,3,'Kandahar','KAN:AF',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(20,3,'Wardak','WAR:AF',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(21,3,'Zabul','ZAB:AF',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(22,3,'I prefer not to specify the state','__:AF',1,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(23,4,'Parish of Saint George','03:AG',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(24,4,'Parish of Saint John','04:AG',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(25,4,'Parish of Saint Mary','05:AG',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(26,4,'Parish of Saint Peter','07:AG',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(27,4,'Barbuda','10:AG',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(28,4,'I prefer not to specify the state','__:AG',1,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(29,5,'not applicable','--:AI',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(30,6,'Qarku i Beratit','01:AL',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(31,6,'Qarku i Durresit','02:AL',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(32,6,'Qarku i Elbasanit','03:AL',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(33,6,'Qarku i Gjirokastres','05:AL',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(34,6,'Qarku i Korces','06:AL',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(35,6,'Qarku i Shkodres','10:AL',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(36,6,'Qarku i Tiranes','11:AL',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(37,6,'Qarku i Vlores','12:AL',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(38,6,'I prefer not to specify the state','__:AL',1,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(39,7,'Aragatsotni Marz','AG:AM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(40,7,'Armaviri Marz','AV:AM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(41,7,'Yerevan','ER:AM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(42,7,'Kotayk\'i Marz','KT:AM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(43,7,'Lorru Marz','LO:AM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(44,7,'Syunik\'i Marz','SU:AM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(45,7,'Tavushi Marz','TV:AM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(46,7,'Vayots\' Dzori Marz','VD:AM',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(47,7,'I prefer not to specify the state','__:AM',1,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(48,8,'Bengo Province','BGO:AO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(49,8,'Benguela','BGU:AO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(50,8,'Provincia do Bie','BIE:AO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(51,8,'Cabinda','CAB:AO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(52,8,'Kuando Kubango','CCU:AO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(53,8,'Cunene Province','CNN:AO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(54,8,'Cuanza Norte Province','CNO:AO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(55,8,'Kwanza Sul','CUS:AO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(56,8,'Huambo','HUA:AO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(57,8,'Huila Province','HUI:AO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(58,8,'Lunda Norte Province','LNO:AO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(59,8,'Lunda Sul','LSU:AO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(60,8,'Luanda Province','LUA:AO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(61,8,'Malanje Province','MAL:AO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(62,8,'Moxico','MOX:AO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(63,8,'Namibe Province','NAM:AO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(64,8,'Provincia do Uige','UIG:AO',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(65,8,'I prefer not to specify the state','__:AO',1,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(66,9,'not applicable','--:AQ',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(67,10,'Salta','A:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(68,10,'Buenos Aires','B:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(69,10,'Buenos Aires F.D.','C:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(70,10,'Provincia de San Luis','D:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(71,10,'Entre Rios','E:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(72,10,'Provincia de La Rioja','F:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(73,10,'Santiago del Estero','G:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(74,10,'Chaco','H:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(75,10,'Provincia de San Juan','J:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(76,10,'Provincia de Catamarca','K:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(77,10,'La Pampa','L:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(78,10,'Mendoza','M:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(79,10,'Provincia de Misiones','N:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(80,10,'Formosa','P:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(81,10,'Neuquen','Q:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(82,10,'Rio Negro','R:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(83,10,'Santa Fe','S:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(84,10,'Provincia de Tucuman','T:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(85,10,'Chubut','U:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(86,10,'Tierra del Fuego','V:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(87,10,'Corrientes','W:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(88,10,'Cordoba','X:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(89,10,'Provincia de Jujuy','Y:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(90,10,'Santa Cruz','Z:AR',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(91,10,'I prefer not to specify the state','__:AR',1,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(92,11,'Eastern District','E:AS',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(93,11,'I prefer not to specify the state','__:AS',1,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(94,12,'Burgenland','1:AT',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(95,12,'Carinthia','2:AT',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(96,12,'Lower Austria','3:AT',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(97,12,'Upper Austria','4:AT',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(98,12,'Salzburg','5:AT',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(99,12,'Styria','6:AT',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(100,12,'Tyrol','7:AT',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(101,12,'Vorarlberg','8:AT',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(102,12,'Vienna','9:AT',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(103,12,'I prefer not to specify the state','__:AT',1,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(104,13,'Australian Capital Territory','ACT:AU',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(105,13,'New South Wales','NSW:AU',0,'2019-09-23 11:40:09','2019-09-23 11:40:09'),
(106,13,'Northern Territory','NT:AU',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(107,13,'Queensland','QLD:AU',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(108,13,'South Australia','SA:AU',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(109,13,'Tasmania','TAS:AU',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(110,13,'Victoria','VIC:AU',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(111,13,'Western Australia','WA:AU',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(112,13,'I prefer not to specify the state','__:AU',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(113,14,'not applicable','--:AW',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(114,15,'Alands landsbygd','Alands landsbygd:AX',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(115,15,'Alands skaergard','Alands skaergard:AX',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(116,15,'Mariehamns stad','Mariehamns stad:AX',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(117,15,'I prefer not to specify the state','__:AX',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(118,16,'Absheron Rayon','ABS:AZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(119,16,'Baku City','BA:AZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(120,16,'Nakhichevan','NX:AZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(121,16,'Quba Rayon','QBA:AZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(122,16,'Qusar Rayon','QUS:AZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(123,16,'Shaki City','SAK:AZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(124,16,'Sumqayit City','SM:AZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(125,16,'Khachmaz Rayon','XAC:AZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(126,16,'Goygol Rayon','XAN:AZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(127,16,'I prefer not to specify the state','__:AZ',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(128,17,'Federation of Bosnia and Herzegovina','BIH:BA',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(129,17,'Brčko','BRC:BA',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(130,17,'Republika Srpska','SRP:BA',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(131,17,'I prefer not to specify the state','__:BA',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(132,18,'Christ Church','01:BB',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(133,18,'Saint Andrew','02:BB',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(134,18,'Saint James','04:BB',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(135,18,'Saint Lucy','07:BB',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(136,18,'Saint Michael','08:BB',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(137,18,'Saint Thomas','11:BB',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(138,18,'I prefer not to specify the state','__:BB',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(139,19,'Barisal Division','A:BD',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(140,19,'Chittagong','B:BD',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(141,19,'Dhaka Division','C:BD',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(142,19,'Khulna Division','D:BD',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(143,19,'Rajshahi Division','E:BD',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(144,19,'Rangpur Division','F:BD',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(145,19,'I prefer not to specify the state','__:BD',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(146,20,'Brussels Capital','BRU:BE',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(147,20,'Flanders','VLG:BE',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(148,20,'Wallonia','WAL:BE',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(149,20,'I prefer not to specify the state','__:BE',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(150,21,'Centre','03:BF',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(151,21,'Centre-Est','04:BF',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(152,21,'High-Basins Region','09:BF',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(153,21,'I prefer not to specify the state','__:BF',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(154,22,'Blagoevgrad','01:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(155,22,'Burgas','02:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(156,22,'Varna','03:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(157,22,'Oblast Veliko Turnovo','04:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(158,22,'Oblast Vidin','05:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(159,22,'Oblast Vratsa','06:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(160,22,'Gabrovo','07:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(161,22,'Oblast Dobrich','08:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(162,22,'Oblast Kurdzhali','09:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(163,22,'Oblast Kyustendil','10:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(164,22,'Lovech','11:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(165,22,'Oblast Montana','12:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(166,22,'Pazardzhik','13:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(167,22,'Pernik','14:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(168,22,'Oblast Pleven','15:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(169,22,'Plovdiv','16:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(170,22,'Oblast Razgrad','17:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(171,22,'Oblast Ruse','18:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(172,22,'Oblast Silistra','19:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(173,22,'Oblast Sliven','20:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(174,22,'Oblast Smolyan','21:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(175,22,'Sofia-Capital','22:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(176,22,'Sofiya','23:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(177,22,'Oblast Stara Zagora','24:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(178,22,'Oblast Turgovishte','25:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(179,22,'Oblast Khaskovo','26:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(180,22,'Oblast Shumen','27:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(181,22,'Oblast Yambol','28:BG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(182,22,'I prefer not to specify the state','__:BG',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(183,23,'Manama','13:BH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(184,23,'Southern Governorate','14:BH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(185,23,'Muharraq','15:BH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(186,23,'Central Governorate','16:BH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(187,23,'Northern','17:BH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(188,23,'I prefer not to specify the state','__:BH',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(189,24,'Bujumbura Mairie Province','BM:BI',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(190,24,'I prefer not to specify the state','__:BI',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(191,25,'Atlantique Department','AQ:BJ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(192,25,'Littoral','LI:BJ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(193,25,'I prefer not to specify the state','__:BJ',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(194,26,'not applicable','--:BL',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(195,27,'Saint George','GC:BM',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(196,27,'Hamilton city','HC:BM',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(197,27,'Sandys Parish','SA:BM',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(198,27,'I prefer not to specify the state','__:BM',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(199,28,'Belait District','BE:BN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(200,28,'Brunei and Muara District','BM:BN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(201,28,'Temburong District','TE:BN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(202,28,'Tutong District','TU:BN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(203,28,'I prefer not to specify the state','__:BN',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(204,29,'El Beni','B:BO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(205,29,'Departamento de Cochabamba','C:BO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(206,29,'Departamento de Chuquisaca','H:BO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(207,29,'Departamento de La Paz','L:BO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(208,29,'Departamento de Pando','N:BO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(209,29,'Oruro','O:BO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(210,29,'Departamento de Potosi','P:BO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(211,29,'Departamento de Santa Cruz','S:BO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(212,29,'Departamento de Tarija','T:BO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(213,29,'I prefer not to specify the state','__:BO',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(214,30,'Bonaire','BO:BQ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(215,30,'I prefer not to specify the state','__:BQ',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(216,31,'Acre','AC:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(217,31,'Alagoas','AL:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(218,31,'Amazonas','AM:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(219,31,'Amapa','AP:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(220,31,'Bahia','BA:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(221,31,'Ceara','CE:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(222,31,'Federal District','DF:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(223,31,'Espirito Santo','ES:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(224,31,'Goias','GO:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(225,31,'Maranhao','MA:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(226,31,'Minas Gerais','MG:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(227,31,'Mato Grosso do Sul','MS:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(228,31,'Mato Grosso','MT:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(229,31,'Para','PA:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(230,31,'Paraiba','PB:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(231,31,'Pernambuco','PE:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(232,31,'Piaui','PI:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(233,31,'Parana','PR:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(234,31,'Rio de Janeiro','RJ:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(235,31,'Rio Grande do Norte','RN:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(236,31,'Rondonia','RO:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(237,31,'Roraima','RR:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(238,31,'Rio Grande do Sul','RS:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(239,31,'Santa Catarina','SC:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(240,31,'Sergipe','SE:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(241,31,'Sao Paulo','SP:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(242,31,'Tocantins','TO:BR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(243,31,'I prefer not to specify the state','__:BR',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(244,32,'Bimini','BI:BS',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(245,32,'Central Eleuthera District','CE:BS',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(246,32,'Central Abaco District','CO:BS',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(247,32,'City of Freeport District','FP:BS',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(248,32,'Harbour Island','HI:BS',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(249,32,'New Providence District','NP:BS',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(250,32,'North Andros District','NS:BS',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(251,32,'Spanish Wells District','SW:BS',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(252,32,'I prefer not to specify the state','__:BS',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(253,33,'Paro','11:BT',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(254,33,'Chhukha Dzongkhag','12:BT',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(255,33,'Thimphu Dzongkhag','15:BT',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(256,33,'Mongar Dzongkhag','42:BT',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(257,33,'I prefer not to specify the state','__:BT',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(258,34,'Central District','CE:BW',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(259,34,'North East District','NE:BW',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(260,34,'South East District','SE:BW',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(261,34,'I prefer not to specify the state','__:BW',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(262,35,'Brest','BR:BY',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(263,35,'Minsk','MI:BY',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(264,35,'Gomel','HO:BY',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(265,35,'Grodnenskaya','HR:BY',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(266,35,'Mogilev','MA:BY',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(267,35,'Vitebsk','VI:BY',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(268,35,'I prefer not to specify the state','__:BY',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(269,36,'Belize District','BZ:BZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(270,36,'Cayo District','CY:BZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(271,36,'Stann Creek District','SC:BZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(272,36,'I prefer not to specify the state','__:BZ',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(273,37,'Alberta','AB:CA',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(274,37,'British Columbia','BC:CA',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(275,37,'Manitoba','MB:CA',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(276,37,'New Brunswick','NB:CA',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(277,37,'Newfoundland and Labrador','NL:CA',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(278,37,'Nova Scotia','NS:CA',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(279,37,'Northwest Territories','NT:CA',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(280,37,'Nunavut','NU:CA',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(281,37,'Ontario','ON:CA',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(282,37,'Prince Edward Island','PE:CA',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(283,37,'Quebec','QC:CA',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(284,37,'Saskatchewan','SK:CA',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(285,37,'Yukon','YT:CA',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(286,37,'I prefer not to specify the state','__:CA',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(287,38,'not applicable','--:CC',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(288,39,'Province du Bas-Congo','BC:CD',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(289,39,'Katanga Province','KA:CD',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(290,39,'Kinshasa City','KN:CD',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(291,39,'Nord Kivu','NK:CD',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(292,39,'I prefer not to specify the state','__:CD',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(293,40,'Commune de Bangui','BGF:CF',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(294,40,'I prefer not to specify the state','__:CF',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(295,41,'Sangha','13:CG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(296,41,'Commune de Brazzaville','BZV:CG',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(297,41,'I prefer not to specify the state','__:CG',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(298,42,'Aargau','AG:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(299,42,'Appenzell Innerrhoden','AI:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(300,42,'Appenzell Ausserrhoden','AR:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(301,42,'Bern','BE:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(302,42,'Basel-Landschaft','BL:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(303,42,'Basel-City','BS:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(304,42,'Fribourg','FR:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(305,42,'Geneva','GE:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(306,42,'Glarus','GL:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(307,42,'Grisons','GR:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(308,42,'Jura','JU:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(309,42,'Lucerne','LU:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(310,42,'Neuchâtel','NE:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(311,42,'Nidwalden','NW:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(312,42,'Obwalden','OW:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(313,42,'Saint Gallen','SG:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(314,42,'Schaffhausen','SH:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(315,42,'Solothurn','SO:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(316,42,'Schwyz','SZ:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(317,42,'Thurgau','TG:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(318,42,'Ticino','TI:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(319,42,'Uri','UR:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(320,42,'Vaud','VD:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(321,42,'Valais','VS:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(322,42,'Zug','ZG:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(323,42,'Zurich','ZH:CH',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(324,42,'I prefer not to specify the state','__:CH',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(325,43,'Lagunes','01:CI',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(326,43,'Haut-Sassandra','02:CI',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(327,43,'I prefer not to specify the state','__:CI',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(328,44,'not applicable','--:CK',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(329,45,'Aysen','AI:CL',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(330,45,'Antofagasta','AN:CL',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(331,45,'Region de Arica y Parinacota','AP:CL',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(332,45,'Region de la Araucania','AR:CL',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(333,45,'Atacama','AT:CL',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(334,45,'Region del Biobio','BI:CL',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(335,45,'Coquimbo','CO:CL',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(336,45,'Region del Libertador General Bernardo O\'Higgins','LI:CL',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(337,45,'Los Lagos','LL:CL',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(338,45,'Region de Los Rios','LR:CL',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(339,45,'Region de Magallanes y de la Antartica Chilena','MA:CL',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(340,45,'Maule','ML:CL',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(341,45,'Santiago Metropolitan','RM:CL',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(342,45,'Tarapacá','TA:CL',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(343,45,'Region de Valparaiso','VS:CL',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(344,45,'I prefer not to specify the state','__:CL',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(345,46,'Adamaoua','AD:CM',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(346,46,'Centre','CE:CM',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(347,46,'Littoral','LT:CM',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(348,46,'North Region','NO:CM',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(349,46,'North-West Region','NW:CM',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(350,46,'West','OU:CM',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(351,46,'South Region','SU:CM',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(352,46,'South-West Region','SW:CM',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(353,46,'I prefer not to specify the state','__:CM',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(354,47,'Beijing Shi','11:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(355,47,'Tianjin Shi','12:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(356,47,'Hebei','13:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(357,47,'Shanxi Sheng','14:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(358,47,'Inner Mongolia','15:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(359,47,'Liaoning','21:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(360,47,'Jilin Sheng','22:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(361,47,'Heilongjiang Sheng','23:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(362,47,'Shanghai Shi','31:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(363,47,'Jiangsu Sheng','32:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(364,47,'Zhejiang Sheng','33:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(365,47,'Anhui Sheng','34:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(366,47,'Fujian','35:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(367,47,'Jiangxi Sheng','36:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(368,47,'Shandong Sheng','37:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(369,47,'Henan Sheng','41:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(370,47,'Hubei','42:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(371,47,'Hunan','43:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(372,47,'Guangdong','44:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(373,47,'Guangxi Zhuangzu Zizhiqu','45:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(374,47,'Hainan','46:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(375,47,'Chongqing Shi','50:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(376,47,'Sichuan Sheng','51:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(377,47,'Guizhou Sheng','52:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(378,47,'Yunnan','53:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(379,47,'Tibet Autonomous Region','54:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(380,47,'Shaanxi','61:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(381,47,'Gansu Sheng','62:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(382,47,'Qinghai Sheng','63:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(383,47,'Ningxia Huizu Zizhiqu','64:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(384,47,'Xinjiang Uygur Zizhiqu','65:CN',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(385,47,'I prefer not to specify the state','__:CN',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(386,48,'Departamento del Amazonas','AMA:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(387,48,'Antioquia','ANT:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(388,48,'Departamento de Arauca','ARA:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(389,48,'Atlántico','ATL:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(390,48,'Departamento de Bolivar','BOL:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(391,48,'Departamento de Boyaca','BOY:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(392,48,'Departamento de Caldas','CAL:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(393,48,'Departamento del Caqueta','CAQ:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(394,48,'Departamento de Casanare','CAS:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(395,48,'Departamento del Cauca','CAU:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(396,48,'Departamento del Cesar','CES:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(397,48,'Departamento de Cordoba','COR:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(398,48,'Cundinamarca','CUN:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(399,48,'Bogota D.C.','DC:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(400,48,'Departamento del Guainia','GUA:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(401,48,'Departamento del Guaviare','GUV:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(402,48,'Departamento del Huila','HUI:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(403,48,'Departamento de La Guajira','LAG:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(404,48,'Departamento del Magdalena','MAG:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(405,48,'Departamento del Meta','MET:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(406,48,'Departamento de Narino','NAR:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(407,48,'Departamento de Norte de Santander','NSA:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(408,48,'Quindio Department','QUI:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(409,48,'Departamento de Risaralda','RIS:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(410,48,'Departamento de Santander','SAN:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(411,48,'Departamento de Sucre','SUC:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(412,48,'Departamento de Tolima','TOL:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(413,48,'Departamento del Valle del Cauca','VAC:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(414,48,'Departamento del Vaupes','VAU:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(415,48,'Departamento del Vichada','VID:CO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(416,48,'I prefer not to specify the state','__:CO',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(417,49,'not applicable','--:COUNTRY_ISO_CODE',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(418,50,'Provincia de Alajuela','A:CR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(419,50,'Provincia de Cartago','C:CR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(420,50,'Provincia de Guanacaste','G:CR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(421,50,'Provincia de Heredia','H:CR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(422,50,'Provincia de Limon','L:CR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(423,50,'Provincia de Puntarenas','P:CR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(424,50,'Provincia de San Jose','SJ:CR',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(425,50,'I prefer not to specify the state','__:CR',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(426,51,'Provincia de Pinar del Rio','01:CU',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(427,51,'La Habana','03:CU',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(428,51,'Provincia de Matanzas','04:CU',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(429,51,'Provincia de Cienfuegos','06:CU',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(430,51,'Provincia de Sancti Spiritus','07:CU',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(431,51,'Provincia de Ciego de Avila','08:CU',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(432,51,'Provincia de Camaguey','09:CU',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(433,51,'Las Tunas','10:CU',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(434,51,'Provincia de Holguin','11:CU',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(435,51,'Provincia Granma','12:CU',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(436,51,'Provincia de Santiago de Cuba','13:CU',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(437,51,'Provincia de Guantanamo','14:CU',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(438,51,'Artemisa','Artemisa:CU',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(439,51,'I prefer not to specify the state','__:CU',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(440,52,'Concelho da Praia','PR:CV',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(441,52,'I prefer not to specify the state','__:CV',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(442,53,'not applicable','--:CW',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(443,54,'not applicable','--:CX',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(444,55,'Lefkosia','01:CY',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(445,55,'Limassol','02:CY',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(446,55,'Larnaka','03:CY',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(447,55,'Ammochostos','04:CY',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(448,55,'Pafos','05:CY',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(449,55,'Keryneia','06:CY',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(450,55,'I prefer not to specify the state','__:CY',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(451,56,'Jihocesky kraj','JC:CZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(452,56,'South Moravian','JM:CZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(453,56,'Karlovarsky kraj','KA:CZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(454,56,'Kralovehradecky kraj','KR:CZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(455,56,'Liberecky kraj','LI:CZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(456,56,'Moravskoslezsky kraj','MO:CZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(457,56,'Olomoucky kraj','OL:CZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(458,56,'Pardubicky kraj','PA:CZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(459,56,'Plzensky kraj','PL:CZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(460,56,'Hlavni mesto Praha','PR:CZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(461,56,'Central Bohemia','ST:CZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(462,56,'Ustecky kraj','US:CZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(463,56,'Kraj Vysocina','VY:CZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(464,56,'Zlín','ZL:CZ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(465,56,'I prefer not to specify the state','__:CZ',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(466,57,'Brandenburg','BB:DE',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(467,57,'Land Berlin','BE:DE',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(468,57,'Baden-Württemberg Region','BW:DE',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(469,57,'Bavaria','BY:DE',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(470,57,'Bremen','HB:DE',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(471,57,'Hesse','HE:DE',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(472,57,'Hamburg','HH:DE',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(473,57,'Mecklenburg-Vorpommern','MV:DE',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(474,57,'Lower Saxony','NI:DE',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(475,57,'North Rhine-Westphalia','NW:DE',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(476,57,'Rheinland-Pfalz','RP:DE',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(477,57,'Schleswig-Holstein','SH:DE',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(478,57,'Saarland','SL:DE',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(479,57,'Saxony','SN:DE',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(480,57,'Saxony-Anhalt','ST:DE',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(481,57,'Thuringia','TH:DE',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(482,57,'I prefer not to specify the state','__:DE',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(483,58,'not applicable','--:DJ',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(484,59,'North Denmark','81:DK',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(485,59,'Central Jutland','82:DK',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(486,59,'South Denmark','83:DK',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(487,59,'Capital Region','84:DK',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(488,59,'Zealand','85:DK',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(489,59,'I prefer not to specify the state','__:DK',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(490,60,'Saint Andrew','02:DM',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(491,60,'Saint George','04:DM',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(492,60,'Saint Patrick','09:DM',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(493,60,'I prefer not to specify the state','__:DM',1,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(494,61,'Provincia de San Jose de Ocoa','Provincia de San Jose de Ocoa:DO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(495,61,'Provincia de Santo Domingo','Provincia de Santo Domingo:DO',0,'2019-09-23 11:40:10','2019-09-23 11:40:10'),
(496,61,'Nacional','01:DO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(497,61,'Provincia de Barahona','04:DO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(498,61,'Provincia Duarte','06:DO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(499,61,'Provincia de El Seibo','08:DO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(500,61,'Provincia Espaillat','09:DO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(501,61,'Provincia de Independencia','10:DO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(502,61,'Provincia de La Altagracia','11:DO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(503,61,'Provincia de La Romana','12:DO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(504,61,'Provincia de La Vega','13:DO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(505,61,'Provincia de Monte Cristi','15:DO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(506,61,'Provincia de Pedernales','16:DO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(507,61,'Provincia de Peravia','17:DO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(508,61,'Puerto Plata','18:DO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(509,61,'Provincia de San Cristobal','21:DO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(510,61,'Provincia de San Juan','22:DO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(511,61,'Provincia de San Pedro de Macoris','23:DO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(512,61,'Provincia Sanchez Ramirez','24:DO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(513,61,'Provincia de Santiago','25:DO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(514,61,'Provincia de Santiago Rodriguez','26:DO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(515,61,'Provincia de Hato Mayor','30:DO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(516,61,'I prefer not to specify the state','__:DO',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(517,62,'Wilaya de Chlef','02:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(518,62,'Wilaya de Laghouat','03:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(519,62,'Wilaya de Batna','05:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(520,62,'Wilaya de Bejaia','06:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(521,62,'Wilaya de Bechar','08:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(522,62,'Wilaya de Blida','09:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(523,62,'Wilaya de Tamanrasset','11:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(524,62,'Wilaya de Tlemcen','13:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(525,62,'Wilaya de Tiaret','14:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(526,62,'Wilaya de Tizi Ouzou','15:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(527,62,'Wilaya d\' Alger','16:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(528,62,'Wilaya de Djelfa','17:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(529,62,'Wilaya de Jijel','18:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(530,62,'Wilaya de Setif','19:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(531,62,'Wilaya de Saida','20:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(532,62,'Annaba','23:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(533,62,'Wilaya de Constantine','25:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(534,62,'Wilaya de Mascara','29:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(535,62,'Wilaya de Ouargla','30:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(536,62,'Oran','31:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(537,62,'Illizi','33:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(538,62,'Wilaya de Bordj Bou Arreridj','34:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(539,62,'El Tarf','36:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(540,62,'Wilaya de Tissemsilt','38:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(541,62,'Wilaya de Souk Ahras','41:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(542,62,'Wilaya de Tipaza','42:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(543,62,'Wilaya de Ghardaia','47:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(544,62,'Wilaya de Relizane','48:DZ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(545,62,'I prefer not to specify the state','__:DZ',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(546,63,'Provincia del Azuay','A:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(547,63,'Provincia de Bolivar','B:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(548,63,'Provincia del Carchi','C:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(549,63,'Provincia de Francisco de Orellana','D:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(550,63,'Provincia de Esmeraldas','E:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(551,63,'Provincia del Canar','F:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(552,63,'Provincia del Guayas','G:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(553,63,'Provincia del Chimborazo','H:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(554,63,'Provincia de Imbabura','I:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(555,63,'Provincia de Loja','L:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(556,63,'Provincia de Manabi','M:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(557,63,'Provincia de Napo','N:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(558,63,'Provincia de El Oro','O:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(559,63,'Provincia de Pichincha','P:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(560,63,'Provincia de Los Rios','R:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(561,63,'Provincia de Morona-Santiago','S:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(562,63,'Provincia de Santo Domingo de los Tsachilas','SD:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(563,63,'Provincia de Santa Elena','SE:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(564,63,'Provincia del Tungurahua','T:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(565,63,'Provincia de Sucumbios','U:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(566,63,'Provincia de Cotopaxi','X:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(567,63,'Provincia del Pastaza','Y:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(568,63,'Provincia de Zamora-Chinchipe','Z:EC',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(569,63,'I prefer not to specify the state','__:EC',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(570,64,'Harju','37:EE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(571,64,'Hiiumaa','39:EE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(572,64,'Ida-Virumaa','44:EE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(573,64,'Jõgevamaa','49:EE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(574,64,'Järvamaa','51:EE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(575,64,'Lääne','57:EE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(576,64,'Lääne-Virumaa','59:EE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(577,64,'Põlvamaa','65:EE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(578,64,'Pärnumaa','67:EE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(579,64,'Raplamaa','70:EE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(580,64,'Saare','74:EE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(581,64,'Tartu','78:EE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(582,64,'Valgamaa','82:EE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(583,64,'Viljandimaa','84:EE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(584,64,'Võrumaa','86:EE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(585,64,'I prefer not to specify the state','__:EE',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(586,65,'Alexandria','ALX:EG',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(587,65,'Muhafazat Asyut','AST:EG',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(588,65,'Red Sea','BA:EG',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(589,65,'Beheira Governorate','BH:EG',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(590,65,'Muhafazat Bani Suwayf','BNS:EG',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(591,65,'Muhafazat al Qahirah','C:EG',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(592,65,'Muhafazat ad Daqahliyah','DK:EG',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(593,65,'Muhafazat Dumyat','DT:EG',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(594,65,'Muhafazat al Gharbiyah','GH:EG',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(595,65,'Muhafazat al Jizah','GZ:EG',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(596,65,'Ismailia Governorate','IS:EG',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(597,65,'Muhafazat al Qalyubiyah','KB:EG',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(598,65,'Luxor','LX:EG',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(599,65,'Muhafazat al Minya','MN:EG',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(600,65,'Muhafazat Bur Sa`id','PTS:EG',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(601,65,'Muhafazat Suhaj','SHG:EG',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(602,65,'Eastern Province','SHR:EG',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(603,65,'Muhafazat Shamal Sina\'','SIN:EG',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(604,65,'As Suways','SUZ:EG',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(605,65,'I prefer not to specify the state','__:EG',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(606,66,'Maekel Region','MA:ER',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(607,66,'I prefer not to specify the state','__:ER',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(608,67,'Andalusia','AN:ES',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(609,67,'Aragon','AR:ES',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(610,67,'Principality of Asturias','AS:ES',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(611,67,'Cantabria','CB:ES',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(612,67,'Ceuta','CE:ES',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(613,67,'Castille and León','CL:ES',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(614,67,'Castille-La Mancha','CM:ES',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(615,67,'Canary Islands','CN:ES',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(616,67,'Catalonia','CT:ES',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(617,67,'Extremadura','EX:ES',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(618,67,'Galicia','GA:ES',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(619,67,'Balearic Islands','IB:ES',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(620,67,'Murcia','MC:ES',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(621,67,'Madrid','MD:ES',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(622,67,'Melilla','ML:ES',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(623,67,'Navarre','NC:ES',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(624,67,'Basque Country','PV:ES',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(625,67,'La Rioja','RI:ES',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(626,67,'Valencia','VC:ES',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(627,67,'I prefer not to specify the state','__:ES',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(628,68,'Adis Abeba Astedader','AA:ET',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(629,68,'Afar Region','AF:ET',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(630,68,'Amhara','AM:ET',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(631,68,'Bīnshangul Gumuz','BE:ET',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(632,68,'Dire Dawa','DD:ET',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(633,68,'Gambela','GA:ET',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(634,68,'Harari Region','HA:ET',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(635,68,'Oromiya','OR:ET',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(636,68,'Somali','SO:ET',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(637,68,'Tigray','TI:ET',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(638,68,'I prefer not to specify the state','__:ET',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(639,69,'South Karelia','02:FI',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(640,69,'Southern Ostrobothnia','03:FI',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(641,69,'Southern Savonia','04:FI',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(642,69,'Kainuu','05:FI',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(643,69,'Haeme','06:FI',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(644,69,'Central Ostrobothnia','07:FI',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(645,69,'Central Finland','08:FI',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(646,69,'Lapland','10:FI',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(647,69,'Pirkanmaa','11:FI',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(648,69,'Ostrobothnia','12:FI',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(649,69,'North Karelia','13:FI',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(650,69,'Northern Ostrobothnia','14:FI',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(651,69,'Northern Savo','15:FI',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(652,69,'Päijänne Tavastia','16:FI',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(653,69,'Satakunta','17:FI',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(654,69,'Uusimaa','18:FI',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(655,69,'Varsinais-Suomi','19:FI',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(656,69,'Oulu','OL:FI',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(657,69,'I prefer not to specify the state','__:FI',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(658,70,'Central','C:FJ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(659,70,'Western','W:FJ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(660,70,'I prefer not to specify the state','__:FJ',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(661,71,'not applicable','--:FK',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(662,72,'not applicable','--:FM',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(663,73,'Eysturoy','Eysturoy:FO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(664,73,'Norðoyar','Nor??oyar:FO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(665,73,'Streymoy','Streymoy:FO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(666,73,'Suðuroy','Su??uroy:FO',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(667,73,'I prefer not to specify the state','__:FO',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(668,74,'Alsace','A:FR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(669,74,'Aquitaine','B:FR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(670,74,'Auvergne','C:FR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(671,74,'Bourgogne','D:FR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(672,74,'Brittany','E:FR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(673,74,'Centre','F:FR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(674,74,'Champagne-Ardenne','G:FR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(675,74,'Corsica','H:FR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(676,74,'Franche-Comté','I:FR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(677,74,'Île-de-France','J:FR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(678,74,'Languedoc-Roussillon','K:FR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(679,74,'Limousin','L:FR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(680,74,'Lorraine','M:FR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(681,74,'Midi-Pyrénées','N:FR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(682,74,'Nord-Pas-de-Calais','O:FR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(683,74,'Lower Normandy','P:FR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(684,74,'Haute-Normandie','Q:FR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(685,74,'Pays de la Loire','R:FR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(686,74,'Picardie','S:FR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(687,74,'Poitou-Charentes','T:FR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(688,74,'Provence-Alpes-Côte d\'Azur','U:FR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(689,74,'Rhône-Alpes','V:FR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(690,74,'I prefer not to specify the state','__:FR',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(691,75,'Estuaire','1:GA',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(692,75,'Province du Haut-Ogooue','2:GA',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(693,75,'Province du Moyen-Ogooue','3:GA',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(694,75,'Province de la Ngounie','4:GA',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(695,75,'Province de l\'Ogooue-Maritime','8:GA',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(696,75,'I prefer not to specify the state','__:GA',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(697,76,'England','ENG:GB',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(698,76,'Kent','KEN:GB',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(699,76,'City of London','LND:GB',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(700,76,'Northern Ireland','NIR:GB',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(701,76,'Scotland','SCT:GB',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(702,76,'Somerset','SOM:GB',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(703,76,'Surrey','SRY:GB',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(704,76,'Wales','WLS:GB',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(705,76,'I prefer not to specify the state','__:GB',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(706,77,'Saint George','03:GD',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(707,77,'Saint John','04:GD',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(708,77,'Saint Patrick','06:GD',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(709,77,'I prefer not to specify the state','__:GD',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(710,78,'Abkhazia','AB:GE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(711,78,'Ajaria','AJ:GE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(712,78,'Guria','GU:GE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(713,78,'Imereti','IM:GE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(714,78,'Mtskheta-Mtianeti','MM:GE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(715,78,'Racha-Lechkhumi and Kvemo Svaneti','RL:GE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(716,78,'Shida Kartli','SK:GE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(717,78,'Samegrelo and Zemo Svaneti','SZ:GE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(718,78,'K\'alak\'i T\'bilisi','TB:GE',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(719,78,'I prefer not to specify the state','__:GE',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(720,79,'not applicable','--:GF',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(721,80,'Saint Peter Port','Saint Peter Port:GG',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(722,80,'I prefer not to specify the state','__:GG',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(723,81,'Greater Accra Region','AA:GH',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(724,81,'Ashanti Region','AH:GH',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(725,81,'Brong-Ahafo','BA:GH',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(726,81,'Central Region','CP:GH',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(727,81,'Eastern Region','EP:GH',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(728,81,'Volta Region','TV:GH',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(729,81,'Upper East Region','UE:GH',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(730,81,'Upper West Region','UW:GH',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(731,81,'Western Region','WP:GH',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(732,81,'I prefer not to specify the state','__:GH',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(733,82,'not applicable','--:GI',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(734,83,'Kujalleq','KU:GL',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(735,83,'Qaasuitsup','QA:GL',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(736,83,'Qeqqata','QE:GL',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(737,83,'Sermersooq','SM:GL',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(738,83,'I prefer not to specify the state','__:GL',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(739,84,'City of Banjul','B:GM',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(740,84,'I prefer not to specify the state','__:GM',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(741,85,'Boke Region','B:GN',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(742,85,'Conakry Region','C:GN',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(743,85,'Kindia','D:GN',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(744,85,'Faranah','F:GN',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(745,85,'Kankan Region','K:GN',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(746,85,'Labe Region','L:GN',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(747,85,'Mamou Region','M:GN',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(748,85,'Nzerekore Region','N:GN',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(749,85,'I prefer not to specify the state','__:GN',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(750,86,'not applicable','--:GP',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(751,87,'Provincia de Bioko Norte','BN:GQ',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(752,87,'I prefer not to specify the state','__:GQ',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(753,88,'East Macedonia and Thrace','A:GR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(754,88,'Central Macedonia','B:GR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(755,88,'West Macedonia','C:GR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(756,88,'Epirus','D:GR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(757,88,'Thessaly','E:GR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(758,88,'Ionian Islands','F:GR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(759,88,'West Greece','G:GR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(760,88,'Central Greece','H:GR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(761,88,'Attica','I:GR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(762,88,'Peloponnese','J:GR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(763,88,'North Aegean','K:GR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(764,88,'South Aegean','L:GR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(765,88,'Crete','M:GR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(766,88,'I prefer not to specify the state','__:GR',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(767,89,'not applicable','--:GS',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(768,90,'Departamento de Alta Verapaz','AV:GT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(769,90,'Departamento de Chimaltenango','CM:GT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(770,90,'Departamento de Chiquimula','CQ:GT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(771,90,'Departamento de Escuintla','ES:GT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(772,90,'Departamento de Guatemala','GU:GT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(773,90,'Departamento de Huehuetenango','HU:GT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(774,90,'Departamento de Izabal','IZ:GT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(775,90,'Departamento de Jutiapa','JU:GT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(776,90,'Departamento del Peten','PE:GT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(777,90,'Departamento de Quetzaltenango','QZ:GT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(778,90,'Departamento de Retalhuleu','RE:GT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(779,90,'Departamento de Sacatepequez','SA:GT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(780,90,'Departamento de San Marcos','SM:GT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(781,90,'Departamento de Solola','SO:GT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(782,90,'Departamento de Santa Rosa','SR:GT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(783,90,'Suchitepeque','SU:GT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(784,90,'Departamento de Totonicapan','TO:GT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(785,90,'Departamento de Zacapa','ZA:GT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(786,90,'I prefer not to specify the state','__:GT',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(787,91,'Santa Rita Municipality','Santa Rita Municipality:GU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(788,91,'Barrigada','Barrigada:GU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(789,91,'Dededo','Dededo:GU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(790,91,'Hagatna','Hagatna:GU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(791,91,'Inarajan','Inarajan:GU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(792,91,'Tamuning','Tamuning:GU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(793,91,'Yigo','Yigo:GU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(794,91,'I prefer not to specify the state','__:GU',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(795,92,'Bissau','BS:GW',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(796,92,'Cacheu Region','CA:GW',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(797,92,'I prefer not to specify the state','__:GW',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(798,93,'Demerara-Mahaica Region','DE:GY',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(799,93,'East Berbice-Corentyne Region','EB:GY',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(800,93,'Upper Demerara-Berbice Region','UD:GY',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(801,93,'I prefer not to specify the state','__:GY',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(802,94,'Southern','HSO:HK',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(803,94,'Wanchai','HWC:HK',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(804,94,'Kowloon City','KKC:HK',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(805,94,'Kwon Tong','KKT:HK',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(806,94,'Sham Shui Po','KSS:HK',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(807,94,'Wong Tai Sin','KWT:HK',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(808,94,'Sha Tin','NST:HK',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(809,94,'Yuen Long District','NYL:HK',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(810,94,'I prefer not to specify the state','__:HK',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(811,95,'Departamento de Atlantida','AT:HN',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(812,95,'Departamento de Comayagua','CM:HN',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(813,95,'Departamento de Copan','CP:HN',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(814,95,'Departamento de Cortes','CR:HN',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(815,95,'Departamento de El Paraiso','EP:HN',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(816,95,'Departamento de Francisco Morazan','FM:HN',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(817,95,'Departamento de Gracias a Dios','GD:HN',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(818,95,'Bay Islands','IB:HN',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(819,95,'Departamento de Intibuca','IN:HN',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(820,95,'Departamento de Lempira','LE:HN',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(821,95,'Departamento de Santa Barbara','SB:HN',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(822,95,'Departamento de Valle','VA:HN',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(823,95,'Departamento de Yoro','YO:HN',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(824,95,'I prefer not to specify the state','__:HN',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(825,96,'Zagreb County','01:HR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(826,96,'Krapinsko-Zagorska Zupanija','02:HR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(827,96,'Sisacko-Moslavacka Zupanija','03:HR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(828,96,'Karlovacka Zupanija','04:HR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(829,96,'Varazdinska Zupanija','05:HR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(830,96,'Koprivnicko-Krizevacka Zupanija','06:HR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(831,96,'Bjelovarsko-Bilogorska Zupanija','07:HR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(832,96,'Primorsko-Goranska Zupanija','08:HR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(833,96,'Licko-Senjska Zupanija','09:HR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(834,96,'Viroviticko-Podravska Zupanija','10:HR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(835,96,'Pozesko-Slavonska Zupanija','11:HR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(836,96,'Brodsko-Posavska Zupanija','12:HR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(837,96,'Zadarska Zupanija','13:HR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(838,96,'Osjecko-Baranjska Zupanija','14:HR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(839,96,'Sibensko-Kninska Zupanija','15:HR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(840,96,'Vukovarsko-Srijemska Zupanija','16:HR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(841,96,'Splitsko-Dalmatinska Zupanija','17:HR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(842,96,'Istarska Zupanija','18:HR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(843,96,'Dubrovacko-Neretvanska Zupanija','19:HR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(844,96,'Medimurska Zupanija','20:HR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(845,96,'Grad Zagreb','21:HR',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(846,96,'I prefer not to specify the state','__:HR',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(847,97,'Centre','CE:HT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(848,97,'Nord','ND:HT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(849,97,'Departement du Nord-Est','NE:HT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(850,97,'Departement de l\'Ouest','OU:HT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(851,97,'Sud-Est','SE:HT',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(852,97,'I prefer not to specify the state','__:HT',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(853,98,'Baranya','BA:HU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(854,98,'Bekes','BE:HU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(855,98,'Bács-Kiskun','BK:HU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(856,98,'Budapest fovaros','BU:HU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(857,98,'Borsod-Abaúj-Zemplén','BZ:HU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(858,98,'Csongrad megye','CS:HU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(859,98,'Fejér','FE:HU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(860,98,'Győr-Moson-Sopron','GS:HU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(861,98,'Hajdú-Bihar','HB:HU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(862,98,'Heves megye','HE:HU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(863,98,'Jász-Nagykun-Szolnok','JN:HU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(864,98,'Komárom-Esztergom','KE:HU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(865,98,'Nograd megye','NO:HU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(866,98,'Pest megye','PE:HU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(867,98,'Somogy megye','SO:HU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(868,98,'Szabolcs-Szatmár-Bereg','SZ:HU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(869,98,'Tolna megye','TO:HU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(870,98,'Vas','VA:HU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(871,98,'Veszprem megye','VE:HU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(872,98,'Zala','ZA:HU',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(873,98,'I prefer not to specify the state','__:HU',1,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(874,99,'Nanggroe Aceh Darussalam Province','AC:ID',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(875,99,'Bali','BA:ID',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(876,99,'Bangka–Belitung Islands','BB:ID',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(877,99,'Propinsi Bengkulu','BE:ID',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(878,99,'Banten','BT:ID',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(879,99,'Provinsi Gorontalo','GO:ID',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(880,99,'Provinsi Jambi','JA:ID',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(881,99,'West Java','JB:ID',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(882,99,'East Java','JI:ID',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(883,99,'Daerah Khusus Ibukota Jakarta','JK:ID',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(884,99,'Central Java','JT:ID',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(885,99,'West Kalimantan','KB:ID',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(886,99,'East Kalimantan','KI:ID',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(887,99,'Riau Islands','KR:ID',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(888,99,'South Kalimantan','KS:ID',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(889,99,'Central Kalimantan','KT:ID',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(890,99,'Provinsi Lampung','LA:ID',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(891,99,'Provinsi Maluku','MA:ID',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(892,99,'Provinsi Maluku Utara','MU:ID',0,'2019-09-23 11:40:11','2019-09-23 11:40:11'),
(893,99,'West Nusa Tenggara','NB:ID',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(894,99,'East Nusa Tenggara','NT:ID',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(895,99,'Provinsi Papua','PA:ID',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(896,99,'West Papua','PB:ID',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(897,99,'Provinsi Riau','RI:ID',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(898,99,'North Sulawesi','SA:ID',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(899,99,'West Sumatra','SB:ID',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(900,99,'Sulawesi Tenggara','SG:ID',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(901,99,'South Sulawesi','SN:ID',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(902,99,'Provinsi Sulawesi Barat','SR:ID',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(903,99,'South Sumatra','SS:ID',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(904,99,'Central Sulawesi','ST:ID',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(905,99,'North Sumatra','SU:ID',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(906,99,'Daerah Istimewa Yogyakarta','YO:ID',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(907,99,'I prefer not to specify the state','__:ID',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(908,100,'Connaught','C:IE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(909,100,'County Galway','G:IE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(910,100,'Leinster','L:IE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(911,100,'Munster','M:IE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(912,100,'Ulster','U:IE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(913,100,'County Wexford','WX:IE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(914,100,'I prefer not to specify the state','__:IE',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(915,101,'Southern District','D:IL',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(916,101,'Haifa','HA:IL',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(917,101,'Jerusalem','JM:IL',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(918,101,'Central District','M:IL',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(919,101,'Tel Aviv','TA:IL',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(920,101,'Northern District','Z:IL',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(921,101,'I prefer not to specify the state','__:IL',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(922,102,'not applicable','--:IM',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(923,103,'Union Territory of Andaman and Nicobar Islands','AN:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(924,103,'Andhra Pradesh','AP:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(925,103,'Arunachal Pradesh','AR:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(926,103,'Assam','AS:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(927,103,'Bihar','BR:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(928,103,'Chandigarh','CH:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(929,103,'State of Chhattisgarh','CT:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(930,103,'Daman and Diu','DD:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(931,103,'National Capital Territory of Delhi','DL:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(932,103,'Dadra and Nagar Haveli','DN:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(933,103,'Goa','GA:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(934,103,'Gujarat','GJ:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(935,103,'State of Himachal Pradesh','HP:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(936,103,'Haryana','HR:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(937,103,'State of Jharkhand','JH:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(938,103,'Kashmir','JK:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(939,103,'Karnataka','KA:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(940,103,'Kerala','KL:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(941,103,'Laccadives','LD:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(942,103,'Maharashtra','MH:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(943,103,'Meghalaya','ML:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(944,103,'Manipur','MN:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(945,103,'Madhya Pradesh','MP:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(946,103,'Mizoram','MZ:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(947,103,'Nagaland','NL:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(948,103,'Odisha','OR:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(949,103,'State of Punjab','PB:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(950,103,'Union Territory of Puducherry','PY:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(951,103,'Rajasthan','RJ:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(952,103,'Sikkim','SK:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(953,103,'Telangana','TG:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(954,103,'Tamil Nadu','TN:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(955,103,'Tripura','TR:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(956,103,'Uttarakhand','UL:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(957,103,'Uttar Pradesh','UP:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(958,103,'West Bengal','WB:IN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(959,103,'I prefer not to specify the state','__:IN',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(960,104,'not applicable','--:IO',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(961,105,'Anbar','AN:IQ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(962,105,'Muhafazat Arbil','AR:IQ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(963,105,'Muhafazat al Basrah','BA:IQ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(964,105,'Muhafazat Babil','BB:IQ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(965,105,'Mayorality of Baghdad','BG:IQ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(966,105,'Dihok','DA:IQ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(967,105,'Diyālá','DI:IQ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(968,105,'Dhi Qar','DQ:IQ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(969,105,'Maysan','MA:IQ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(970,105,'An Najaf','NA:IQ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(971,105,'Muhafazat Ninawa','NI:IQ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(972,105,'Muhafazat Salah ad Din','SD:IQ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(973,105,'Muhafazat as Sulaymaniyah','SU:IQ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(974,105,'Muhafazat Kirkuk','TS:IQ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(975,105,'I prefer not to specify the state','__:IQ',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(976,106,'East Azerbaijan','01:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(977,106,'Ostan-e Azarbayjan-e Gharbi','02:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(978,106,'Ostan-e Ardabil','03:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(979,106,'Isfahan','04:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(980,106,'Ostan-e Ilam','05:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(981,106,'Bushehr','06:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(982,106,'Ostan-e Tehran','07:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(983,106,'Ostan-e Chahar Mahal va Bakhtiari','08:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(984,106,'Khuzestan','10:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(985,106,'Zanjan','11:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(986,106,'Semnān','12:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(987,106,'Sistan and Baluchestan','13:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(988,106,'Fars','14:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(989,106,'Kerman','15:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(990,106,'Ostan-e Kordestan','16:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(991,106,'Ostan-e Kermanshah','17:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(992,106,'Ostan-e Kohgiluyeh va Bowyer Ahmad','18:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(993,106,'Ostan-e Gilan','19:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(994,106,'Ostan-e Lorestan','20:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(995,106,'Māzandarān','21:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(996,106,'Markazi','22:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(997,106,'Hormozgan','23:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(998,106,'Ostan-e Hamadan','24:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(999,106,'Yazd','25:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1000,106,'Qom','26:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1001,106,'Ostan-e Golestan','27:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1002,106,'Ostan-e Qazvin','28:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1003,106,'Ostan-e Khorasan-e Jonubi','29:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1004,106,'Razavi Khorasan','30:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1005,106,'Ostan-e Khorasan-e Shomali','31:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1006,106,'Alborz','Alborz:IR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1007,106,'I prefer not to specify the state','__:IR',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1008,107,'Capital Region','1:IS',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1009,107,'Southern Peninsula','2:IS',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1010,107,'West','3:IS',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1011,107,'Westfjords','4:IS',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1012,107,'Northwest','5:IS',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1013,107,'Northeast','6:IS',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1014,107,'South','8:IS',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1015,107,'I prefer not to specify the state','__:IS',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1016,108,'Piedmont','21:IT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1017,108,'Aosta Valley','23:IT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1018,108,'Lombardy','25:IT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1019,108,'Trentino-Alto Adige','32:IT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1020,108,'Veneto','34:IT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1021,108,'Friuli Venezia Giulia','36:IT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1022,108,'Liguria','42:IT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1023,108,'Emilia-Romagna','45:IT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1024,108,'Tuscany','52:IT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1025,108,'Umbria','55:IT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1026,108,'The Marches','57:IT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1027,108,'Latium','62:IT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1028,108,'Abruzzo','65:IT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1029,108,'Molise','67:IT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1030,108,'Campania','72:IT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1031,108,'Apulia','75:IT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1032,108,'Basilicate','77:IT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1033,108,'Calabria','78:IT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1034,108,'Sicily','82:IT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1035,108,'Sardinia','88:IT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1036,108,'I prefer not to specify the state','__:IT',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1037,109,'Saint Helier','Saint Helier:JE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1038,109,'I prefer not to specify the state','__:JE',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1039,110,'Kingston','01:JM',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1040,110,'Parish of Saint Andrew','02:JM',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1041,110,'Parish of Saint Mary','05:JM',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1042,110,'Parish of Saint Ann','06:JM',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1043,110,'Parish of Saint James','08:JM',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1044,110,'Parish of Westmoreland','10:JM',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1045,110,'St. Elizabeth','11:JM',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1046,110,'Parish of Manchester','12:JM',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1047,110,'Parish of Clarendon','13:JM',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1048,110,'Parish of Saint Catherine','14:JM',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1049,110,'I prefer not to specify the state','__:JM',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1050,111,'Amman','AM:JO',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1051,111,'Balqa','BA:JO',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1052,111,'Irbid','IR:JO',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1053,111,'Mafraq','MA:JO',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1054,111,'Madaba','MD:JO',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1055,111,'I prefer not to specify the state','__:JO',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1056,112,'Hokkaidō','01:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1057,112,'Aomori','02:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1058,112,'Iwate','03:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1059,112,'Miyagi','04:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1060,112,'Akita','05:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1061,112,'Yamagata','06:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1062,112,'Fukushima-ken','07:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1063,112,'Ibaraki','08:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1064,112,'Tochigi','09:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1065,112,'Gunma','10:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1066,112,'Saitama','11:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1067,112,'Chiba','12:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1068,112,'Tōkyō','13:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1069,112,'Kanagawa','14:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1070,112,'Niigata','15:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1071,112,'Toyama','16:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1072,112,'Ishikawa','17:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1073,112,'Fukui','18:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1074,112,'Yamanashi','19:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1075,112,'Nagano','20:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1076,112,'Gifu','21:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1077,112,'Shizuoka','22:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1078,112,'Aichi','23:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1079,112,'Mie','24:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1080,112,'Shiga Prefecture','25:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1081,112,'Kyōto','26:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1082,112,'Ōsaka','27:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1083,112,'Hyōgo','28:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1084,112,'Nara','29:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1085,112,'Wakayama','30:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1086,112,'Tottori','31:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1087,112,'Shimane','32:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1088,112,'Okayama','33:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1089,112,'Hiroshima','34:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1090,112,'Yamaguchi','35:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1091,112,'Tokushima','36:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1092,112,'Kagawa','37:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1093,112,'Ehime','38:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1094,112,'Kōchi','39:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1095,112,'Fukuoka','40:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1096,112,'Saga Prefecture','41:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1097,112,'Nagasaki','42:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1098,112,'Kumamoto','43:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1099,112,'Ōita','44:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1100,112,'Miyazaki','45:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1101,112,'Kagoshima','46:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1102,112,'Okinawa','47:JP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1103,112,'I prefer not to specify the state','__:JP',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1104,113,'Garissa District','Garissa District:KE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1105,113,'Homa Bay District','Homa Bay District:KE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1106,113,'Kakamega District','Kakamega District:KE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1107,113,'Kiambu District','Kiambu District:KE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1108,113,'Kisii District','Kisii District:KE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1109,113,'Kitui District','Kitui District:KE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1110,113,'Kwale District','Kwale District:KE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1111,113,'Machakos District','Machakos District:KE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1112,113,'Makueni District','Makueni District:KE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1113,113,'Mandera District','Mandera District:KE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1114,113,'Mombasa District','Mombasa District:KE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1115,113,'Nakuru District','Nakuru District:KE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1116,113,'Nandi South District','Nandi South District:KE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1117,113,'Siaya District','Siaya District:KE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1118,113,'Tharaka District','Tharaka District:KE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1119,113,'Trans Nzoia District','Trans Nzoia District:KE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1120,113,'Uasin Gishu','Uasin Gishu:KE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1121,113,'Nairobi Province','110:KE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1122,113,'Kisumu','Kisumu:KE',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1123,113,'I prefer not to specify the state','__:KE',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1124,114,'Chuyskaya Oblast\'','C:KG',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1125,114,'I prefer not to specify the state','__:KG',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1126,115,'Banteay Meanchey','1:KH',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1127,115,'Phnom Penh','12:KH',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1128,115,'Preah Sihanouk','18:KH',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1129,115,'Battambang','2:KH',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1130,115,'Kampong Chhnang','4:KH',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1131,115,'Kampong Speu','5:KH',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1132,115,'Kampong Thom','6:KH',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1133,115,'Kandal','8:KH',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1134,115,'I prefer not to specify the state','__:KH',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1135,116,'Gilbert Islands','G:KI',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1136,116,'I prefer not to specify the state','__:KI',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1137,117,'Ndzuwani','A:KM',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1138,117,'Grande Comore','G:KM',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1139,117,'I prefer not to specify the state','__:KM',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1140,118,'Saint Anne Sandy Point','02:KN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1141,118,'Saint George Basseterre','03:KN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1142,118,'Saint Paul Charlestown','10:KN',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1143,118,'I prefer not to specify the state','__:KN',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1144,119,'Pyongyang','01:KP',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1145,119,'I prefer not to specify the state','__:KP',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1146,120,'Seoul','11:KR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1147,120,'Busan','26:KR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1148,120,'Daegu','27:KR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1149,120,'Incheon','28:KR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1150,120,'Gwangju','29:KR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1151,120,'Daejeon','30:KR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1152,120,'Ulsan','31:KR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1153,120,'Gyeonggi-do','41:KR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1154,120,'Gangwon-do','42:KR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1155,120,'Chungcheongbuk-do','43:KR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1156,120,'Chungcheongnam-do','44:KR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1157,120,'Jeollabuk-do','45:KR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1158,120,'Jeollanam-do','46:KR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1159,120,'Gyeongsangbuk-do','47:KR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1160,120,'Gyeongsangnam-do','48:KR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1161,120,'Jeju-do','49:KR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1162,120,'I prefer not to specify the state','__:KR',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1163,121,'Al Aḩmadī','AH:KW',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1164,121,'Al Farwaniyah','FA:KW',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1165,121,'Muhafazat Hawalli','HA:KW',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1166,121,'Al Asimah','KU:KW',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1167,121,'I prefer not to specify the state','__:KW',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1168,122,'not applicable','--:KY',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1169,123,'Aqmola Oblysy','AKM:KZ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1170,123,'Aktyubinskaya Oblast\'','AKT:KZ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1171,123,'Almaty Qalasy','ALA:KZ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1172,123,'Almaty Oblysy','ALM:KZ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1173,123,'Astana Qalasy','AST:KZ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1174,123,'Atyrau Oblysy','ATY:KZ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1175,123,'Bayqongyr Qalasy','BAY:KZ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1176,123,'Qaraghandy Oblysy','KAR:KZ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1177,123,'Qostanay Oblysy','KUS:KZ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1178,123,'Qyzylorda Oblysy','KZY:KZ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1179,123,'Mangistauskaya Oblast\'','MAN:KZ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1180,123,'Pavlodar Oblysy','PAV:KZ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1181,123,'Severo-Kazakhstanskaya Oblast\'','SEV:KZ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1182,123,'East Kazakhstan','VOS:KZ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1183,123,'Yuzhno-Kazakhstanskaya Oblast\'','YUZ:KZ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1184,123,'Batys Qazaqstan Oblysy','ZAP:KZ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1185,123,'Zhambyl Oblysy','ZHA:KZ',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1186,123,'I prefer not to specify the state','__:KZ',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1187,124,'Vientiane','VT:LA',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1188,124,'I prefer not to specify the state','__:LA',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1189,125,'Mohafazat Aakkar','AK:LB',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1190,125,'Mohafazat Liban-Nord','AS:LB',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1191,125,'Beyrouth','BA:LB',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1192,125,'Mohafazat Baalbek-Hermel','BH:LB',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1193,125,'Mohafazat Liban-Sud','JA:LB',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1194,125,'Mohafazat Mont-Liban','JL:LB',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1195,125,'I prefer not to specify the state','__:LB',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1196,126,'Anse-la-Raye','AR:LC',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1197,126,'Castries Quarter','CA:LC',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1198,126,'Choiseul Quarter','CH:LC',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1199,126,'Gros-Islet','GI:LC',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1200,126,'Vieux-Fort','VF:LC',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1201,126,'I prefer not to specify the state','__:LC',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1202,127,'Balzers','01:LI',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1203,127,'Eschen','02:LI',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1204,127,'Gemeinde Gamprin','03:LI',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1205,127,'Mauren','04:LI',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1206,127,'Planken','05:LI',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1207,127,'Ruggell','06:LI',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1208,127,'Schaan','07:LI',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1209,127,'Schellenberg','08:LI',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1210,127,'Triesen','09:LI',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1211,127,'Triesenberg','10:LI',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1212,127,'Vaduz','11:LI',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1213,127,'I prefer not to specify the state','__:LI',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1214,128,'Western Province','1:LK',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1215,128,'Central Province','2:LK',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1216,128,'Eastern Province','5:LK',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1217,128,'North Western Province','6:LK',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1218,128,'North Central Province','7:LK',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1219,128,'Province of Uva','8:LK',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1220,128,'I prefer not to specify the state','__:LK',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1221,129,'River Gee County','River Gee County:LR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1222,129,'Montserrado County','MO:LR',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1223,129,'I prefer not to specify the state','__:LR',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1224,130,'Maseru','A:LS',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1225,130,'I prefer not to specify the state','__:LS',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1226,131,'Alytaus apskritis','AL:LT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1227,131,'Klaipedos apskritis','KL:LT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1228,131,'Kauno apskritis','KU:LT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1229,131,'Marijampoles apskritis','MR:LT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1230,131,'Panevėžys','PN:LT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1231,131,'Siauliu apskritis','SA:LT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1232,131,'Taurages apskritis','TA:LT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1233,131,'Telsiu apskritis','TE:LT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1234,131,'Utenos apskritis','UT:LT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1235,131,'Vilnius County','VL:LT',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1236,131,'I prefer not to specify the state','__:LT',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1237,132,'District de Diekirch','D:LU',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1238,132,'District de Grevenmacher','G:LU',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1239,132,'District de Luxembourg','L:LU',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1240,132,'I prefer not to specify the state','__:LU',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1241,133,'Aizkraukles Rajons','002:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1242,133,'Aizpute','003:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1243,133,'Aluksnes Rajons','007:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1244,133,'Ādaži','011:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1245,133,'Baldone','013:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1246,133,'Balvu Rajons','015:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1247,133,'Bauskas Rajons','016:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1248,133,'Carnikava','020:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1249,133,'Cesu Rajons','022:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1250,133,'Daugavpils','025:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1251,133,'Dobeles Rajons','026:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1252,133,'Dundaga','027:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1253,133,'Engure','029:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1254,133,'Gulbenes Rajons','033:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1255,133,'Ikšķile','035:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1256,133,'Jaunjelgava','038:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1257,133,'Jelgavas Rajons','041:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1258,133,'Jekabpils Municipality','042:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1259,133,'Kandava','043:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1260,133,'Kraslavas Rajons','047:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1261,133,'Kuldigas Rajons','050:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1262,133,'Ķegums','051:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1263,133,'Ķekava','052:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1264,133,'Lielvārde','053:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1265,133,'Limbazu Rajons','054:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1266,133,'Līvāni','056:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1267,133,'Ludzas Rajons','058:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1268,133,'Madona Municipality','059:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1269,133,'Mazsalaca','060:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1270,133,'Mālpils','061:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1271,133,'Mārupe','062:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1272,133,'Ogre','067:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1273,133,'Olaine','068:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1274,133,'Ozolnieku Novads','069:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1275,133,'Preili Municipality','073:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1276,133,'Rezeknes Rajons','077:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1277,133,'Ropazu Novads','080:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1278,133,'Rundales Novads','083:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1279,133,'Salaspils Novads','087:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1280,133,'Saldus Municipality','088:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1281,133,'Siguldas Novads','091:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1282,133,'Smiltenes Novads','094:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1283,133,'Strencu Novads','096:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1284,133,'Talsi Municipality','097:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1285,133,'Tukuma Rajons','099:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1286,133,'Valka Municipality','101:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1287,133,'Varaklanu Novads','102:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1288,133,'Ventspils Municipality','106:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1289,133,'Viesites Novads','107:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1290,133,'Zilupes Novads','110:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1291,133,'Jelgava','JEL:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1292,133,'Jurmala','JUR:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1293,133,'Liepaja','LPX:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1294,133,'Rezekne','REZ:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1295,133,'Riga','RIX:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1296,133,'Valmiera District','VMR:LV',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1297,133,'I prefer not to specify the state','__:LV',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1298,134,'Sha`biyat Banghazi','BA:LY',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1299,134,'Sha`biyat Misratah','MI:LY',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1300,134,'Sha`biyat Nalut','NL:LY',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1301,134,'Sha`biyat Sabha','SB:LY',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1302,134,'Tripoli','TB:LY',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1303,134,'I prefer not to specify the state','__:LY',1,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1304,135,'Region de Tanger-Tetouan','01:MA',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1305,135,'Gharb-Chrarda-Beni Hssen','02:MA',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1306,135,'Taza-Al Hoceima-Taounate','03:MA',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1307,135,'Oriental','04:MA',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1308,135,'Region de Fes-Boulemane','05:MA',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1309,135,'Region de Meknes-Tafilalet','06:MA',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1310,135,'Region de Rabat-Sale-Zemmour-Zaer','07:MA',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1311,135,'Region du Grand Casablanca','08:MA',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1312,135,'Chaouia-Ouardigha','09:MA',0,'2019-09-23 11:40:12','2019-09-23 11:40:12'),
(1313,135,'Doukkala-Abda','10:MA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1314,135,'Marrakech-Tensift-Al Haouz','11:MA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1315,135,'Tadla-Azilal','12:MA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1316,135,'Region de Souss-Massa-Draa','13:MA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1317,135,'Guelmim-Es Semara','14:MA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1318,135,'Laayoune-Boujdour-Sakia El Hamra','15:MA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1319,135,'I prefer not to specify the state','__:MA',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1320,136,'not applicable','--:MC',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1321,137,'Anenii Noi','AN:MD',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1322,137,'Municipiul Balti','BA:MD',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1323,137,'Municipiul Bender','BD:MD',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1324,137,'Cahul','CA:MD',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1325,137,'Raionul Calarasi','CL:MD',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1326,137,'Criuleni','CR:MD',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1327,137,'Municipiul Chisinau','CU:MD',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1328,137,'Donduşeni','DO:MD',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1329,137,'Drochia','DR:MD',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1330,137,'Raionul Edineţ','ED:MD',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1331,137,'Gagauzia','GA:MD',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1332,137,'Hînceşti','HI:MD',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1333,137,'Laloveni','IA:MD',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1334,137,'Nisporeni','NI:MD',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1335,137,'Orhei','OR:MD',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1336,137,'Unitatea Teritoriala din Stinga Nistrului','SN:MD',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1337,137,'Raionul Soroca','SO:MD',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1338,137,'Strășeni','ST:MD',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1339,137,'I prefer not to specify the state','__:MD',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1340,138,'Budva','05:ME',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1341,138,'Herceg Novi','08:ME',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1342,138,'Kotor','10:ME',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1343,138,'Opstina Niksic','12:ME',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1344,138,'Pljevlja','14:ME',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1345,138,'Podgorica','16:ME',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1346,138,'Ulcinj','20:ME',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1347,138,'I prefer not to specify the state','__:ME',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1348,139,'not applicable','--:MF',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1349,140,'Analamanga Region','Analamanga Region:MG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1350,140,'Atsimo-Andrefana Region','Atsimo-Andrefana Region:MG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1351,140,'Atsinanana Region','Atsinanana Region:MG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1352,140,'Boeny Region','Boeny Region:MG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1353,140,'Diana Region','Diana Region:MG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1354,140,'Sava Region','Sava Region:MG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1355,140,'Upper Matsiatra','Upper Matsiatra:MG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1356,140,'Vakinankaratra Region','Vakinankaratra Region:MG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1357,140,'I prefer not to specify the state','__:MG',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1358,141,'not applicable','--:MH',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1359,142,'Berovo','03:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1360,142,'Bitola','04:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1361,142,'Bogdanci','05:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1362,142,'Veles','13:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1363,142,'Gevgelija','18:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1364,142,'Gostivar','19:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1365,142,'Debar','21:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1366,142,'Opstina Delcevo','23:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1367,142,'Demir Hisar','25:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1368,142,'Ilinden','34:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1369,142,'Kavadarci','36:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1370,142,'Opstina Karpos','38:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1371,142,'Opstina Kicevo','40:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1372,142,'Opstina Kocani','42:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1373,142,'Kumanovo','47:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1374,142,'Makedonska Kamenica','51:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1375,142,'Negotino','54:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1376,142,'Novo Selo','56:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1377,142,'Ohrid','58:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1378,142,'Prilep','62:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1379,142,'Opstina Probistip','63:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1380,142,'Opstina Radovis','64:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1381,142,'Opstina Stip','70:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1382,142,'Struga','71:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1383,142,'Strumica','72:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1384,142,'Tetovo','76:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1385,142,'Čair','79:MK',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1386,142,'I prefer not to specify the state','__:MK',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1387,143,'Bamako Region','BKO:ML',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1388,143,'I prefer not to specify the state','__:ML',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1389,144,'Magway Region','03:MM',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1390,144,'Mandalay Region','04:MM',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1391,144,'Yangon Region','06:MM',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1392,144,'Kayin State','13:MM',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1393,144,'Shan State','17:MM',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1394,144,'I prefer not to specify the state','__:MM',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1395,145,'Darhan-Uul Aymag','037:MN',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1396,145,'Hentiy Aymag','039:MN',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1397,145,'Hovsgol Aymag','041:MN',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1398,145,'Hovd','043:MN',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1399,145,'Central Aimak','047:MN',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1400,145,'Selenge Aymag','049:MN',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1401,145,'Suhbaatar Aymag','051:MN',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1402,145,'Ömnögovĭ','053:MN',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1403,145,'Övörhangay','055:MN',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1404,145,'Dzavhan Aymag','057:MN',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1405,145,'Middle Govĭ','059:MN',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1406,145,'East Aimak','061:MN',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1407,145,'East Gobi Aymag','063:MN',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1408,145,'Govi-Sumber','064:MN',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1409,145,'Govi-Altay Aymag','065:MN',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1410,145,'Bulgan','067:MN',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1411,145,'Bayanhongor Aymag','069:MN',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1412,145,'Bayan-Olgiy Aymag','071:MN',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1413,145,'Arhangay Aymag','073:MN',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1414,145,'Ulaanbaatar Hot','1:MN',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1415,145,'I prefer not to specify the state','__:MN',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1416,146,'not applicable','--:MO',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1417,147,'Saipan','S:MP',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1418,147,'I prefer not to specify the state','__:MP',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1419,148,'not applicable','--:MQ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1420,149,'District de Nouakchott','NKC:MR',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1421,149,'I prefer not to specify the state','__:MR',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1422,150,'Parish of Saint Peter','Parish of Saint Peter:MS',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1423,150,'I prefer not to specify the state','__:MS',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1424,151,'Attard','01:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1425,151,'Balzan','02:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1426,151,'Il-Birgu','03:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1427,151,'Birkirkara','04:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1428,151,'Birzebbuga','05:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1429,151,'Bormla','06:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1430,151,'Dingli','07:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1431,151,'Il-Furjana','09:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1432,151,'Il-Gudja','11:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1433,151,'Il-Gzira','12:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1434,151,'Ghajnsielem','13:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1435,151,'L-Gharb','14:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1436,151,'Hal Gharghur','15:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1437,151,'L-Ghasri','16:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1438,151,'Hal Ghaxaq','17:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1439,151,'Il-Hamrun','18:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1440,151,'L-Iklin','19:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1441,151,'L-Isla','20:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1442,151,'Kirkop','23:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1443,151,'Lija','24:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1444,151,'Luqa','25:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1445,151,'Il-Marsa','26:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1446,151,'Marsaskala','27:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1447,151,'Marsaxlokk','28:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1448,151,'L-Imdina','29:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1449,151,'Il-Mellieha','30:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1450,151,'L-Imgarr','31:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1451,151,'Il-Mosta','32:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1452,151,'L-Imqabba','33:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1453,151,'L-Imsida','34:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1454,151,'L-Imtarfa','35:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1455,151,'Il-Munxar','36:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1456,151,'In-Nadur','37:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1457,151,'In-Naxxar','38:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1458,151,'Paola','39:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1459,151,'Tal-Pieta','41:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1460,151,'Qormi','43:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1461,151,'Il-Qrendi','44:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1462,151,'Victoria','45:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1463,151,'Ir-Rabat','46:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1464,151,'Safi','47:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1465,151,'Saint Julian','48:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1466,151,'Saint John','49:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1467,151,'Saint Lawrence','50:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1468,151,'Saint Paul’s Bay','51:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1469,151,'Sannat','52:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1470,151,'Saint Lucia','53:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1471,151,'Saint Venera','54:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1472,151,'Is-Siggiewi','55:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1473,151,'Tas-Sliema','56:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1474,151,'Is-Swieqi','57:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1475,151,'Tarxien','58:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1476,151,'Ta\' Xbiex','59:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1477,151,'Il-Belt Valletta','60:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1478,151,'Ix-Xaghra','61:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1479,151,'Ix-Xewkija','62:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1480,151,'Haz-Zabbar','64:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1481,151,'Iz-Zebbug','65:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1482,151,'Haz-Zebbug','66:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1483,151,'Iz-Zejtun','67:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1484,151,'Iz-Zurrieq','68:MT',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1485,151,'I prefer not to specify the state','__:MT',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1486,152,'Black River District','BL:MU',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1487,152,'Moka District','MO:MU',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1488,152,'Port Louis District','PL:MU',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1489,152,'Plaines Wilhems District','PW:MU',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1490,152,'Rodrigues','RO:MU',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1491,152,'Riviere du Rempart District','RR:MU',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1492,152,'Savanne District','SA:MU',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1493,152,'I prefer not to specify the state','__:MU',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1494,153,'Maale','MLE:MV',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1495,153,'I prefer not to specify the state','__:MV',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1496,154,'Central Region','C:MW',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1497,154,'Northern Region','N:MW',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1498,154,'Southern Region','S:MW',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1499,154,'I prefer not to specify the state','__:MW',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1500,155,'Aguascalientes','AGU:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1501,155,'Estado de Baja California','BCN:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1502,155,'Baja California Sur','BCS:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1503,155,'Campeche','CAM:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1504,155,'Chihuahua','CHH:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1505,155,'Chiapas','CHP:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1506,155,'Coahuila','COA:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1507,155,'Colima','COL:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1508,155,'Mexico City','DIF:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1509,155,'Durango','DUR:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1510,155,'Guerrero','GRO:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1511,155,'Guanajuato','GUA:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1512,155,'Hidalgo','HID:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1513,155,'Jalisco','JAL:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1514,155,'Estado de Mexico','MEX:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1515,155,'Michoacán','MIC:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1516,155,'Morelos','MOR:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1517,155,'Nayarit','NAY:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1518,155,'Nuevo León','NLE:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1519,155,'Oaxaca','OAX:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1520,155,'Puebla','PUE:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1521,155,'Querétaro','QUE:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1522,155,'Quintana Roo','ROO:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1523,155,'Sinaloa','SIN:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1524,155,'San Luis Potosí','SLP:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1525,155,'Sonora','SON:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1526,155,'Tabasco','TAB:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1527,155,'Tamaulipas','TAM:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1528,155,'Tlaxcala','TLA:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1529,155,'Veracruz','VER:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1530,155,'Yucatán','YUC:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1531,155,'Zacatecas','ZAC:MX',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1532,155,'I prefer not to specify the state','__:MX',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1533,156,'Johor','01:MY',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1534,156,'Kedah','02:MY',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1535,156,'Kelantan','03:MY',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1536,156,'Melaka','04:MY',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1537,156,'Negeri Sembilan','05:MY',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1538,156,'Pahang','06:MY',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1539,156,'Penang','07:MY',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1540,156,'Perak','08:MY',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1541,156,'Perlis','09:MY',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1542,156,'Selangor','10:MY',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1543,156,'Terengganu','11:MY',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1544,156,'Sabah','12:MY',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1545,156,'Sarawak','13:MY',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1546,156,'Kuala Lumpur','14:MY',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1547,156,'Labuan','15:MY',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1548,156,'Putrajaya','16:MY',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1549,156,'I prefer not to specify the state','__:MY',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1550,157,'Maputo Province','L:MZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1551,157,'Cidade de Maputo','MPM:MZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1552,157,'Nampula','N:MZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1553,157,'Cabo Delgado Province','P:MZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1554,157,'Provincia de Zambezia','Q:MZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1555,157,'Sofala Province','S:MZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1556,157,'Tete','T:MZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1557,157,'I prefer not to specify the state','__:MZ',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1558,158,'Zambezi Region','CA:NA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1559,158,'Erongo','ER:NA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1560,158,'Karas','KA:NA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1561,158,'Khomas','KH:NA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1562,158,'Kunene','KU:NA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1563,158,'Otjozondjupa','OD:NA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1564,158,'Oshana','ON:NA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1565,158,'Omusati','OS:NA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1566,158,'Oshikoto','OT:NA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1567,158,'I prefer not to specify the state','__:NA',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1568,159,'South Province','S:NC',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1569,159,'I prefer not to specify the state','__:NC',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1570,160,'Niamey','8:NE',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1571,160,'I prefer not to specify the state','__:NE',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1572,161,'not applicable','--:NF',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1573,162,'Abia State','AB:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1574,162,'Adamawa','AD:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1575,162,'Akwa Ibom State','AK:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1576,162,'Benue State','BE:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1577,162,'Cross River State','CR:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1578,162,'Delta','DE:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1579,162,'Ebonyi State','EB:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1580,162,'Edo','ED:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1581,162,'Ekiti State','EK:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1582,162,'Enugu State','EN:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1583,162,'Federal Capital Territory','FC:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1584,162,'Imo State','IM:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1585,162,'Kaduna State','KD:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1586,162,'Kebbi State','KE:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1587,162,'Kano State','KN:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1588,162,'Kogi State','KO:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1589,162,'Katsina State','KT:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1590,162,'Kwara State','KW:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1591,162,'Lagos','LA:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1592,162,'Niger State','NI:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1593,162,'Ogun State','OG:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1594,162,'Ondo State','ON:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1595,162,'Osun State','OS:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1596,162,'Oyo State','OY:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1597,162,'Plateau State','PL:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1598,162,'Rivers State','RI:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1599,162,'Sokoto State','SO:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1600,162,'Taraba State','TA:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1601,162,'Yobe State','YO:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1602,162,'Zamfara State','ZA:NG',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1603,162,'I prefer not to specify the state','__:NG',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1604,163,'Region Autonoma Atlantico Sur','AS:NI',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1605,163,'Departamento de Chinandega','CI:NI',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1606,163,'Departamento de Esteli','ES:NI',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1607,163,'Departamento de Granada','GR:NI',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1608,163,'Departamento de Jinotega','JI:NI',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1609,163,'Departamento de Leon','LE:NI',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1610,163,'Departamento de Managua','MN:NI',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1611,163,'Departamento de Masaya','MS:NI',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1612,163,'Departamento de Matagalpa','MT:NI',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1613,163,'Departamento de Nueva Segovia','NS:NI',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1614,163,'Departamento de Rivas','RI:NI',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1615,163,'I prefer not to specify the state','__:NI',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1616,164,'Provincie Drenthe','DR:NL',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1617,164,'Provincie Flevoland','FL:NL',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1618,164,'Friesland','FR:NL',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1619,164,'Provincie Gelderland','GE:NL',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1620,164,'Groningen','GR:NL',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1621,164,'Limburg','LI:NL',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1622,164,'North Brabant','NB:NL',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1623,164,'North Holland','NH:NL',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1624,164,'Provincie Overijssel','OV:NL',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1625,164,'Provincie Utrecht','UT:NL',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1626,164,'Provincie Zeeland','ZE:NL',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1627,164,'South Holland','ZH:NL',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1628,164,'I prefer not to specify the state','__:NL',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1629,165,'Østfold','01:NO',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1630,165,'Akershus','02:NO',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1631,165,'Oslo County','03:NO',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1632,165,'Hedmark','04:NO',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1633,165,'Oppland','05:NO',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1634,165,'Buskerud','06:NO',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1635,165,'Vestfold','07:NO',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1636,165,'Telemark','08:NO',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1637,165,'Aust-Agder','09:NO',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1638,165,'Vest-Agder Fylke','10:NO',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1639,165,'Rogaland Fylke','11:NO',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1640,165,'Hordaland Fylke','12:NO',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1641,165,'Sogn og Fjordane Fylke','14:NO',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1642,165,'More og Romsdal fylke','15:NO',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1643,165,'Sor-Trondelag Fylke','16:NO',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1644,165,'Nord-Trondelag Fylke','17:NO',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1645,165,'Nordland Fylke','18:NO',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1646,165,'Troms Fylke','19:NO',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1647,165,'Finnmark Fylke','20:NO',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1648,165,'I prefer not to specify the state','__:NO',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1649,166,'Central Region','1:NP',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1650,166,'Western Region','3:NP',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1651,166,'I prefer not to specify the state','__:NP',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1652,167,'Anabar','02:NR',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1653,167,'I prefer not to specify the state','__:NR',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1654,168,'not applicable','--:NU',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1655,169,'Auckland','AUK:NZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1656,169,'Bay of Plenty','BOP:NZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1657,169,'Canterbury','CAN:NZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1658,169,'Gisborne','GIS:NZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1659,169,'Hawke\'s Bay','HKB:NZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1660,169,'Marlborough','MBH:NZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1661,169,'Manawatu-Wanganui','MWT:NZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1662,169,'Nelson','NSN:NZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1663,169,'Northland','NTL:NZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1664,169,'Otago','OTA:NZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1665,169,'Southland','STL:NZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1666,169,'Tasman','TAS:NZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1667,169,'Taranaki','TKI:NZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1668,169,'Wellington','WGN:NZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1669,169,'Waikato','WKO:NZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1670,169,'West Coast','WTC:NZ',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1671,169,'I prefer not to specify the state','__:NZ',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1672,170,'Al Batinah','Al Batinah:OM',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1673,170,'Ash Sharqiyah','Ash Sharqiyah:OM',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1674,170,'Muhafazat ad Dakhiliyah','DA:OM',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1675,170,'Muhafazat Masqat','MA:OM',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1676,170,'Muhafazat Zufar','ZU:OM',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1677,170,'I prefer not to specify the state','__:OM',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1678,171,'Provincia de Bocas del Toro','1:PA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1679,171,'Provincia de Cocle','2:PA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1680,171,'Provincia de Colon','3:PA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1681,171,'Provincia de Chiriqui','4:PA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1682,171,'Provincia del Darien','5:PA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1683,171,'Provincia de Herrera','6:PA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1684,171,'Provincia de Los Santos','7:PA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1685,171,'Provincia de Panama','8:PA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1686,171,'Provincia de Veraguas','9:PA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1687,171,'Embera-Wounaan','EM:PA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1688,171,'Guna Yala','KY:PA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1689,171,'Ngoebe-Bugle','NB:PA',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1690,171,'I prefer not to specify the state','__:PA',1,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1691,172,'Amazonas','AMA:PE',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1692,172,'Ancash','ANC:PE',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1693,172,'Apurimac','APU:PE',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1694,172,'Arequipa','ARE:PE',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1695,172,'Ayacucho','AYA:PE',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1696,172,'Cajamarca','CAJ:PE',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1697,172,'Callao','CAL:PE',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1698,172,'Cusco','CUS:PE',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1699,172,'Region de Huanuco','HUC:PE',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1700,172,'Huancavelica','HUV:PE',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1701,172,'Ica','ICA:PE',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1702,172,'Junin','JUN:PE',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1703,172,'La Libertad','LAL:PE',0,'2019-09-23 11:40:13','2019-09-23 11:40:13'),
(1704,172,'Lambayeque','LAM:PE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1705,172,'Lima','LIM:PE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1706,172,'Provincia de Lima','LMA:PE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1707,172,'Loreto','LOR:PE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1708,172,'Madre de Dios','MDD:PE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1709,172,'Departamento de Moquegua','MOQ:PE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1710,172,'Pasco','PAS:PE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1711,172,'Piura','PIU:PE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1712,172,'Puno','PUN:PE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1713,172,'Region de San Martin','SAM:PE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1714,172,'Tacna','TAC:PE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1715,172,'Tumbes','TUM:PE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1716,172,'Ucayali','UCA:PE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1717,172,'I prefer not to specify the state','__:PE',1,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1718,173,'Iles du Vent','V:PF',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1719,173,'I prefer not to specify the state','__:PF',1,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1720,174,'Chimbu Province','CPK:PG',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1721,174,'Central Province','CPM:PG',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1722,174,'East New Britain Province','EBR:PG',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1723,174,'Eastern Highlands Province','EHG:PG',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1724,174,'Enga Province','EPW:PG',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1725,174,'East Sepik Province','ESW:PG',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1726,174,'Gulf Province','GPK:PG',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1727,174,'Milne Bay Province','MBA:PG',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1728,174,'Morobe Province','MPL:PG',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1729,174,'Madang Province','MPM:PG',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1730,174,'Manus Province','MRL:PG',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1731,174,'National Capital','NCD:PG',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1732,174,'New Ireland','NIK:PG',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1733,174,'Northern Province','NPP:PG',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1734,174,'Bougainville','NSA:PG',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1735,174,'West Sepik Province','SAN:PG',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1736,174,'Southern Highlands Province','SHM:PG',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1737,174,'West New Britain Province','WBK:PG',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1738,174,'Western Highlands Province','WHM:PG',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1739,174,'Western Province','WPD:PG',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1740,174,'I prefer not to specify the state','__:PG',1,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1741,175,'National Capital Region','00:PH',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1742,175,'Ilocos','01:PH',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1743,175,'Cagayan Valley','02:PH',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1744,175,'Central Luzon','03:PH',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1745,175,'Bicol','05:PH',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1746,175,'Western Visayas','06:PH',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1747,175,'Central Visayas','07:PH',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1748,175,'Eastern Visayas','08:PH',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1749,175,'Zamboanga Peninsula','09:PH',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1750,175,'Northern Mindanao','10:PH',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1751,175,'Davao','11:PH',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1752,175,'Soccsksargen','12:PH',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1753,175,'Caraga','13:PH',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1754,175,'Autonomous Region in Muslim Mindanao','14:PH',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1755,175,'Cordillera','15:PH',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1756,175,'Calabarzon','40:PH',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1757,175,'Mimaropa','41:PH',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1758,175,'Province of Cebu','CEB:PH',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1759,175,'Province of Laguna','LAG:PH',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1760,175,'Province of Pampanga','PAM:PH',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1761,175,'Province of Pangasinan','PAN:PH',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1762,175,'I prefer not to specify the state','__:PH',1,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1763,176,'Balochistan','BA:PK',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1764,176,'Islamabad Capital Territory','IS:PK',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1765,176,'Azad Kashmir','JK:PK',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1766,176,'Gilgit-Baltistan','NA:PK',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1767,176,'Khyber Pakhtunkhwa','NW:PK',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1768,176,'Punjab','PB:PK',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1769,176,'Sindh','SD:PK',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1770,176,'Federally Administered Tribal Areas','TA:PK',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1771,176,'I prefer not to specify the state','__:PK',1,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1772,177,'Lower Silesian Voivodeship','DS:PL',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1773,177,'Kujawsko-Pomorskie','KP:PL',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1774,177,'Lubusz','LB:PL',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1775,177,'Łódź Voivodeship','LD:PL',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1776,177,'Lublin Voivodeship','LU:PL',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1777,177,'Lesser Poland Voivodeship','MA:PL',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1778,177,'Masovian Voivodeship','MZ:PL',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1779,177,'Opole Voivodeship','OP:PL',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1780,177,'Podlasie','PD:PL',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1781,177,'Subcarpathian Voivodeship','PK:PL',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1782,177,'Pomeranian Voivodeship','PM:PL',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1783,177,'Świętokrzyskie','SK:PL',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1784,177,'Silesian Voivodeship','SL:PL',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1785,177,'Warmian-Masurian Voivodeship','WN:PL',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1786,177,'Greater Poland Voivodeship','WP:PL',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1787,177,'West Pomeranian Voivodeship','ZP:PL',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1788,177,'I prefer not to specify the state','__:PL',1,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1789,178,'not applicable','--:PM',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1790,179,'not applicable','--:PN',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1791,180,'Aguas Buenas','Aguas Buenas:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1792,180,'Bayamon Municipio','Bayamon Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1793,180,'Cabo Rojo Municipio','Cabo Rojo Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1794,180,'Caguas Municipio','Caguas Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1795,180,'Camuy Municipio','Camuy Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1796,180,'Canovanas Municipio','Canovanas Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1797,180,'Carolina Municipio','Carolina Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1798,180,'Catano Municipio','Catano Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1799,180,'Cayey Municipio','Cayey Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1800,180,'Ceiba Municipio','Ceiba Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1801,180,'Ciales Municipio','Ciales Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1802,180,'Cidra Municipio','Cidra Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1803,180,'Coamo Municipio','Coamo Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1804,180,'Corozal Municipio','Corozal Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1805,180,'Culebra Municipio','Culebra Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1806,180,'Dorado Municipio','Dorado Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1807,180,'Fajardo Municipio','Fajardo Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1808,180,'Guanica Municipio','Guanica Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1809,180,'Guayama Municipio','Guayama Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1810,180,'Guayanilla Municipio','Guayanilla Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1811,180,'Guaynabo Municipio','Guaynabo Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1812,180,'Gurabo Municipio','Gurabo Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1813,180,'Hatillo Municipio','Hatillo Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1814,180,'Hormigueros Municipio','Hormigueros Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1815,180,'Humacao Municipio','Humacao Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1816,180,'Juana Diaz Municipio','Juana Diaz Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1817,180,'Lajas Municipio','Lajas Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1818,180,'Lares Municipio','Lares Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1819,180,'Las Piedras Municipio','Las Piedras Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1820,180,'Loiza Municipio','Loiza Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1821,180,'Luquillo Municipio','Luquillo Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1822,180,'Manati Municipio','Manati Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1823,180,'Maricao Municipio','Maricao Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1824,180,'Maunabo Municipio','Maunabo Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1825,180,'Mayagueez Municipio','Mayagueez Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1826,180,'Moca Municipio','Moca Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1827,180,'Morovis Municipio','Morovis Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1828,180,'Municipio de Isabela','Municipio de Isabela:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1829,180,'Municipio de Jayuya','Municipio de Jayuya:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1830,180,'Municipio de Juncos','Municipio de Juncos:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1831,180,'Naguabo Municipio','Naguabo Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1832,180,'Naranjito Municipio','Naranjito Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1833,180,'Orocovis Municipio','Orocovis Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1834,180,'Patillas Municipio','Patillas Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1835,180,'Penuelas Municipio','Penuelas Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1836,180,'Ponce Municipio','Ponce Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1837,180,'Quebradillas Municipio','Quebradillas Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1838,180,'Rincon Municipio','Rincon Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1839,180,'Rio Grande Municipio','Rio Grande Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1840,180,'Sabana Grande Municipio','Sabana Grande Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1841,180,'Salinas Municipio','Salinas Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1842,180,'San German Municipio','San German Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1843,180,'San Juan','San Juan:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1844,180,'San Lorenzo Municipio','San Lorenzo Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1845,180,'San Sebastian Municipio','San Sebastian Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1846,180,'Santa Isabel Municipio','Santa Isabel Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1847,180,'Toa Alta Municipio','Toa Alta Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1848,180,'Toa Baja Municipio','Toa Baja Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1849,180,'Trujillo Alto Municipio','Trujillo Alto Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1850,180,'Utuado Municipio','Utuado Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1851,180,'Vega Alta Municipio','Vega Alta Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1852,180,'Vega Baja Municipio','Vega Baja Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1853,180,'Vieques Municipio','Vieques Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1854,180,'Villalba Municipio','Villalba Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1855,180,'Yabucoa Municipio','Yabucoa Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1856,180,'Yauco Municipio','Yauco Municipio:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1857,180,'Adjuntas','Adjuntas:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1858,180,'Aguada','Aguada:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1859,180,'Aguadilla','Aguadilla:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1860,180,'Aibonito','Aibonito:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1861,180,'Anasco','Anasco:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1862,180,'Arecibo','Arecibo:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1863,180,'Arroyo','Arroyo:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1864,180,'Barceloneta','Barceloneta:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1865,180,'Barranquitas','Barranquitas:PR',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1866,180,'I prefer not to specify the state','__:PR',1,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1867,181,'Gaza Strip','Gaza Strip:PS',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1868,181,'West Bank','West Bank:PS',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1869,181,'I prefer not to specify the state','__:PS',1,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1870,182,'Aveiro','01:PT',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1871,182,'Distrito de Beja','02:PT',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1872,182,'Distrito de Braga','03:PT',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1873,182,'Bragança','04:PT',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1874,182,'Distrito de Castelo Branco','05:PT',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1875,182,'Distrito de Coimbra','06:PT',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1876,182,'Distrito de Evora','07:PT',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1877,182,'Distrito de Faro','08:PT',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1878,182,'Distrito da Guarda','09:PT',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1879,182,'Distrito de Leiria','10:PT',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1880,182,'Lisbon','11:PT',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1881,182,'Distrito de Portalegre','12:PT',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1882,182,'Distrito do Porto','13:PT',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1883,182,'Distrito de Santarem','14:PT',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1884,182,'Distrito de Setubal','15:PT',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1885,182,'Distrito de Viana do Castelo','16:PT',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1886,182,'Distrito de Vila Real','17:PT',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1887,182,'Distrito de Viseu','18:PT',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1888,182,'Azores','20:PT',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1889,182,'Madeira','30:PT',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1890,182,'I prefer not to specify the state','__:PT',1,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1891,183,'not applicable','--:PW',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1892,184,'Departamento del Alto Parana','10:PY',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1893,184,'Departamento Central','11:PY',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1894,184,'Departamento de Canindeyu','14:PY',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1895,184,'Departamento de Presidente Hayes','15:PY',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1896,184,'Departamento de Alto Paraguay','16:PY',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1897,184,'Departamento de Boqueron','19:PY',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1898,184,'Departamento de San Pedro','2:PY',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1899,184,'Departamento del Guaira','4:PY',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1900,184,'Departamento de Caaguazu','5:PY',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1901,184,'Departamento de Caazapa','6:PY',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1902,184,'Departamento de Itapua','7:PY',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1903,184,'Departamento de Misiones','8:PY',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1904,184,'Asuncion','ASU:PY',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1905,184,'I prefer not to specify the state','__:PY',1,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1906,185,'Baladiyat ad Dawhah','DA:QA',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1907,185,'Baladiyat ar Rayyan','RA:QA',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1908,185,'Al Wakrah','WA:QA',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1909,185,'I prefer not to specify the state','__:QA',1,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1910,186,'not applicable','--:RE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1911,187,'Judetul Alba','AB:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1912,187,'Judetul Arges','AG:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1913,187,'Arad','AR:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1914,187,'Bucuresti','B:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1915,187,'Judetul Bacau','BC:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1916,187,'Bihor','BH:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1917,187,'Judetul Bistrita-Nasaud','BN:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1918,187,'Judetul Braila','BR:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1919,187,'Judetul Botosani','BT:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1920,187,'Judetul Brasov','BV:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1921,187,'Judetul Buzau','BZ:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1922,187,'Judetul Cluj','CJ:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1923,187,'Judetul Calarasi','CL:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1924,187,'Judetul Caras-Severin','CS:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1925,187,'Constanta','CT:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1926,187,'Covasna','CV:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1927,187,'Judetul Dambovita','DB:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1928,187,'Dolj','DJ:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1929,187,'Gorj','GJ:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1930,187,'Judetul Galati','GL:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1931,187,'Giurgiu','GR:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1932,187,'Hunedoara','HD:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1933,187,'Harghita','HR:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1934,187,'Ilfov','IF:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1935,187,'Judetul Ialomita','IL:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1936,187,'Judetul Iasi','IS:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1937,187,'Judetul Mehedinti','MH:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1938,187,'Maramureş','MM:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1939,187,'Judetul Mures','MS:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1940,187,'Judetul Neamt','NT:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1941,187,'Olt','OT:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1942,187,'Prahova','PH:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1943,187,'Judetul Sibiu','SB:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1944,187,'Judetul Salaj','SJ:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1945,187,'Satu Mare','SM:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1946,187,'Suceava','SV:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1947,187,'Tulcea','TL:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1948,187,'Judetul Timis','TM:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1949,187,'Teleorman','TR:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1950,187,'Judetul Valcea','VL:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1951,187,'Vrancea','VN:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1952,187,'Vaslui','VS:RO',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1953,187,'I prefer not to specify the state','__:RO',1,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1954,188,'Central Serbia','Central Serbia:RS',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1955,188,'Autonomna Pokrajina Vojvodina','VO:RS',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1956,188,'I prefer not to specify the state','__:RS',1,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1957,189,'Respublika Adygeya','AD:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1958,189,'Respublika Altay','AL:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1959,189,'Altai Krai','ALT:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1960,189,'Amurskaya Oblast\'','AMU:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1961,189,'Arkhangelskaya','ARK:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1962,189,'Astrakhanskaya Oblast\'','AST:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1963,189,'Bashkortostan','BA:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1964,189,'Belgorodskaya Oblast\'','BEL:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1965,189,'Bryanskaya Oblast\'','BRY:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1966,189,'Respublika Buryatiya','BU:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1967,189,'Chechnya','CE:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1968,189,'Chelyabinsk','CHE:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1969,189,'Chukotskiy Avtonomnyy Okrug','CHU:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1970,189,'Chuvashia','CU:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1971,189,'Dagestan','DA:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1972,189,'Respublika Ingushetiya','IN:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1973,189,'Irkutskaya Oblast\'','IRK:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1974,189,'Ivanovskaya Oblast\'','IVA:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1975,189,'Kamtchatski Kray','KAM:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1976,189,'Kabardino-Balkarskaya Respublika','KB:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1977,189,'Karachayevo-Cherkesiya','KC:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1978,189,'Krasnodarskiy Kray','KDA:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1979,189,'Kemerovskaya Oblast\'','KEM:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1980,189,'Kaliningradskaya Oblast\'','KGD:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1981,189,'Kurganskaya Oblast\'','KGN:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1982,189,'Khabarovsk Krai','KHA:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1983,189,'Khanty-Mansiyskiy Avtonomnyy Okrug-Yugra','KHM:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1984,189,'Kirovskaya Oblast\'','KIR:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1985,189,'Respublika Khakasiya','KK:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1986,189,'Kalmykiya','KL:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1987,189,'Kaluzhskaya Oblast\'','KLU:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1988,189,'Komi Republic','KO:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1989,189,'Kostromskaya Oblast\'','KOS:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1990,189,'Republic of Karelia','KR:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1991,189,'Kurskaya Oblast\'','KRS:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1992,189,'Krasnoyarskiy Kray','KYA:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1993,189,'Leningrad','LEN:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1994,189,'Lipetskaya Oblast\'','LIP:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1995,189,'Magadanskaya Oblast\'','MAG:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1996,189,'Respublika Mariy-El','ME:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1997,189,'Respublika Mordoviya','MO:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1998,189,'Moskovskaya','MOS:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(1999,189,'Moscow','MOW:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2000,189,'Murmansk','MUR:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2001,189,'Nenetskiy Avtonomnyy Okrug','NEN:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2002,189,'Novgorodskaya Oblast\'','NGR:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2003,189,'Nizhegorodskaya Oblast\'','NIZ:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2004,189,'Novosibirskaya Oblast\'','NVS:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2005,189,'Omskaya Oblast\'','OMS:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2006,189,'Orenburgskaya Oblast\'','ORE:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2007,189,'Orlovskaya Oblast\'','ORL:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2008,189,'Perm Krai','PER:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2009,189,'Penzenskaya Oblast\'','PNZ:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2010,189,'Primorskiy Kray','PRI:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2011,189,'Pskovskaya Oblast\'','PSK:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2012,189,'Rostov','ROS:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2013,189,'Ryazanskaya Oblast\'','RYA:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2014,189,'Respublika Sakha (Yakutiya)','SA:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2015,189,'Sakhalinskaya Oblast\'','SAK:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2016,189,'Samarskaya Oblast\'','SAM:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2017,189,'Saratovskaya Oblast\'','SAR:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2018,189,'North Ossetia','SE:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2019,189,'Smolenskaya Oblast\'','SMO:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2020,189,'St.-Petersburg','SPE:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2021,189,'Stavropol\'skiy Kray','STA:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2022,189,'Sverdlovskaya Oblast\'','SVE:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2023,189,'Tatarstan','TA:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2024,189,'Tambovskaya Oblast\'','TAM:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2025,189,'Tomskaya Oblast\'','TOM:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2026,189,'Tul\'skaya Oblast\'','TUL:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2027,189,'Tverskaya Oblast\'','TVE:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2028,189,'Respublika Tyva','TY:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2029,189,'Tyumenskaya Oblast\'','TYU:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2030,189,'Udmurtskaya Respublika','UD:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2031,189,'Ulyanovsk Oblast','ULY:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2032,189,'Volgogradskaya Oblast\'','VGG:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2033,189,'Vladimirskaya Oblast\'','VLA:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2034,189,'Vologodskaya Oblast\'','VLG:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2035,189,'Voronezhskaya Oblast\'','VOR:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2036,189,'Yamalo-Nenetskiy Avtonomnyy Okrug','YAN:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2037,189,'Yaroslavskaya Oblast\'','YAR:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2038,189,'Jewish Autonomous Oblast','YEV:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2039,189,'Transbaikal Territory','ZAB:RU',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2040,189,'I prefer not to specify the state','__:RU',1,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2041,190,'Kigali','01:RW',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2042,190,'I prefer not to specify the state','__:RW',1,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2043,191,'Ar Riyāḑ','01:SA',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2044,191,'Makkah Province','02:SA',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2045,191,'Al Madinah al Munawwarah','03:SA',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2046,191,'Eastern Province','04:SA',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2047,191,'Al-Qassim','05:SA',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2048,191,'Mintaqat Ha\'il','06:SA',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2049,191,'Mintaqat Tabuk','07:SA',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2050,191,'Northern Borders','08:SA',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2051,191,'Jizan','09:SA',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2052,191,'Mintaqat Najran','10:SA',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2053,191,'Mintaqat al Bahah','11:SA',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2054,191,'Al Jawf','12:SA',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2055,191,'Mintaqat `Asir','14:SA',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2056,191,'I prefer not to specify the state','__:SA',1,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2057,192,'Guadalcanal Province','GU:SB',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2058,192,'I prefer not to specify the state','__:SB',1,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2059,193,'English River','16:SC',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2060,193,'Takamaka','23:SC',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2061,193,'I prefer not to specify the state','__:SC',1,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2062,194,'Northern Darfur','DN:SD',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2063,194,'Southern Darfur','DS:SD',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2064,194,'Kassala','KA:SD',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2065,194,'Khartoum','KH:SD',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2066,194,'Southern Kordofan','KS:SD',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2067,194,'River Nile','NR:SD',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2068,194,'I prefer not to specify the state','__:SD',1,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2069,195,'Stockholm','AB:SE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2070,195,'Västerbotten','AC:SE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2071,195,'Norrbotten','BD:SE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2072,195,'Uppsala','C:SE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2073,195,'Södermanland','D:SE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2074,195,'Östergötland','E:SE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2075,195,'Jönköping','F:SE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2076,195,'Kronoberg','G:SE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2077,195,'Kalmar','H:SE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2078,195,'Gotland','I:SE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2079,195,'Blekinge','K:SE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2080,195,'Skåne','M:SE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2081,195,'Halland','N:SE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2082,195,'Västra Götaland','O:SE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2083,195,'Värmland','S:SE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2084,195,'Örebro','T:SE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2085,195,'Västmanland','U:SE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2086,195,'Dalarna','W:SE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2087,195,'Gävleborg','X:SE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2088,195,'Västernorrland','Y:SE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2089,195,'Jämtland','Z:SE',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2090,195,'I prefer not to specify the state','__:SE',1,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2091,196,'not applicable','--:SG',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2092,197,'Saint Helena','HL:SH',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2093,197,'I prefer not to specify the state','__:SH',1,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2094,198,'Obcina Ajdovscina','001:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2095,198,'Beltinci','002:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2096,198,'Obcina Bled','003:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2097,198,'Bohinj','004:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2098,198,'Borovnica','005:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2099,198,'Brda','007:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2100,198,'Brezovica','008:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2101,198,'Obcina Brezice','009:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2102,198,'Obcina Tisina','010:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2103,198,'Celje','011:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2104,198,'Cerknica','013:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2105,198,'Obcina Crensovci','015:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2106,198,'Obcina Divaca','019:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2107,198,'Dobrepolje','020:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2108,198,'Dobrova-Polhov Gradec','021:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2109,198,'Dol pri Ljubljani','022:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2110,198,'Obcina Domzale','023:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2111,198,'Dornava','024:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2112,198,'Dravograd','025:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2113,198,'Duplek','026:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2114,198,'Gorenja Vas-Poljane','027:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2115,198,'Obcina Gorisnica','028:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2116,198,'Gornja Radgona','029:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2117,198,'Grosuplje','032:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2118,198,'Hrastnik','034:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2119,198,'Idrija','036:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2120,198,'Ig','037:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2121,198,'Ilirska Bistrica','038:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2122,198,'Obcina Ivancna Gorica','039:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2123,198,'Izola','040:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2124,198,'Jesenice','041:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2125,198,'Kamnik','043:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2126,198,'Kanal','044:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2127,198,'Obcina Kidricevo','045:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2128,198,'Obcina Kobarid','046:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2129,198,'Obcina Kocevje','048:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2130,198,'Koper','050:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2131,198,'Kranj','052:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2132,198,'Kranjska Gora','053:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2133,198,'Obcina Krsko','054:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2134,198,'Obcina Lasko','057:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2135,198,'Lenart','058:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2136,198,'Lendava','059:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2137,198,'Litija','060:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2138,198,'Ljubljana','061:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2139,198,'Logatec','064:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2140,198,'Obcina Loska Dolina','065:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2141,198,'Maribor','070:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2142,198,'Medvode','071:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2143,198,'Obcina Menges','072:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2144,198,'Obcina Mezica','074:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2145,198,'Miren-Kostanjevica','075:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2146,198,'Obcina Moravce','077:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2147,198,'Mozirje','079:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2148,198,'Murska Sobota','080:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2149,198,'Naklo','082:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2150,198,'Nova Gorica','084:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2151,198,'Mestna Obcina Novo mesto','085:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2152,198,'Pesnica','089:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2153,198,'Piran','090:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2154,198,'Obcina Podcetrtek','092:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2155,198,'Postojna','094:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2156,198,'Ptuj','096:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2157,198,'Puconci','097:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2158,198,'Obcina Radece','099:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2159,198,'Radlje ob Dravi','101:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2160,198,'Radovljica','102:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2161,198,'Obcina Ravne na Koroskem','103:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2162,198,'Obcina Rogaska Slatina','106:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2163,198,'Obcina Ruse','108:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2164,198,'Sevnica','110:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2165,198,'Obcina Sezana','111:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2166,198,'Slovenj Gradec','112:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2167,198,'Slovenska Bistrica','113:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2168,198,'Slovenske Konjice','114:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2169,198,'Obcina Sencur','117:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2170,198,'Obcina Sentilj','118:SI',0,'2019-09-23 11:40:14','2019-09-23 11:40:14'),
(2171,198,'Obcina Sentjernej','119:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2172,198,'Obcina Sentjur','120:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2173,198,'Škofja Loka','122:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2174,198,'Obcina Skofljica','123:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2175,198,'Obcina Smarje pri Jelsah','124:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2176,198,'Obcina Smartno ob Paki','125:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2177,198,'Obcina Sostanj','126:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2178,198,'Obcina Tolmin','128:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2179,198,'Trbovlje','129:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2180,198,'Trebnje','130:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2181,198,'Obcina Trzic','131:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2182,198,'Velenje','133:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2183,198,'Vipava','136:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2184,198,'Vodice','138:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2185,198,'Vojnik','139:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2186,198,'Vrhnika','140:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2187,198,'Zagorje ob Savi','142:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2188,198,'Obcina Zelezniki','146:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2189,198,'Obcina Ziri','147:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2190,198,'Dolenjske Toplice','157:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2191,198,'Obcina Hoce-Slivnica','160:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2192,198,'Horjul','162:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2193,198,'Komenda','164:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2194,198,'Lovrenc na Pohorju','167:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2195,198,'Markovci','168:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2196,198,'Obcina Miklavz na Dravskem Polju','169:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2197,198,'Polzela','173:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2198,198,'Prebold','174:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2199,198,'Prevalje','175:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2200,198,'Selnica ob Dravi','178:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2201,198,'Obcina Sempeter-Vrtojba','183:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2202,198,'Trzin','186:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2203,198,'Obcina Verzej','188:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2204,198,'Obcina Zalec','190:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2205,198,'Obcina Zirovnica','192:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2206,198,'Obcina Poljcane','200:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2207,198,'Obcina Sredisce ob Dravi','202:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2208,198,'Gorje','207:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2209,198,'Log–Dragomer','208:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2210,198,'Obcina Starse','215:SI',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2211,198,'I prefer not to specify the state','__:SI',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2212,199,'Svalbard','21:SJ',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2213,199,'I prefer not to specify the state','__:SJ',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2214,200,'Banskobystricky kraj','BC:SK',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2215,200,'Bratislavsky kraj','BL:SK',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2216,200,'Kosicky kraj','KI:SK',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2217,200,'Nitriansky kraj','NI:SK',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2218,200,'Presovsky kraj','PV:SK',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2219,200,'Trnavsky kraj','TA:SK',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2220,200,'Trenciansky kraj','TC:SK',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2221,200,'Zilinsky kraj','ZI:SK',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2222,200,'I prefer not to specify the state','__:SK',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2223,201,'Western Area','W:SL',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2224,201,'I prefer not to specify the state','__:SL',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2225,202,'Castello di Acquaviva','01:SM',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2226,202,'Castello di Fiorentino','05:SM',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2227,202,'Castello di San Marino Citta','07:SM',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2228,202,'Serravalle','09:SM',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2229,202,'I prefer not to specify the state','__:SM',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2230,203,'Dakar','DK:SN',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2231,203,'Fatick','FK:SN',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2232,203,'Region de Kaffrine','KA:SN',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2233,203,'Kolda','KD:SN',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2234,203,'Region de Kedougou','KE:SN',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2235,203,'Kaolack','KL:SN',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2236,203,'Louga','LG:SN',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2237,203,'Region de Sedhiou','SE:SN',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2238,203,'Saint-Louis','SL:SN',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2239,203,'Tambacounda','TC:SN',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2240,203,'I prefer not to specify the state','__:SN',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2241,204,'Banaadir','BN:SO',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2242,204,'Woqooyi Galbeed','WO:SO',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2243,204,'I prefer not to specify the state','__:SO',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2244,205,'Distrikt Brokopondo','BR:SR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2245,205,'Distrikt Commewijne','CM:SR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2246,205,'Distrikt Coronie','CR:SR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2247,205,'Distrikt Marowijne','MA:SR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2248,205,'Distrikt Paramaribo','PM:SR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2249,205,'Distrikt Para','PR:SR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2250,205,'Distrikt Saramacca','SA:SR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2251,205,'Distrikt Sipaliwini','SI:SR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2252,205,'I prefer not to specify the state','__:SR',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2253,206,'Central Equatoria','EC:SS',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2254,206,'I prefer not to specify the state','__:SS',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2255,207,'São Tomé Island','S:ST',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2256,207,'I prefer not to specify the state','__:ST',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2257,208,'Departamento de Ahuachapan','AH:SV',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2258,208,'Departamento de La Libertad','LI:SV',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2259,208,'Departamento de Morazan','MO:SV',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2260,208,'Departamento de Santa Ana','SA:SV',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2261,208,'Departamento de San Miguel','SM:SV',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2262,208,'Departamento de Sonsonate','SO:SV',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2263,208,'Departamento de San Salvador','SS:SV',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2264,208,'Departamento de Usulutan','US:SV',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2265,208,'I prefer not to specify the state','__:SV',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2266,209,'not applicable','--:SX',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2267,210,'Damascus Governorate','DI:SY',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2268,210,'Aleppo Governorate','HL:SY',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2269,210,'Hama Governorate','HM:SY',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2270,210,'Latakia Governorate','LA:SY',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2271,210,'As-Suwayda Governorate','SU:SY',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2272,210,'I prefer not to specify the state','__:SY',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2273,211,'Hhohho District','HH:SZ',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2274,211,'Manzini District','MA:SZ',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2275,211,'I prefer not to specify the state','__:SZ',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2276,212,'not applicable','--:TC',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2277,213,'Chari-Baguirmi Region','CB:TD',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2278,213,'Hadjer-Lamis','HL:TD',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2279,213,'Logone Occidental Region','LO:TD',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2280,213,'Ouaddai Region','OD:TD',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2281,213,'I prefer not to specify the state','__:TD',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2282,214,'Archipel des Kerguelen','Archipel des Kerguelen:TF',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2283,214,'I prefer not to specify the state','__:TF',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2284,215,'Maritime','M:TG',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2285,215,'Savanes','S:TG',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2286,215,'I prefer not to specify the state','__:TG',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2287,216,'Bangkok','10:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2288,216,'Changwat Samut Prakan','11:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2289,216,'Changwat Nonthaburi','12:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2290,216,'Changwat Pathum Thani','13:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2291,216,'Changwat Phra Nakhon Si Ayutthaya','14:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2292,216,'Changwat Ang Thong','15:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2293,216,'Changwat Lop Buri','16:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2294,216,'Changwat Sing Buri','17:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2295,216,'Changwat Chai Nat','18:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2296,216,'Changwat Sara Buri','19:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2297,216,'Changwat Chon Buri','20:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2298,216,'Changwat Rayong','21:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2299,216,'Changwat Chanthaburi','22:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2300,216,'Changwat Trat','23:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2301,216,'Changwat Chachoengsao','24:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2302,216,'Changwat Prachin Buri','25:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2303,216,'Changwat Nakhon Nayok','26:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2304,216,'Changwat Sa Kaeo','27:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2305,216,'Changwat Nakhon Ratchasima','30:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2306,216,'Changwat Buriram','31:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2307,216,'Changwat Surin','32:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2308,216,'Changwat Sisaket','33:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2309,216,'Changwat Ubon Ratchathani','34:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2310,216,'Changwat Yasothon','35:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2311,216,'Changwat Chaiyaphum','36:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2312,216,'Changwat Amnat Charoen','37:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2313,216,'Changwat Nong Bua Lamphu','39:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2314,216,'Changwat Khon Kaen','40:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2315,216,'Changwat Udon Thani','41:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2316,216,'Changwat Loei','42:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2317,216,'Changwat Nong Khai','43:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2318,216,'Changwat Maha Sarakham','44:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2319,216,'Changwat Roi Et','45:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2320,216,'Changwat Kalasin','46:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2321,216,'Changwat Sakon Nakhon','47:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2322,216,'Changwat Mukdahan','49:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2323,216,'Chiang Mai Province','50:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2324,216,'Changwat Lamphun','51:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2325,216,'Changwat Lampang','52:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2326,216,'Changwat Uttaradit','53:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2327,216,'Changwat Phrae','54:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2328,216,'Changwat Nan','55:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2329,216,'Changwat Phayao','56:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2330,216,'Changwat Chiang Rai','57:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2331,216,'Changwat Mae Hong Son','58:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2332,216,'Changwat Nakhon Sawan','60:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2333,216,'Changwat Uthai Thani','61:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2334,216,'Changwat Kamphaeng Phet','62:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2335,216,'Changwat Tak','63:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2336,216,'Changwat Sukhothai','64:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2337,216,'Changwat Phitsanulok','65:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2338,216,'Changwat Phichit','66:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2339,216,'Changwat Phetchabun','67:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2340,216,'Changwat Ratchaburi','70:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2341,216,'Changwat Kanchanaburi','71:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2342,216,'Changwat Suphan Buri','72:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2343,216,'Changwat Nakhon Pathom','73:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2344,216,'Changwat Samut Sakhon','74:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2345,216,'Changwat Samut Songkhram','75:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2346,216,'Changwat Phetchaburi','76:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2347,216,'Changwat Prachuap Khiri Khan','77:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2348,216,'Changwat Nakhon Si Thammarat','80:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2349,216,'Changwat Krabi','81:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2350,216,'Changwat Phangnga','82:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2351,216,'Phuket','83:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2352,216,'Changwat Surat Thani','84:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2353,216,'Changwat Ranong','85:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2354,216,'Changwat Chumphon','86:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2355,216,'Changwat Songkhla','90:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2356,216,'Changwat Satun','91:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2357,216,'Changwat Trang','92:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2358,216,'Changwat Phatthalung','93:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2359,216,'Changwat Pattani','94:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2360,216,'Changwat Yala','95:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2361,216,'Changwat Narathiwat','96:TH',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2362,216,'I prefer not to specify the state','__:TH',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2363,217,'Gorno-Badakhshan','GB:TJ',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2364,217,'I prefer not to specify the state','__:TJ',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2365,218,'Nukunonu','N:TK',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2366,218,'I prefer not to specify the state','__:TK',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2367,219,'Dili','DI:TL',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2368,219,'I prefer not to specify the state','__:TL',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2369,220,'Ahal','A:TM',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2370,220,'I prefer not to specify the state','__:TM',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2371,221,'Gouvernorat de Tunis','11:TN',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2372,221,'Gouvernorat de l\'Ariana','12:TN',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2373,221,'Manouba','14:TN',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2374,221,'Gouvernorat de Nabeul','21:TN',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2375,221,'Gouvernorat de Beja','31:TN',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2376,221,'Gouvernorat de Sidi Bouzid','43:TN',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2377,221,'Gouvernorat de Sousse','51:TN',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2378,221,'Gouvernorat de Monastir','52:TN',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2379,221,'Gouvernorat de Mahdia','53:TN',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2380,221,'Gouvernorat de Sfax','61:TN',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2381,221,'Gafsa','71:TN',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2382,221,'I prefer not to specify the state','__:TN',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2383,222,'Tongatapu','04:TO',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2384,222,'Vava`u','05:TO',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2385,222,'I prefer not to specify the state','__:TO',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2386,223,'Adana','01:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2387,223,'Adiyaman','02:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2388,223,'Afyonkarahisar','03:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2389,223,'Ağrı','04:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2390,223,'Amasya','05:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2391,223,'Ankara','06:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2392,223,'Antalya','07:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2393,223,'Artvin','08:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2394,223,'Aydın','09:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2395,223,'Balıkesir','10:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2396,223,'Bilecik','11:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2397,223,'Bingöl','12:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2398,223,'Bitlis','13:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2399,223,'Bolu','14:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2400,223,'Burdur','15:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2401,223,'Bursa','16:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2402,223,'Çanakkale','17:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2403,223,'Çankırı','18:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2404,223,'Çorum','19:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2405,223,'Denizli','20:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2406,223,'Diyarbakir','21:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2407,223,'Edirne','22:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2408,223,'Elazığ','23:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2409,223,'Erzincan','24:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2410,223,'Erzurum','25:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2411,223,'Eskişehir','26:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2412,223,'Gaziantep','27:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2413,223,'Giresun','28:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2414,223,'Guemueshane','29:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2415,223,'Hakkâri','30:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2416,223,'Hatay','31:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2417,223,'Isparta','32:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2418,223,'Mersin','33:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2419,223,'Istanbul','34:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2420,223,'Izmir','35:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2421,223,'Kars','36:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2422,223,'Kastamonu','37:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2423,223,'Kayseri','38:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2424,223,'Kırklareli','39:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2425,223,'Kırşehir','40:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2426,223,'Kocaeli','41:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2427,223,'Konya','42:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2428,223,'Kütahya','43:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2429,223,'Malatya','44:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2430,223,'Manisa','45:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2431,223,'Kahramanmaraş','46:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2432,223,'Mardin','47:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2433,223,'Muğla','48:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2434,223,'Muş','49:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2435,223,'Nevsehir','50:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2436,223,'Nigde','51:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2437,223,'Ordu','52:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2438,223,'Rize','53:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2439,223,'Sakarya','54:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2440,223,'Samsun','55:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2441,223,'Siirt','56:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2442,223,'Sinop','57:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2443,223,'Sivas','58:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2444,223,'Tekirdağ','59:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2445,223,'Tokat','60:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2446,223,'Trabzon','61:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2447,223,'Tunceli','62:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2448,223,'Şanlıurfa','63:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2449,223,'Uşak','64:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2450,223,'Van','65:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2451,223,'Yozgat','66:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2452,223,'Zonguldak','67:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2453,223,'Aksaray','68:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2454,223,'Bayburt','69:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2455,223,'Karaman','70:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2456,223,'Kırıkkale','71:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2457,223,'Batman','72:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2458,223,'Şırnak','73:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2459,223,'Bartın','74:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2460,223,'Ardahan','75:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2461,223,'Iğdır','76:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2462,223,'Yalova','77:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2463,223,'Karabuek','78:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2464,223,'Kilis','79:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2465,223,'Osmaniye','80:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2466,223,'Duezce','81:TR',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2467,223,'I prefer not to specify the state','__:TR',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2468,224,'Borough of Arima','ARI:TT',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2469,224,'Chaguanas','CHA:TT',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2470,224,'Couva-Tabaquite-Talparo','CTT:TT',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2471,224,'Diego Martin','DMN:TT',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2472,224,'Eastern Tobago','ETO:TT',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2473,224,'Penal/Debe','PED:TT',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2474,224,'City of Port of Spain','POS:TT',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2475,224,'Princes Town','PRT:TT',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2476,224,'Mayaro','RCM:TT',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2477,224,'City of San Fernando','SFO:TT',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2478,224,'Sangre Grande','SGE:TT',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2479,224,'Siparia','SIP:TT',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2480,224,'San Juan/Laventille','SJL:TT',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2481,224,'Tunapuna/Piarco','TUP:TT',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2482,224,'Tobago','WTO:TT',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2483,224,'I prefer not to specify the state','__:TT',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2484,225,'Funafuti','FUN:TV',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2485,225,'I prefer not to specify the state','__:TV',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2486,226,'Fukien','Fukien:TW',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2487,226,'Kaohsiung','Kaohsiung:TW',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2488,226,'Taipei','Taipei:TW',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2489,226,'Taiwan','Taiwan:TW',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2490,226,'I prefer not to specify the state','__:TW',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2491,227,'Arusha','01:TZ',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2492,227,'Dar es Salaam Region','02:TZ',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2493,227,'Dodoma','03:TZ',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2494,227,'Kagera','05:TZ',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2495,227,'Pemba North','06:TZ',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2496,227,'Zanzibar Urban/West','15:TZ',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2497,227,'Morogoro','16:TZ',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2498,227,'Mwanza','18:TZ',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2499,227,'Tanga','25:TZ',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2500,227,'Njombe','Njombe:TZ',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2501,227,'I prefer not to specify the state','__:TZ',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2502,228,'Vinnyts\'ka Oblast\'','05:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2503,228,'Volyns\'ka Oblast\'','07:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2504,228,'Luhans\'ka Oblast\'','09:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2505,228,'Dnipropetrovska Oblast\'','12:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2506,228,'Donets\'ka Oblast\'','14:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2507,228,'Zhytomyrs\'ka Oblast\'','18:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2508,228,'Zakarpattia Oblast','21:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2509,228,'Zaporizhia','23:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2510,228,'Ivano-Frankivs\'ka Oblast\'','26:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2511,228,'Kyiv City','30:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2512,228,'Kyiv Oblast','32:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2513,228,'Kirovohrads\'ka Oblast\'','35:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2514,228,'Misto Sevastopol\'','40:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2515,228,'Crimea','43:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2516,228,'L\'vivs\'ka Oblast\'','46:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2517,228,'Mykolayivs\'ka Oblast\'','48:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2518,228,'Odessa','51:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2519,228,'Poltavs\'ka Oblast\'','53:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2520,228,'Rivnens\'ka Oblast\'','56:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2521,228,'Sums\'ka Oblast\'','59:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2522,228,'Ternopil\'s\'ka Oblast\'','61:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2523,228,'Kharkivs\'ka Oblast\'','63:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2524,228,'Khersons\'ka Oblast\'','65:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2525,228,'Khmel\'nyts\'ka Oblast\'','68:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2526,228,'Cherkas\'ka Oblast\'','71:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2527,228,'Chernihiv','74:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2528,228,'Chernivtsi','77:UA',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2529,228,'I prefer not to specify the state','__:UA',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2530,229,'Central Region','C:UG',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2531,229,'I prefer not to specify the state','__:UG',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2532,230,'not applicable','--:UM',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2533,231,'Alaska','AK:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2534,231,'Alabama','AL:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2535,231,'Arkansas','AR:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2536,231,'Arizona','AZ:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2537,231,'California','CA:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2538,231,'Colorado','CO:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2539,231,'Connecticut','CT:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2540,231,'District of Columbia','DC:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2541,231,'Delaware','DE:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2542,231,'Florida','FL:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2543,231,'Georgia','GA:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2544,231,'Hawaii','HI:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2545,231,'Iowa','IA:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2546,231,'Idaho','ID:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2547,231,'Illinois','IL:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2548,231,'Indiana','IN:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2549,231,'Kansas','KS:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2550,231,'Kentucky','KY:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2551,231,'Louisiana','LA:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2552,231,'Massachusetts','MA:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2553,231,'Maryland','MD:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2554,231,'Maine','ME:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2555,231,'Michigan','MI:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2556,231,'Minnesota','MN:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2557,231,'Missouri','MO:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2558,231,'Mississippi','MS:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2559,231,'Montana','MT:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2560,231,'North Carolina','NC:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2561,231,'North Dakota','ND:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2562,231,'Nebraska','NE:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2563,231,'New Hampshire','NH:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2564,231,'New Jersey','NJ:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2565,231,'New Mexico','NM:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2566,231,'Nevada','NV:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2567,231,'New York','NY:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2568,231,'Ohio','OH:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2569,231,'Oklahoma','OK:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2570,231,'Oregon','OR:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2571,231,'Pennsylvania','PA:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2572,231,'Rhode Island','RI:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2573,231,'South Carolina','SC:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2574,231,'South Dakota','SD:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2575,231,'Tennessee','TN:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2576,231,'Texas','TX:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2577,231,'Utah','UT:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2578,231,'Virginia','VA:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2579,231,'Vermont','VT:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2580,231,'Washington','WA:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2581,231,'Wisconsin','WI:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2582,231,'West Virginia','WV:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2583,231,'Wyoming','WY:US',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2584,231,'I prefer not to specify the state','__:US',1,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2585,232,'Canelones','CA:UY',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2586,232,'Colonia','CO:UY',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2587,232,'Departamento de Durazno','DU:UY',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2588,232,'Florida','FD:UY',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2589,232,'Maldonado','MA:UY',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2590,232,'Departamento de Montevideo','MO:UY',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2591,232,'Departamento de Paysandu','PA:UY',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2592,232,'Departamento de Salto','SA:UY',0,'2019-09-23 11:40:15','2019-09-23 11:40:15'),
(2593,232,'Soriano','SO:UY',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2594,232,'Departamento de Tacuarembo','TA:UY',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2595,232,'I prefer not to specify the state','__:UY',1,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2596,233,'Qashqadaryo','QA:UZ',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2597,233,'Samarqand Viloyati','SA:UZ',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2598,233,'Surxondaryo Viloyati','SU:UZ',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2599,233,'Toshkent Shahri','TK:UZ',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2600,233,'I prefer not to specify the state','__:UZ',1,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2601,234,'not applicable','--:VA',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2602,235,'Parish of Charlotte','01:VC',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2603,235,'Parish of Saint George','04:VC',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2604,235,'Grenadines','06:VC',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2605,235,'I prefer not to specify the state','__:VC',1,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2606,236,'Capital','A:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2607,236,'Anzoátegui','B:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2608,236,'Apure','C:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2609,236,'Aragua','D:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2610,236,'Barinas','E:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2611,236,'Bolívar','F:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2612,236,'Carabobo','G:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2613,236,'Falcón','I:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2614,236,'Guárico','J:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2615,236,'Lara','K:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2616,236,'Mérida','L:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2617,236,'Miranda','M:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2618,236,'Monagas','N:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2619,236,'Nueva Esparta','O:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2620,236,'Portuguesa','P:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2621,236,'Sucre','R:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2622,236,'Táchira','S:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2623,236,'Estado Trujillo','T:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2624,236,'Yaracuy','U:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2625,236,'Zulia','V:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2626,236,'Dependencias Federales','W:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2627,236,'Vargas','X:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2628,236,'Delta Amacuro','Y:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2629,236,'Amazonas','Z:VE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2630,236,'I prefer not to specify the state','__:VE',1,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2631,237,'not applicable','--:VG',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2632,238,'Saint Croix Island','C:VI',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2633,238,'Saint John Island','J:VI',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2634,238,'Saint Thomas Island','T:VI',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2635,238,'I prefer not to specify the state','__:VI',1,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2636,239,'Tinh Lai Chau','01:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2637,239,'Tinh Lao Cai','02:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2638,239,'Tinh Tuyen Quang','07:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2639,239,'Tinh Lang Son','09:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2640,239,'Tinh Quang Ninh','13:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2641,239,'Tinh Hoa Binh','14:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2642,239,'Tinh Ninh Binh','18:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2643,239,'Tinh Thai Binh','20:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2644,239,'Tinh Thanh Hoa','21:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2645,239,'Tinh Nghe An','22:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2646,239,'Tinh Ha Tinh','23:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2647,239,'Tinh Quang Tri','25:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2648,239,'Tinh Thua Thien-Hue','26:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2649,239,'Tinh Quang Nam','27:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2650,239,'Kon Tum','28:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2651,239,'Tinh Quang Ngai','29:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2652,239,'Gia Lai','30:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2653,239,'Tinh Binh Dinh','31:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2654,239,'Tinh Dak Lak','33:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2655,239,'Tinh Khanh Hoa','34:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2656,239,'Tinh Lam Dong','35:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2657,239,'Tinh Tay Ninh','37:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2658,239,'Tinh Dong Nai','39:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2659,239,'Tinh Binh Thuan','40:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2660,239,'Tinh Ba Ria-Vung Tau','43:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2661,239,'An Giang','44:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2662,239,'Tinh Tien Giang','46:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2663,239,'Thanh Pho Can Tho','48:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2664,239,'Tinh Vinh Long','49:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2665,239,'Tinh Ben Tre','50:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2666,239,'Tinh Tra Vinh','51:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2667,239,'Tinh Soc Trang','52:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2668,239,'Tinh Bac Giang','54:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2669,239,'Tinh Bac Ninh','56:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2670,239,'Tinh Binh Duong','57:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2671,239,'Thanh Pho Da Nang','60:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2672,239,'Tinh Hai Duong','61:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2673,239,'Thanh Pho Hai Phong','62:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2674,239,'Thanh Pho Ha Noi','64:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2675,239,'Ho Chi Minh City','65:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2676,239,'Tinh Hung Yen','66:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2677,239,'Tinh Nam Dinh','67:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2678,239,'Tinh Phu Tho','68:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2679,239,'Tinh Thai Nguyen','69:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2680,239,'Tinh Vinh Phuc','70:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2681,239,'Huyen Dien Bien','71:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2682,239,'Hau Giang','73:VN',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2683,239,'I prefer not to specify the state','__:VN',1,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2684,240,'Penama Province','PAM:VU',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2685,240,'Shefa Province','SEE:VU',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2686,240,'I prefer not to specify the state','__:VU',1,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2687,241,'Circonscription d\'Uvea','W:WF',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2688,241,'I prefer not to specify the state','__:WF',1,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2689,242,'Fa`asaleleaga','FA:WS',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2690,242,'Tuamasaga','TU:WS',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2691,242,'I prefer not to specify the state','__:WS',1,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2692,243,'Komuna e Ferizajt','Komuna e Ferizajt:XK',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2693,243,'Komuna e Gjilanit','Komuna e Gjilanit:XK',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2694,243,'Komuna e Mitrovices','Komuna e Mitrovices:XK',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2695,243,'Komuna e Prishtines','Komuna e Prishtines:XK',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2696,243,'Prizren','Prizren:XK',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2697,243,'I prefer not to specify the state','__:XK',1,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2698,244,'Aden','AD:YE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2699,244,'Muhafazat Hadramawt','HD:YE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2700,244,'Sanaa','SN:YE',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2701,244,'I prefer not to specify the state','__:YE',1,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2702,245,'Dzaoudzi','Dzaoudzi:YT',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2703,245,'Koungou','Koungou:YT',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2704,245,'Mamoudzou','Mamoudzou:YT',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2705,245,'Pamandzi','Pamandzi:YT',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2706,245,'I prefer not to specify the state','__:YT',1,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2707,246,'Eastern Cape','EC:ZA',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2708,246,'Orange Free State','FS:ZA',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2709,246,'Gauteng','GP:ZA',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2710,246,'Limpopo','LP:ZA',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2711,246,'Mpumalanga','MP:ZA',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2712,246,'Northern Cape','NC:ZA',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2713,246,'Province of North West','NW:ZA',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2714,246,'Province of the Western Cape','WC:ZA',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2715,246,'KwaZulu-Natal','ZN:ZA',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2716,246,'I prefer not to specify the state','__:ZA',1,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2717,247,'Western Province','01:ZM',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2718,247,'Central Province','02:ZM',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2719,247,'Luapula Province','04:ZM',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2720,247,'Northern Province','05:ZM',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2721,247,'North-Western Province','06:ZM',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2722,247,'Southern Province','07:ZM',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2723,247,'Copperbelt','08:ZM',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2724,247,'Lusaka Province','09:ZM',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2725,247,'I prefer not to specify the state','__:ZM',1,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2726,248,'Bulawayo','BU:ZW',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2727,248,'Harare','HA:ZW',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2728,248,'Manicaland','MA:ZW',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2729,248,'Mashonaland East Province','ME:ZW',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2730,248,'Midlands Province','MI:ZW',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2731,248,'Matabeleland North','MN:ZW',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2732,248,'Matabeleland South Province','MS:ZW',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2733,248,'Mashonaland West','MW:ZW',0,'2019-09-23 11:40:16','2019-09-23 11:40:16'),
(2734,248,'I prefer not to specify the state','__:ZW',1,'2019-09-23 11:40:16','2019-09-23 11:40:16');
/*!40000 ALTER TABLE `home_states` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `installments`
--

DROP TABLE IF EXISTS `installments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `installments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `inst_date` datetime DEFAULT NULL,
  `assessment_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `comments` text DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `anon_comments` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_installments_on_assessment_id` (`assessment_id`),
  KEY `index_installments_on_group_id` (`group_id`),
  KEY `index_installments_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_1a7158a65b` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`),
  CONSTRAINT `fk_rails_1a7eeb8754` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_8c4f898425` FOREIGN KEY (`assessment_id`) REFERENCES `assessments` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `installments`
--

LOCK TABLES `installments` WRITE;
/*!40000 ALTER TABLE `installments` DISABLE KEYS */;
/*!40000 ALTER TABLE `installments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `languages`
--

DROP TABLE IF EXISTS `languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `name_en` varchar(255) DEFAULT NULL,
  `name_ko` varchar(255) DEFAULT NULL,
  `translated` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_languages_on_code` (`code`),
  UNIQUE KEY `index_languages_on_name_en` (`name_en`)
) ENGINE=InnoDB AUTO_INCREMENT=187 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `languages`
--

LOCK TABLES `languages` WRITE;
/*!40000 ALTER TABLE `languages` DISABLE KEYS */;
INSERT INTO `languages` VALUES
(1,'aa','Afar','아파르어',0),
(2,'ab','Abkhazian','압하스어',0),
(3,'af','Afrikaans','아프리칸스어',0),
(4,'ak','Akan','아칸어',0),
(5,'sq','Albanian','알바니아어',0),
(6,'am','Amharic','암하라어',0),
(7,'ar','Arabic','아랍어',0),
(8,'an','Aragonese','아라곤어',0),
(9,'hy','Armenian','아르메니아어',0),
(10,'as','Assamese','아삼어',0),
(11,'av','Avaric','아바르어',0),
(12,'ae','Avestan','아베스타어',0),
(13,'ay','Aymara','아이마라어',0),
(14,'az','Azerbaijani','아제르바이잔어',0),
(15,'ba','Bashkir','바시키르어',0),
(16,'bm','Bambara','밤바라어',0),
(17,'eu','Basque','바스크어',0),
(18,'be','Belarusian','벨로루시어',0),
(19,'bn','Bengali','벵골어',0),
(20,'bh','Bihari languages','비하르어',0),
(21,'bi','Bislama','비슬라마',0),
(22,'bs','Bosnian','보스니아어',0),
(23,'br','Breton','브르타뉴어',0),
(24,'bg','Bulgarian','불가리아어',0),
(25,'my','Burmese','미얀마어',0),
(26,'ca','Catalan; Valencian','카탈루냐어',0),
(27,'ch','Chamorro','차모로어',0),
(28,'ce','Chechen','체첸어',0),
(29,'zh','Chinese','중국어',0),
(30,'cu','Church Slavic; Old Slavonic; Church Slavonic; Old Bulgarian; Old Church Slavonic','Church Slavic; Old Slavonic; Church Slavonic; Old Bulgarian; Old Church Slavonic',0),
(31,'cv','Chuvash','추바슈어',0),
(32,'kw','Cornish','콘월어',0),
(33,'co','Corsican','코르시카어',0),
(34,'cr','Cree','크리어',0),
(35,'cs','Czech','체코어',0),
(36,'da','Danish','덴마크어',0),
(37,'dv','Divehi; Dhivehi; Maldivian','디베히어',0),
(38,'nl','Dutch; Flemish','네덜란드어',0),
(39,'dz','Dzongkha','종카어',0),
(40,'en','English','영어',1),
(41,'eo','Esperanto','에스페란토어',0),
(42,'et','Estonian','에스토니아어',0),
(43,'ee','Ewe','에웨어',0),
(44,'fo','Faroese','페로스어',0),
(45,'fj','Fijian','피지어',0),
(46,'fi','Finnish','핀란드어',0),
(47,'fr','French','프랑스어',0),
(48,'fy','Western Frisian','프리지아어',0),
(49,'ff','Fulah','풀라어',0),
(50,'ka','Georgian','조지아어',0),
(51,'de','German','독일어',0),
(52,'gd','Gaelic; Scottish Gaelic','고이델어',0),
(53,'ga','Irish','아일랜드어',0),
(54,'gl','Galician','갈리시아어',0),
(55,'gv','Manx','맨어',0),
(56,'el','Greek, Modern (1453-)','그리스어 (현대) (1453년 이후)',0),
(57,'gn','Guarani','과라니어',0),
(58,'gu','Gujarati','구자라트어',0),
(59,'ht','Haitian; Haitian Creole','아이티어',0),
(60,'ha','Hausa','하우사어',0),
(61,'he','Hebrew','히브리어',0),
(62,'hz','Herero','헤레로어',0),
(63,'hi','Hindi','힌두어',0),
(64,'ho','Hiri Motu','히리 모투',0),
(65,'hr','Croatian','크로아티아어',0),
(66,'hu','Hungarian','헝가리어',0),
(67,'ig','Igbo','이그보어',0),
(68,'is','Icelandic','아이슬란드어',0),
(69,'io','Ido','이도',0),
(70,'ii','Sichuan Yi; Nuosu','쓰촨 이어',0),
(71,'iu','Inuktitut','이누이트어',0),
(72,'ie','Interlingue; Occidental','인테르링구어 (옥시덴탈)',0),
(73,'ia','Interlingua (International Auxiliary Language Association)','인테르링구아 (국제보조어협회)',0),
(74,'id','Indonesian','인도네시아어',0),
(75,'ik','Inupiaq','이누피아크어',0),
(76,'it','Italian','이탈리아어',0),
(77,'jv','Javanese','자와어',0),
(78,'ja','Japanese','일본어',0),
(79,'kl','Kalaallisut; Greenlandic','그린란드어',0),
(80,'kn','Kannada','칸나다어',0),
(81,'ks','Kashmiri','카슈미르어',0),
(82,'kr','Kanuri','카누리어',0),
(83,'kk','Kazakh','카자흐어',0),
(84,'km','Central Khmer','중부 크메르어',0),
(85,'ki','Kikuyu; Gikuyu','키쿠유어',0),
(86,'rw','Kinyarwanda','르완다어',0),
(87,'ky','Kirghiz; Kyrgyz','키르기스어',0),
(88,'kv','Komi','코미어',0),
(89,'kg','Kongo','콩고어',0),
(90,'ko','Korean','한국어',0),
(91,'kj','Kuanyama; Kwanyama','콰냐마어',0),
(92,'ku','Kurdish','쿠르드어',0),
(93,'lo','Lao','라오어',0),
(94,'la','Latin','라틴어',0),
(95,'lv','Latvian','라트비아어',0),
(96,'li','Limburgan; Limburger; Limburgish','림뷔르흐어',0),
(97,'ln','Lingala','링갈라어',0),
(98,'lt','Lithuanian','리투아니아어',0),
(99,'lb','Luxembourgish; Letzeburgesch','룩셈부르크어',0),
(100,'lu','Luba-Katanga','루바카탕가어',0),
(101,'lg','Ganda','간다어',0),
(102,'mk','Macedonian','마케도니아어',0),
(103,'mh','Marshallese','마셜어',0),
(104,'ml','Malayalam','말라얄람어',0),
(105,'mi','Maori','마오리어',0),
(106,'mr','Marathi','마라티어',0),
(107,'ms','Malay','말레이어',0),
(108,'mg','Malagasy','말라가시어',0),
(109,'mt','Maltese','몰타어',0),
(110,'mo','Moldavian; Moldovan','몰도바어',0),
(111,'mn','Mongolian','몽골어',0),
(112,'na','Nauru','나우루어',0),
(113,'nv','Navajo; Navaho','나바호어',0),
(114,'nr','Ndebele, South; South Ndebele','은데벨레어 (남)',0),
(115,'nd','Ndebele, North; North Ndebele','은데벨레어 (북)',0),
(116,'ng','Ndonga','은동가어',0),
(117,'ne','Nepali','네팔어',0),
(118,'nn','Norwegian Nynorsk; Nynorsk, Norwegian','뉘노리스크',0),
(119,'nb','Bokmål, Norwegian; Norwegian Bokmål','보크몰',0),
(120,'no','Norwegian','노르웨이어',0),
(121,'ny','Chichewa; Chewa; Nyanja','니안자어',0),
(122,'oc','Occitan (post 1500)','오크어 (1500년 이후)',0),
(123,'oj','Ojibwa','오지브와어',0),
(124,'or','Oriya','오리야어',0),
(125,'om','Oromo','오로모어',0),
(126,'os','Ossetian; Ossetic','오세트어',0),
(127,'pa','Panjabi; Punjabi','펀자브어',0),
(128,'fa','Persian','페르시아어',0),
(129,'pi','Pali','팔리어',0),
(130,'pl','Polish','폴란드어',0),
(131,'pt','Portuguese','포르투갈어',0),
(132,'ps','Pushto; Pashto','파슈토어',0),
(133,'qu','Quechua','케추아어족',0),
(134,'rm','Romansh','로만슈어',0),
(135,'ro','Romanian','루마니아어',0),
(136,'rn','Rundi','룬디어',0),
(137,'ru','Russian','러시아어',0),
(138,'sg','Sango','상고어',0),
(139,'sa','Sanskrit','산스크리트어',0),
(140,'si','Sinhala; Sinhalese','싱할라어',0),
(141,'sk','Slovak','슬로바키아어',0),
(142,'sl','Slovenian','슬로베니아어',0),
(143,'se','Northern Sami','사미어 (북)',0),
(144,'sm','Samoan','사모아어',0),
(145,'sn','Shona','쇼나어',0),
(146,'sd','Sindhi','신디어',0),
(147,'so','Somali','소말리아어',0),
(148,'st','Sotho, Southern','소토어 (남)',0),
(149,'es','Spanish; Castilian','스페인어',0),
(150,'sc','Sardinian','사르데냐어',0),
(151,'sr','Serbian','세르비아어',0),
(152,'ss','Swati','스와티어',0),
(153,'su','Sundanese','순다어',0),
(154,'sw','Swahili','스와힐리어',0),
(155,'sv','Swedish','스웨덴어',0),
(156,'ty','Tahitian','타히티어',0),
(157,'ta','Tamil','타밀어',0),
(158,'tt','Tatar','타타르어',0),
(159,'te','Telugu','텔루구어',0),
(160,'tg','Tajik','타지크어',0),
(161,'tl','Tagalog','타갈로그어',0),
(162,'th','Thai','타이어',0),
(163,'bo','Tibetan','티베트어',0),
(164,'ti','Tigrinya','티그리냐어',0),
(165,'to','Tonga (Tonga Islands)','통가어 (통가 제도)',0),
(166,'tn','Tswana','츠와나어',0),
(167,'ts','Tsonga','총가어',0),
(168,'tk','Turkmen','투르크멘어',0),
(169,'tr','Turkish','터키어',0),
(170,'tw','Twi','알칸어군',0),
(171,'ug','Uighur; Uyghur','위구르어',0),
(172,'uk','Ukrainian','우크라이나어',0),
(173,'ur','Urdu','우르두어',0),
(174,'uz','Uzbek','우즈베크어',0),
(175,'ve','Venda','벤다어',0),
(176,'vi','Vietnamese','베트남어',0),
(177,'vo','Volapük','볼라퓌크',0),
(178,'cy','Welsh','웨일스어',0),
(179,'wa','Walloon','왈론어',0),
(180,'wo','Wolof','월로프어',0),
(181,'xh','Xhosa','코사어',0),
(182,'yi','Yiddish','이디시어',0),
(183,'yo','Yoruba','요루바어',0),
(184,'za','Zhuang; Chuang','좡어',0),
(185,'zu','Zulu','줄루어',0),
(186,'__','I prefer not to answer',NULL,0);
/*!40000 ALTER TABLE `languages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `narratives`
--

DROP TABLE IF EXISTS `narratives`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `narratives` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_en` varchar(255) DEFAULT NULL,
  `scenario_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `member_ko` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_narratives_on_scenario_id` (`scenario_id`),
  CONSTRAINT `fk_rails_da4a9ae69b` FOREIGN KEY (`scenario_id`) REFERENCES `scenarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `narratives`
--

LOCK TABLES `narratives` WRITE;
/*!40000 ALTER TABLE `narratives` DISABLE KEYS */;
INSERT INTO `narratives` VALUES
(1,'Natasha',1,'2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(2,'Anika',1,'2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(3,'Lionel',1,'2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(4,'Alex',1,'2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(5,'Anna',2,'2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(6,'Jose',2,'2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(7,'Sam',2,'2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(8,'Kim',2,'2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(9,'John',3,'2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(10,'Marie',3,'2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(11,'Hannah',3,'2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(12,'Iain',3,'2019-09-23 11:40:16','2019-09-23 11:40:16',NULL);
/*!40000 ALTER TABLE `narratives` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `projects`
--

DROP TABLE IF EXISTS `projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `projects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `course_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `start_dow` int(11) DEFAULT NULL,
  `end_dow` int(11) DEFAULT NULL,
  `active` tinyint(1) DEFAULT 0,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `factor_pack_id` int(11) DEFAULT NULL,
  `style_id` int(11) DEFAULT NULL,
  `anon_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_projects_on_course_id` (`course_id`),
  KEY `index_projects_on_factor_pack_id` (`factor_pack_id`),
  KEY `index_projects_on_style_id` (`style_id`),
  CONSTRAINT `fk_rails_07e8a3d0a3` FOREIGN KEY (`style_id`) REFERENCES `styles` (`id`),
  CONSTRAINT `fk_rails_589498d3ea` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`),
  CONSTRAINT `fk_rails_c64048b0e4` FOREIGN KEY (`factor_pack_id`) REFERENCES `factor_packs` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `projects`
--

LOCK TABLES `projects` WRITE;
/*!40000 ALTER TABLE `projects` DISABLE KEYS */;
/*!40000 ALTER TABLE `projects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quotes`
--

DROP TABLE IF EXISTS `quotes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quotes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `text_en` varchar(255) DEFAULT NULL,
  `attribution` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quotes`
--

LOCK TABLES `quotes` WRITE;
/*!40000 ALTER TABLE `quotes` DISABLE KEYS */;
INSERT INTO `quotes` VALUES
(1,'Alone we can do so little; together we can do so much.','Helen Keller','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(2,'If I have seen further, it is by standing on the shoulders of giants.\n','Isaac Newton','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(3,'No one can whistle a symphony. It takes a whole orchestra to play it.','H.E. Luccock','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(4,'If everyone is moving forward together, then success takes care of itself.\n','Henry Ford','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(5,'Coming together is a beginning, staying together is progress, and working together is success.\n','Henry Ford','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(6,'Talent wins games, but teamwork and intelligence win championships.','Michael Jordan','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(7,'The strength of the team is each individual member. The strength of each member is the team.\n','Phil Jackson','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(8,'There is no such thing as a self-made man. You will reach your goals only with the help of others.\n','George Shinn','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(9,'It is literally true that you can succeed best and quickest by helping others to succeed.\n','Napolean Hill','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(10,'The whole is other than the sum of the parts.','Kurt Koffka','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(11,'The ratio of \'We\'s to \'I\'s is the best indicator of the development of a team.','Lewis B. Ergen','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(12,'If you want to lift yourself up, lift up someone else.','Booker T. Washington','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(13,'Great things in business are never done by one person; they\'re done by a team of people.\n','Steve Jobs','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(14,'Individually, we are one drop. Together, we are an ocean.','Ryunosuke Satoro','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(15,'Cooperation is the thorough conviction that nobody can get there unless everybody gets there.\n','Virginia Burden','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(16,'Dialogue isn\'t a competition to be the smartest or the most correct person in the room; it is a collaboration to find the truth.\n','Oli Anderson','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(17,'When people challenge your ideas, they help you (whether they know it or not).\n','Oli Anderson','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(18,'Teamwork makes the dream work.','Bang Gae','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(19,'None of us is as smart as all of us.','Ken Blanchard','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(20,'Teamwork is the secret that makes common people achieve uncommon results.','Ifeanyi Onuoha','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(21,'We must all hang together or most assuredly we shall all hang separately.','Ben Franklin','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(22,'People achieve more as a result of working with others than against them.','Dr. Allan Fromme','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(23,'Teamwork: A few harmless flakes working together can unleash an avalanche of destruction.\n','Justin Sewell','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(24,'The nice thing about teamwork is that you always have others on your side.\n','Margaret Carty','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(25,'When he took time to help the man up the mountain, lo, he scaled it himself.','Tibetan Proverb','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(26,'When spider webs unite, they can tie up a lion.','Ethiopian Proverb','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(27,'It\'s a very important thing to learn to talk to people you disagree with.\n','Pete Seeger','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(28,'No member of a crew is praised for the rugged individuality of his rowing.','Ralph Waldo Emerson','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(29,'You don\'t get harmony when everybody sings the same note.','Doug Floyd','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(30,'In teamwork, silence isn\'t golden. Its deadly.','Mark Sanborn','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(31,'If you try and we lose, then it isn\'t your fault. But if you don\'t try and we lose, then it\'s all your fault.\"\n','Orson Scott Card','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(32,'There is little success where there is little laughter.','Andrew Carnegie','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(33,'A major reason capable people fail to advance is that they don\'t work well with their colleagues.\n','Lee Iacocca','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(34,'It takes two flints to make a fire.','Louisa May Alcott','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(35,'The main ingredient of stardom is the rest of the team.','John Wooden','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(36,'Disruption isnt about what happens to you. Its about how you respond to what happens to you.\n','Jay Samit','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(37,'As a coach, I play not my eleven best, but my best eleven.','Knute Rockne','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(38,'I suppose leadership at one time meant muscles, but today it means getting along with people.\n','Mohandas Ghandi','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(39,'I\'m not the smartest fellow in the world, but I sure can pick smart colleagues.\n','Franklin D. Roosevelt','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(40,'Sometimes the most ordinary things could be made extraordinary simply by doing them with the right people.\n','Nicholas Sparks','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(41,'Collaborate with people you can learn from.\n','Pharrell','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(42,'When we learn how to work together versus against each other things might start getting better.\n','Alex Elle','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(43,'It takes both sides to build a bridge.\n','Fredrik Nael','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(44,'A group becomes a team when each member is sure enough of himself to praise the skills of others.\n','Norman Shidle','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(45,'It\'s better to have a great team than a team of greats.\n','Simon Sinek','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(46,'The chain is only as strong as the weakest link  \n','Thomas Reid','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(47,'A single leaf working alone provides no shade.\n','Chuck Page','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(48,'The way to achieve your own success is to be willing to help somebody else get it first.\n','Iyanla Vanzant','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(49,'We rise by lifting others.\n','Robert Ingersoll','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(50,'If you take out the team in teamwork, it’s just work. Now who wants that?\n','Matthew Woodring Stover','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(51,'I don’t like that man. I must get to know him better.\n','Abraham Lincoln','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(52,'It is amazing what you can accomplish if you do not care who gets the credit.\n','Harry S. Truman','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(53,'\"On this team, we\'re all united in a common goal: to keep my job.\"\n','Lou Holtz','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(54,'Trust is knowing that when a team member does push you, they\'re doing it because they care about the team.\n','Patrick Lencioni','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(55,'Many hands make light work.\n','John Heywood','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(56,'Never doubt that a small group of thoughtful, committed citizens can change the world; indeed, it\'s the only thing that ever has.\n','Margaret Mead','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(57,'Thoroughly to teach another is the best way to learn for yourself.\n','Tryon Edwards','2019-09-23 11:40:17','2019-09-23 11:40:17'),
(58,'You may have the greatest bunch of individual stars in the world, but if they don\'t play together, the club won\'t be worth a dime.\n','Babe Ruth','2019-09-23 11:40:17','2019-09-23 11:40:17');
/*!40000 ALTER TABLE `quotes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reactions`
--

DROP TABLE IF EXISTS `reactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `behavior_id` int(11) DEFAULT NULL,
  `narrative_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `improvements` text DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `experience_id` int(11) DEFAULT NULL,
  `instructed` tinyint(1) DEFAULT NULL,
  `other_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_reactions_on_behavior_id` (`behavior_id`),
  KEY `index_reactions_on_experience_id` (`experience_id`),
  KEY `index_reactions_on_narrative_id` (`narrative_id`),
  KEY `index_reactions_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_7f421c2684` FOREIGN KEY (`experience_id`) REFERENCES `experiences` (`id`),
  CONSTRAINT `fk_rails_9f02fc96a0` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_c7ec08af40` FOREIGN KEY (`behavior_id`) REFERENCES `behaviors` (`id`),
  CONSTRAINT `fk_rails_e65aaa237a` FOREIGN KEY (`narrative_id`) REFERENCES `narratives` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reactions`
--

LOCK TABLES `reactions` WRITE;
/*!40000 ALTER TABLE `reactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `reactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rosters`
--

DROP TABLE IF EXISTS `rosters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rosters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role` int(11) NOT NULL DEFAULT 4,
  `course_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_rosters_on_course_id` (`course_id`),
  KEY `index_rosters_on_role` (`role`),
  KEY `index_rosters_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_51ff61356a` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_c39627e3e4` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rosters`
--

LOCK TABLES `rosters` WRITE;
/*!40000 ALTER TABLE `rosters` DISABLE KEYS */;
/*!40000 ALTER TABLE `rosters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rubrics`
--

DROP TABLE IF EXISTS `rubrics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rubrics` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `version` int(11) NOT NULL DEFAULT 1,
  `published` tinyint(1) NOT NULL DEFAULT 0,
  `parent_id` bigint(20) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `school_id` int(11) DEFAULT NULL,
  `anon_name` varchar(255) DEFAULT NULL,
  `anon_description` varchar(255) DEFAULT NULL,
  `anon_version` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_rubrics_on_name_and_version_and_parent_id` (`name`,`version`,`parent_id`),
  KEY `index_rubrics_on_parent_id` (`parent_id`),
  KEY `index_rubrics_on_user_id` (`user_id`),
  KEY `index_rubrics_on_school_id` (`school_id`),
  CONSTRAINT `fk_rails_0b2276316d` FOREIGN KEY (`parent_id`) REFERENCES `rubrics` (`id`),
  CONSTRAINT `fk_rails_28ec4c65ca` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`),
  CONSTRAINT `fk_rails_b5b6f45923` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rubrics`
--

LOCK TABLES `rubrics` WRITE;
/*!40000 ALTER TABLE `rubrics` DISABLE KEYS */;
/*!40000 ALTER TABLE `rubrics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scenarios`
--

DROP TABLE IF EXISTS `scenarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scenarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name_en` varchar(255) DEFAULT NULL,
  `behavior_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name_ko` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_scenarios_on_behavior_id` (`behavior_id`),
  CONSTRAINT `fk_rails_cb659c3c70` FOREIGN KEY (`behavior_id`) REFERENCES `behaviors` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scenarios`
--

LOCK TABLES `scenarios` WRITE;
/*!40000 ALTER TABLE `scenarios` DISABLE KEYS */;
INSERT INTO `scenarios` VALUES
(1,'Equal Participation',1,'2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(2,'Group Domination',3,'2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(3,'Social Loafing',4,'2019-09-23 11:40:16','2019-09-23 11:40:16',NULL);
/*!40000 ALTER TABLE `scenarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES
('20170115031828'),
('20170115064115'),
('20170115070431'),
('20170115071238'),
('20170115071944'),
('20170115072104'),
('20170115072301'),
('20170115074013'),
('20170115080733'),
('20170115080901'),
('20170115081145'),
('20170115091046'),
('20170115091956'),
('20170115092752'),
('20170115093038'),
('20170115094815'),
('20170115103526'),
('20170115105424'),
('20170115111424'),
('20170115111609'),
('20170116062743'),
('20170116103703'),
('20170117104127'),
('20170117115431'),
('20170117120755'),
('20170118045213'),
('20170118045302'),
('20170118045614'),
('20170118070916'),
('20170119125723'),
('20170119133102'),
('20170119134145'),
('20170120013435'),
('20170120013843'),
('20170120013944'),
('20170120014106'),
('20170120014709'),
('20170120094750'),
('20170126073154'),
('20170127030217'),
('20170127030436'),
('20170127030610'),
('20170206053808'),
('20170206071120'),
('20170208064148'),
('20170209045242'),
('20170209064126'),
('20170213051438'),
('20170219004833'),
('20170220103043'),
('20170225093221'),
('20170225093259'),
('20170227124407'),
('20170228021027'),
('20170303025903'),
('20170316161141'),
('20170318114421'),
('20170318115157'),
('20170318115702'),
('20170318120059'),
('20170318120238'),
('20170318120547'),
('20170318120735'),
('20170318141645'),
('20170320150239'),
('20170330153632'),
('20170331025301'),
('20170331040142'),
('20170331045901'),
('20170401061207'),
('20170401065733'),
('20170402133941'),
('20170402134023'),
('20170406070704'),
('20170406070715'),
('20170407024545'),
('20170410131734'),
('20170411005748'),
('20170411010018'),
('20170411010208'),
('20170419023423'),
('20170419145439'),
('20170425000307'),
('20170524022348'),
('20170524023157'),
('20170524023603'),
('20170524023820'),
('20170524023947'),
('20170524024114'),
('20170524044413'),
('20170524112411'),
('20170527033545'),
('20170529054801'),
('20170529054817'),
('20170616035248'),
('20170616040505'),
('20170618121948'),
('20170621041602'),
('20170621041603'),
('20170621041604'),
('20170622054334'),
('20170622054630'),
('20170630203730'),
('20170630203930'),
('20170701103930'),
('20170701153930'),
('20170701155140'),
('20170701171634'),
('20170701173434'),
('20170701191534'),
('20170702053534'),
('20170702054534'),
('20170702055534'),
('20170728135355'),
('20170728140605'),
('20170728142028'),
('20170729021942'),
('20170729030240'),
('20170731084719'),
('20170803080009'),
('20170807013336'),
('20170824050028'),
('20170828054803'),
('20171009050315'),
('20171014054009'),
('20171014135440'),
('20171014135942'),
('20171017020030'),
('20171022013628'),
('20171026030636'),
('20171103055606'),
('20171118140620'),
('20171225131145'),
('20180115065402'),
('20180129083336'),
('20180226064814'),
('20180228001942'),
('20180318021636'),
('20180320071940'),
('20180401054814'),
('20180407212714'),
('20180913021018'),
('20190113055316'),
('20190204083206'),
('20190204084200'),
('20190423122433'),
('20190423123022'),
('20190428135713'),
('20190508060916'),
('20190520002703'),
('20190520042318'),
('20190520054740'),
('20190521031731'),
('20190523014532'),
('20190621144829'),
('20190818234515'),
('20191028013641'),
('20200103190548'),
('20200429043801'),
('20200621012559'),
('20200706041850'),
('20200811031128'),
('20210330044054'),
('20210330044055'),
('20220219194244'),
('20220226235110'),
('20221201214357'),
('20221204025950'),
('20230127221505'),
('20230127225045'),
('20230128043847'),
('20230206032450'),
('20230206040920'),
('20230212031949'),
('20230218040723'),
('20230219025034');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schools`
--

DROP TABLE IF EXISTS `schools`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schools` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` text DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `anon_name` varchar(255) DEFAULT NULL,
  `timezone` varchar(255) NOT NULL DEFAULT 'UTC',
  `courses_count` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schools`
--

LOCK TABLES `schools` WRITE;
/*!40000 ALTER TABLE `schools` DISABLE KEYS */;
INSERT INTO `schools` VALUES
(1,'A large, Midwestern university','Indiana University','2019-09-23 11:40:16','2019-09-23 11:40:16','Eayo institute','UTC',0),
(2,'The State University of New York, Korea','SUNY Korea','2019-09-23 11:40:16','2019-09-23 11:40:16','Quatz institute','Seoul',0);
/*!40000 ALTER TABLE `schools` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) NOT NULL,
  `data` text DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `styles`
--

DROP TABLE IF EXISTS `styles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `styles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name_en` varchar(255) DEFAULT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name_ko` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_styles_on_name_en` (`name_en`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `styles`
--

LOCK TABLES `styles` WRITE;
/*!40000 ALTER TABLE `styles` DISABLE KEYS */;
INSERT INTO `styles` VALUES
(1,'Default','new','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(2,'Sliders (simple)','slider_basic','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL);
/*!40000 ALTER TABLE `styles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `themes`
--

DROP TABLE IF EXISTS `themes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `themes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `name_en` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name_ko` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_themes_on_code` (`code`),
  UNIQUE KEY `index_themes_on_name_en` (`name_en`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `themes`
--

LOCK TABLES `themes` WRITE;
/*!40000 ALTER TABLE `themes` DISABLE KEYS */;
INSERT INTO `themes` VALUES
(1,'a','MJ','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(2,'b','Maverick','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(3,'c','Peppermint','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(4,'d','Manhattan','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(5,'e','Carrot','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(6,'f','Hot Dog Stand','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(7,'g','Decepticon','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(8,'h','just one','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL);
/*!40000 ALTER TABLE `themes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `encrypted_password` varchar(255) NOT NULL DEFAULT '',
  `reset_password_token` varchar(255) DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) NOT NULL DEFAULT 0,
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) DEFAULT NULL,
  `last_sign_in_ip` varchar(255) DEFAULT NULL,
  `confirmation_token` varchar(255) DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `confirmation_sent_at` datetime DEFAULT NULL,
  `unconfirmed_email` varchar(255) DEFAULT NULL,
  `failed_attempts` int(11) NOT NULL DEFAULT 0,
  `unlock_token` varchar(255) DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `gender_id` int(11) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `timezone` varchar(255) DEFAULT 'UTC',
  `admin` tinyint(1) DEFAULT NULL,
  `welcomed` tinyint(1) DEFAULT NULL,
  `last_emailed` datetime DEFAULT NULL,
  `theme_id` int(11) DEFAULT 1,
  `school_id` int(11) DEFAULT NULL,
  `anon_first_name` varchar(255) DEFAULT NULL,
  `anon_last_name` varchar(255) DEFAULT NULL,
  `researcher` tinyint(1) DEFAULT NULL,
  `language_id` int(11) NOT NULL DEFAULT 40,
  `date_of_birth` date DEFAULT NULL,
  `home_state_id` int(11) DEFAULT NULL,
  `cip_code_id` int(11) DEFAULT NULL,
  `primary_language_id` int(11) DEFAULT NULL,
  `started_school` date DEFAULT NULL,
  `impairment_visual` tinyint(1) DEFAULT NULL,
  `impairment_auditory` tinyint(1) DEFAULT NULL,
  `impairment_motor` tinyint(1) DEFAULT NULL,
  `impairment_cognitive` tinyint(1) DEFAULT NULL,
  `impairment_other` tinyint(1) DEFAULT NULL,
  `provider` varchar(255) NOT NULL DEFAULT 'email',
  `uid` varchar(255) NOT NULL DEFAULT '',
  `tokens` text DEFAULT NULL,
  `instructor` tinyint(1) NOT NULL DEFAULT 0,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_uid_and_provider` (`uid`,`provider`),
  UNIQUE KEY `index_users_on_confirmation_token` (`confirmation_token`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`),
  UNIQUE KEY `index_users_on_unlock_token` (`unlock_token`),
  KEY `index_users_on_cip_code_id` (`cip_code_id`),
  KEY `index_users_on_gender_id` (`gender_id`),
  KEY `index_users_on_home_state_id` (`home_state_id`),
  KEY `index_users_on_language_id` (`language_id`),
  KEY `index_users_on_school_id` (`school_id`),
  KEY `index_users_on_theme_id` (`theme_id`),
  CONSTRAINT `fk_rails_342250fdc1` FOREIGN KEY (`theme_id`) REFERENCES `themes` (`id`),
  CONSTRAINT `fk_rails_3fa423ca74` FOREIGN KEY (`cip_code_id`) REFERENCES `cip_codes` (`id`),
  CONSTRAINT `fk_rails_45f4f12508` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`),
  CONSTRAINT `fk_rails_47055e3204` FOREIGN KEY (`gender_id`) REFERENCES `genders` (`id`),
  CONSTRAINT `fk_rails_570f5e37b9` FOREIGN KEY (`home_state_id`) REFERENCES `home_states` (`id`),
  CONSTRAINT `fk_rails_e7d0538b2c` FOREIGN KEY (`school_id`) REFERENCES `schools` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES
(1,'$2a$04$CaDetLlxhfe65uYCvlL91O7wEhBwXc5ucNtVlholavm2KpDmAmbzG',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'2019-09-23 11:40:17','2020-08-11 03:13:58','Micah','Modell',NULL,NULL,'UTC',1,NULL,NULL,1,NULL,'Ashley','Welch',NULL,40,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'email','micah.modell@gmail.com',NULL,0,1);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `values`
--

DROP TABLE IF EXISTS `values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `values` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `installment_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `factor_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_values_on_factor_id` (`factor_id`),
  KEY `index_values_on_installment_id` (`installment_id`),
  KEY `index_values_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_1986796f2c` FOREIGN KEY (`factor_id`) REFERENCES `factors` (`id`),
  CONSTRAINT `fk_rails_3abc1a1414` FOREIGN KEY (`installment_id`) REFERENCES `installments` (`id`),
  CONSTRAINT `fk_rails_690f376fee` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `values`
--

LOCK TABLES `values` WRITE;
/*!40000 ALTER TABLE `values` DISABLE KEYS */;
/*!40000 ALTER TABLE `values` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `weeks`
--

DROP TABLE IF EXISTS `weeks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `weeks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `narrative_id` int(11) DEFAULT NULL,
  `week_num` int(11) DEFAULT NULL,
  `text_en` text DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `text_ko` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_weeks_on_week_num_and_narrative_id` (`week_num`,`narrative_id`),
  KEY `index_weeks_on_narrative_id` (`narrative_id`),
  CONSTRAINT `fk_rails_8ccbaf6e42` FOREIGN KEY (`narrative_id`) REFERENCES `narratives` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=169 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `weeks`
--

LOCK TABLES `weeks` WRITE;
/*!40000 ALTER TABLE `weeks` DISABLE KEYS */;
INSERT INTO `weeks` VALUES
(1,4,1,'<p> In group time, we began by setting up weekly team meetings. My group\nseems to be nice, and Anika and I shared one of our big lecture courses\nlast semester. Lionel says he just transferred into this school. The\nproject is pretty big and fairly open-ended, so we brainstormed topic ideas\nfor the rest of the time. </p>\n\n<p> Anika was pretty quiet &mdash; maybe she suggested an idea or two.\nEveryone else seemed to have a lot to say, though. Natasha\'s ideas almost\nalways made me laugh. She seems to be working hard to get outside the box\nand mostly she did it. This meant that many of her ideas weren\'t really\nuseable, but they were fun and often they helped me to come up with other\nideas, too. Toward the end of our meeting, Lionel noticed that no one was\ntaking notes, so we recounted the ideas we could remember while he wrote\nthem down and we discussed those 14 ideas. </p>\n\n<p> Before the meeting ended, we crossed off the ones that didn\'t seem to\nwork (this got rid of most of Natasha\'s) and ultimately narrowed it down to\nsix. I recommended we each look for resources on all the topics to get\nfamiliar with them. Next week, we will report back and select a topic.\nEveryone agreed with this, so we had a plan. </p>\n\n<p> After searching for about half an hour, it was pretty clear that only\ntwo of the topics really work for this project, so I focused on those. I\nfigure that if we are all working on this independently, we are likely to\ncome up with many of the same materials, so I tried not to spend too much\ntime on the ones I found easily, but rather to dig deeper instead. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(2,4,2,'<p> Anika found a lot of materials for one of the topics that I had a rough\ntime with, but Lionel and Natasha also focused on the same two as me. We\nended up with a lot of duplication, but at least we all know those topics.\nWhen we dug into what Anika found for the third topic, I couldn\'t see how\nwe would be able to use much of it &mdash; the research mostly just had\nmentions of what we needed. Even Anika seemed to mostly dismiss the topic,\nand our discussion quickly centered on our most promising two topics. </p>\n\n<p> There was a lot of discussion about which to choose &mdash; everyone\nhad an opinion. Then Natasha suggested that we try to combine them. We\nwasted about ten minutes trying to see if we could make that work, but\nultimately we couldn\'t and wound up back where we started. Our first vote\nwas split down the middle, so I decided to make a list of pros and cons. I\nmay have conveniently skewed the list in favor of my preference, but either\nway, our next vote was unanimous. Alex immediately pointed out that the\nother topic, although more exciting on the surface, would have probably\nbeen much more complicated and difficult. </p>\n\n<p> The obvious next step was to find more materials on our selected topic,\nso we figured out the major subtopics and divided them amongst ourselves.\nWe decided everyone would return next week with summaries of what they\'d\nfound to make it easier for the group to get moving quickly. To make sure\nwe didn\'t wind up with a million competing summaries for the many duplicate\nmaterials, I split up the materials we\'d already got among us. </p>\n\n<p> I found some more materials and then spent about half an hour writing\nthose summaries. The project would be big, but it is pretty straightforward\nso far. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(3,4,3,'<p> During our meeting, we began sorting through the materials. Lionel\'s\nand Natasha\'s materials were in good shape. At one point, Natasha misread\none of Lionel\'s summaries and made everyone laugh, but it was a pretty\nlucky mistake. In the ensuing conversation, a whole new light was shone on\nthe topic. I\'m not sure if that\'s what Natasha intended, but if so, it was\nbrilliant.  </p>\n\n<p> I guess I should have spent more time writing because no one understood\nwhat I wrote. I\'m not used to working in groups, and I guess I forget to\nexplain everything. I just wrote down my observations (which, in this case,\nI could have used to write my own paper), but it wasn\'t complete and I had\nto explain it for the rest of the group. They did like my observations,\nthough! I told them I\'d rework them for next week.  </p>\n\n<p> Anika\'s summaries, on the other hand, were just a sentence or two each.\nInitially, she seemed to think they would be useful to us. After some\nawkward questions, I asked her point blank if she\'d prefer to use Natasha\'s\nsummaries or her own to write the paper, and she understood. The question\nwas a bit blunt, but if Anika was offended, she didn\'t show it. I suspect\nit helped that we all had things to do to improve our work for next week.\n</p>\n\n<p> I restructured my summaries this week to look more like summaries than\nmy own notes. When I was done, I asked my roommate to take a look, and he\nhad a few good questions that I subsequently addressed. All told, it took\nme about an hour and forty-five minutes. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(4,4,4,'<p> Lionel was a bit late to the meeting this week, but Anika wasn\'t there\nat all. She hadn\'t been in class and no one had heard anything from her, so\nwe weren\'t sure what was going on.  </p>\n\n<p> When it looked like she wouldn\'t be coming, we began working through my\nupdated materials. Lionel and Natasha were both much happier this time.\nLionel pointed out that they could use some editing, but that they were\nmuch improved. He made a point of saying he really liked some of the\nobservations I\'d made. He volunteered to try to redo Anika\'s work and\nassemble what we had for the assignment due next week, but Natasha said\nshe\'d work on Anika\'s part and get it to him so he could include them. She\nsaid she didn\'t want him overloaded. She also asked me to put together a\nbasic outline of what the paper should look like. What a smart idea! </p>\n\n<p> Putting together the outline didn\'t really take a whole lot of time.\n</p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(5,4,5,'<p> Lionel turned in our assignment this week in class and Anika was there,\ntoo. It seems she\'d had to go home in a rush because her mother went to the\nhospital, but she had done her summaries and got them to Lionel in time for\nhim to include them in what he turned in. Our instructor gave us some time\nto meet as a group at the end of class, and we spent the time looking at my\noutline. Lionel seemed to be satisfied with it, but Anika and Natasha\nweren\'t. I wasn\'t really sure what they didn\'t like because we didn\'t have\nmuch time to get into it, but I tried to make some changes that evening.\n</p>\n\n<p> At our meeting, it took a while to really understand where we weren\'t\nconnecting. I thought the two of them were looking for me to make some\nchanges to what I had, but it turned out they had completely different\nideas of where this was going &mdash; from each other as well as from me!\nLionel seemed to be confused and stayed out of our discussion. I think he\nfigured it was all a simple misunderstanding that\'d get worked out quickly,\nbut he managed to be very involved in the conversation because his face is\nvery expressive. It was clear that he was being swayed by Natasha. So was\nI, for that matter. After about half an hour, we modified the outline to\nlook more like what Natasha was describing. Even Anika reluctantly agreed\nthat it was probably the right way to go. </p>\n\n<p> With the outline settled, Anika suggested we split the outline up into\nquarters and each write one for next week. Lionel spoke up quickly for the\nsecond section and I took the third because I didn\'t want to write the\nintroduction or the conclusion. Fortunately, Natasha took the former and\nAnika took the latter. </p>\n\n<p> It took me about two hours to write my draft of the paper because I\njust couldn\'t seem to make everything work properly. I finally stopped when\nI had something, but it\'s hardly my best work. It just doesn\'t seem to all\nfit properly. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(6,4,6,'<p> It seems that no one was really able to make the pieces work quite\nright, so we had to rethink our approach. I had a feeling Anika would bring\nup her idea from last week, and she did. Fortunately, I\'d thought a lot\nabout that when I ran into trouble writing and was quickly able to point\nout where and how we\'d run into the same problems her way. Lionel listened\nfor a bit and then suggested that we try something that he had used on a\npast project; it was a really good idea. It would, of course, require some\nadaptation, but it could work out very well for us.  </p>\n\n<p> Natasha and Anika joined in, and we ironed it out together. It was sort\nof exciting, really. In spite of it being his idea, Lionel seemed to be\nnervous about suggesting anything, but he also contributed. About halfway\ninto our meeting, we started looking back at the pieces we\'d already\nwritten and seeing if/where they still fit. It looked like we would be left\nwith about half a paper still to write. </p>\n\n<p> This time, we each took pieces that were left to write. Anika and\nNatasha fought a bit over who took one of the tricky parts, but ultimately\nwe all wound up with pieces we could handle. </p>\n\n<p> A few days later, Lionel asked if I could help him out with one of his\npieces. I felt bad because I hadn\'t started any of my writing, but of\ncourse I said yes. We worked on it for about an hour and he answered all\nhis own questions, so I don\'t know why he needed me.  </p>\n\n<p> When we moved on to my work, he couldn\'t understand any of what I\'d\nthrown together that morning. I knew it needed work, but it was also nice\nto have him pointing out exactly where. Sometimes it\'s tough to see what\nyou\'re thinking through other people\'s eyes. I am pretty sure he helped me\nmore than I helped him, and I told him so, but he probably didn\'t believe\nme &mdash; he really doesn\'t think he\'s very smart. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(7,4,7,'<p> I was a bit late because one of my instructors offered to run a study\nsession to prepare for the midterms, and I desperately needed the help. I\nfelt bad that I forgot to tell the group last week, but when I arrived I\nlearned that everyone else had been late for similar reasons. </p>\n\n<p> In spite of this, everyone was happier with what we had this week and,\nafter running through what we had, the paper was starting to look pretty\ngood. We spent much of our time assembling the pieces into a single paper.\nWhen we did, we realized that neither the introduction nor the conclusion\nworked very well any longer. Natasha asked Lionel to write the\nintroduction, because the new structure of the paper was his idea, but I\nthink he honestly doesn\'t understand that it was true. He actually denied\nit &mdash; and I don\'t think it was because he didn\'t want to write the\npiece. When he said he\'d do it, he made Anika promise that she\'d review it\nthe following week.  </p>\n\n<p> I volunteered to rework the conclusion, but Natasha asked me instead to\nproofread and format the document, while she rewrote the conclusion. Anika\ndidn\'t have anything for the week, and I think she didn\'t want to feel like\na slacker, so she said she\'d proofread the document, as well &mdash; just\nto have an extra set of eyes on it.  </p>\n\n<p> Natasha also told us she\'d be late next week because one of her\nmidterms would run until the start of this meeting. </p>\n\n<p> Proofreading took me awhile. It\'s a good paper, but you can tell it was\nwritten by four different people. I found lots of little things, but there\nwere a few things that will need major rework. One part of what Natasha had\nwritten probably made sense when she wrote it, but the instructor\ncompletely contradicted it in class, so we\'ll have to completely rewrite\nthat piece. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(8,4,8,'<p> I thought the group would be bummed that I was so nitpicky, but they\nwere thrilled I\'d found so much stuff. Anika found good stuff, too, but I\nhad almost everything she did and then about half again as many. We decided\nthat we couldn\'t make the bigger changes in time for the draft that\'s due\nnext week. We will be able to write it, but everyone has tight schedules\nthis week. We can\'t get it written and give anyone else a chance to take a\nlook at it before we have to turn it in; no one felt that would be OK. </p>\n\n<p> Natasha showed up just as we finished going through the fixes to the\npaper. Next we looked at Lionel\'s introduction and Anika immediately asked\nwhat everyone was thinking: why was it so short? Lionel just shrugged and\nwe all read it. As it turned out, Anika shouldn\'t have said anything before\nshe read it &mdash; it covered everything it needed to and was pretty good.\nNeither Natasha nor I had any ideas for improving it. I think Anika\nfelt like she had to do something, so after she thought about it for a\nmoment, she agreed that nothing was missing, but said she had some ideas\nfor beefing it up a bit. A few minutes later we had a new version that was\nlonger and felt a bit more complete. It was good, but not really necessary.\nI suggested making a part of what Natasha added a bit more concise. </p>\n\n<p> When we were done, Anika said she\'d add in the conclusion, make the\nchanges we talked about and have a version of the paper ready to turn in\nnext week in class. Natasha said that she\'d try to make the larger changes\nthat I\'d suggested. Lionel volunteered to start building a PowerPoint for\nthe upcoming presentation. I felt bad, but asked if anyone minded if I took\nthe week off because I had to prepare for a late midterm next week in my\ntoughest subject. No one minded. </p>\n\n<p> This week I did nothing for this class outside of our meeting. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(9,4,9,'<p> Anika not only brought a copy of our paper to class for the instructor,\nbut also brought copies for each of us to look at between class and our\nmeeting. This way, we didn\'t waste our meeting time on reading through it.\nAs an added bonus, Natasha had merged her changes into this latest version.\nUnfortunately, she\'d had a difficult time making those changes and they\nwere not complete. She brought a list of questions and possible answers,\nand we spent a good twenty minutes on that before we came to any answers.\nAt some point while I was listening, I had a fantastic idea so I said I\'d\ntake it home and work on it for next week. No one argued with me. </p>\n\n<p> Next we discussed the presentation &mdash; beginning with the\nPowerPoint Lionel had put together. Before Anika could comment (because she\nalways does), Lionel pointed out that this was just a start and that he\nknew there wasn\'t much to it. He recommended that everyone claim a few\nslides and modify them when they worked on what they were going to say. At\nthis, Anika just shut her mouth and I have to admit, that was pretty\nsatisfying. She\'s not mean or anything, but it was nice to not hear her\nbeing critical for once.  </p>\n\n<p> Natasha chose a few slides, including the first one, but Lionel said he\nwanted to introduce us. I was a bit surprised, because I didn\'t figure he\'d\nvolunteer for such a visible role. Ultimately, we decided that they\'d both\ngive it a shot and see which one we like best when we practice next week.\nI\'m actually excited about making it into a bit of a competition. </p>\n\n<p> I enjoy public speaking, so I spent a long time iterating over my\ntalking points for our presentation. My roommate is probably sick of\nhearing it, but I feel good about the presentation. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(10,4,10,'<p> I liked my presentation, but Anika and Natasha both had some ideas for\nimprovement. One of Anika\'s ideas was really a good one, but most of them\nwere sort of picky. It\'s no big deal, though &mdash; while I don\'t think\nthe ideas really improve anything, they won\'t hurt either, so I\'ll make\nthem.  </p>\n\n<p> Anika and Natasha both presented well, and they took home a lot of\nfeedback, as well. Frankly, I\'m pretty sure my presentation was better than\neither of theirs. I know that we aren\'t competing against each other and we\nall have to do well, but it felt good to know that mine was good &mdash; no\nmatter what they said. </p>\n\n<p> Lionel on the other hand&hellip; I don\'t know what was going on there!\nIt looked like this was his first time building a PowerPoint, and he spent\nall his time playing with his new toy! There were animations and images and\nwords flying in and out. Every slide was completely different, too. The\nworst part was that he just read all the words off the slide! Everyone\n&mdash; especially Anika &mdash; had a lot of feedback for him. I think we\nshould have been a bit gentler with him; although he\'s really bright, he\ndoesn\'t seem to know it. I could see on his face that took it really hard.\n</p>\n\n<p> Needless to say, it wasn\'t much of a competition. Natasha\'s\nintroduction was much better than his and we had to go with her for it. I\nthink she might use some of his visual ideas, though &mdash; it looks like\nhe spent a bunch of time cropping our heads for the main slide and it was\npretty nice (if also a bit cheesy). </p>\n\n<p> After the meeting ended and Natasha and Anika left, I offered to work\nwith him and help him with his presentation, but he said no. I think he was\nembarrassed. I hope I didn\'t make him feel worse. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(11,4,11,'<p> In class, the instructor returned the drafts and we met briefly during\nclass to review it. There weren\'t many comments, and most of them were\npretty minor or issues that Natasha had already fixed. However, there was\none comment that concerned us all: a diagram might help here. I can\'t\nbelieve that this was the first time I realized that we were presenting our\ninstructor with a great big wall of text_ko:  \ntext_en! How could we have missed that?\nWe\'d definitely have things to talk about at this week\'s team meeting. </p>\n\n<p> Lionel arrived a bit late as we were talking about our complete lack of\nimages. However, while we were still at the complaining-about-it stage, he\nwas way ahead of us. He actually apologized as he pulled out a bunch of\nsketches he\'d \"thrown together.\" They were fantastic! His were done with\npencil on scraps of paper and Natasha copied them over with black pen on\nfull sheets so they were crisper and easier to see. We worked on them for\nabout half an hour, making small changes here and there. Natasha\nvolunteered create new versions to include in the document. </p>\n\n<p> We spent the rest of the meeting working through the presentation and\neveryone sounded better this week &mdash; especially Lionel. It was like he\nwas a completely different person. We all commented on the dramatic\nimprovement. I\'m not sure he quite believed it, but there was some relief\non his face. He was also more active in providing feedback to everyone\nelse. He pointed out that I\'d included something that wasn\'t actually in\nour paper. I told him where I\'d found it and he seemed glad, but not\nsatisfied. He asked if we wanted to talk in the presentation about\nsomething that we didn\'t mention in the paper. Natasha and Anika didn\'t\nthink it was a big deal, but he clearly felt like it\'s a bad idea. He\nwouldn\'t let it go, but he wasn\'t saying I needed to take it out &mdash; he\nwas asking where we should add it to the paper. I told him that I didn\'t\nthink it was a big deal and also that I didn\'t have time to do it. So, he\nsaid that he\'d add it into the paper himself. Problem solved! </p>\n\n<p> I practiced some more for the presentation, but mostly left this class\nalone because I\'m pretty sure we are in good shape. However, after giving\nit a lot of thought, I realized that Lionel had a good point. I removed\nthat piece that we spent so much time discussing in the meeting. It\ntightened things up a bit to do so and wasn\'t really needed. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(12,4,12,'<p> Lionel\'s images really added a lot to our paper, making it easier for\npeople to understand parts of it. Lionel also claimed one of the images for\none of his slides, and it worked much better than the bullet points he\'d\nhad on there. I can\'t believe we didn\'t have any images in at all until\nnow. </p>\n\n<p> This week, the presentation was much better and after another three\npractice runs, it sounded smooth. Anika managed to slow down quite a lot. I\nthink Lionel was a little bit frustrated to find that, after our argument\nlast week, I\'d removed the bit he added into the paper. I probably should\nhave told him when I made that decision. Natasha added the photos of us to\nher introduction slide, and they looked pretty good. Finally, and arguably\nmost importantly, we managed to cut it down to the correct time. </p>\n\n<p> I practiced a few more times during the week when I was able to find a\nmoment here and there. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(13,4,13,'<p> The presentation went OK, but not quite as smoothly as I\'d hoped. I was\nnervous and I think I didn\'t speak as loudly as I should have. I\'m pretty\nsure that most people heard me, but it should have been louder. Anika, on\nthe other hand, raced through her presentation and as a result, I don\'t\nthink anyone understood her. We wound up finishing up about thirty seconds\nearly.  </p>\n\n<p> Our classmates asked some good questions, which showed that our\npresentation was decent; they understood enough to ask questions. Anika,\nwho spoke last, naturally received all the questions, but she handed them\noff to whomever she felt was best suited to answer them &mdash; that was a\nnice touch. There weren\'t a lot of questions, and none of them came to me.\nWe should have discussed clothes beforehand because Lionel wore slacks and\na sports jacket, and Natasha wore a dress skirt and blouse. Anika and I\nwere dressed very casually, and it was a bit uncomfortable. </p>\n\n<p> Generally, though, I think we felt good about the work we\'d done. I\nexpect positive feedback and good grades. </p>\n\n<p> We only met briefly this week because we were mostly finished and we\nall had finals to study for, but I said I\'d go through the paper one more\ntime. We all agreed that we\'d only meet briefly next week to address any\nlarge issues I might find.  </p>\n\n<p> I spent about another hour and didn\'t find anything major &mdash; just\nlots of little stuff that I could fix without anyone else\'s input. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(14,4,14,'<p> At the final meeting, we reviewed the paper to make sure it was ready\nfor submission at the end of the week. As we went through it, Anika took\nissue with a few of the changes I\'d made. The language I used was a bit\nambiguous and it could be read to mean the opposite of what we intended.\nShe was right, but I don\'t feel badly, because I don\'t know how she noticed\nit. It took the rest of us a while to see it. Maybe it was because we all\nknow what we\'re trying to say, but once I saw it, I couldn\'t un-see it.\nWhen I finally did see it, I said I\'d fix it, but I wasn\'t really sure that\nI could. Fortunately, Anika saved me. She said she had no problem doing it\n&mdash; as long as everyone trusted her (there wasn\'t enough time for her\nto make the changes and get us all to say OK in time). Of course we all\ntrusted her and said so. </p>\n\n<p> The night before she sent it in to our instructor, Anika sent us a copy\nof the document to make sure we were all OK with it. I took a quick look\nand then wrote back to tell her to go ahead and submit it. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(15,1,1,'<p> In group time, we began by setting up weekly team meetings. My group\nmembers seem to be nice and one of them, Lionel, is a transfer student. The\nproject is pretty big and fairly open-ended, so we brainstormed topic ideas\nfor the most of the time. </p>\n\n<p> I tried to think creatively while we brainstormed. Most of what I\nsuggested wasn\'t realistic and I knew that, but I was taught that you\nshould throw out all ideas uncritically during a brainstorming session.\nThey did make the rest of the group laugh, though, and others often built\noff of them, so I think it was a success. At some point, Lionel noticed\nthat no one was taking notes, so we recounted what we could remember while\nhe wrote them down, and we discussed those. </p>\n\n<p> Before the meeting ended, we crossed off the ones that didn\'t seem to\nwork (this got rid of most of mine &mdash; haha!) and narrowed the list\ndown to six. Alex asked us to each look for resources on all the topics so\nthat next week, we will report back and select a topic together. </p>\n\n<p> This was not exactly a difficult task and it only took about an hour of\nmy time. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(16,1,2,'<p> Anika found a lot of materials for one of the topics that I had a rough\ntime with. Alex and Lionel also focused on the same two as I did. We ended\nup with a lot of duplication, but at least we all know those topics. When\nwe dug into what Anika found for the third topic, we couldn\'t see how we\nwould be able to use much of it &mdash; the research just had mentions of\nwhat we needed. Our discussion quickly centered on our most promising two\ntopics. </p>\n\n<p> There was a lot of discussion about which to choose &mdash; everyone\nseemed to have a strong opinion. I suggested that maybe we could combine\nthem into one. That didn\'t really work, but I think it helped us to see\nthem a bit differently before we settled into making decisions. Our first\nvote was split down the middle, so Alex made a list of pros and cons. That\nhelped us to put things in perspective. Our next vote was unanimous. As\nAlex pointed out, the other topic, although more exciting on the surface,\nwould have probably been much more complicated and difficult. </p>\n\n<p> The obvious next step was to find more materials on our selected topic,\nso we figured out the major subtopics and divided them amongst ourselves.\nWe decided everyone would return next week with summaries of what we\'ve\nfound to make it easier for the group to get moving quickly. To make sure\nwe didn\'t wind up with a million competing summaries for the many duplicate\nmaterials, Alex thought to split up the materials we\'d already got among\nus. </p>\n\n<p> I found some more materials this week, then I wrote my summaries. I\nprobably spent an hour on this. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(17,1,3,'<p> During our meeting, we began sorting through the materials. Lionel\'s\nand my materials were in good shape. I thought that one of Lionel\'s\nsummaries was a bit odd, but when I read it out loud to check if I was\ncrazy, I realized I was reading it wrong. I got everyone to laugh again\n&mdash; but this time it wasn\'t at all intentional. Lionel took it a bit\nfurther, however, and turned it into an interesting suggestion.  </p>\n\n<p> Alex\'s summaries, unfortunately, were confusing, and no one understood\nthem. He had to explain what he meant a lot of the time; that was\nfrustrating. He seemed a bit embarrassed and told us he\'d rewrite the\nsummaries to make them clearer.  </p>\n\n<p> Anika\'s summaries, on the other hand, were just a sentence or two each.\nInitially, she seemed to think that would be useful to us, and she couldn\'t\nseem to understand why they weren\'t. After some awkward moments, Alex asked\nher if she\'d prefer to use my summaries or her own to write the paper; I\nthink it clicked for her. We all had things to do to improve our work for\nnext week. </p>\n\n<p> It took me about twenty minutes to apply my group\'s suggestions. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(18,1,4,'<p> Anika wasn\'t at the meeting this week. She wasn\'t in class, either, and\nno one had heard anything from her. We weren\'t sure what was going on.\n</p>\n\n<p> When it was clear that she wouldn\'t be coming, we began working through\nAlex\'s updated materials; they were much improved. They could use some\nediting, but at least they make sense now, and he is obviously very smart.\nI think maybe his mind races ahead of his fingers. Lionel volunteered to\ntry to redo Anika\'s work and put what we have together for the assignment\ndue next week, but I said no. I don\'t think it\'s fair that he should be\noverloaded like that. I told him I\'d work on Anika\'s part and get it to\nLionel three days before class so he could include them. I also asked Alex\nto put together a basic outline of what the paper should look like so we\ncan get started on that. </p>\n\n<p> It took me about an hour to redo Anika\'s materials and their summaries\nand I got Lionel the materials a day early. The next day we heard from\nAnika; her mother had been ill and Anika went home to visit her in the\nhospital. In spite of this, she still managed to send us her redone\nsummaries. I expect Lionel had time to incorporate them. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(19,1,5,'<p> Lionel turned in our assignment this week in class. Our instructor gave\nus some time to meet as a group at the end of class. We reviewed the\noutline Alex put together since no one else had brought anything with them.\nAlex seemed to be satisfied with it, but Anika and I weren\'t. We didn\'t\nreally have much time to get into it, though. </p>\n\n<p> At our meeting, it took a while to really understand where we weren\'t\nconnecting. I thought that Anika and I both wanted the same thing, but it\nturned out we had completely ideas of where this was going! Alex, Anika and\nI talked for about half an hour, but Lionel mostly didn\'t say anything. I\ndon\'t know if he just didn\'t care, but he was pretty quiet. Ultimately, we\nsort of settled on my plan and modified the outline Alex had put together\nto look more like what I was describing. </p>\n\n<p> Anika then suggested we split the outline up into quarters and each\nwrite one for next week. Lionel spoke up quickly for the second section, so\nI grabbed the first part. Anika took the last, and that left the third part\nfor Alex. </p>\n\n<p> I banged my head against this assignment for over an hour before I gave\nup. This approach just wasn\'t working and I wasn\'t sure how we could fix\nit. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(20,1,6,'<p> No one was really able to make their pieces work quite right, so we had\nto rethink our approach. Anika once again brought out her initial\npreference from last time, but Alex was a step ahead of her and pointed out\nwhere we\'d run into the same problems that way. Lionel listened for a bit\nand then suggested that we try something he had used on a past project, and\nit was a really exciting idea. It would, of course, require some\nadaptation, but it could work out very well for us.  </p>\n\n<p> Anika and I ironed it out together. In spite of it being his idea,\nLionel seemed to be nervous about suggesting anything, but he did\ncontribute. About halfway into our meeting, we started looking back at the\npieces we\'d already written to see if/where they still fit. It looked like\nwe would be left with about half a paper still to write. </p>\n\n<p> This time, we each claimed pieces that were left to write. Anika took\none of the bits that I\'d already started looking at. I told her I wanted to\nwrite that one, but she wouldn\'t budge. She eventually traded with me for\nanother piece, but not the one I\'d really wanted. I just went with it\nbecause I didn\'t want to argue. </p>\n\n<p> I had a lot of writing to do this week, but I also had a lot to do in\nmy other classes, so I spread this out over two nights of about an hour and\na half each. Maybe not the most productive time in the world, but I got it\ndone. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(21,1,7,'<p> I was a bit late because it took me longer than I\'d expected to finish\nup a project due in the class immediately after our meeting. As it turned\nout, though, I wasn\'t the only one late &mdash; Alex didn\'t show up for\nabout half an hour! I guess mid-term study sessions are taking up a lot of\ntime. </p>\n\n<p> Everyone was happy with what we had this week. After running through\nwhat we had, the paper was starting to look pretty good. We spent much of\nour time assembling the pieces into a single paper. When we did, we\nrealized that neither the introduction nor the conclusion worked very well\nany longer. I figured that Lionel should write these, since he had to have\nthe best handle on it. But he responded that it wasn\'t his idea and that he\nwasn\'t comfortable with it. This seemed absurd; I reminded him that he was\nthe one who suggested this structure when we were all stuck. Eventually, he\nsaid he\'d do it but he wanted someone to review it afterward; Anika\nvolunteered.  </p>\n\n<p> Alex volunteered to rewrite the conclusion, but I was afraid his\nwriting wasn\'t very good, so I asked him instead to proofread and format\nthe document while I rewrote the conclusion. Anika didn\'t have anything for\nthe week and I think she didn\'t want to feel like a slacker, so she said\nshe\'d proofread the document, as well &mdash; just to have an extra set of\neyes on it. Before we ended the meeting, I told everyone I\'d be late next\nweek because one of my midterms would run until the start of this meeting.\n</p>\n\n<p> The conclusion was pretty straightforward, but I stupidly started off\ntrying to fix what we had; that just made a mess. When I decided to just go\nahead and rewrite the whole thing, everything fell into place nicely. I was\nable to knock it out in under an hour. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(22,1,8,'<p> I arrived just as the group finished going through the fixes to the\npaper. I figured I\'d go through it on my own later, but everyone looked\nsatisfied. </p>\n\n<p> We next looked at Lionel\'s introduction, and Anika immediately asked\nwhat everyone was thinking: why was it so short? Lionel just shrugged and\nwe all read it. As it turned out, Anika shouldn\'t have said anything before\nshe read it &mdash; it really covered everything it needed to and was\npretty good. Neither Alex nor I had any ideas for improving it.  </p>\n\n<p> I think Anika felt like she had to do something. After she thought\nabout it for a moment, she said that while nothing was missing, she had\nsome ideas for beefing it up a bit. A few minutes later, we had a new\nversion that was longer and felt a bit meatier. </p>\n\n<p> When we were done, Anika said she\'d add in the conclusion, make the\nchanges we talked about and have a version of the paper ready to turn in\nnext week in class. I, in turn, volunteered to try to make the larger\nchanges that Alex suggested. Lionel said he\'d start working on a PowerPoint\nfor the upcoming presentation. Alex asked if anyone minded if he didn\'t do\nanything this week because he has a late midterm next week in his toughest\nsubject. It made sense to me and no one seemed to mind, so we went with it.\n</p>\n\n<p> I did re-read the document this week, and Alex and Anika had done a\ngreat job with it. It took me about two hours to make the changes, though,\nbecause I had to do a bunch of research to support it. I was still left\nwith a bunch of questions that I really need the group to work out. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(23,1,9,'<p> Anika not only brought a copy of our paper to class for the instructor,\nbut also brought copies for each of us to look at between class and our\nmeeting. This way we didn\'t have to waste our meeting time on reading\nthrough it. As a result, I was able to merge my changes into the version\nAnika gave to the instructor, so everything was nicely consolidated. </p>\n\n<p> I brought the merged document, along with a list of remaining questions\nand possible answers, to our group meeting. We spent twenty minutes on that\nbefore we came to any answers. Alex was pretty quiet during most of the\ndiscussion, but after noticing something, he said he thought he had an\nidea. He tried to explain it and, in true Alex form, he didn\'t do a very\ngood job, but what I did understand seemed to make sense. I think he saw\nthat we weren\'t quite following his explanation, so he asked if he could\ntake it home and work on it for next week. I was hesitant, because he\ndoesn\'t usually explain his own ideas well, but I said OK. We still have\ntime in case it requires too much cleanup. In fact, everyone was OK with\nit. </p>\n\n<p> We next discussed the presentation &mdash; beginning with the\nPowerPoint Lionel had put together. Before Anika could comment (because she\nalways does), Lionel pointed out that this was just a start; he knew there\nwasn\'t much to it. He recommended that everyone claim a few slides and\nmodify them when they worked on what they were going to say. At this, Anika\njust shut her mouth. I have to admit, that was pretty satisfying. She\'s not\nmean or anything, but it was nice not to hear her being critical for once.\n</p>\n\n<p> I claimed a few slides, including the first one, but Lionel said he\nwanted to introduce us. I was surprised, because I didn\'t figure he\'d\nvolunteer for such a visible role. We ultimately decided that we should\nboth give it a shot and see which one we all like best when we practice\nnext week. I\'m actually excited about making it into a bit of a\ncompetition. </p>\n\n<p> While I\'m told I\'m good at it, I really hate public speaking. I wanted\nto go first because I want to get my part over with as soon as possible. I\nthink I over-prepare to avoid looking stupid. I spent about two hours\nagonizing over this two-minute presentation. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(24,1,10,'<p> Everyone\'s presentations were pretty good, except for Lionel\'s. I\'m not\nsure what was going on, but it didn\'t seem like he had prepared very much.\nHe did some fun things with his slides, but then he just read them\nverbatim. Also, I thought the slides were also quite tacky. I tried to keep\nout of it because I didn\'t want to be obnoxious, since his work was being\ncompared to mine. Anika was pretty harsh, though. I don\'t think she knows\nhow not to be, but she really should have been gentler; he\'s really bright,\nbut he doesn\'t seem to know it. I think he takes criticism pretty hard.\n</p>\n\n<p> It wasn\'t really much of a competition. I\'ll be doing the introduction\n&mdash; even Lionel voted for me to do it. I am going to try to use some of\nhis ideas to spruce up the slides though &mdash; just not quite so much. I\nespecially like what he did with images of our heads bouncing onto the\nslide. It was a bit silly, but fun. </p>\n\n<p> I spent another hour this week on my slides and practicing. I also\nenlisted my best friend to listen and give me feedback. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(25,1,11,'<p> In class, the instructor returned the drafts. We met briefly to review\nours. There weren\'t many comments, and most of them were pretty minor or\nissues that I had already fixed. There was one comment, however, that\nconcerned us all: a diagram might help here. We were presenting our\ninstructor with a great big wall of text! How did we miss that? We\'d\ndefinitely have things to talk about at this week\'s meeting. </p>\n\n<p> Lionel arrived late as we were talking about our complete lack of\nimages. While we were still at the complaining-about-it stage, though, he\nwas way ahead of us. He actually apologized as he pulled out a bunch of\nsketches he\'d \"thrown together.\" They were a great start. They were tough\nto see, so I quickly copied them over with black pen on full sheets so they\nwere crisper. We worked on them for half an hour, making small changes here\nand there. I volunteered create new versions to include in the document.\n</p>\n\n<p> We spent the rest of the meeting working through the presentation.\nEveryone sounded better this week &mdash; especially Lionel. It was like he\nwas a completely different person. We all commented on the dramatic\nimprovement. I\'m not sure he quite believed it, but there was some relief\non his face and I felt better. He was also more active in providing\nfeedback to everyone else. He pointed out that Alex had included something\nthat wasn\'t actually in our paper. Alex told him where he\'d found it and\nLionel seemed glad, but not satisfied. He asked if we wanted to talk in the\npresentation about something that we didn\'t mention in the paper. I don\'t\nthink it was a big deal because it was true, but he clearly felt like it\nwas a bad idea and he wouldn\'t let it go. He wasn\'t telling Alex to take it\nout &mdash; he was asking where we should add it to the paper. He offered\nto make the change, so we said OK. </p>\n\n<p> I practiced some more for the presentation, but mostly I already felt\ngood about that. I instead spent my time on creating new versions of the\nimages for the paper. Lionel must have spent a lot of time thinking about\nthese. I was able to make them clearer and crisper, but there wasn\'t much\nelse I could do to improve upon them, and they really add a lot to the\npaper. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(26,1,12,'<p> Everyone loved what the images did for our paper &mdash; they would\nmake it a lot easier for people to understand certain parts of it. Lionel\nalso claimed one of the images for one of his slides, and it worked much\nbetter than the bullet points he\'d had on there. I still can\'t believe we\ndidn\'t have any images in at all until now. </p>\n\n<p> The presentation was much better this week. After another three\npractice runs, it sounded smooth. I felt bad for Lionel, though, because\nafter last week\'s discussion, Alex had second thoughts and removed the\ncontroversial bit from his presentation, but didn\'t think to let Lionel\nknow, so Lionel still added it to the paper. I decided to keep Lionel\'s\nphotos of us on our introduction slide, and everyone liked that. Finally,\nand arguably most importantly, we managed to cut it down to the correct\ntime. </p>\n\n<p> I practiced a few more times during the week when I was able to find a\nmoment here and there. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(27,1,13,'<p> The presentation went OK, but not quite as smoothly as I\'d hoped. Alex\nseemed nervous and got quieter than I\'d have liked, but I\'m pretty sure\nthat most people heard him. Anika, on the other hand, raced through her\npresentation; I don\'t think anyone understood her. We wound up finishing up\nabout 30 seconds early. </p>\n\n<p> Our classmates asked some good questions, which showed that our\npresentation was decent; they understood enough to ask questions. Anika,\nwho spoke last, naturally received all the questions, but she handed them\noff to whomever she felt was best suited to answer them &mdash; that was a\nnice touch. There weren\'t a lot of questions, and none of them came to me.\n</p>\n\n<p> We should have discussed clothes beforehand; Lionel wore slacks and a\nsports jacket, and I wore a dress skirt and blouse. Anika and Alex were\ndressed very casually, and it was a bit uncomfortable. </p>\n\n<p> Generally, though, I think we felt good about the work we\'d done. I\nexpect positive feedback and good grades. </p>\n\n<p> We only met briefly this week because we were mostly finished and we\nall had finals to study for, but Alex said he had time to go through the\npaper once more. Quite frankly, he\'s the best person to do it, so no one\ndisagreed. We also agreed that we\'d only meet briefly next week to make\nsure Alex didn\'t find any huge problems. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(28,1,14,'<p> At the final meeting, we reviewed the paper to make sure it was ready\nfor submission at the end of the week. As we went through it, Anika took\nissue with a few of the changes Alex made. It didn\'t seem like anything\nuntil she pointed it out, but some of the language he used was a bit\nambiguous. It could be read to mean the opposite of what we intended.  </p>\n\n<p> It took us all a while to see it, because we all know what we\'re trying\nto say, but once I saw it, I couldn\'t un-see it. Alex seemed to have the\nhardest time of it. He hesitantly volunteered to fix it before submission,\nbut we could all see that was a bad idea. Anika said she had no problem\ndoing it as long as everyone trusted her, because there wasn\'t enough time\nfor her to make the changes and get us all to say OK in time. Of course, we\nall trusted her and said so. </p>\n\n<p> The night before she sent it in to our instructor, Anika sent us a copy\nof the document just to make sure we were all OK with it. I didn\'t have a\nchance to read it carefully, but I wrote back and said OK. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(29,2,1,'<p> In group time, we began by setting up weekly team meetings. My group\nmembers seem to be nice. One of my teammates, Alex, I recognized from one\nof our big lecture courses last semester. One of the others, Lionel, is a\ntransfer. The project is pretty big and fairly open-ended, so we\nbrainstormed topic ideas for the most of the time. </p>\n\n<p> I didn\'t have a whole lot to say, so I mostly listened, but everyone\nelse seemed to have a lot of ideas. Natasha\'s ideas made me laugh. She\nseems to be working hard to think outside the box, and she mostly did it.\nThis meant that many of her ideas weren\'t really useable, but they were fun\nand they seemed to give other people ideas, too. At some point, Lionel\nnoticed that no one was taking notes, so we recounted what we could\nremember while he wrote them down, and we discussed those. </p>\n\n<p> Before the meeting ended, we crossed off the ideas that didn\'t seem to\nwork (this got rid of most of Natasha\'s) and narrowed the list down to six.\nAlex asked us to look for resources on all the topics so that next week, we\nwill report back and select a topic together. </p>\n\n<p> When I started looking for reference materials, I got off on a tangent.\nI wound up spending two hours on the task and found a bunch of materials,\nbut most of them were for just one topic. I don\'t think they\'ll really work\nfor what we need. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(30,2,2,'<p> Alex, Lionel and Natasha all focused on the same two topics, and\neveryone agreed that the topic I\'d done the most work on wasn\'t really\nviable. We ended up with a lot of duplication &mdash; especially between\nAlex and Natasha &mdash; but they all seemed to have a pretty good handle\non both topics. Our discussion quickly centered on our most promising two\ntopics. </p>\n\n<p> There was a lot of discussion about which to choose &mdash; everyone\nhad an opinion. Then Natasha suggested that we try to combine them. That\ndidn\'t really work, but I think it helped us to see them a bit differently\nbefore we settled into making decisions. Our first vote split evenly down\nthe middle, so Alex made a list of pros and cons. It helped to put things\nin perspective. Our next vote was unanimous. As Alex pointed out, the other\ntopic, although more exciting on the surface, would have probably been much\nmore complicated and difficult. </p>\n\n<p> The obvious next step was to find more materials on our selected topic,\nso we figured out the major subtopics and divided them amongst ourselves.\nWe decided everyone would return next week with summaries of what they\'d\nfound to make it easier for the group to get moving quickly. To make sure\nwe didn\'t wind up with a million competing summaries for the many duplicate\nmaterials, Alex thought to split up the materials we\'d already got among\nus. </p>\n\n<p> I found some more materials that week, then I wrote my summaries. I\nprobably spent an hour on this class work. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(31,2,3,'<p> During our meeting, we began sorting through the materials. Lionel\'s\nand Natasha\'s materials were in good shape. Natasha made me laugh when she\nmisread one of my summaries and shone a completely different light on it.\nIt turned into an interesting suggestion, too.  </p>\n\n<p> Natasha\'s contributions were solid, and we didn\'t spend too much time\non them, but Alex\'s summaries were confusing and no one understood them. He\nhad to explain what he meant a lot of the time. That frustrated Lionel and\nNatasha.  </p>\n\n<p> We then looked at my summaries, and they didn\'t think I\'d written\nenough. I thought that I\'d written everything that was necessary and I\nthought they were upset that I didn\'t pretty it up, but then Alex asked me\nflat out if I\'d prefer to use Natasha\'s summaries or my own to write the\npaper; that\'s when I got it.  </p>\n\n<p> I had only been thinking about doing this for the assignment due in two\nweeks because I don\'t do summaries like this myself, but I guess that\'s\nsort of a waste of time, isn\'t it? If we\'re to get a good grade here, we\'ll\nall need to help each other out, won\'t we? I did feel a bit stupid, but he\nwas right. Fortunately, we all have things to do to improve our work for\nnext week. </p>\n\n<p> I spent an hour cleaning up and filling out my summaries to be as\ncomplete as Natasha\'s. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(32,2,4,'<p> My mom has been ill for some time, and I found out that she was in\nhospital, so I drove back home to see her. The doctors took two days to\nfigure out what it was and it wound up a false alarm. I headed back to\nschool when they said they were comfortable with discharging her and,\nhonestly, that was the first time I even thought about this project. </p>\n\n<p> When I got back to town, I emailed the group to apologize and I sent\nout my summaries. I don\'t know why I didn\'t think to do that before I left,\nbut I just didn\'t. I hope they aren\'t too upset, but I haven\'t heard\nanything back from any of them. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(33,2,5,'<p> Lionel turned in our assignment this week in class, and our instructor\ngave us some time to meet as a group. We spent the time looking at the\noutline Alex put together, since no one else had brought anything with\nthem. Alex seemed to be satisfied with it, but Natasha and I weren\'t. We\ndidn\'t really have much time to get into it, though. </p>\n\n<p> At our meeting, it took a while to really understand where we weren\'t\nconnecting. I thought that Natasha and I both wanted the same thing, but it\nturns out we had completely ideas of where this was going! Alex, Natasha\nand I talked for half an hour, but I think Lionel was afraid to say\nanything. We ultimately sort of settled on Natasha\'s plan and modified the\noutline Alex had put together to look more like what she was describing. I\nstill think my idea was better, but hers wasn\'t bad. I could see that I\nwasn\'t convincing anyone, so I went along with it. </p>\n\n<p> With the outline settled, I suggested we split the outline up into\nquarters and each write one for next week. Lionel spoke up quickly for the\nsecond section. Natasha grabbed the first part, and I took the last. That\nleft the third part for Alex. </p>\n\n<p> It took me an hour and a half to see that this approach just wouldn\'t\nwork. We would have to go back and do it the way I thought at first, so I\nstopped about mid-way through and started working on a version that went\nthe way I thought it should. I had a lot of other work for this week,\nthough, so I didn\'t get very much of that done. I figure I\'ll still be\nahead of everyone else, anyway. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(34,2,6,'<p> I was right &mdash; no one was really able to make the pieces work\nquite right, so we had to rethink our approach. When I asked that we look\nat my idea from last week again, though, Alex had also been thinking about\nit and found that we\'d run into the same problems that way. Lionel\nsuggested that we try something he had used on a past project; it was a\nreally good idea. It would, of course, require some adaptation, but it\ncould work out very well for us.  </p>\n\n<p> It was quite exciting, and we all worked on ironing it out together.\nLionel seemed to be nervous about suggesting anything, but he contributed.\nAbout halfway into our meeting, we started looking back at the pieces we\'d\nalready written to see if/where they still fit. It looked like we would be\nleft with about half a paper still to write. </p>\n\n<p> This time, we each claimed pieces that were left to write. For some\nreason, Natasha wanted one of the tricky bits that I spoke for. She didn\'t\nhave any real reason for wanting it, except that I think she wanted to\noffload a boring piece. I traded her one of my other fun parts, though, for\nthe boring bit. Everyone was happy (I think)! </p>\n\n<p> I wound up spending an hour on the tricky piece alone. I was proud of\nit when I was done, but I still had other parts to do. I wound up spending\nan hour and a half more over the course of the week before I was ready for\nour meeting. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(35,2,7,'<p> Everyone else was late for our meeting this week. I guess that they all\nhad mid-term study sessions today, and they all forgot to mention it last\nweek. Kind of annoying, but there was nothing to be done about it. Alex\ndidn\'t arrive for half an hour! </p>\n\n<p> I didn\'t stay upset for long, though. Everyone had done their part for\nthe week and, after running through what we had, the paper was starting to\nlook pretty good. We spent much of our time assembling the pieces into a\nsingle paper. When we did, we realized that neither the introduction nor\nthe conclusion worked very well any longer. Natasha asked Lionel to write\nthe introduction, because the new structure of the paper was his idea, but\nhe claimed that it really wasn\'t his idea and didn\'t feel up to it. Alex\npushed this, though, and I volunteered to review it if he was concerned;\nthat seemed to satisfy Lionel. He said he\'d do it, but he made me promise\nthat I\'d review it the following week &mdash; I thought this was odd,\nbecause I\'d already volunteered to do it, but of course I promised I would.\n</p>\n\n<p> Alex volunteered to rework the conclusion, but Natasha asked him\ninstead to proofread and format the document while she rewrote the\nconclusion. He\'s not a very good writer. This left me without anything to\ndo for class for the week and I felt bad, so I said I\'d proofread the\ndocument, as well, to have an extra set of eyes on it. Before we ended the\nmeeting, Natasha told us she\'d be late next week because one of her\nmidterms would run until the start of this meeting. </p>\n\n<p> Proofreading took me awhile. It\'s a good paper, but it\'s been written\nby four different people. After an hour, I felt I\'d improved it\nsignificantly. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(36,2,8,'<p> While Alex may not be good at making sure he puts all the right detail\nin himself, he is good at making sure everyone else does. He found all\nsorts of issues all over the paper &mdash; much more than I found. There\nwere a few items I\'d got that he didn\'t, but he did a much more thorough\njob than I\'d done. Most of the issues were pretty small, but a few would\nhave to wait for after we turn in the draft next week. We will be able to\nrewrite it, but everyone has tight schedules this week.  </p>\n\n<p> We next looked at Lionel\'s introduction; it was incredibly short. I\nasked him why and he just shrugged, so there was nothing to do but to read\nit. I probably shouldn\'t have said anything before I read it because he\nmanaged to cover all the bases in about half the word count than what I\ncould write.  </p>\n\n<p> Neither Natasha nor Alex had any ideas for improving it, but I was\nstill uncomfortable with it being so short. I told them that, although he\nwas right and everything necessary was in there, I was still uncomfortable\nwith it being so short. The others nodded a bit &mdash; they didn\'t argue.\nI made a couple of suggestions and so did Natasha. It didn\'t really add\nanything, but it made me feel better. Alex cut some of it back down again,\nbut I think we all felt good about it. </p>\n\n<p> When we were done, I said I\'d add in the conclusion, make the changes\nwe talked about and have a version of the paper ready to turn in next week\nin class. Natasha said that she\'d try to make the larger changes that Alex\nhad suggested. Lionel volunteered to start building a PowerPoint for the\nupcoming presentation. Alex asked if anyone minded if he didn\'t do anything\nthis week because he has a late midterm next week in his toughest subject.\n</p>\n\n<p> It only took me half an hour to get through everything this week, but\nthen I took another half hour reviewing it since we\'d be submitting it.\nWhen I was done, I made sure I had copies for everyone to review, in\naddition to the one for the instructor. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(37,2,9,'<p> We were happy to have copies to look at, but our instructor didn\'t give\nus any group time in class, so it wasn\'t as helpful as I\'d hoped it would\nbe. It did mean we didn\'t need to waste our meeting time on reading through\nit, though.  </p>\n\n<p> Natasha merged her changes into this latest version, which she brought\nto our meeting. She\'d had a difficult time making those changes, however,\nand they were not complete. She brought a list of questions and possible\nanswers, and we spent twenty minutes on that before we came to any answers.\n</p>\n\n<p> Alex was pretty quiet during most of the discussion, but suddenly he\nsaid he had an idea after seeing something that Natasha had done. He tried\nto explain it, but I think he saw that we weren\'t quite understanding, and\nhe asked if he could take it home to work on it for next week. I was\nhesitant because he doesn\'t usually explain his own ideas well, but I said\nOK. We still have time in case it requires too much cleanup. In fact,\neveryone was OK with it. </p>\n\n<p> We next discussed the presentation &mdash; beginning with the\nPowerPoint Lionel had put together. Lionel emphasized that this was just a\nstart and that he knew there wasn\'t much in it. He recommended that\neveryone claim a few slides and modify them when they worked on what they\nwere going to say. Natasha spoke for a few slides, including the first one,\nbut this time Lionel said he wanted to introduce us. I was surprised,\nbecause I didn\'t figure he\'d volunteer for such a visible role. We\nultimately decided that they\'d both give it a shot and see which one we\'d\nall like best when we practice next week. </p>\n\n<p> I didn\'t spend too much time on this this week. I didn\'t take that much\non because I had a lot of work for my other classes. I don\'t think anyone\nnoticed, but my parts were pretty simple. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(38,2,10,'<p> Everyone\'s presentations were pretty good, except for Lionel\'s. I don\'t\nknow what was going on there! It looked like this was his first time\nbuilding a PowerPoint, and he spent all his time playing with his new toy!\nThere were animations, images and words flying in and out. Every slide was\ncompletely different, too. The worst part was that he just read all the\nwords off the slides! We all had a lot of feedback for him &mdash; to be\nfair, there was a lot of feedback for everyone, but with him it wasn\'t\nnit-picky; it was pretty major.  </p>\n\n<p> I think maybe we were a bit too harsh, because he was really down\nafterwards. We should have been gentler with him; although he\'s really\nbright, he doesn\'t seem to know it. I could see on his face that he took it\nreally hard, but I just couldn\'t keep my mouth shut. I wasn\'t the only one,\nbut I was probably the harshest. I really did try to be constructive, but\nit probably didn\'t come out that way.  </p>\n\n<p> Needless to say, it wasn\'t much of a competition. Natasha\'s\nintroduction was much better than his, so she\'s going to present it. I\nthink she might use some of his visual ideas, though &mdash; it looks like\nhe spent a bunch of time cropping our heads for the main slide, and it was\nactually pretty nice (if also a bit cheesy). </p>\n\n<p> I spent some time practicing and applying the feedback this week, but\nthat didn\'t take too long. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(39,2,11,'<p> In class, the instructor returned the drafts, and we met briefly during\nclass to review it. There weren\'t many comments. Most of them were pretty\nminor or issues that Natasha had already fixed. There was one comment that\nconcerned us all, though: a diagram might help here. We were presenting our\ninstructor with a great big wall of text_ko:  \ntext_en! How did we miss that? We\'d\ndefinitely have things to talk about at this week\'s team meeting. </p>\n\n<p> Lionel arrived a bit late as we were talking about our complete lack of\nimages. While we were still at the complaining-about-it stage, though, he\nwas way ahead of us. He actually apologized as he pulled out a bunch of\nsketches he\'d \"thrown together.\" They were a great start. Natasha quickly\ncopied them over with black pen on full sheets so they were crisper and\neasier to see. We worked on them for half an hour, making small changes\nhere and there. Natasha volunteered create new versions to include in the\npaper. </p>\n\n<p> We spent the rest of the meeting working through the presentation.\nEveryone sounded better this week &mdash; especially Lionel. It was like he\nwas a completely different person. We all commented on the dramatic\nimprovement. I\'m not sure he quite believed it, but there was some relief\non his face, and I felt better. He was also more active in providing\nfeedback to everyone else. He pointed out that Alex had included something\nthat wasn\'t actually in our paper. Alex told him where he\'d found it and\nLionel seemed glad, but not satisfied. He asked if we wanted to talk in the\npresentation about something that we didn\'t mention in the paper. I didn\'t\nthink it was a big deal because it was true, but he clearly felt like it\nwas a bad idea and he wouldn\'t let it go.  </p>\n\n<p> He wasn\'t telling Alex to take it out &mdash; he was asking where we\nshould add it to the paper. I still didn\'t want to waste time on it because\nI thought it was fine, but he offered to make the change, so we said OK.\n</p>\n\n<p> I practiced some more for the presentation, but mostly left this class\nalone because I\'m pretty sure we are in good shape. The biggest comment\nthey\'d all had for me was that I was speaking too fast, so I worked on\nslowing it down. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(40,2,12,'<p> Lionel\'s images really added a lot to our paper. They would really make\nit easier for people to understand parts of it. Lionel also claimed one of\nthe images for one of his slides. It worked much better than the bullet\npoints he\'d had on there. I still can\'t believe we didn\'t have any images\nin at all until now. </p>\n\n<p> The presentation was much better this week. After another three\npractice runs, it sounded smooth. I felt bad for Lionel, though, because\nafter last week\'s discussion, Alex had second thoughts and removed the\ncontroversial bit of his presentation, but he didn\'t think to let Lionel\nknow, so Lionel had still added it to the paper. I could see how frustrated\nLionel was, but he didn\'t say anything at all about it. It was actually\ndifficult to keep from laughing about it, but I am pretty sure no one would\nhave liked that very much.  </p>\n\n<p> Natasha added the photos of us to her introduction slide, and they\nlooked pretty good. Finally, and arguably most importantly, we managed to\ncut it down to the correct time. </p>\n\n<p> I practiced a few more times during the week when I was able to find a\nmoment here and there. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(41,2,13,'<p> The presentation went OK, but not quite as smoothly as I\'d hoped. Alex\nseemed nervous and got quieter than I\'d have liked, but I\'m pretty sure\nthat most people heard him. They told me that, despite my efforts to avoid\ndoing so, I raced through my presentation. We wound up finishing up about\n30 seconds early.  </p>\n\n<p> Our classmates asked some good questions, which showed that our\npresentation was decent (because they understood at least enough to ask\nquestions). Since I spoke last, it seemed natural that I would direct\nquestions to the rest of the team (the ones who seemed to know those topics\nbest), and that worked quite well. There weren\'t a lot of questions, but\nenough.  </p>\n\n<p> We probably should have discussed clothes beforehand. Lionel wore\nslacks and a sports jacket, and Natasha wore a dress skirt and blouse. Alex\nand I were dressed very casually, and it was a bit uncomfortable. </p>\n\n<p> Generally, though, I think we felt good about the work we\'d done. I\nexpect positive feedback and good grades. </p>\n\n<p> We only met briefly this week because we were mostly finished, and we\nall had finals to study for, but Alex said that he had time to go through\nthe paper once more. Quite frankly, he\'s the best person to do it, so no\none disagreed. We also agreed that we\'d only meet briefly next week to make\nsure Alex didn\'t find any huge problems. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(42,2,14,'<p> At the final meeting, we reviewed the paper to make sure it was ready\nfor submission at the end of the week. As we went through it, I took issue\nwith a few of the changes Alex made. The language he used was a bit\nambiguous, and it could be read to mean the opposite of what we intended. I\nhad to explain it a few times and it took them a while to see it, but\neventually they did. They agreed that it needed to be fixed.  </p>\n\n<p> Alex offered to fix it, but I said I\'d do it because everyone else had\na hard time seeing it to begin with. It really only made sense for me to do\nit, but I was nervous about making a change and turning it in without\neveryone getting a chance to see it (we figured there wasn\'t enough time\nfor me to make the changes and get an OK  from everyone in time). They all\nsaid I should just go ahead and do it, though, so I took it. </p>\n\n<p> I worked on it that night and I could have sent it out, but figured it\nwould be best to proofread the whole thing the next day. I sent it out to\nthe team the next night and I got responses the following morning. I\nactually managed to send the paper in a bit early as a result! </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(43,3,1,'<p> In group time, we began by setting up weekly team meetings. This\nproject is pretty huge and I don\'t think any of us have had to do one like\nthis before.  I know how to work hard, though &mdash; I had a rough time at\nmy previous college, before I could bring my grades up enough to transfer\nin here. The rest of my group are freshmen, and it looks like they all knew\neach other already. I felt a bit left out, but that\'s life, I guess. </p>\n\n<p> The project is fairly open-ended, so we brainstormed topic ideas for\nmost of the first meeting. Natasha\'s ideas were easily the most fun &mdash;\nwhile Alex and I were suggesting fairly standard things, she managed to\nkeep coming up with interesting perspectives. Not all of them were\nappropriate, but they sure kept the discussion lively, and it didn\'t take\nmuch to make them useable.  </p>\n\n<p> Anika was quiet. I could tell that she was paying attention, but I\nguess she\'s a bit shy. When we started to slow down a bit, I realized that\nno one was taking any notes, so we tried to run back through the ideas\nwhile I wrote them down. We talked about the ones we remembered. </p>\n\n<p> Before the meeting ended, we narrowed it down to six ideas. We decided\nto all look for resources on all the topics. We will discuss them and\ndecide on one next week. </p>\n\n<p> During the week, I tried to look for stuff on all six topics, but while\nthey all sounded good during the meeting, only two of them really seem to\nwork for our project. Interestingly, one of the two was one that I\'m pretty\nsure started with a joke by Natasha. After an hour, I felt well-prepared\nfor those two topics, but I kept looking for stuff on the other topics for\nanother hour to make sure I had something for all the rest. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(44,3,2,'<p> Anika found a lot of materials for one of the topics that I had a rough\ntime with, but Alex and Natasha also focused on the same two as I did. We\nended up with a lot of duplication, but at least we all know those topics.\nWhen we dug into what Anika found for the third topic, I couldn\'t see how\nwe would be able to use much of it &mdash; the research just had mentions\nof what we needed. Our discussion quickly became about our most promising\ntwo topics. </p>\n\n<p> We had a lot of discussion about which to choose &mdash; everyone had\nan opinion. Then Natasha suggested that we try to combine them. We wasted\nten minutes trying to see if we could make that work, but ultimately we\ncouldn\'t. We wound up back where we started. Our first vote split evenly\ndown the middle, but Alex started writing pros and cons; seeing that made\nboth Anika and I change our votes. The other topic, although more exciting,\nwould have probably been more difficult. </p>\n\n<p> The obvious next step was to find more materials, so we divided up the\nmajor subtopics amongst ourselves. We decided everyone would return next\nweek with summaries of what they\'d found to make it easier for the group to\nget moving quickly. Alex also split up the duplicates among us. </p>\n\n<p> I found some more materials, and then I spent an hour writing and\nproofreading those summaries. Everyone in my group really seems to belong\nhere. It\'s going to be tough to keep up, but if I lose my scholarship, I\'m\nfinished. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(45,3,3,'<p> During our meeting, we began sorting through the materials. I showed\nmine first to get it over with, and no one had any complaints. Natasha made\nme laugh when she misread one of my summaries and shone a completely\ndifferent light on it. It turned into an interesting suggestion, too.  </p>\n\n<p> Natasha\'s contributions were solid and we didn\'t spend too much time on\nthem. Alex\'s materials were difficult to understand and we needed his help\nto interpret what he meant. He seemed a bit embarrassed and told us he\'d\nrewrite the summaries to make them clearer.  </p>\n\n<p> Anika\'s summaries were just a sentence or two each. I don\'t know how\nshe thought that would be useful to us. After some awkward moments, Alex\nasked her if she\'d prefer to use Natasha\'s summaries or her own to write\nthe paper, and I think it clicked for her. We all had things to do to\nimprove our work for next week. </p>\n\n<p> I carried Natasha\'s suggestion through my summaries and I think I did a\npretty good job, but it really didn\'t take much time. I felt like I should\nbe doing more, but couldn\'t think of anything to do, so I mostly focused on\nmy other classes this week. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(46,3,4,'<p> Anika wasn\'t at the meeting when I got there. She hadn\'t been in class,\nand no one had heard anything from her. We weren\'t sure what was going on.\n</p>\n\n<p> When it looked like she wouldn\'t be coming, we began working through\nAlex\'s updated materials; they were much improved. They could use some\nediting, but at least they made sense now, and he is obviously very smart.\nI think maybe his mind races ahead of his fingers. I volunteered to try to\nredo Anika\'s work and put what we had together for the assignment due next\nweek, but Natasha said no. She said she\'d work on Anika\'s part and get it\nto me to three days before class so I could include them. She also asked\nAlex to put together a basic outline of what the paper should look like so\nwe could get started on that. Alex agreed, and I thought it was a great\nidea for him to keep us moving forward. </p>\n\n<p> Natasha got me the materials a day early, and I had plenty of time to\nput everything together. It took half an hour to put it all together and\nanother half to clean it all up.  </p>\n\n<p> The next evening, Anika got in touch with all of us, explaining that\nher mother had taken ill and that she\'d had to return home to be with her\nin the hospital. She\'d also included the materials she\'d been working on.\nThey were much improved &mdash; better in most cases than what Natasha had\nbeen able to put together. I was glad to have them, but it meant another\nforty five minutes to merge them with what Natasha provided. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(47,3,5,'<p> I turned in our assignment this week in class, and our instructor gave\nus some time to meet as a group. We spent the time looking at Alex\'s\noutline since that was the only new thing we had. I thought it was decent,\nbut Anika and Natasha seemed to feel differently. We didn\'t have enough\ntime to really get into it during class, but it was clear that the three of\nthem had different visions of what the paper should look like. </p>\n\n<p> Alex had made a few changes and once it was clear what those visions\nwere, I had to admit that they all had good ideas. I didn\'t have much to\nsay at first because I don\'t usually outline my papers &mdash; I just start\nwriting, but working in a group we have to agree on who is writing what.\nAfter 30 minutes of arguing (that I mostly stayed out of), we modified\nAlex\'s outline to incorporate much of what Natasha wanted. Over the course\nof the discussion, Natasha won Anika over to her perspective. </p>\n\n<p> With the outline settled, Anika suggested we split the outline up into\nquarters and each write one for next week. I spoke up quickly for the\nsecond section because I wasn\'t sure I could write the introduction or the\nconclusion. Fortunately, Natasha took the former and Anika took the latter.\n</p>\n\n<p> It took me two hours to write my part of the paper, but then I spent\nanother half hour proofreading it. I don\'t think it\'s great, but hopefully\nwhen the others review it, they\'ll be able to do what I can\'t. While I was\nwriting, I was reminded of a paper that I\'d written during my own freshman\nyear. I did a good job with it and this one has a lot of similarities\n&mdash; completely different topic, but it made me feel a bit more\ncomfortable. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(48,3,6,'<p> This week\'s meeting was uncomfortable. I thought the rest of the group\nwould be able to help me smooth out the rough parts of my piece, but it\nturned out everyone had similar rough spots. No one was really able to make\nhis or her piece work quite right. We had to rethink our whole approach.\n</p>\n\n<p> Anika once again brought out her initial preference from last time, but\nAlex was a step ahead of her and pointed out where we\'d run into the same\nproblems that way. After listening for a bit, I told the team about that\npaper I\'d written two years ago, because it seemed relevant. Alex jumped on\nit immediately. He said he thought it was a really good idea and could work\nwell &mdash; especially in light of the past two weeks\' in-class lectures.\n</p>\n\n<p> Natasha and Anika joined in and modified the outline. There were a\ncouple of places where I was able to offer some suggestions and help, too.\nAbout halfway into our meeting, we started looking back at the pieces we\'d\nalready written to see if/where they still fit. It looked like we would be\nleft with about half a paper still to write. </p>\n\n<p> This time, we each took pieces that were left to write. I didn\'t care\nwhich parts I took, but Anika and Natasha sure did. It seemed like they\nargued about almost all of them, but ultimately we all wound up with pieces\nwe could handle. </p>\n\n<p> One of my parts was pretty straightforward and I wrote it in half an\nhour, but the other one gave me a lot of trouble. For some reason, I just\ncouldn\'t make it work properly, so I set it aside. The next night I still\ncouldn\'t seem to get a handle on it, so I contacted Alex to see if we could\nwork it out together.  </p>\n\n<p> We met up for about an hour and he answered all my questions. We then\nlooked at his work. I often couldn\'t understand what he was saying and\nneeded to ask him to explain things more thoroughly. I felt pretty stupid,\nbut he said that I helped him and sounded sincere. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(49,3,7,'<p> I was late this week by about ten minutes because I had a study session\nfor one of my midterms coming next week. However, I was only the second\nperson to arrive. Natasha walked in five minutes later, out of breath from\nrunning to the meeting, and Alex didn\'t arrive for almost half an hour.\nBoth of them were coming from midterm preps. </p>\n\n<p> In spite of this, everyone was happier with what we had this week and,\nafter running through what we had, the paper is starting to look pretty\ngood. We spent much of our time assembling the pieces into a single paper.\nWhen we did, we realized that neither the introduction nor the conclusion\nworked very well any longer. Natasha asked that I write the introduction,\nsaying that the new structure of the paper was my idea, but it wasn\'t. They\nwere the ones who put most of it together &mdash; all I did was mention a\npast project I\'d done. I said I\'d do it only if one of them would review it\nthe following week. Anika said she\'d be happy to.  </p>\n\n<p> Alex volunteered to rework the conclusion, but Natasha quickly asked\nhim instead to proofread and format the document while she rewrote the\nconclusion. He was happy with this. I\'m glad, because his writing is pretty\nbad. Hopefully he does a better job with editing. Anika said she\'d\nproofread the document as well &mdash; just to have an extra set of eyes on\nit.  </p>\n\n<p> Natasha also told us she\'d be late next week because one of her\nmidterms would run until the start of this meeting. </p>\n\n<p> Writing the introduction wasn\'t really very difficult at all, and only\ntook me half an hour &mdash; I just hope it\'s what they\'re looking for. I\nre-read it later in the week to make sure I couldn\'t improve on it, but it\nstill seemed OK, so I\'ll just wait to hear what my teammates say. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(50,3,8,'<p> While Alex may not be good at making sure he puts all the right details\nin himself, he is good at making sure everyone else puts them in. He found\nall sorts of issues all over the paper. Most of them were pretty small, but\na few would have to wait for after we turn in the draft next week. They\nweren\'t horrible or anything, so that\'s fine. He also made the whole paper\nlook exactly the way the instructor asked us to (at least as near as I\ncould tell). It looks very professional. Anika also did a good job and\nnoted a few things that Alex missed, but she also missed many of the items\nthat Alex found. Why couldn\'t Alex do this with his own work? </p>\n\n<p> Natasha showed up just as we were finishing up with Alex and Anika\'s\nwork. We took a look at my introduction, and Anika asked why it was so\nshort before she even read it. I didn\'t know what to say, so I just\nshrugged and they read it. They were all quiet for a moment until Natasha\nshrugged and admitted that she couldn\'t think of anything that was missing\nand Alex agreed.  </p>\n\n<p> Anika thought for another moment and then she, too, agreed that nothing\nwas missing. She had some ideas for beefing it up a bit, though. Ten\nminutes later, we had a new version that was longer and felt a bit more\ncomplete. Her conclusion looked great to me, and only Alex made a\nsuggestion. </p>\n\n<p> When we were done, Anika said she\'d add in the conclusion, make the\nchanges we talked about and have a version of the paper ready to turn in\nnext week in class. Natasha said that she\'d try to make the larger changes\nthat Alex suggested. I wasn\'t sure what I could do this week because we\nseemed to be in pretty good shape, but I said I\'d start building a\nPowerPoint for the upcoming presentation. Alex asked if anyone minded if he\ndidn\'t do anything this week because he had a late midterm next week in his\ntoughest subject. </p>\n\n<p> I don\'t know what I was thinking when I volunteered for the PowerPoint.\nI had no idea what to put in it. After staring at a blank presentation for\nabout 20 minutes, I took our outline and made slides for each major topic.\nSeeing this, I rearranged it a little bit and added in some sub-headings,\nbut mostly I didn\'t do anything with it. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(51,3,9,'<p> Anika not only brought a copy of our paper to class for the instructor,\nbut also brought copies for each of us to look at between class and our\nmeeting. This way, we didn\'t waste our meeting time on reading through it.\nAs a bonus, Natasha had merged her changes into this latest version. She\'d\nunfortunately had a difficult time making those changes and they were not\ncomplete. She brought a list of questions and possible answers and we spent\ntwenty minutes on that before we came to any answers.  </p>\n\n<p> Alex was pretty quiet during the discussion. At one point, though, he\nsaid he thought he had an idea after seeing what Natasha had done. He asked\nif he could take it home and work on it for next week; no one argued with\nthat. </p>\n\n<p> We next discussed the presentation &mdash; beginning with the\nPowerPoint I put together. Before Anika could comment, I pointed out that\nthis was just a start and that I knew there wasn\'t much to it. I said I\nthought everyone should claim a few slides and modify them when they worked\non what they were going to say. At this, Anika just shut her mouth and I\nhave to admit, that was pretty satisfying. It felt good to anticipate her\nquestions and head them off.  </p>\n\n<p> Natasha chose a few slides, including the first one, but I said that I\nwanted to introduce us. I don\'t think either of us had a very good reason\nfor wanting to begin the presentation. Neither Alex nor Anika had any\nopinion on it, so we decided that we\'d both give it a shot and see which\none we all like best when we practice next week. I\'m kind of excited about\nmaking it into a bit of a competition. </p>\n\n<p> I spent a lot more time on the introduction slide than I did on the\nothers this week, but I didn\'t completely ignore them. I built out my\nslides a bit with some clipart and a few more bullet points, but they were\npretty good as they were. For the introduction, I included little photos of\neveryone and had them bounce in. Then I animated the quick overview with\n\"whoosh\" effects. It\'s a bit cheesy, but I like it. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(52,3,10,'<p> So, maybe I should have spent some more time on what I would say in the\nintroduction and less time on the slides (I think I went overboard).\nNatasha will open the presentation and I feel pretty dumb. On the plus\nside, they liked using the little photos of us all and they didn\'t hate the\n\"whoosh\" effect &mdash; but we\'re not keeping it, either. Everyone else\nsounded so much better than I did and I feel way out of my league.  </p>\n\n<p> I did get a lot of good suggestions, but they all seem so obvious that\nI should have known them. They all had recommendations for each other, too,\nbut theirs didn\'t seem nearly as obvious as mine. I was really feeling like\nI could handle this, and then they showed me just how much I don\'t belong\nhere. Anika seemed especially disappointed. </p>\n\n<p> After class, Alex hung back and offered to help me fix things this\nweek, but at that moment, I couldn\'t imagine how anyone could possibly fix\nmy awful performance, so I said no. </p>\n\n<p> When I got back to my room, I regretted it. I realized it\'s way too\nlate to drop the class. I should have said yes, but I figured what was done\nwas done. I\'d just have to try hard not to let them down too much again. I\nmade all the specific changes they suggested, and I practiced about a\nbillion times for anyone who would sit still long enough. I swear, my\nroommate and my mom must have my part of the presentation memorized at this\npoint, but I will not let my team down again. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(53,3,11,'<p> In class, the instructor returned the drafts, and we met briefly during\nclass to review it. There weren\'t many comments. Most of them were pretty\nminor or issues that Natasha had already fixed. There was one comment that\nconcerned me, though: a diagram might help here. I can\'t believe that this\nwas the first time I realized we were presenting our instructor with a\ngreat big wall of text! How could I have missed that? I took the document\nhome and sketched out ideas for four diagrams I felt would help us to\ncommunicate our point. </p>\n\n<p> I got to the meeting late, and everyone was already talking about our\ncomplete lack of images. I apologized and pulled out my sketches, and\neveryone\'s faces lit up. My sketches weren\'t very good, but I think they\nhelped everyone to come up with better ideas. After 30 minutes, Natasha\n(who is a much better artist than I), had three good diagrams to work with.\nShe said she\'d be happy to build them out and add them to the paper for\nnext week. </p>\n\n<p> We spent the rest of the meeting working through the presentation, and\neveryone sounded better this week. Anika even commented that mine had\nimproved dramatically. I noticed a bunch of mistakes, but no one talked\nabout them. Feeling better about the presentation, I was better able to\nlisten to their parts and offer them feedback. I noticed that Alex was\nspeaking too quietly, while Anika was a bit too fast.  </p>\n\n<p> Alex included something that I didn\'t remember from anywhere in the\npaper. He told me where he\'d found the information, and I believe him\nbecause he\'s got a great memory, but I wasn\'t sure that we wanted to talk\nin the presentation about something that we didn\'t mention in the paper.\nNatasha and Anika didn\'t think it was a big deal, but I feel like it\'s a\nbad idea. If it\'s important enough to talk about, shouldn\'t we write about\nit, too? Isn\'t this supposed to be a presentation of what we\'ve learned? I\nasked Alex to add it to the paper, but he didn\'t think it was necessary,\nand neither did Anika or Natasha. I think everyone\'s getting tired and just\nwants to be done with this. Finally, I just said that I\'d add it into the\npaper myself. </p>\n\n<p> I only spent half an hour making the small addition to our paper and\npracticing this week. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(54,3,12,'<p> The images Natasha put together really added a lot to our paper and I\ncan see them making it easier for people to understand some aspects of it.\nI also claimed one of the images for one of my slides, because it would\nspeak so much better than the bullet points I had on there. I can\'t believe\nwe didn\'t have any images in at all until now. </p>\n\n<p> This week the presentation was much better. After another three\npractice runs, it sounded smooth. Alex was consistently speaking loud\nenough to be heard by the audience and we\'d slowed Anika down. I was a\nlittle bit frustrated to find that, after our argument last week, Alex\nremoved the bit they forced me to add into the paper. It\'s not as though\nit\'s out of place or that it needed to be in the presentation, but why\ncouldn\'t he have just gotten rid of it last week when I asked him about it?\n</p>\n\n<p> Natasha added the photos of us to her introduction slide, and I have to\nadmit, her intro was much better than mine. Finally, and arguably most\nimportantly, we managed to cut it down to the correct time. </p>\n\n<p> I practiced a few more times during the week when I was able to find a\nmoment. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(55,3,13,'<p> The presentation went OK, but not quite as smoothly as I\'d hoped. Alex\nseemed a bit nervous and got quiet, but I\'m pretty sure that most people\nheard him. Anika, on the other hand, raced through her presentation and as\na result, I don\'t think anyone understood her. We wound up finishing up\nabout 30 seconds early &mdash; I can\'t imagine that\'s a good thing.  </p>\n\n<p> Our classmates asked some good questions, which showed that they\nunderstood most of our presentation. Anika, who spoke last, naturally\nreceived all the questions, but she handed them off to whomever she felt\nwas best suited to answer them. There weren\'t a lot of questions, but I got\nto answer two and I felt good about being able to do that in front of our\ninstructor.  </p>\n\n<p> We should have discussed clothes beforehand. I came slacks and a sports\njacket, and Natasha wore a dress skirt and blouse. Alex and Anika were\ndressed very casually, and it was a bit uncomfortable. </p>\n\n<p> Generally, though, I think we felt good about the work we\'d done. I\nexpect positive feedback and good grades. </p>\n\n<p> We only met briefly this week because we were mostly finished and we\nall had finals to study for, but Alex said that he had time to go through\nit once more. Quite frankly, he\'s the best person to do it, so no one\ndisagreed. We also agreed that we\'d only meet briefly next week to make\nsure Alex didn\'t find any huge problems. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(56,3,14,'<p> At the final meeting, we reviewed the paper to make sure it was ready\nfor submission at the end of the week. As we went through it, Anika took\nissue with a few of the changes Alex made. It didn\'t seem like anything\nuntil she pointed it out that some of the language he used was a bit\nambiguous, and it could be read to mean the opposite of what we intended.\n</p>\n\n<p> It took us all a while to see it because we all know what we\'re trying\nto say, but once I saw it, I couldn\'t un-see it. Alex seemed to have the\nhardest time of it, and he hesitantly volunteered to fix it before\nsubmission, but we could all see that was a bad idea. Anika said she had no\nproblem doing it as long as everyone trusted her, because there wasn\'t\nenough time for her to make the changes and get us all to say OK in time.\nOf course we all trusted her and said so. </p>\n\n<p> The night before she sent it in to our instructor, Anika sent us a copy\nof the document to make sure we were all OK with it. I didn\'t have a chance\nto read it carefully, but I wrote back and said OK. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(57,5,1,'<p> In group time the first week, we began by setting up weekly team\nmeetings. The rest of my group are freshmen and they\'re all nervous about\nthis \"huge project\" but, as a sophomore, I\'ve already done lots of them.\nIt\'s clear that if I don\'t provide a lot of guidance, I\'ll wind up writing\neverything myself at the end. </p>\n\n<p> The project looks fairly open-ended, so we brainstormed topic ideas for\nmost of the time. I suggested some that I thought were pretty obvious and\neveryone seemed really impressed, so I told them I\'d done this sort of\nproject before. Jose tried to be involved, but the two ideas he suggested\nwere pretty mediocre. When Sam spoke, I wasn\'t sure if he was serious or\nnot. His suggestions were kind of funny, but I\'m not sure that was his\nintent &mdash; he definitely has a unique approach. Kim mostly just\nlistens; I guess she\'s shy or maybe just getting comfortable. Everyone\nfocused on trying to improve on my suggestions. </p>\n\n<p> Before the meeting ended, we narrowed it down to five ideas. I\nrecommended we each look for resources on one topic, report back next time\nand then select a topic, and everyone thought this was a pretty good idea.\nI spoke up for the topic that was most interesting to me &mdash; I\'d\nalready done some work on it for another class. Sam spoke for another and,\nafter a moment, Jose took another &mdash; but he didn\'t sound thrilled\nabout it. Kim said she\'d take the last two, but that seemed like too much\nfor her, so I said I\'d take it. She surprised me by insisting, so we\ncompromised and split it. She seems nice but hasn\'t said very much and I\ndon\'t know what to make of her. </p>\n\n<p> The research for this week took me about an hour. I\'ve got tons of\nmaterials on both topics because I was able to use some materials from the\nother class, as well. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(58,5,2,'<p> We began the meeting by going over the materials we\'d collected over\nthe last week, and it was very disappointing. I\'m glad Kim and I split that\nlast topic or the group would have junk for both of hers &mdash; she\'s\nclearly out of her depth. To be fair, though, it seems that neither Sam nor\nJose did much better. There are some things that we can use, but I can see\nthey barely read any of what they found. As a result, we spent most of the\nmeeting talking about how I conducted my research and vetted the results.\nSam didn\'t even understand why what he found wasn\'t useable, until I asked\na few questions about the topic &mdash; things that we\'d need to know for\nthe paper &mdash; and where he found the answers. Of course, he could only\nanswer one or two of them. I then went to my own notes and answered the\nsame questions for the topics I took, and then he seemed to understand.\n</p>\n\n<p> When I pointed out that they should redo their research for next week,\nSam actually suggested that the group just go with the topic I researched\nsince I\'d done such a good job with it (again, not sure if he was serious).\nI argued that this is obviously no good, because they still won\'t have any\nidea how to do the research &mdash; and this might not be the best topic\nfor us, anyway. Ultimately, they agreed and decided to redo the research\nfor next week. </p>\n\n<p> We ended early and Kim stopped me as I was about to leave. She told me\nshe thought I was rude to Sam by laughing at him, and we had an argument. I\nexplained that I wasn\'t being mean, I was just trying to help everyone get\nthe most out of the class! I wasn\'t trying to be mean &mdash; I thought he\nwas joking! I told her I\'d try to be more sensitive in the future, and she\nwas OK with it. </p>\n\n<p> Since my materials were fine, I didn\'t have anything to do this week,\nbut I did spend about half an hour looking for materials for the other\ntopics to help them out. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(59,5,3,'<p> In this week\'s meeting, we sorted through the materials we\'d got to\nevaluate them and decide on a topic, but it was tough to come to agreement.\nThey\'d all brought better materials this week. I feel like I never should\nhave pushed them to redo their research, because Sam came back loving his\ntopic, even though the materials available for it were pretty weak. Even\nworse &mdash; he convinced Kim to agree. I don\'t know how that happened,\nbecause I pointed out that the materials available were really thin and\nthere really wasn\'t much on which to base a paper. On the other hand, Jose,\nwho didn\'t much like his own topic, agreed that the topic I\'d initially\nselected was the best of them &mdash; it\'s got the best resources\navailable, as well. The discussion went on for most of the scheduled\nmeeting time, and ultimately the group settled on the topic I\'d researched.\nI\'m not positive that Sam\'s really on board, but he did say \'ok.\' </p>\n\n<p> After the topic was settled, I started drafting our outline and\neveryone joined in. It became clear pretty quickly that I\'d have to teach\nthem how to structure a paper properly. Even afterward, Sam proposed some\nodd ideas that he said would make it more interesting. I had to explain\nthat, while that was great for fiction, this was needed to be professional.\nAgain, he gave in, but I\'m not sure that meant he agreed. Jose suggested we\nsplit up the source materials among ourselves, look for a few more, write\nwhat we can about them and bring that back next week. It wasn\'t a bad idea,\nbut as soon as I started assigning them, everyone got upset with how I was\ndoing it, so I asked them to claim one they wanted until there were none\nleft. This worked pretty well, but Jose took one that was really too\ncomplicated and difficult, so I offered to help with it; this seemed to\nupset him. </p>\n\n<p> I spent about another hour taking notes this week. I took some notes on\nthat piece for Jose, but he never did get in touch with me to work on it,\nso I figured I\'d bring them to class and give them to him there. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(60,5,4,'<p> Jose was obnoxious in class about the notes I\'d put together to help\nhim. When I handed them to him after class, he looked at me like I was\ncrazy. I don\'t get it, but he did take them. </p>\n\n<p> Jose and Sam were late to the meeting this week, but that\'s not such a\nbig deal. What wasn\'t OK was that Sam forgot to write summaries for two of\nthe five parts he was supposed to bring! No one else seemed to care until I\nreminded them that we only had one week left before we turned it in. It\'s a\nshame, because he did a great job with what he did write. Jose seems to\nhave completely ignored all the notes I gave him and a quick glance at his\nsummaries shows that he doesn\'t understand what we\'re doing with this\npaper. It\'s not garbage, but there is a lot of work left to do. Kim did an\nOK job on her parts, but, while they are OK for next week, they are on the\nshort side and she didn\'t think about the outline at all or where her\nsummaries might fit into it. It\'s going to take a lot of work to build this\nout into a paper.  </p>\n\n<p> Naturally, everyone was surprised to see my summaries because they were\nmuch more complete. Also, no one else had thought to include pointers to\nthe sections where they should be used in our outline. Unfortunately, with\nthis due next week, there\'s no time for them to fix theirs. Sam said he\'d\nput everything together for what we need to turn in, since he still has to\nwrite a lot of his materials. I told him to send it to me so I could look\nat it before we turn it in. </p>\n\n<p> Next we talked about the outline and Kim had some really good ideas for\nimproving it. Everyone agreed, but Sam complained that it was too much for\nhim to do for next week and asked that we just make a note of it and make\nthe changes later, but this won\'t get us the feedback we need from the\ninstructor. Anyway, he\'s the one who didn\'t do his work for this week...\nKim stepped up, however, and offered to make the changes if Sam could get\nthe rest of it done by the middle of the week. Sam agreed. I really hope I\ncan trust them to do it right. </p>\n\n<p> Before we left, I reminded everyone that we need a completed draft\nready in another four weeks and that they should build out their summaries\nto look more like mine for next week. From the looks on their faces, it\nseemed no one else realized this was necessary, but no one argued. </p>\n\n<p> There wasn\'t much for me to do this week outside of the meeting, so I\nfocused on my other classwork. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(61,5,5,'<p> Kim was a little late, but turned in our paper in in class. After\nclass, the instructor allowed some time to meet for group work, and we\nreviewed Sam and Kim\'s work &mdash; they explained that they met up in the\nmiddle of last week after Sam had done his part and worked on finishing\neverything up together. There wasn\'t a lot of time in class and it looked\nok. I pointed to a few problems, but there weren\'t a lot of comments. </p>\n\n<p> Everyone was happy to see the paper starting to take shape and we\ndiscussed what we should do next. Sam suggested that we each build out the\nsummaries we\'d been working on, but I had to point out that that wouldn\'t\nwork, because some of them would appear all throughout the paper. I was\nabout to speak, but Jose had arrived and heard us talking about what came\nnext. He said we should just wait for the feedback from our instructor,\nanyway. He argued that we should take the week off, instead! The worst part\nwas that Kim and Sam also thought this was a good idea.  </p>\n\n<p> I had to explain that the first assignment was basically just to make\nsure we were moving forward. I also told them that, in my experience, it\noften took weeks for them to get this sort of thing back to us; if we\nwaited on that, we\'d never have the draft completed in time. I can\'t\nbelieve they didn\'t know! Also, it\'s getting toward mid-term time and we\'ll\nappreciate the extra time to study later if we finish most of this now.\n</p>\n\n<p> I told them we have to keep moving to get this done. That meant\nsplitting the paper into four pieces and each of us taking one &mdash; we\ncould save the introduction and conclusion to be written after the rest is\nin place. Eventually they agreed to this. </p>\n\n<p> I took the last quarter of the paper and spent a lot of time working on\nit this week. The topics in this part were mostly done by Sam and Jose, and\nI had to fix many major problems with Jose\'s work. He\'s trying, but doesn\'t\nreally get it. I had to review a bunch of the materials to see what they\nwere really saying and then redo everything. He misinterpreted the\nmaterials and was therefore arguing the wrong point. He probably won\'t even\nrecognize much of this as his work. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(62,5,6,'<p> Sam and Kim were again there when I arrived this week, but Jose was\nnot. We started by looking at Kim\'s work. It was well written and she\'s\nmade some good observations that I hadn\'t even thought of. We spent some\ntime exploring those observations further, and it gave me some ideas to add\nto mine. Sam\'s looks fantastic because he included some great visuals that\nmade it easy to understand what he was trying to say &mdash; he should be\nan illustrator. This started us talking about where else we might be able\nto add images to strengthen our paper. We came up with a diagram and a\ngraph that would really help, and Kim volunteered to take the graph, but I\ndon\'t want her to be overloaded since I\'ll probably ask her to do much of\nthe proofreading and formatting. Plus, Sam\'s obviously good at it. So I\nasked him to do them both, and he seemed happy. </p>\n\n<p> Then Jose showed up, about fifteen minutes late, saying his coach had\nbeen holding the team late to prepare for their upcoming game. We moved on\nto the part of the paper I\'d rewritten and Jose was angry because he didn\'t\nunderstand why I changed his part of it. I said that what he had put\ntogether had helped me orient myself, but that I\'d had to make some changes\nso it would all make sense and work toward the same vision. He responded\nthat it was my vision and not the group\'s. Then Kim spoke up to say that\neven though the paper is much different from what she thought it would be,\nit was clear that I had a lot of experience and that the paper was turning\nout well. After that, Jose admitted that he was going in a different\ndirection and asked us to think about writing the paper that way &mdash; he\nthought it was valid. So we talked about the problems we might run into\n(not the least of which being that we\'d have to do a major rewrite).\nUltimately, he gave up and stayed on the same path, of course. Obviously,\nwe didn\'t look at Jose\'s work because he would have to make some major\nchanges to it, anyway. </p>\n\n<p> Since none of their pieces are really finished and I had some things I\nwanted to add to mine (thanks, Kim!), we decided to each spend another week\nwith our own parts. I volunteered to write the introduction and conclusion,\nas well. My own additions took me longer than expected &mdash; I spent\nabout an hour on it. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(63,5,7,'<p> Jose was late again this week. It was only about five minutes this\ntime, but it\'s getting to be a habit and he said the game was last week, so\nI asked him to please try to be on time in the future; he glared at me. He\nreminded me that his coach has been keeping him longer lately and then\nadded that it didn\'t matter because I was doing the whole project anyway\n&mdash; that it didn\'t make much difference if he was there or not. How am\nI supposed to respond to that? I reminded him that it\'s a group project and\nthat we\'re all working toward a shared grade on this. Really! Am I supposed\nto apologize for being more experienced? Kim stepped in at this point to\ncalm Jose down. She confirmed, and asked me to confirm that we were working\nas equals on a group project. </p>\n\n<p> Everyone\'s pieces looked much better this week &mdash; especially\nJose\'s, which was pretty much entirely rewritten. While Sam\'s very good\nwith visuals, his writing skills leave a lot to be desired. At first, I was\nmaking a lot of comments and corrections, but then I gave up and told him\nthat I\'d take it and fix it for next week. He was fine with that. Everyone\nseemed to be pretty happy with the way the paper was turning out, in fact\n&mdash; even Jose. </p>\n\n<p> I suggested that maybe we might want to trade pieces to proofread for\nnext week and then end early. Nobody was opposed to this, and I\'d already\nvolunteered to take Sam\'s work. Kim said she\'d assemble the four pieces for\nnext week so we could see the whole thing together. I wasn\'t comfortable\nwith this because we would all be looking at our pieces separately this\nweek, and it wasn\'t fair to make her do all of that. However, she pointed\nout that we could still make our edits to the pieces in the larger paper\nand she was volunteering to make the changes in the final document, too.\nSo, since I couldn\'t think of any good reason why we shouldn\'t, we went\nwith it. </p>\n\n<p> Jose asked that we change our meeting time for next week because he has\nsome study sessions to attend. Sam asked if we might even be able to cancel\nit, since we\'ve all got mid-terms coming up and our paper is looking like\nit\'s in pretty good shape; Kim agreed with him. Naturally, no one\nremembered that it was my planning and organization that put us in such a\ngood position. We decided to change next week\'s meeting to fifteen minutes\nimmediately after class; it will be primarily to pass around the updated\ndocument and our corrections. </p>\n\n<p> It took me a while to get through Sam\'s work, and I had to rework a lot\nof it. All told, it took me about an hour. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(64,5,8,'<p> During this week\'s class, some of the discussion touched on the topic\nof our paper, and Jose and Sam both were active in the discussion. This\nlead to some lively debate, and it became clear that there were competing\npoints of view within the classroom. </p>\n\n<p> After class, we met briefly as we decided last week. Kim did a good job\nof not only integrating her own work into the paper, but cleaning things up\nin general. She seems to have a real knack for that. She moved some things\naround throughout the paper, and it\'s a real improvement. She\'s also\napplied the formatting throughout the document and it\'s looking good. Jose\nand Sam were also impressed. Kim put a lot of work into it. The changes\nmade it difficult, however, to distinguish one piece from the other. We\ndecided we should look through our high-level comments and feedback to see\nwhat still makes sense to incorporate, and then hand the detail work back\nto Kim to apply in the new version. Most of the changes ended up being work\nthat Kim had already done. </p>\n\n<p> Then, Sam brought up the class discussion and asked what we should do\nabout addressing the other viewpoints. While we probably should mention\nthem, Jose looked at this as some sort of vindication of where he was going\noriginally (that I corrected). Worse yet, Sam agreed! Our existing approach\nshowed we are creative and thoughtful, rather than just parrots of the\ntextbooks. When the discussion stretched on, I suggested that maybe we\nshould hold our regularly-scheduled meeting to finish the discussion. No\none wanted to do that. I offered instead to add in a note explaining the\nother perspective, and Sam really liked this idea. He explained that he\nreally likes the direction we\'ve taken the paper, but that he was nervous\nthat we\'d look like we\'d completely missed that alternative perspective.\nHe\'s got a really good point, too. This got Jose on board, but he wanted to\nwrite it. I said no way! His other work has been sloppy, and I said I\nwouldn\'t risk turning in something unfinished, even if it is just a draft.\nKim told him that if he could get it to her by mid-week, she\'d include it\nin the draft she was preparing. On our way out, I caught Kim and asked her\nto be sure to keep the note brief. </p>\n\n<p> I didn\'t have anything to do outside of class this week, so I focused\non my other class work. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(65,5,9,'<p> Kim had our paper ready to be submitted when she arrived in class, and\nshe also brought a copy for each of us to look at afterward, but we didn\'t\nmeet because both Sam and Jose had already left. I was really hoping to\nhave a chance to go through it together, but that was probably best because\nit gave me a chance to look over the whole paper. Although it integrates\nnicely, I thought that Kim would keep Jose\'s brief note brief; instead, it\nadds almost a full page. </p>\n\n<p> About ten minutes into the meeting, I started to get up and leave\nbecause I was the only one there. Just then, Jose arrived and asked why I\nwas leaving. It seems that Kim told Jose and Sam she\'d be late to the\nmeeting, so they decided to just meet later instead &mdash; but no one\nthought to tell me. When everyone finally arrived, I tried not to make a\nbig deal, but I was pretty upset. </p>\n\n<p> I pulled out my own changes to the document and no one questioned any\nof them. They were mostly minor at this point, but I did trim down some of\nJose\'s note. No one said anything. I asked them to please take another look\nat the paper this week, but I doubt they will.  If they do, they probably\nwon\'t see anything. I guess everyone is exhausted. Maybe they hate me? </p>\n\n<p> Our next task was to begin preparing for the presentation. We drafted\nan initial PowerPoint, and they all just accepted the assignments that I\nsuggested &mdash; they pretty much followed the parts of the paper they\'d\neach written. I expected there to be some discussion, so I asked if\neveryone was OK with it. They said it was fine, so I guess they are. We all\nagreed to start working on our talking points and our slides in the deck.\n</p>\n\n<p> I am very comfortable with my topic, but that translated into it\nrunning about twice as long as it should. It took me two nights to get it\nto something workable because I had a lot of other projects to work on,\ntoo, and I just couldn\'t focus. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(66,5,10,'<p> We spent the first fifteen minutes practicing our presentation &mdash;\nthe one that\'s only supposed to take seven minutes! Have none of these\npeople ever presented anything before? Jose talked for five minutes about\neverything but his topics before he introduced Sam. Sam, in turn, had the\nsmart idea to add the diagrams to the slides, but then proceeded to\ndescribe the images, rather than the story they are supposed to tell. I\nhave no idea what Kim was talking about since she seems to be so petrified\nof public speaking that her voice never got up above a whisper. By\ncomparison, I thought mine was pretty decent. I may not be the best\npresenter, but at least I stayed on topic and close to the time limit. </p>\n\n<p> We spent the rest of the meeting working on the presentations.\nFortunately, I wasn\'t the only one criticizing and pointing out flaws. Each\nof us (including me) took home a bunch of things to work on before the next\nmeeting if this presentation is going to run smoothly. I have to slow down\nand rework a few phrases that didn\'t make sense to them when they heard it.\nAlso, after seeing what Sam put together, I\'ve got some ideas for improving\nmy slides. </p>\n\n<p> I actually spent another hour and a half just practicing my part\n&mdash; and that was after about half an hour of reworking. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(67,5,11,'<p> In class, the instructor returned the drafts to the groups, and we met\nbriefly during class to review it. The instructor left only six comments in\nour paper &mdash; glad we didn\'t wait on that! One comment read,\n\"Interesting approach! I like that you reached beyond what we did in\nclass.\" The comments clearly favored the results of my guidance (in\ncontrast with the direction Jose was pushing for). Another comment\ncomplimented the images. One of the comments indicated a need to further\ndevelop a section and another asked us to recheck one of our references.\n</p>\n\n<p> Our meeting opened up very strangely, as Jose completely misinterpreted\nthe instructor\'s comment. He thought the instructor was complimenting the\nfact that the document took what we talked about in class a bit further. It\ntook me a while to understand that\'s what he was thinking and then I tried\nto gently help him understand the truth. Eventually he said he understood,\nbut I\'m not sure that he really did. Sam and Kim both stayed out of that\ndisagreement and were quick to move on afterward. I told them that I\'d make\nthe requested changes this week because I\'d already started. </p>\n\n<p> The presentations were better this week, but we still need more\npractice and a bunch of rework. Jose changed his part in response to what\nhe thought the instructor was saying, but I\'m not sure I can convince him\nto fix it completely. He did say he\'d change it some to make sure it\'s\nstill in line with what everyone else wrote, and I guess this is OK. We do\nhave the note in the paper, so I guess he\'s got that covered. Sam and Kim\nhad both fixed some parts of theirs, but we spent most of the meeting\nfixing other parts. We also talked about how we should dress for the\npresentation. Kim had an elaborate costume idea that was completely\nunprofessional (and I hate dressing up in costumes). I said business\ncasual. When we ended the meeting, I reminded everyone that our\npresentation is in just two weeks. </p>\n\n<p> Reworking the paper this week took me about two hours, but I didn\'t\nmind. If I hadn\'t done it, it probably would have been wrong. Also, the\ninstructor was right about the reference &mdash; I\'ll have to ask Sam what\nhappened with that and if he\'s able to track down the correct reference.\nI\'m glad my part of the presentation is finished now. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(68,5,12,'<p> We had to start without Kim this week because she left a message with\nJose that she\'d be late due to a meeting for another class. The group spent\nsome time reviewing my changes to the paper. I asked Sam about the\nincorrect reference and he just laughed and rifled through his notes. He\nexplained that it was just a placeholder he threw in while he was writing,\nand he never got around to removing it. It\'s pretty funny that it stayed in\nthis long without anyone noticing. I continued and both of them were fine\nwith my fixes. </p>\n\n<p> Kim arrived just as I finished looking at the changes. She asked to\ntake another look, but I asked her to look at it after the meeting,\ninstead, so that we would have time to practice the presentation again.\nNone of them made many changes &mdash; even Sam, and that\'s annoying\n&mdash; but the presentation felt much better this week. They must have\npracticed a lot. After two practice runs, it sounded smooth. While it\'s\nstill running too long, we agreed that everyone will probably speak faster\nin class and the instructor probably won\'t be a stickler on time. </p>\n\n<p> We decided to end early this week. I reminded everyone to wear formal\nbusiness clothes to the presentation next week. </p>\n\n<p> I practiced a few more times this week, but mostly I was free again to\nwork on my other coursework. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(69,5,13,'<p> We were the only group dressed professionally, and I think that\nprobably earned us some points. Kim managed to speak loudly and clearly\nenough that the instructor only had to ask her to speak up once. Jose\nstumbled on his first few sentences, but he quickly relaxed and did a great\njob. The biggest surprise, though was Sam: he added an analogy at the end\nthat not only tied everything together, but it also made everyone laugh. It\nwas unexpected and risky, but it worked out well. There weren\'t a lot of\nquestions for us, and I stepped forward to direct them to the best person\nto answer. </p>\n\n<p> I think we can expect positive feedback and good grades.  </p>\n\n<p> Since the paper is mostly finished, we all decided to skip this week\'s\nmeeting and each give the paper one last review for the following week.\n</p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(70,5,14,'<p> At the final meeting, we compared notes and found that we had no major\nchanges to make. Kim took all four versions and said she\'d make all the\nchanges and then submit it at the end of the week. I asked her to send it\nto me first because I want to take one last look at it. She was annoyed by\nthis, but she agreed. </p>\n\n<p> When she got me the paper, there were no changes to make, but it felt\ngood to give it a final review and submit it. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(71,6,1,'<p> In group time the first week, we began by setting up weekly team\nmeetings. I think we got lucky, because Anna is already a sophomore, while\nthe rest of us are freshmen. It seems like she knows what she\'s doing. </p>\n\n<p> The project is fairly open-ended, so we brainstormed topic ideas for\nthe rest of the time. I suggested some topics, but they weren\'t nearly as\ngood as Anna\'s ideas. I knew they weren\'t that great before I said them,\nbut when I caught a glimpse of Anna\'s face when I said them, I felt dumb.\nShe told us that she\'s done this sort of thing before. Thankfully,\neverything I said was sort of overshadowed by Sam\'s contribution that no\none knew how to respond to. When he speaks, I can\'t tell if he\'s serious or\nnot. His suggestions are kind of funny, but I\'m not sure that\'s his intent\n&mdash; he definitely has a unique approach. Kim mostly just listens; I\nguess she\'s shy or maybe just getting comfortable. Soon, everyone focused\non trying to improve on Anna\'s suggestions.  </p>\n\n<p> Before the meeting ended, we narrowed it down to five ideas. Anna told\nus we should each look for resources on one topic and then report back next\nweek. She spoke up for a topic she\'d already worked on in another class.\nSam quickly spoke up for another and, then I chose the most interesting one\nthat was left. Honestly, though, I was disappointed because I liked the one\nAnna chose, but I\'ll give this a shot. Kim said she\'d take the last two,\nbut I guess Anna\'s concerned, so she offered to take one herself. Kim\ninsisted, though, that she can handle it, so Anna split it with her. I\'m\nnervous about Kim, too, because she hasn\'t said or contributed much, but\nthat\'s fine. We\'ve got time. </p>\n\n<p> I spent about 45 minutes researching my topic this week and I found a\nlot of materials, so I feel pretty good. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(72,6,2,'<p> We began the meeting by going over the materials we collected over the\nlast week. Anna was clearly disappointed, and she didn\'t hide it well. She\nspent most of the meeting talking about how she did her research. It was\nhelpful, but makes me feel like I\'m a child. I\'m going to have to do a lot\nof it again. Sam asked some questions indicating that he didn\'t see why his\nmaterials are mostly unusable, and Anna just laughed at him. He asked again\nand this time Anna responded with a few detailed questions that Sam\ncouldn\'t answer. She then went to her own notes to answer the same\nquestions. It seemed a bit cruel (and I\'m glad it wasn\'t me) because I\ncouldn\'t have answered those questions. Sure, they are important and all,\nbut we\'re new to this and she\'s not. She\'s already worked on this topic\nbefore. </p>\n\n<p> I suggested that, in the interest of time, maybe we just go with the\ntopic she worked on, but Anna insisted that we redo our work. She pointed\nout that we all need to be able to do the research. No one could argue with\nthat, so we said we\'d redo our work. </p>\n\n<p> The next night, I spent about another hour and a half finding and\nskimming through new materials. I was still able to use most of my original\nmaterials. I found a bunch of additional ones, too. I don\'t love this\ntopic, though, so it feels like a waste of time. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(73,6,3,'<p> During this week\'s meeting, we sorted through the materials to decide\non a topic; we have much better materials this week. It turns out that\nSam\'s topic is really cool, but it was clear Anna was more interested in\nher own topic. So was I. It\'s really got the most potential, and we\'ve got\nthe best resources for it. We went back and forth for most of the meeting\nand it was a pretty good debate, but in the end, I thought Anna\'s topic was\nbest, and Kim wound up agreeing with us (even though she started out siding\nwith Sam). After Kim changed her mind, Sam agreed to go along. </p>\n\n<p> After the topic was settled, there wasn\'t much time, but Anna jumped\nright into drafting an outline, and she wouldn\'t let anyone else help. Sam\nhad some interesting ideas about how to make the paper easier to read, but\nwhen he brought them up, Anna took it as a sign that none of us had ever\nwritten a research paper before. We all had to sit through her explaining\nto us what an outline is and why we use it &mdash; that\'s ten minutes of my\nlife wasted. No one made any comments on the outline after that. </p>\n\n<p> When I suggested that we each take a few of our sources, search for\nmore content on our own and then write up summaries for next week, Anna\nagreed and started assigning them out. She acted like she was the only one\nwith a brain, however, and she didn\'t trust the rest of us to get anything\nright, so she took the materials that were actually interesting and offered\nany depth &mdash; strange, since she made such a big deal out of making\nsure we were all \"learning\" during the initial research. I wasn\'t the only\none upset &mdash; Kim spoke up first to request a specific topic, and then\nSam and I did the same. This clearly irritated Anna, but eventually she\ngave in and we each claimed the ones we most wanted. This seemed fine and I\ntook one that I thought I could make into something interesting, but\napparently Anna didn\'t think I could handle it. She told me she\'d \"help\" me\nwith it &mdash; like I\'m incompetent or something. I just said OK and moved\non &mdash; she can do what she wants, but I\'m writing it. </p>\n\n<p> I spent about two hours on reading, searching and writing summaries. I\nlike how it turned out. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(74,6,4,'<p> After class this week, Anna handed me her \"help\" &mdash; her completed\nsummary was even longer than mine! Does she think I\'m not competent to\nwrite anything? I wasn\'t sure how to respond; I just kept thinking this\ncouldn\'t really be happening, but when I realized it was, I took the paper\nand walked away. When I got home, I found that she\'d pulled out completely\ndifferent main points. I can see that this is where she\'s going, but my\napproach is just as good, and I didn\'t have time to make any changes to\nwhat I\'d written, anyway. </p>\n\n<p> I was a bit late to the meeting, but it was only about five minutes and\nSam was just arriving when I walked in. I can tell that Anna wasn\'t\nthrilled with what I brought, but she was more upset that Sam didn\'t finish\nhis part. She was particularly upset because she thought we were writing\nour completed portions to be added directly into the paper &mdash; and\napparently no one else thought this. What does she expect? She tells\neveryone what to do because she\'s got more experience, but then she doesn\'t\nexplain what she means &mdash; assuming that we have the same experience\nthat she does. Kim called her out on this, asking why she wrote so much\nalready when we\'re so early in the project. After all, we only have the\npreliminary structure done, and this is only the fourth week of class.\n</p>\n\n<p> Anna got upset and asked how she would be able to put anything together\nusing materials as thin as this; that\'s when Sam spoke up. He made a joke\nabout how poorly he\'d done his part &mdash; his wasn\'t just thin, it was\nnonexistent. It wasn\'t that funny, really, but everyone laughed and he\nvolunteered to assemble next week\'s assignment since he still has pieces to\nwrite. He also suggested that we take a look at what we\'ve got and whether\nthe outline we put together still fits. It was really either that or fight\nfor another hour, so everyone was all for it. </p>\n\n<p> The discussion was OK, and Kim offered some really good ideas about how\nto sequence things. It helped me to see the paper differently, and it gave\nme some more ideas. Anna agreed that the sequence is a good idea, but Sam\nquickly pointed out that he wouldn\'t have time to do it all, and Anna\nstarted getting upset again. I also don\'t have time to help out;\nfortunately, Kim offered to make the changes if Sam could get the rest of\nit done by the middle of the week. Sam gladly accepted this, and they\ndecided to coordinate later. </p>\n\n<p> Naturally, before we left, Anna had to remind everyone that we need to\nkeep working on our summaries because we\'ve got the draft due in another\nfour weeks. </p>\n\n<p> I spent about half an hour on my sections this week, but I mostly\nfocused on my other classes. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(75,6,5,'<p> Kim had our assignment ready and turned it in during class. The\ninstructor allowed some time at the end of class this week, so we reviewed\nwhat she and Sam put together. It seems they met up in the middle of the\nweek and finished it together. Anna was pleased with their work, so the\nmeeting went pretty smoothly. </p>\n\n<p> My coach kept us late all week to prepare for a home game against our\nrivals in two weeks, so I was about twenty minutes late. It was a tough\npractice and I was exhausted, so when I arrived and the group was\ndiscussing our next steps, I suggested we take a break from it for a week\nwhile we wait for feedback from the instructor. Sam and Kim seemed to think\nthis was a pretty good idea, but Anna got upset. She spent the next ten\nminutes explaining that she thought the instructor probably would barely\nlook at our papers, much less provide meaningful feedback. She said it\'d\nprobably be weeks before we got it back; by that point, we\'d have no time\nleft to get our draft together. She kept talking about how we couldn\'t stop\nnow because of midterms, scheduling and all sorts of other junk. I gave up\nbecause I just didn\'t want to hear any more. I really could have used a\nbreak, but I guess she won\'t let us have one. </p>\n\n<p> We split the paper up into quarters and each took a section to write up\nfor next week. Before we left, I told everyone that I\'d probably be late\nthe next week because of our practices. </p>\n\n<p> I had to spend about two and a half hours writing my part of the paper\nthis week. I mostly had to work with Sam\'s contribution and just a bit of\nKim\'s. Sam\'s contributions were difficult to understand. He had some good\npoints, but the way he wrote was very confusing and took a long time to\nunderstand &mdash; sometimes it was easier to just go back to the sources.\nThey also seemed to miss part of the point. Ultimately, I had to write most\nof it from scratch. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(76,6,6,'<p> I was a little late again for our meeting this week because of\npractice. Before I arrived, the group went through Kim\'s and Sam\'s work. I\ndidn\'t really get a chance to read either of them, but Sam included visuals\nin his and it makes a big difference! I guess that they all agreed and\nlooked for places to add more. </p>\n\n<p> Next, we reviewed Anna\'s. She sort of apologized to me for changing it\nto make sure it all made sense and worked toward the same point. As I read,\nthough, it became clear that she rewrote almost everything I gave her. I\nrecognize it, of course &mdash; it\'s all very similar to the \"help\" she\ngave me. I completely wasted my time and might as well not have written\nanything!  </p>\n\n<p> I answered that it was her vision and not that of the group. Kim spoke\nup and took Anna\'s side, saying she liked where the paper was going. I\nrealized that it didn\'t matter what I said or did, because we were just\nhelping Anna write her paper. It wasn\'t a bad paper, but it wasn\'t ours\neither. It was clear that I\'d have to rewrite most of the work I\'d done\nthis week, so we didn\'t bother looking at mine. </p>\n\n<p> As it turned out, I didn\'t have as many changes to make as I thought.\nIt only took me about 45 minutes to fix it all up. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(77,6,7,'<p> I was a little late this week because I think I pulled a muscle or\nsomething in my leg at practice. When I arrived Anna yelled at me for it.\nCouldn\'t she see that I was limping? Anyway, what did it matter since she\nwas writing the whole paper herself? We started to get into it but then Kim\nspoke up to calm us both down. She made Anna confirm (out loud) that we are\nall equals, working on this project together. Of course, Anna had to remind\neveryone that she had more experience than anyone else, but Kim pushed us\non anyway. </p>\n\n<p> Anna was happy with everyone\'s work this week &mdash; especially mine.\nOf course, I\'m basically just doing exactly what she told me. She was\ndisappointed by Sam\'s work, and there are a lot of corrections to be made\nthere, but it\'s nothing at all like last week. Anna told him she\'d take it\nand rewrite it for next week. At this, Anna told us we needed to trade\npieces and proofread each other\'s work for next week. Everyone was OK with\nthis, but Kim wanted to get started on assembling the paper and volunteered\nto do that. Anna pointed out that it would be tough to match the individual\npieces with the assembled document so that we could make the changes, Kim\nsaid she\'d take care of it, so it was decided. </p>\n\n<p> As we were getting ready to go, I asked if anyone would mind changing\nour meeting time for next week &mdash; I had a study session to prepare for\none of my midterms. Sam agreed and asked that we cancel it, since the paper\nis in pretty good shape. Kim was on board. Anna decided that we should\nstill meet, but only briefly immediately after class to share our changes.\n</p>\n\n<p> I took Kim\'s piece and it was really in pretty good shape. I was able\nto read through it quickly and I had very few comments or corrections to\nmake. I wonder if Sam will have much to say about mine. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(78,6,8,'<p> During this week\'s class some of the discussion touched on the topic of\nour paper, and it felt good to have a lot to contribute in class. There was\nsome good debate about the competing points of view &mdash; specifically,\nthere was a lot of interest in what I had written but that Anna had\nremoved. Sam, although usually pretty quiet during class, even got in on\nthe discussion and made a few good observations, although I\'m not sure\neveryone really understood them. I landed in a pretty smart group. </p>\n\n<p> After class, we met briefly as we decided last week. Kim did a great\njob on the paper again, and Sam\'s diagrams were mostly spot on. One of them\nseemed odd, but I couldn\'t explain why. Fortunately, Anna understood and\nasked Sam to make a few changes in line with my comments. Sam said he\nwasn\'t a good enough artist, however. He said that he agreed with me and\nthat he\'d like to be able to do it, but he doesn\'t have the skill. I can\'t\nreally argue with that, can I? Even like this, the diagrams really help to\nspruce things up and I didn\'t want to spend that much time on them, anyway\n&mdash; I was much more interested in the class discussion. Since Kim had\ndone such a great job, most of our own comments and changes weren\'t\nrelevant any longer, so we mostly just handed them to her to incorporate\nfor next week. </p>\n\n<p> When I wanted to talk about fixing our paper because the class was\ninterested in what I wanted to say, Anna said it was boring and that she\ndidn\'t have time to explain all the problems with it and asked if we wanted\nto hold our regular meeting to discuss it. Of course, we couldn\'t do this\nbecause we all had other study sessions to go to, but Sam also wanted to\ninclude my perspective. Finally, Anna gave in and agreed to add a section\non it, but she wouldn\'t let me to write it &mdash; like I\'d screw it up or\nsomething! She said that she didn\'t want us turning in something that was\n\"sloppy\" &mdash; my work is not sloppy! Fortunately, Kim spoke up and asked\nAnna if she\'d be OK with me writing it if she reviewed it first. Anna was\nOK with that, so Kim asked me to get it to her by mid-week. I feel like a\nchild, but whatever. </p>\n\n<p> I wanted to make sure that Anna couldn\'t complain about it being\n\"sloppy,\" so after spending an hour and a half writing the new section, I\nspent another hour proofreading it the next night before sending it to Kim.\n</p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(79,6,9,'<p> Kim had our paper ready to be submitted when she arrived in class. She\nalso brought a copy for each of us to review. I took a look that evening\nand Kim had done a great job of adding in my new section. She\'d made a few\nchanges to make it clearer, but mostly used what I gave her. I thanked her\nduring the week and she appreciated it. She also told me that she\'d be\nabout ten minutes late to our meeting this week. I mentioned it to Sam when\nI saw him in a class we share.  </p>\n\n<p> Unfortunately, we took this as a reason not to rush to our meeting, but\nno one mentioned it to Anna. She was packing up to leave when I arrived.\nOops. She seemed really uptight and stressed in the meeting. She\'s never\nbeen fun, but this seemed different &mdash; she must have been really\nangry. </p>\n\n<p> Anna had a long list of changes to the paper and some of them were big,\nbut no one said anything &mdash; I know I was feeling guilty and I imagine\neveryone else was, too. She asked us all to take another look at the whole\npaper and read it straight through for next week to make sure we haven\'t\nmissed anything. </p>\n\n<p> Our next task was to begin preparing for the presentation. Anna drafted\na PowerPoint for us to use, and then assigned slides to each of us. At one\npoint, she asked if anyone was upset with their piece and no one was, so\nshe kept going. She told us we needed to write up our talking points for\neach of our slides and practice a few times in front of a mirror for next\nweek. </p>\n\n<p> I am pretty comfortable with my topic, and it didn\'t take me long to\nwrite down some notes on index cards. Honestly, I\'m pretty good at public\nspeaking, so I don\'t think I need to prep too much. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(80,6,10,'<p> Wow! Anna found nothing but fault in my presentation! She pointed out\neverything I forgot to include and didn\'t seem to like anything about what\nI did include. To be fair, she wasn\'t the only one, but she was pretty\nharsh. No one else did a great job, either &mdash; including Anna. She\nmight think she\'s much better than all of us, but even she had a bunch of\nthings to fix.  </p>\n\n<p> Sam\'s slides looked better than everyone else\'s because he used a lot\nof the diagrams he\'d drawn, but he missed a few important points that\nweren\'t represented in them. Kim\'s was probably the best of all, but she\nspoke very quietly to her notes, rather than to the audience. After three\npractice runs, everyone took home a list of things to fix their\npresentations. </p>\n\n<p> I spent an hour and a half reworking my part &mdash; and then about\nhalf an hour practicing it. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(81,6,11,'<p> In class, the instructor returned the drafts to the groups, and we met\nbriefly during class to review it. The instructor left only six comments in\nour paper, but one at the front of the paper read, \"Interesting approach! I\nlike that you reached beyond what we did in class.\" The instructor clearly\npraised the section I got Anna to include. Another comment complimented the\nimages. One of the comments indicated a need to further develop a section,\nand another asked us to recheck one of our references. I couldn\'t wait to\nsee Anna\'s reaction to the instructor\'s comment! I even fixed my\npresentation accordingly. </p>\n\n<p> Our meeting was frustrating because Anna wouldn\'t even consider the\nidea that the instructor\'s comment was referring to my addition. I can\'t\nbelieve I walked in thinking the paper would change the way I wanted it to.\nI walked out glad that I was able to keep any of my work in at all. Both\nSam and Kim stayed out of the discussion. When I asked what they thought,\nthey just shrugged. Anna said she\'d make the changes the instructor\nrequested this week. </p>\n\n<p> Everyone\'s presentations were better this week, but we still need more\npractice and rework. Sam and Kim had both fixed some parts of theirs, but\nwe spent most of the meeting fixing other parts. Anna had improved upon\nhers significantly since last week. I don\'t know how she did it, but it\nsounded perfect. Finally, we talked about how we should dress for the\npresentation. Kim had a cool costume idea that was in keeping with our\ntopic that Sam and I both liked, but Anna said that would look\nunprofessional. She said we had to wear business clothes. When we ended the\nmeeting, Anna reminded everyone that our presentation is in just two weeks.\n</p>\n\n<p> Since I still had my old notes, it only took me about fifteen minutes\nto get my presentation back in shape again. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(82,6,12,'<p> Kim let me know that she\'d be late because of another meeting, so we\nstarted without her. We spent some time reviewing Anna\'s changes to the\npaper, and then she asked Sam about the reference we needed to check on. He\njust laughed and rifled through his notes. He explained that it was a\nplaceholder he threw in while he was writing, and he never got around to\nreplacing it with the correct one. I got the feeling that he left it in\nthere just to see if anyone would notice it at all. </p>\n\n<p> Kim arrived just as Anna finished looking at the changes. Kim asked us\nto take another look, but Anna told her to review it after the meeting,\ninstead. Although it didn\'t seem like anyone made very many changes, the\npresentation felt much better this week. Whatever it was, after two\npractice runs, we sounded smooth. While it\'s still running too long, we\nagreed that everyone will probably speak faster in class, and the\ninstructor probably won\'t be a stickler on time. </p>\n\n<p> We decided to end early this week, but before we split up, Anna\nwouldn\'t be Anna if she didn\'t remind everyone to wear formal business\nclothes to the presentation next week. </p>\n\n<p> I practiced once this week with a friend, but mostly I focused on my\nother coursework. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(83,6,13,'<p> We were the only group dressed professionally, and I think that\nprobably earned us some points. Kim managed to speak loudly and clearly\nenough that the instructor only had to ask her to speak up once. I stumbled\non my first few sentences, but then I relaxed and I think it went well. The\nbiggest surprise, though was Sam, he added an analogy at the end that not\nonly tied everything together, but also made everyone laugh. It was\nunexpected and risky, but it worked out well. There weren\'t a lot of\nquestions for us and naturally, Anna stepped forward to answer them. </p>\n\n<p> I think we can expect positive feedback and good grades. </p>\n\n<p> Since the paper is mostly finished, we all decided to cancel this\nweek\'s meeting and instead each give the paper one last review for the\nfollowing week. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(84,6,14,'<p> At the final meeting, we compared notes and found that we had no major\nchanges to make. Kim took all four versions and said she\'d make what few\nchanges there were and submit it at the end of the week. Anna asked her to\nsend it to her first, because I guess she doesn\'t completely trust her. Kim\nwas annoyed by this, but said she\'d do it. </p>\n\n<p> As far as I know, the paper went in on time as planned and I imagine\nwe\'ll get a good grade. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(85,7,1,'<p> In group time the first week, we began by setting up weekly team\nmeetings. I think we got lucky because Anna is already a sophomore while\nthe rest of us are freshmen. It seems like she knows what she\'s doing. </p>\n\n<p> The project is fairly open-ended, so we brainstormed topic ideas for\nthe rest of the time. Kim was quiet, but Jose, Anna and I all volunteered a\nfew topics. Two of mine were meant to be jokes, but no one seemed to\nunderstand them. The third was serious, but no one seemed to understand it,\neither, which is frustrating. Everyone loved it when Anna suggested the\nsame thing a little later. She had a bunch of good ideas and I don\'t think\nshe was stealing my idea or anything, I just said it wrong. Anyway,\neveryone thinks Anna is brilliant, so we focused on her suggestions. </p>\n\n<p> Before the meeting ended, we narrowed it down to five ideas. Anna told\nus we should each look for resources on one topic and then report back next\nweek. She spoke up for the topic she explained more clearly than me, and I\nquickly spoke up for another one I liked. After a few moments, Jose took\nanother. Kim said she\'d take the last two, but I guess Anna\'s concerned, so\nshe offered to take one herself. However, Kim insisted that she could\nhandle it, and eventually Anna split it with her. </p>\n\n<p> I spent about 30 minutes researching my topic this week and I think\nwe\'re off to a good start, so I feel pretty good. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(86,7,2,'<p> We began the meeting by going over the materials we collected over the\nlast week. Anna was clearly disappointed, but I didn\'t understand what the\nproblem was. This was only the second week and we were just trying to\nnarrow down the topic.  </p>\n\n<p> Anna laughed and started asking questions about the materials I\'d\nfound. They were very in-depth questions, and it\'s not as though we needed\nto know all of that now. However, she argued that we would need to know the\nanswers to evaluate the topics effectively, and she could answer those\nquestions for hers. I didn\'t agree with her, but I didn\'t want to fight\nabout it, so I said I did. </p>\n\n<p> Jose suggested that, in the interest of time, maybe we just go with the\ntopic she worked on, but Anna insisted told us that we had to redo our\nwork. She pointed out that we all need to be able to do the research\n&mdash; and maybe one of the other topics would be better for our group.\nShe\'s going to be a pain in the neck. We all agreed with her and said we\'d\nredo our work. </p>\n\n<p> The next night, I spent about another hour and a half on finding and\nskimming through new materials. Most of my materials were still fine, but I\nread more of them and now I can defend them. I found some extras, as well.\nI\'m really liking this topic and I\'m becoming convinced that this is the\none to go with. There\'s lots of material on it and it\'s just plain\ninteresting! </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(87,7,3,'<p> During this week\'s meeting, we sorted through the materials we\'ve got\nto evaluate to decide on a topic and we have much better materials this\nweek. I really like the topic I researched, but Anna is pushing for the one\nshe took initially. I tried to explain how we could touch on so many\ndifferent areas with mine, but that\'s exactly why Anna doesn\'t like it\n&mdash; she thinks that we wouldn\'t be able to focus ourselves. Kim seemed\nto understand what I\'m saying and agreed with me, but Jose supported Anna.\nWe went back and forth for most of the meeting and really it was a pretty\ngood discussion, but in the end, Anna won Kim over.  </p>\n\n<p> After the topic was settled, there wasn\'t much time left, but Anna\njumped right into drafting an outline, and she wouldn\'t let anyone else\nhelp. I suggested something I\'ve used before to try to make the paper\neasier to read, but Anna didn\'t like it and wanted to go with a more\nconventional approach. She figured that we just didn\'t know how to write a\npaper, so she spent about ten minutes explaining to us what an outline is\nand why we use it. No one made any comments on the outline after that. </p>\n\n<p> Jose suggested that we each take a few of our sources, search for more\non our own and then write up summaries for next week so we\'re ready for the\nfirst assignment. Anna agreed and started assigning them out. However, she\ndid it like she\'d decided that she was the only one with a brain and she\ndidn\'t trust any of the rest of us to get anything right, so she took all\nthe materials that were actually interesting and offered any depth &mdash;\nstrange, since she made such a big deal out of making sure we were all\n\"learning\" during the initial research. I wasn\'t the only one upset &mdash;\nKim spoke up first to request a specific topic and then Jose and I joined\nin. This clearly irritated Anna, but eventually she gave in and we each\nclaimed the ones we most wanted. She still couldn\'t let go, though, and\nwhen Jose claimed one that she wanted, she told him she\'d \"help\" him with\nit because it was very complex. He wasn\'t happy about that. </p>\n\n<p> I spent about an hour reading, searching and getting started on the\nsummaries one night this week, but figured I\'d do the rest next week. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(88,7,4,'<p> I made a mistake. I forgot to finish my summaries until about half an\nhour before our meeting. Not only was I late to the meeting as a result,\nbut I didn\'t have time to finish, either. Jose was just arriving when I\nwalked in and Anna got upset with us both for being late, but then she was\neven more upset when we shared our work. Anna wasn\'t sure who to be more\nupset with: me or Jose. Kim\'s work was OK, but Jose\'s were a bit on the\nbrief side. However, after she got through my first three summaries, there\nwas no hiding the fact that I\'d forgot two of them. I apologized and\nexplained that I\'d had a lot to do for my other classes. Both Kim and Jose\nunderstood, but Anna just couldn\'t let it go. </p>\n\n<p> Then she showed us her pieces which went way beyond \"summary\" and\nlooked like completed portions to be added directly into the paper. She\nasked why we didn\'t all include pointers to where the summaries should\nultimately fit in the paper like she did. Kim argued with her on this. She\nasked why Anna\'s written so much already when we\'re so early in the\nproject. After all, we only have the preliminary structure done and this is\nonly the fourth week of class. Anna got upset and asked how anyone would be\nable to put anything together using materials as thin as this.  </p>\n\n<p> That\'s when I spoke up. I tried to lighten the mood by pointing out\nthat mine wasn\'t just thin, it was nonexistent, and everyone laughed. It\nwasn\'t that funny, really, but I think we needed it. I also volunteered to\nassemble next week\'s assignment, since I still had pieces to do. Finally, I\ntried to move us on by suggesting that we take a look at what we\'d got and\nwhether or not the outline we put together still fits. The truth is I was\njust trying to get Anna to move beyond the poor quality of everyone\'s work.\n</p>\n\n<p> The discussion was OK, and Kim offered some really good ideas about how\nto sequence things. I thought they were good ideas, but we really didn\'t\nhave time to put them together. There was just no way I could get all of\nthat done in the next week. However, Anna really liked the idea and started\ngetting upset with me for not having time. I know I screwed up this week,\nbut does she want me to mess up again next week? Fortunately, Kim stepped\nup and offered to make the changes if I could get the rest of it done by\nthe middle of the week. I accepted this and we decided to figure out the\ndetails after the meeting. </p>\n\n<p> Naturally, before we left, Anna had to remind everyone that we need to\nkeep working on our summaries because we\'ve got the draft due in another\nfour weeks. </p>\n\n<p> After the meeting, Kim asked me to let her know when I was done with my\npart and when I did, she suggested that we meet at the library the next\nevening. We got to talking about the project and other classes. Although\nshe\'s quiet, she seems to notice everything. She even pointed out that she\nliked how my topic idea was turning out &mdash; she noticed that I was\nreally the first one to suggest our topic! </p>\n\n<p> Anyway, we both had time, so we sat down to work together on the\nrevisions and it was so easy to work with her. At one point, though, she\nblocked what I thought was a good idea, asking if I thought I could\nconvince Anna to go along with it. It\'s annoying, but she was right. We\nfinished the writing much quicker than I\'d expected &mdash; maybe an hour\nor so.  </p>\n\n<p> All told, I think I spent about two and a half hours on this outside of\nour weekly meeting. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(89,7,5,'<p> Kim had our assignment ready and turned it in during class. The\ninstructor allowed some time at the end of class this week, so we all\nreviewed what she and I put together. Anna was pleased with what we\'d done,\nso the meeting went pretty smoothly. </p>\n\n<p> Kim and I arrived a couple of minutes early for our meeting and we were\njoking, but then Anna showed up and we got down to business. After working\nwith Kim last week, I really see how the paper is taking shape. I suggested\nthat maybe we further build out our summaries into the paper. Anna just\nlooked at me like I was dumb and said that we had to break it up into\nquarters because each of the summaries would be represented in multiple\nplaces in our outline. I thought we weren\'t quite ready to start on the\nactual paper yet, but I couldn\'t explain that and she\'d already decided,\nanyway.  </p>\n\n<p> That\'s when Jose showed up and said we should take the week off! He\nargued that we had to wait for the instructor\'s feedback. Kim and I\njokingly encouraged him, but I don\'t think he thought it was a joke. I\'m\npretty sure Anna didn\'t, either, because she got very upset and spent the\nnext ten minutes explaining that the instructor probably would barely look\nat our papers, much less provide meaningful feedback. She pointed out that\nit\'d probably be weeks before we got anything back and by that point we\'d\nhave no time left to get our draft together. She kept on about how we\ncouldn\'t stop now because we\'d want to take a break later during midterms.\nShe was right about all of it, of course, but Jose was really disappointed.\nHe said he\'d be late next week either way because of practice. </p>\n\n<p> We split the paper up into quarters and each took a section to write up\nfor next week. </p>\n\n<p> My section was supported by some of my own summaries, as well as a lot\nof Anna\'s work and some of Kim\'s. I have to admit that Anna\'s a good\nwriter. She really made it easy for me to put things together with her\nnotes and pointers. She provided a nearly-complete set of instructions for\nme to follow in building out the paper. It\'s like she\'s known exactly how\nthis paper would look from the very beginning.  </p>\n\n<p> I had some ideas for diagrams that would help to make some things\nclearer, so I went ahead and drafted them. I spent a lot of time on this\nbecause I sort of get absorbed in trying to make my art perfect. As a\nresult, I probably spent about two and a half hours on everything together.\n</p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(90,7,6,'<p> Kim and I arrived at around the same time for the meeting this week.\nAnna got there a few minutes later and we reviewed our work. Kim had done\nwell with her piece and we spent a long time talking about some of her\nobservations and what they could mean in other parts of the paper. My\nwriting is nowhere near as good, but Anna was distracted by the images I\nincluded. I have to admit that I\'m pretty proud of them. We spent some time\nlooking through Anna\'s and Kim\'s pieces, trying to come up with visuals\nthere, too. Kim said that she\'d add a chart using some of her data, but\nAnna told me to do it.  </p>\n\n<p> At first I was happy because I had fun with them, but Kim responded\nthat she hadn\'t done a lot of that sort of thing before and wanted to try\nit even if she then handed it to me to clean up. I thought it was a good\nidea, but Anna seemed not to hear it. She said I should do it because I\'m\ngood at it &mdash; but it didn\'t feel like a compliment. It feels like\nthat\'s all I\'m good for. I thought it should all be shared around, anyway?\nHow else is everyone going to learn? </p>\n\n<p> Then Jose arrived and he reminded us that his team was preparing for\ntheir upcoming game and he\'d be late for the next couple of weeks as a\nresult. I think he\'s here on a sports scholarship. Anyway, he was very\nupset when we looked at Anna\'s changes to his work. I didn\'t see what he\ngave her, so I\'m not sure, but he said she ripped out or rewrote most of it\nand I believe it. She\'s always telling everyone what to do (he\'s right) and\nshe clearly doesn\'t think much of him or his work. Anna said she was just\ntrying to make sure the paper looks and feels consistent.  </p>\n\n<p> This time, Jose wasn\'t backing down, though, and they probably would\nhave argued for the rest of the meeting, but Kim spoke up. She commented\nthat even though the paper is much different from what she thought it would\nbe, it was turning out well. Jose asked us to at least consider including\nthe perspective that Anna ripped out, but Anna tore the idea apart as too\nconventional and obvious. She said that we would wind up with just another\nboring paper that anyone could write and that we\'d have to spend a huge\namount of time rewriting the paper that way &mdash; she asked if Jose\nwanted to do a complete rewrite for next week. At this, Jose gave up and we\ndecided to keep the paper as she\'d written it. We didn\'t bother looking at\nJose\'s work for this week because he would have to make some major changes\nto it, anyway. </p>\n\n<p> I enjoyed working on images again this week and they all look even\nbetter now. The team offered good suggestions, but also I had some more\nideas. I really like doing this kind of work. With that and the substantial\ncleanup I needed to do to the written portion, I probably spent almost\nanother hour and a half this week. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(91,7,7,'<p> Jose was a little late again when he arrived this week, but this time\nhe was visibly limping. I\'m not sure if Anna thought he was faking it or\nwhat, but she asked him to \"please try to be on time in the future\" in an\noverly polite tone. This set Jose off and he sniped back that it didn\'t\nmatter since she was obviously writing the whole thing herself however she\nwanted. Kim spoke up to calm them both down. She even made everyone,\nincluding Anna, confirm (out loud) that we are all equals, working on this\nproject together. Of course, Anna had to remind us that she had more\nexperience than anyone else, but Kim pushed us on anyway. </p>\n\n<p> Anna was clearly disappointed with my work this week, but it wasn\'t too\nbad and the images were good. We decided to swap papers with each other to\nproofread them; and she took mine. Everyone was OK with this, but Kim\nwanted to get started on assembling the paper and volunteered to do that,\nas well. At first, Anna said no because it would be tough to match the\nindividual pieces with the assembled document so that we could make the\nchanges, but Kim said she\'d take care of it. </p>\n\n<p> As we were getting ready to go, Jose asked if anyone would mind\nchanging our meeting time for next week &mdash; he has a study session to\nprepare for one of his midterms. I thought that was a great idea I because\nalso have midterms coming &mdash; I suggested that we cancel it, since the\npaper is in pretty good shape. Naturally, Anna said no. She said we should\nstill meet, but that we can do it briefly, immediately after class to share\nour changes. </p>\n\n<p> I took Anna\'s piece and so there wasn\'t much to clean up (she\'d\nprobably change it all back, even if I had). I was able to read through it\nquickly. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(92,7,8,'<p> During this week\'s class, some of the discussion touched on the topic\nof our paper and it felt good to be so well prepared. There was some good\ndebate about the competing points of view and Jose spoke up a lot. I made a\nfew comments, but, as usual, they didn\'t quite come out right. I could see\nthat no one seemed to quite understand what I was saying. I\'m not good at\nthat sort of thing. </p>\n\n<p> After class, we met briefly as we decided last week. Kim did a great\njob on the document again; she made a lot of changes on my portion. Jose\npointed out a problem in with part of my piece, but I didn\'t get it until\nAnna got impatient and told me I\'d forgot one of the diagrams. I had to\nexplain that I\'d actually spent about half an hour on it and couldn\'t make\nit work. I\'m not actually trained as an illustrator or an artist or\nanything. They were all disappointed, but naturally, Anna just told me to\ntry harder. I said I\'d try again, but honestly, I don\'t what more to do.\n</p>\n\n<p> I asked about our in-class discussion and how we wanted to address that\nin the paper. After all, it was clear that there were multiple points of\nview and we should at least acknowledge them. Anna said those approaches\nwere boring and that she wasn\'t going to throw away a good paper &mdash;\npointing out that our existing approach showed that we are both creative\nand thoughtful.  </p>\n\n<p> I agreed with Anna in general, but I pointed out that we need to at\nleast acknowledge the in-class conversation. Anna gave in a little bit and\nallowed a brief section, but didn\'t want Jose to write it because she was\nnervous that his work wasn\'t very good and we wouldn\'t have time to clean\nit up by the time the draft is due next week. Jose was offended by this,\nbut Kim told Anna she\'d review it if Jose could get it to her quickly and\nAnna was OK with that. So Kim asked him to get it to her by mid-week. Jose\naccepted this. </p>\n\n<p> I spent another half an hour on trying to rework the diagram, but I\'m\nsure it\'s not what Anna wants. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(93,7,9,'<p> Kim had our paper ready to be submitted when she arrived in class, and\nshe also brought a copy for each of us to review. I had to leave right\nafter class, but I took a look that evening and it looked good to me. </p>\n\n<p> Later in the week, Jose and I got to talking after a class we share,\nand he told me that this week\'s meeting would start about ten minutes late.\nUnfortunately, it seems that no one mentioned this to Anna. She was getting\nready to leave when we arrived. She\'s usually very serious, but this week\nshe seemed to be even more uptight and stressed &mdash; she was probably\nreally angry. </p>\n\n<p> Anna had a long list of changes to the paper and some of them were\npretty big, but no one said anything &mdash; I know I felt guilty and I\nimagine everyone else did, too. She told us all to take another look at the\nwhole paper and read it straight through for next week to make sure we\nhaven\'t missed anything and no one argued. </p>\n\n<p> Our next task was to begin preparing for the presentation. Anna drafted\na PowerPoint for us to use and then assigned slides to each of us. At one\npoint, she asked if anyone was upset with their piece and I think everyone\nwas afraid to make her mad, so she kept going. Then she told us we needed\nto write up our talking points for each of our slides and to practice a few\ntimes in front of a mirror for next week &mdash; like we\'re all children\nwho have never presented anything before. </p>\n\n<p> I think the images do a pretty good job of communicating the main\nideas, so I used some of them as the basis for my slides. Since am pretty\ncomfortable with my topic, I didn\'t bother with any notes. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(94,7,10,'<p> Wow! Maybe I should have practiced a bit? While everyone liked my use\nof images, they basically said that I focused on them and didn\'t explain\nthe topics well. No one else did a great job, either &mdash; including\nAnna. She had a bunch of things to fix and Jose seemed to be almost happy\nto be able to criticize her for a change. She didn\'t like that at all and\nasked if he was trying to make the presentation better or make her feel\nbad. He shut up after that.  </p>\n\n<p> Even after three practice runs together, everyone took home a list of\nthings to work on to fix their presentations. Kim\'s was probably the best\nof all, but she spoke very quietly to her notes in her own hands, rather\nthan to the audience. </p>\n\n<p> I actually spent an hour and a half reworking my part &mdash; and then\nabout half an hour more practicing it (in front of a mirror). </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(95,7,11,'<p> In class, the instructor returned the drafts to the groups and our team\nmet briefly during class to review it. The instructor left only six\ncomments in our paper, and most of them were pretty small, but one\ncomplimented my images. The only other one that seemed significant asked us\nto further develop a section. </p>\n\n<p> Our meeting opened with another fight between Anna and Jose. Jose\ninterpreted one of the comments to mean that he should write more in the\nsection about alternative perspectives, and Anna disagreed. Anna talked\ndown to him a lot and told him why he couldn\'t be right, and that just kept\nmaking him angrier, but it was clear that he couldn\'t win. I didn\'t want\nhim to win either, because it would mean rewriting the whole paper. Jose\nfinally gave up, and Anna said she\'d make the changes the instructor\nrequested this week. </p>\n\n<p> The presentations were better this week, but we still need more\npractice and rework. Anna had improved upon her presentation significantly\nsince last week. I don\'t know how she did it, but it sounded perfect.  </p>\n\n<p> We also talked about how we should dress for the presentation. Kim had\na cool costume idea that was in line with our topic that Jose and I both\nliked, but Anna said it was unprofessional. She said we had to wear\nbusiness attire so we would look professional. When we ended the meeting,\nAnna reminded everyone that our presentation is in just two weeks. </p>\n\n<p> I had a few small changes to make and did a few practice runs this\nweek, but probably not more than 45 minutes. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(96,7,12,'<p> We had to start without Kim this week because she left a message with\nJose that she\'d be late due to a meeting for another class. We spent some\ntime reviewing Anna\'s changes to the paper, and then she asked me about an\nincorrect reference that the instructor found. I\'ve got to be honest, I am\namazed that the instructor noticed it. I explained that it was just a\nplaceholder I threw in while he was writing.  </p>\n\n<p> Kim arrived just as Anna finished looking at the changes. Kim asked us\nto take another look, but Anna told her to look at it after the meeting,\ninstead. Although it didn\'t seem like anyone made many changes, the\npresentation felt much better this week. After two practice runs, we\nsounded smooth. While it\'s still running too long, we agreed that everyone\nwill probably speak faster in class and the instructor probably won\'t be a\nstickler on time. </p>\n\n<p> We decided we could finish early this week, but before we ended, Anna\nreminded everyone to wear formal business clothes to the presentation next\nweek. </p>\n\n<p> I practiced once this week with a friend, but mostly I focused on my\nother coursework. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(97,7,13,'<p> We were the only group where everyone looked professional, and I think\nthat probably earned us some points. Everyone spoke loudly and clearly\nenough that the instructor only had to ask Kim to speak up once. Jose\nstumbled on his first few sentences, but then he relaxed and I think it\ncame out well, overall. I went last and I added an analogy at the end that\nI think tied things together nicely, and it made everyone laugh. There\nweren\'t a lot of questions for us and naturally, Anna stepped forward to\nanswer them. </p>\n\n<p> I think we can expect positive feedback and good grades. </p>\n\n<p> Since the paper is mostly finished, we all decided to cancel this\nweek\'s meeting and instead each give the paper one last review for next\nweek. Anna told us to read through the paper one more time to make sure we\nhad everything, but we\'ve all got finals to prepare for. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(98,7,14,'<p> At the final meeting, we compared notes and found that we had no major\nchanges to make. Kim took all four versions and said she\'d make what few\nchanges there were and submit it at the end of the week. Anna asked her to\nsend it to her first, because I guess she doesn\'t completely trust her. Kim\nwas annoyed by this, but said she\'d do it. </p>\n\n<p> As far as I know, the paper went in on time as planned and I imagine\nwe\'ll get a good grade. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(99,8,1,'<p> In group time the first week, we began by setting up weekly team\nmeetings. Anna\'s a sophomore and I think her experience is valuable, but\nshe\'s also very pushy. Jose seems like he\'ll work hard, but I especially\nlike Sam. The way he speaks is a bit strange because he uses a lot of big\nwords. It doesn\'t seem like he\'s showing off or anything, he just thinks a\nlot about the words he uses. The trouble is that he often doesn\'t seem to\nuse them quite right. </p>\n\n<p> The project is fairly open-ended, so we brainstormed topic ideas for\nthe rest of the time. We all volunteered a few topics, but I didn\'t have\nany ideas, so I kept my mouth shut. I\'m pretty sure that one of Sam\'s\nsuggestions was a joke and one of them I couldn\'t understand at all, but\none of them was a really good idea. No one seemed to understand any of\nthem, and I didn\'t want to say anything. Later, I was surprised when Anna\nsuggested the same thing as though it was brand new. I don\'t think she was\ntrying to steal credit or anything, I just think she didn\'t understand him.\nAnyway, it\'s a good idea. </p>\n\n<p> Before the meeting ended, we narrowed it down to five ideas. Anna told\nus we should each look for resources on one topic and then report back next\nweek. She spoke up for a topic she\'d already worked on in another class and\nSam quickly spoke up for another. Jose eventually took another one and I\nsaid I\'d take the two that were left. Anna didn\'t like that and said she\'d\ntake one of them, but I put my foot down &mdash; she\'s not going to walk\nall over me. Ultimately, we compromised and split it. </p>\n\n<p> I spent about an hour researching my topic this week and I think we\'re\noff to a good start, so I feel pretty good. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(100,8,2,'<p> We began the meeting by going over the materials we\'d collected over\nthe last week. Anna was clearly disappointed, and she didn\'t hide it well.\nShe spent most of the meeting talking about how she did her research and\nit\'s a big help, but makes me feel like I\'m a child. I\'m going to have to\ndo a lot of it again. Sam asked some questions indicating that he didn\'t\nsee why his materials are mostly unusable, and Anna just laughed at him.\nHe\'s braver than I am, though, because he asked again. Anna responded with\na few detailed questions that Sam couldn\'t answer. She then went to her own\nnotes to answer the same questions. It seemed cruel, and I\'m glad it wasn\'t\nme because I couldn\'t have answered those same questions. Sure, they are\nimportant, but we\'re new to this and she\'s already worked on this topic\nbefore. </p>\n\n<p> Jose suggested that, in the interest of time, maybe we just go with the\ntopic she worked on, but Anna insisted that we had to redo our work. She\npointed out that we all need to be able to do the research She was right\n&mdash; even if it\'s a pain in the neck. I just wish she was nicer about\nit. Sam and Jose also agreed with it. </p>\n\n<p> After the meeting, I pulled Anna aside and told her that she was out of\nline in being so rude to Sam. It was uncalled for and I just couldn\'t stand\nby and let her do it. She pled innocent, though. She said that she honestly\nthought he was joking the first time, and she didn\'t mean to insult him.\nShe said it wasn\'t intentional, but that she\'ll try to be more sensitive in\nthe future. </p>\n\n<p> The next night, I spent another hour finding and skimming through new\nmaterials. I was actually still able to use most of my original materials.\nI found a bunch of additional ones, too. I don\'t love this topic, though,\nso it feels like a waste of time. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(101,8,3,'<p> During our meeting, we sorted through the materials we had to decide on\na topic. There was some conflict between Sam and Anna &mdash; Sam pushed\nfor the topic he\'d researched, while Anna made up her mind that we\'d go\nwith hers. I didn\'t want to get involved, but as Sam explained it, it did\nsound like more fun. It had a lot of potential to let us touch on lots of\ndifferent areas &mdash; but that\'s exactly why Anna didn\'t like it &mdash;\nshe thought we wouldn\'t be able to focus ourselves. Jose is supporting Anna\n&mdash; I think he\'s scared of her. We went back and forth for most of the\nmeeting and it was a pretty good discussion, but in the end, we went with\nAnna\'s topic. It\'s a pretty good one, and it\'s also clear that she will not\ngive up. </p>\n\n<p> After the topic was settled, there wasn\'t much time left, but Anna\njumped right into drafting an outline and she wouldn\'t let anyone else\nhelp. Sam suggested something to make the paper easier to read, but Anna\ndidn\'t like it and wanted to go with a more conventional approach. She\nfigured that we just didn\'t know how to write a paper, so she spent about\nten minutes explaining to us what an outline is and why we use it. No one\nmade any comments on the outline after that. </p>\n\n<p> Jose suggested that we each take a few of our sources, search for more\non our own and then write up summaries for next week, so we\'re ready for\nthe first assignment. Anna agreed and started assigning them out. However,\nshe acted like she was the only one with a brain and didn\'t trust any of\nthe rest of us to get anything right She took all the materials that were\nactually interesting and offered any depth &mdash; strange since she made\nsuch a big deal out of making sure we were all \"learning\" during the\ninitial research. This was not OK, so I told her which topics I\'d take. Sam\nand Jose backed me up by making their own preferences known.  </p>\n\n<p> We spent time negotiating who took what, but it was much better than\nher assignments. This clearly irritated Anna, but with everyone\ndisagreeing, there wasn\'t much she could do. She couldn\'t let go entirely,\nthough, and when Jose claimed one that she wanted, she told him she\'d\n\"help\" him with it because it was very complex &mdash; does she not see how\ninsulting that is? </p>\n\n<p> I spent about an hour and a half on reading, searching and getting\nwriting my summaries this week. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(102,8,4,'<p> Jose and Sam were a bit late to the meeting. Anna was visibly upset,\nbut she didn\'t say anything about it. Sam explained that he forgot to\nfinish two of the five parts he was working on, and I thought she was going\nto explode. I don\'t see why this was such a big deal since we\'ve still got\ntime before even the first assignment. After we took a look at everyone\'s\nwork, she couldn\'t contain herself any longer and asked why no one had done\ntheir work. She compared what we brought to what she brought. She\'s got\nwhat looks like completed portions to be added directly into the paper.\n</p>\n\n<p> I told her to give it a rest &mdash; we still have time and no one was\nslacking off, but she got upset and asked how I would be able to put\nanything together using materials as thin as this. That\'s when Sam spoke\nup. He made a joke about how poorly he\'d done with his part &mdash; his\nwasn\'t just thin, it was nonexistent. It wasn\'t actually funny, but\neveryone laughed, and he volunteered to assemble next week\'s assignment\nsince he still has pieces to do. He also suggested that we take a look at\nwhat we\'ve got and whether the outline we put together still fits. It was\nreally either that or fight for an hour, so everyone is all for it. </p>\n\n<p> I had some new ideas about how to sequence the paper Anna particularly\nliked one idea, but Sam pointed out that he wouldn\'t have time to do it\nall, and she started getting upset again. I offered to make the changes if\nSam could get the rest of it done by the middle of the week. Sam gladly\naccepted this and we decided to coordinate later.  </p>\n\n<p> Naturally, before we left, Anna had to remind everyone that we need to\nkeep working on our summaries because we\'ve got the draft due in another\nfour weeks. </p>\n\n<p> After the meeting, I asked Sam to let me know when he was done with his\npart. When he was done, I suggested that we meet at the library the next\nevening. We got to talking about the project and I pointed out that I knew\nour topic was his idea first. I think he really appreciated that. We worked\ntogether on the revisions and it went smoothly, with me doing most of the\nwriting. There was only one time we disagreed and that was just because I\ndidn\'t think we could make Anna go along with Sam\'s idea. It\'s just not\nworth fighting with her. We finished the writing quicker than I expected\n&mdash; maybe an hour or so.  </p>\n\n<p> The day after I met with Sam, I cleaned everything up and put it all\ntogether for submission. All told, I think I spent about two hours on this\noutside of our weekly meeting. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(103,8,5,'<p> I turned in our assignment in class and the instructor allowed us some\ngroup time at the end of class, so we all reviewed what Sam and I put\ntogether. Anna was particularly pleased with what we\'d done, so the meeting\nwent well. </p>\n\n<p> Sam and I arrived a couple of minutes early for our meeting and we were\njoking a bit, but then Anna showed up and we got down to business. Sam was\nreally getting excited about the paper, and he suggested that we further\nbuild out our summaries into the paper. Anna looked at him like he was dumb\nand told him (like it was obvious) that each of the summaries would fit in\nmultiple places in our outline. He looked confused &mdash; like he wasn\'t\nquite sure what he was trying to say, but that\'s when Jose showed up and\njoked that maybe we should take the week off! He argued that we had to wait\nfor the instructor\'s feedback, anyway. I thought it was funny, so I\nencouraged him, but then I realized he didn\'t think it was a joke. Of\ncourse we would have to keep working if we wanted to get everything done in\ntime.  </p>\n\n<p> Anna took both of us seriously and got upset. She spent the next ten\nminutes explaining that the instructor probably would barely look at our\npapers, much less provide meaningful feedback. She pointed out that it\'d\nprobably be weeks before we got anything back at all and by that point we\'d\nhave no time left to get our draft together. She also made the point that\nif we kept going, we might be in a good place to break later during\nmidterms. Jose was disappointed and said he\'d be late next week either way\nbecause of practice. </p>\n\n<p> We split the paper into quarters, and we each took a section to write\nup for next week. </p>\n\n<p> My section was supported by some of my own summaries, as well as a lot\nof Anna\'s work and I have to admit that Anna\'s a good writer; she made it\neasy for me to put things together with her notes and pointers. It\'s like\nshe\'s known exactly how this paper would look from the very beginning. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(104,8,6,'<p> Again, Sam and I arrived at around the same time for the meeting this\nweek. Anna arrived a few minutes later, and we reviewed our work. We spent\na long time talking about some of my observations and what they could mean\nin other parts of the paper. Anna was distracted from Sam\'s poor writing\nskills by his impressive artistry. This pushed us to spend some time\nlooking through Anna\'s and my pieces to try to come up with good visuals\nthere, too. I volunteered to add a chart of some of my data, but Anna said\nno, because she wanted Sam to do it. I haven\'t really done that kind of\nwork, and I wanted to give it a shot, but Anna still wouldn\'t let me. She\nwants me to do the proofreading because she thinks I\'m really good at it\n(even if it is boring), and she doesn\'t want me to be overworked. It\'s not\nworth fighting about it. There\'ll be other projects... </p>\n\n<p> When Jose arrived, he reminded us that his team is preparing for their\nupcoming game and he\'ll be late for the next couple of weeks. He was very\nupset when we looked at Anna\'s work because I guess she changed a lot of\nwhat he wrote. I didn\'t see what he gave her, so I\'m not sure, but he said\nthat he feels like Anna\'s ignoring or ripping out the work of everyone who\ndoesn\'t do what she wants (true). He pointed out that she\'s always telling\neveryone what to do (he\'s right). Anna said she was just trying to make\nsure the paper feels unified in its vision.  </p>\n\n<p> They probably would have argued for the rest of the meeting, but I\nfigure that since Anna\'s part of our team, we\'re going to have to work with\nher. She\'s got good ideas, so I pointed out that even though the paper is\nmuch different from what I\'d thought it would be, it was turning out well.\nJose asked us to at least consider including the perspective that Anna\nripped out. Anna said no, because we would end up with just another boring\npaper that anyone could write; we\'d have to spend a huge amount of time\nrewriting the paper that way. She asked if Jose wanted to do a complete\nrewrite for next week. At this, Jose gave up and we decided to keep the\npaper as she\'d written it. We didn\'t look at Jose\'s work because he would\nhave to make some major changes to it. </p>\n\n<p> I spent about half an hour cleaning up my part a little more, but that\nwas about all for this week. </p>\n','2019-09-23 11:40:16','2019-09-23 11:40:16',NULL),
(105,8,7,'<p> Jose was late again when he arrived this week, but this time he was\nvisibly limping. I\'m not sure if Anna thought he was faking it, but she\nrudely told him to \"please try to be on time in the future.\" Naturally,\nthis set Jose off, and he shot back that it didn\'t matter since she was\nbasically writing the whole thing herself. Seeing that this was going\nnowhere, I tried to calm everyone down. I reminded everyone that we\'re all\nequals working on this project together, and I even made Jose and Anna both\nsay so out loud. Of course, that won\'t make any difference to Anna, but it\nmade Jose feel better. </p>\n\n<p> After reviewing each other\'s work, we decided to swap papers to\nproofread them. I took Jose\'s, but I also wanted to get started on\nassembling the paper, so I also volunteered to do that. Anna said no at\nfirst, because she thought I couldn\'t handle matching up everyone\'s\nproofreads with the assembled paper, but I promised that I\'d reassemble it\nnext week if I couldn\'t match things up. I felt uncomfortable that we still\nhadn\'t seen all the pieces together. </p>\n\n<p> As we were getting ready to leave, Jose asked if anyone would mind\nchanging our meeting time for next week &mdash; he had a study session to\nprepare for one of his midterms. I also have midterms to study for and Sam\nsuggested that we cancel the meeting, since the paper is in pretty good\nshape. Naturally, Anna said no. She said we should still meet, but that we\ncould do it briefly, immediately after class to share our changes. </p>\n\n<p> I proofread everyone\'s papers as I was putting them together into the\nfinal paper this week. It took me about two hours, and I had to move a\nbunch of things around, but it made me feel better to know that we were\nalmost ready to turn this thing in. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(106,8,8,'<p> During this week\'s class some of the discussion touched on the topic of\nour paper; both Jose and Sam spoke up during the discussion. There was some\ngood debate about the competing points of view. Sam\'s comments made sense\nto me because I know him at this point, but he doesn\'t explain himself\nwell, and I\'m not sure it made sense to anyone else. </p>\n\n<p> After class, we met briefly as we decided last week. Everyone was\nexcited to see the full paper. Jose and Anna pointed out a problem with one\nof the images and asked Sam to fix it, but he said he couldn\'t. Anna was\ndisappointed, but Sam said he\'d already tried to fix it and it always came\nout worse instead of better. Finally he said he\'d give it another try, and\nthat was enough to let us move on. </p>\n\n<p> Sam asked about our in-class discussion and how we wanted to address\nthat in the paper. It was clear that there were multiple points of view,\nand we should at least acknowledge them. Anna listened for a bit but soon\ngot tired of it and told Jose that would make the paper boring. Compared\nwith what we\'ve got, she\'s kind of right.  </p>\n\n<p> Sam pointed out that we need to at least acknowledge the in-class\nconversation, and Jose jumped on this, volunteering to add a section about\nit. Anna agreed, but didn\'t want Jose to write it because I guess she\ndoesn\'t trust him to make it look good enough to turn in next week. I said\nI\'d review it when Jose got it to me and then integrate it. Anna was OK\nwith that. I asked Jose to get it to me by mid-week. Anna caught me on the\nway out and told me to make sure to keep the new section brief. </p>\n\n<p> Jose got the new section to me late in the week, but there was still\nplenty of time for me to put everything together for class. I probably\nspent about an hour on it. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(107,8,9,'<p> In addition to the copy to be turned in, I brought copies of our draft\nfor each of us to review. I couldn\'t stay after class to discuss it,\nthough, and I guess no one met, anyway. This was going to be a busy week\nfor me with an unexpected project dropped on me in another class.  </p>\n\n<p> Later in the week, Jose thanked me during the week for putting the\npaper together, and it really made my day. I told him that I\'d be a little\nlate to the meeting because of this other project I had to work on; he said\nhe\'d let the others know. When I arrived, I learned that Jose told Sam but\n\"forgot\" to tell Anna. She sat in the meeting alone with no idea what was\ngoing on. That was a pretty awful thing to do and, although she tried to\nhide it, Anna was definitely hurt. I felt terrible. </p>\n\n<p> Anna had a long list of changes to the paper and some of them were\npretty big, but no one said anything &mdash; I know I felt guilty. I\nimagine everyone else was, too. She asked us to take another look at the\nwhole paper, and read it straight through for next week to make sure we\nhaven\'t missed anything. </p>\n\n<p> Our next task was to prepare for the presentation. Anna drafted a\nPowerPoint for us to use and then assigned slides to each of us. At one\npoint, she asked if anyone was upset with their piece and no one was, so\nshe kept going. Then she told us we needed to write up our talking points\nfor each of our slides and to practice a few times for next week. </p>\n\n<p> I had a lot to cover in my portion, so it took me awhile to put\ntogether a set of notes. I spent a lot of time practicing it and reworking\nit to try to make sure it fit the time allowed and to make sure it felt\nlike it flowed properly. I don\'t like public speaking, but if I\'m prepared\nthen I\'ll be OK. Two hours later, I felt OK. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(108,8,10,'<p> Wow! I don\'t know what Jose and Sam were thinking &mdash; it looks like\nthey just threw together some notes and didn\'t bother trying with anything\nelse. They spoke way too long and were off-topic throughout. Anna had\nobviously put more thought into it, and I could tell that she\'d actually\npracticed, but she also needed a lot of work. I like Jose, but he seemed to\nbe almost happy to be able to criticize her for a change, and that was\ndisturbing. She didn\'t like that at all and asked if he was trying to make\nthe presentation better or make her feel bad. He shut up after that.  </p>\n\n<p> After three practice runs together, everyone took home a list of things\nto fix their presentations. I need to look out at the audience and speak\nlouder &mdash; that sounds easy, but it\'s just not. More practice for me.\n</p>\n\n<p> I spent about half an hour practicing this week and asked one of my\nfriends to listen to it. She liked it and gave me a few recommendations,\ntoo, but mostly it was just good to practice in front of real people. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(109,8,11,'<p> In class, the instructor returned the drafts to the groups and we met\nbriefly during class to review it. The instructor left only six comments in\nour paper, and most of them were pretty small, but one asked us to further\ndevelop a section. </p>\n\n<p> Our meeting started with another fight between Anna and Jose. Jose\ninterpreted one of the comments to mean that he should write more in the\nsection about alternative perspectives, and Anna, predictably, disagreed.\nAnna talked down to him a lot, and that just kept making him angrier, but\nit was clear that he wasn\'t getting anywhere. It would mean rewriting the\nwhole paper and no one wanted that. Ultimately, Jose gave up and Anna said\nshe\'d make the changes the instructor requested this week. </p>\n\n<p> The presentations were better this week, but we still need more\npractice and a bunch of rework. Jose changed his part in response to what\nhe thought the instructor was saying, but he said he\'d change it to make\nsure it was still in line with what everyone else wrote. We do have the\nnote in the paper, so I guess he\'s got that covered.  </p>\n\n<p> Anna had improved upon hers significantly since last week. I don\'t know\nhow she did it, but it sounded perfect. Most importantly, this time Sam\nfocused on our content rather than the diagrams. Finally, we talked about\nhow we should dress for the presentation. I thought it would be a great\nidea to have costumes in keeping with our topic and both Jose and Sam liked\nthat, but Anna said it would make us look like children. She said we had to\nwear business attire so we would look professional. When we ended the\nmeeting, Anna reminded everyone that our presentation is in just two weeks.\n</p>\n\n<p> I had a few small changes to make and did a few practice runs this\nweek, but probably not more than half an hour. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(110,8,12,'<p> I had to be late this week because of another meeting. When I arrived,\nAnna was finishing up looking at the changes. I asked that we take another\nlook, but Anna told me that it would be better for me to look at it after\nthe meeting, instead &mdash; for the sake of time. Although it didn\'t seem\nlike anyone made very many changes, the presentation felt much better this\nweek. Whatever it was, after two practice runs, we sounded smooth. It\'s\nstill running too long, but the group agreed that everyone will probably\nspeak faster in class, and the instructor probably won\'t be a stickler on\ntime. </p>\n\n<p> When everything looked and sounded good, Anna actually suggested we end\nearly this week, and everyone agreed. However, before we left, Anna\nreminded everyone to wear formal business clothes to the presentation next\nweek. </p>\n\n<p> I practiced once this week with a friend, but mostly I focused on my\nother coursework. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(111,8,13,'<p> We were the only group dressed professionally, and I think that\nprobably earned us some points. I think that all my practice paid off; the\ninstructor only had to ask me to speak up once. Jose stumbled on his first\nfew sentences, but then he relaxed and I think it came out well overall.\nThe biggest surprise, though was Sam; he added an analogy at the end that\nnot only tied everything together, but it also made everyone laugh. It was\nunexpected and risky, but it worked out well. There weren\'t a lot of\nquestions for us and naturally, Anna stepped forward to answer them. </p>\n\n<p> I think we can expect positive feedback and good grades. </p>\n\n<p> Since the paper is mostly finished, we all decided to cancel this\nweek\'s meeting and, instead, each give the paper one last review for next\nweek. Naturally, Anna told us to read through the paper one more time to\nmake sure we had everything.  </p>\n\n<p> I have to admit that I am sick of that paper, and I didn\'t look at it\nat all. It\'s good enough to turn in as it is, and I won\'t make it any\nbetter at this point. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(112,8,14,'<p> At the final meeting, we compared notes and found that we had no major\nchanges to make. I took all four versions to make what few changes there\nwere and submit it at the end of the week. For some reason, Anna didn\'t\ntrust me, though, and asked me to send it to her first. What am I going to\ndo &mdash; ruin it? Of course she still wanted me to put it together, she\njust wanted to make sure she\'s the one to submit it.  </p>\n\n<p> I am so glad this project is over and I hope I never wind up on a team\nwith her again. Of course I said I\'d do it, but I had to keep reminding\nmyself that it was almost over. </p>\n\n<p> Making the changes went pretty quickly and I got her the paper the next\nday. I assume the paper went in on time as planned, and I imagine we\'ll get\na good grade. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(113,9,1,'<p> In group time the first week, we began by setting up weekly team\nmeetings. The project is fairly open-ended, so we brainstormed topic ideas\nfor the rest of the time. </p>\n\n<p> Iain had some really good ideas &mdash; it seems he\'s done this sort of\nthing before. I only had a couple of ideas and none of them are as good as\nhis, but I volunteered both of them anyway. When Marie spoke, I wasn\'t sure\nif she was serious or not. Her suggestions were usually funny &mdash; but\nI\'m not sure they were meant to be. She definitely has a unique approach.\nHannah mostly just listened throughout &mdash; maybe she\'s shy. We built on\neach other\'s suggestions (mostly Iain\'s). </p>\n\n<p> Before the meeting ended, we narrowed it down to three ideas, and Marie\nrecommended we each look for resources on one topic to report back next\ntime and select a topic. This seemed like a pretty good approach, and we\nall agreed. Iain spoke first to claim one topic based upon a prior\ninterest. I spoke up next for another topic because I\'d heard of it before\nand had an idea of where to look. No one challenged me, so it\'s mine. After\nsome consideration, Marie spoke next, and that left Hannah without a topic,\nso we decided she should search for additional materials on Iain\'s topic.\nShe seems nice but hasn\'t said very much. </p>\n\n<p> After the meeting, I did some quick searches and turned up some\npromising materials for the following week. I feel pretty good about being\nable to contribute next week. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(114,9,2,'<p> Hannah started getting upset because she had found few materials and\ncomplained that it was too difficult. Before I had a chance to speak, Iain\npointed out that he\'d gotten more than enough to start with and even\nvolunteered to explain to Hannah how he searched, so she would have a\nbetter idea for the future. </p>\n\n<p> After reviewing the topics and materials everyone found, there was a\nlot of discussion around which topic to choose. Everyone had an opinion.\nMarie led the group in writing out lists of pros and cons, and ultimately\nthe group held a vote and decided on the topic I researched. I was excited\nabout that, because it seemed the most promising and most of the group\nagreed. However, it wasn\'t the one Iain was pushing for, and he seemed\ngrumpy afterward. </p>\n\n<p> The materials I found were just the beginning, so the group divided the\ntopic into subtopics and we each took a few. Hannah and Iain planned to\nmeet separately so Hannah could learn some of Iain\'s research strategies.\nWe plan to have summaries of what we\'ve found for next week so we are ready\nfor the next assignment. </p>\n\n<p> I spent about two hours working on my task for the group. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(115,9,3,'<p> We began our meeting by sorting through the materials. Together, Iain\nand Hannah were able to collect some quality materials and the summaries\nthey\'ve written help Marie and I to understand their value quickly. Clearly\nthey\'ve put a lot of effort into the task. I felt bad when my turn came\nbecause, by comparison, I had to spend more time helping the team to\nunderstand what I found &mdash; I did write them all alone, though. I was\npretty sure the group mostly understood, but I told them I\'d rewrite the\nsummaries to make them clearer, and they were visibly relieved. Oops. </p>\n\n<p> Marie\'s summaries were somewhat better than mine, but I don\'t see how\nmost of them relate. They are interesting and some are funny, but how do\nthey fit in? Iain and Hannah seemed to be confused &mdash; it wasn\'t just\nme. None of us knew how to respond, but after some awkward moments, Iain\nlaid out a few direct questions and I would swear I saw a light bulb go on\nover Marie\'s head. Somehow, the way he asked those questions, she didn\'t\nseem to get upset at all! We all decided that there\'s plenty of time and\nthat we can wait to meet again next week to review the updated materials\nfrom Marie and I. </p>\n\n<p> I spent about two hours rewriting my summaries and even getting some\nmore materials. Maybe it wasn\'t the most productive time, but I really\ndidn\'t want to be embarrassed again, and I kept losing my focus. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(116,9,4,'<p> I spent another hour reviewing all the materials and proofreading my\nwork prior to the meeting. Iain was late by about five minutes, but Hannah\nwas not in class at all and had not arrived at our meeting by the time Iain\ndid. No one had heard anything from her, and she was unreachable using any\nof the contact information she provided. </p>\n\n<p> We went ahead and started without Hannah and began working through\nMarie\'s updated materials, and Iain and I became concerned.  After a few\nmore discussions that were reminiscent of last week, Iain pushed us to move\non; I was happy to join that effort. Marie, though a little confused, went\nwith it. Much less time was needed for my materials because I had improved\nthem a great deal.  Going into the fifth week, I said I\'d put together what\nwe\'ve got for our first assignment. Iain also pushed for us to get started\non an early draft, and we split up the tasks of synthesizing sections of\nthe paper. </p>\n\n<p> Iain caught me outside after the meeting broke up and expressed his\nconcerns about Marie and Hannah. We discussed the possibility of talking to\nthe instructor, but decided to wait for a bit longer since it was only the\nfourth week. Iain thought we could still use some of Marie\'s resources, and\nI volunteered to proofread (i.e. rewrite) her summaries, while Iain offered\nto search for additional content. </p>\n\n<p> I had to spend two nights making sense of those summaries and drafting\nmy portion of the paper. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(117,9,5,'<p> I turned in our assignment during class and it felt good to know that\nwe were on track. Our instructor gave us some of time in class to meet, and\nwe discussed our progress, but none of us expected to have this time, so no\none brought their materials to review. I was mostly finished with my\nportion already and it had gone pretty smoothly. Either everyone else was\nin the same position or they hadn\'t started working on theirs. Either way,\nit was a bit of a waste of time. </p>\n\n<p> Hannah was back for the meeting this week and wearing a cast. She\nslipped on some ice the weekend before and landed in the hospital for\nalmost a week. She did bring a first draft of the section that was assigned\nto her in her absence (I emailed meeting notes to the whole group last\nweek). </p>\n\n<p> Iain was noticeably less enthusiastic this week than he has been in the\npast, and seemed to be less patient with Marie. Also, his draft doesn\'t\nlook like he put much thought into it. There are a number of spots that\nread \"to be determined,\" and I didn\'t see any citations anywhere. Marie was\nclearly nervous when the group reviewed her work, but I was actually\nimpressed with how much she seems to have improved. That must have shown on\nmy face because she seemed to relax after she looked at me. Hannah and I\nboth pointed out a number of rough spots, but I was no longer nervous that\nMarie was struggling. Hannah explained that her own work was incomplete,\nand it clearly was, but (given the circumstances) everyone was just\nimpressed that she\'d done anything. The hours I spent writing paid off, as\nmine was easily the most complete. Usually Iain has a lot to say, but this\nweek he was really quiet. </p>\n\n<p> Marie suggested we each hand off our portion to another team member for\na more thorough review and I volunteered to take Iain\'s because I knew it\nwould need work. He, in turn, claimed mine, but Hannah wanted to take more\ntime to finish her own section. Marie, reminding us of Iain\'s early,\ninsightful comments, asked that he look at her work. Marie took mine. Wow!\nThey were all fighting to take my work! </p>\n\n<p> I spent a lot of time reworking Iain\'s paper. The language was clear\nand readable, but the sections felt thin. In fact, I grew one section so\nmuch that it had to be split out into two. Also, there were only two\ncitations listed and one of them was wrong. It\'s pretty bad and I\'m sure he\ncould have done better than this. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(118,9,6,'<p> Iain was in class this week, but he emailed the team about an hour and\na half before the meeting to say that there was a family emergency and that\nhe would not be able to make the meeting. He sent over his progress on\nMarie\'s part of the paper &mdash; and it didn\'t look he\'d done much more\nthan make the few changes we discussed in class last week. </p>\n\n<p> The meeting was fairly productive and I felt like I could see the paper\nstarting to take shape. Marie took an odd approach to revising my section;\nI think she didn\'t really understand it. Hannah seemed to agree with me,\nand Marie quickly said she\'d go ahead and change it back. The three of us\nspent awhile talking about how satisfied we were with the topic. Feeling\nlike much of the paper was in good shape, Hannah took the pieces home to\nassemble them into a full draft to use moving forward. </p>\n\n<p> Before the meeting ended, I asked about switching next week\'s meeting\ntime so I could meet with another study group &mdash; I really need to\nprepare for a mid-term exam the following week. After some discussion, we\ncouldn\'t agree on a new time, so we decided instead to meet only for half\nan hour. Marie sent an email to let Iain know of the change. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(119,9,7,'<p> This week turned out to be very busy, so I\'m glad we decided to cut the\nmeeting time down. Hannah gave everyone a copy of the document she\nassembled. After about 15 minutes of what was scheduled to be a half-hour\nmeeting, Iain had not arrived, so we all decided to walk through what\nHannah put together. </p>\n\n<p> Hannah clearly spent a lot of time putting everything together. The\nformatting was consistent and I didn\'t see anything missing. There\'s one\nempty section, but she explained that it\'s because she added it &mdash;\nbeing the only one who\'s read it all through, she felt it was necessary. I\njokingly suggested that Iain should write it; Marie quickly countered\nthat\'d mean I\'d end up writing it, anyway. Hannah interrupted our joking\nand said we were being mean. I think she felt bad because, in the\nbeginning, Iain had helped her. She reminded us that he was going through a\nfamily emergency and maybe he was really shaken up by it. I felt a little\nbadly and we all returned to reviewing the document. </p>\n\n<p> Once we finished walking through the document, we agreed to make\nnotes/corrections/suggestions on our own for next week. As we were all\ngetting ready to leave, Iain came in the door of the meeting room. Hannah\nquickly asked him if he was doing OK and what was going on &mdash; it\nseemed like she was afraid Marie or I would have said something mean if she\ndidn\'t speak first. He said his brother was going through something that he\nwas helping him with. We gave him a copy of the paper, and quickly\nexplained what we\'d all be doing for next week. </p>\n\n<p> I only spent about 30 minutes reviewing the document, because I had a\nlot of studying to do for mid-terms, but there is be more work needed\nbefore this project is ready. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(120,9,8,'<p> Everyone was there by the time I arrived this week. My instructor let\nme take a little extra time on my mid-term, which helped me out, but made\nme a little late to the meeting. </p>\n\n<p> Marie has a great eye for detail &mdash; she found spelling and\nformatting errors that everyone else missed. Hannah volunteered to take\neveryone else\'s copies and make all the changes for the draft we turn in\nnext week in class. When I asked about the section that was still missing,\nIain said he thought it was too late to get it into the draft. He figured\nit should be fine to include a note that it will be in the final version\nand he made it clear that he wasn\'t going to do it. I didn\'t think this was\nOK. Marie agreed, and volunteered to draft the section and get it to Hannah\nby the middle of the week. Honestly, I\'m a little nervous about Marie\nwriting it, but it was clear that Iain wasn\'t going to do it, and I really\nneed a break from this project. Hannah figured she wouldn\'t have time to do\nboth the editing and the writing, but agreed to add the new content if\nMarie could write it in time. All Iain offered Marie were some (pretty\ngood) suggestions on how to approach the new content. </p>\n\n<p> The next evening, Marie asked if I could come over to help get the\nsections done in time. She was stressed because some surprise assignments\nin other classes gave her less time than she\'d expected. I said OK, and\nwhen we met up, I found that it was much more complicated than it looked.\nWorking together, we were able to write a decent draft so she could deliver\nit to Hannah the next day, but it took most of the night. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(121,9,9,'<p> Hannah didn\'t provide copies to everyone before class, and that was\nnerve-wracking, but she did have one to turn in to the instructor. She\nturned it in and now we get to wait for feedback. Of course, we already\nknow some of the work that needs done. </p>\n\n<p> Working with Marie last week, we noticed some problems in the draft\nthat will need correcting &mdash; particularly stuff that Iain supposedly\nworked on. It\'s like he didn\'t even touch it. Just before Iain left for\nanother meeting, Marie suggested we could use some diagrams to illustrate\nsome of our points. Iain watched us sketch for a bit before he left. We\ncame up with some good ideas and Marie volunteered to draw them out. I\noffered to reread the entire document and the meeting ended a bit early\nbecause we were mostly done anyway. </p>\n\n<p> I spent another two and a half hours reworking the document this week.\n</p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(122,9,10,'<p> Marie and I both arrived early to this week\'s meeting, and started\nlooking at the images she put together over the past week while we waited\nfor Hannah and Iain to arrive. The images were a bit odd and I don\'t think\nsome of them are appropriate. When Hannah arrived, she said that Iain had\nlet her know he won tickets to the game tonight, and so he couldn\'t make it\nto our meeting &mdash; nothing new there.  </p>\n\n<p> Hannah said she really liked the images Marie put together. They\nreflect Marie\'s quirky personality, but Hannah pointed out that they also\ninclude the right details to get the point across. She described them as\nfunctional, eye-catching, and memorable. They are memorable, but I don\'t\nthink that was the goal here. I wish Iain had showed up, because he always\nseems to have a good feel for the project\'s direction. I\'m pretty sure he\'d\nagree with me, but I felt outnumbered. I made a few requests to tame them\ndown, but ultimately I accepted it, and we moved on. </p>\n\n<p> I\'d made a lot of changes to the document, and some of them were pretty\nbig. I walked through them at a high level to make sure everyone agreed\nbefore starting to prepare for the presentation. We decided on a basic\nstructure and, for the next meeting, we decided that we should each put\ntogether notes or a script for what we would say during our part so we can\npractice it next week. Hannah said she\'d pass this on to Iain. </p>\n\n<p> I\'ve had a difficult time writing my script, so one afternoon I emailed\nIain to see if we could meet and work on it together. However, when I\ndidn\'t hear back from him, I met up with Hannah instead. After working\ntogether for an hour, we both made some good progress. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(123,9,11,'<p> In class, the instructor returned the drafts to the groups and gave us\ntime during class to review it. Unfortunately, while we know there were\nmany problems with that version, the instructor left only five comments in\nour paper. One said, \"This shows promise,\" two corrected grammar issues\nthat we\'ve already fixed, one requested that page numbers be added, and one\nsuggested clarifying one of the sections Marie wrote initially, saying it\nwas a novel approach and that it should be explained more clearly and\nthoroughly. </p>\n\n<p> Everyone arrived on time to the group meeting. The discussion began\nwith how little feedback we received, and whether this meant the paper was\nin great shape or that instructor simply didn\'t really read it. Either way,\nwe had the feedback we\'d been waiting for, and it was time to move forward.\n</p>\n\n<p> Marie asked Iain to review her section again, and he answered that he\nhad already done so once at her request. Marie responded in a snarky tone\nthat she\'d like him to \"actually read it this time.\" This became an\nargument, with Marie accusing Iain of not participating in the group. Iain\nattacked back, saying that the low quality of her work made it very\ndifficult to work with. That wasn\'t fair, and I started to defend Marie for\nat least working and trying hard, and showing up, when Hannah raised her\nvoice and everyone quieted down. She reminded the group that the\npresentation was coming up soon and that we needed to practice. Iain said\nthat, while he wouldn\'t have time to go through the entire paper, he would\ntake a look at Marie\'s section again before next week. </p>\n\n<p> The rest of the meeting was spent working through the presentation.\nMarie put together a PowerPoint and we did a practice run. Iain really\nseems to have put a lot of time into his part; he sounded very polished. He\nalso had many suggestions for the rest of us, but, honestly, they were hard\nto hear after the argument we just had. By the end of the meeting, the\npresentation was still running too long. I have to make decisions on how to\ncut my part down, but with two weeks left, I feel pretty good about it.\n</p>\n\n<p> I spent about an hour on revising and cutting content from my\npresentation during the week. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(124,9,12,'<p> Everyone arrived on time for the meeting this week. Iain provided\nfeedback on Marie\'s section and, reading through it, it became clear that\nmaking these changes would require more substantial changes throughout the\npaper. We could easily have just ignored them because what we have is not\nwrong, but making the changes would certainly improve the paper. However,\nso close to the end of this class, I\'m not sure we have the time to do this\n&mdash; especially with everyone getting ready for final projects and\nexams. It would have been nice if he\'d bothered to read the paper earlier,\nwhen it would have been easier to make these changes. Why didn\'t he even\ntry to start making them?  </p>\n\n<p> Hannah said she thought she had time to make the changes this week, and\nvolunteered to try if someone else would read through it next week. When no\none else responded, I volunteered. She\'s been doing a good job and checking\nit over shouldn\'t be a huge amount of work, even with all my other\nclasswork to prepare. </p>\n\n<p> This week, the presentation was much better. After three practice runs,\nit sounded smooth. While it was still running a bit too long, we agreed\nthat everyone will probably speak faster in class, and the instructor\nprobably won\'t be so strict about timing. </p>\n\n<p> This week, aside from practicing my part of the presentation, I mostly\nfocused on my other classes and end-of-semester activities. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(125,9,13,'<p> The presentation went very smoothly. Hannah seemed nervous, spoke too\nquickly, and faced the PowerPoint instead of the class, but she knew what\nshe was talking about and that showed. The audience asked some good\nquestions, which showed that they understood the presentation, but Iain\nseemed to want to score points by answering most of the questions. I\nstarted to answer one, but he cut me off and he talked right over me as he\nanswered himself. Also, we should have discussed attire beforehand, because\nIain wore a suit, while Hannah and Marie were both wearing dress skirts and\nblouses. I felt out of place in my usual jeans and a sweater. </p>\n\n<p> At our meeting this week, everyone commented on my casual clothes and I\napologized, but I just never thought about it. Aside from that, the group\nfelt good about the work we\'ve done, and we all agreed that we expected\npositive feedback and good grades. Hannah shared her updated version of the\npaper and I took it to review (as we had discussed last week).  </p>\n\n<p> As we were leaving, Marie asked me to send her a copy as soon as I\nfinished reviewing Hannah\'s corrections, so she could take another look at\nit. I spent about an hour reading through the new version, but I only made\na few changes and then sent it on to Marie. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(126,9,14,'<p> At the final meeting, we reviewed the paper to make sure it was ready\nfor submission at the end of the week. Iain volunteered to do a final read,\nprint the document and send it to the instructor. Marie started to attack\nIain for not helping the group &mdash; I think she felt like he was trying\nto steal credit for all our work at the end &mdash; just like he did with\nthe presentation. I was too tired for that, though, and I just wanted the\nproject to be over, so I tried to calm her down and Hannah joined me. I\nsuggested that Marie submit the latest version she had at the deadline, and\nif Iain was able to get her his updates by that time, they\'d go in;\notherwise, she should use what she had &mdash; Marie would send it in. Iain\nwas annoyed, but agreed. </p>\n\n<p> After the deadline, Marie confirmed that Iain got his changes to her in\ntime for her to submit them, and she sent a copy of the finished product to\nthe entire group. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(127,10,1,'<p> In group time the first week, we began by setting up weekly group\nmeetings. The project is fairly open-ended, so we brainstormed topic ideas\nfor the rest of the time. </p>\n\n<p> Iain had some really good ideas &mdash; it seems he\'s done this sort of\nthing before. John tried to be involved by suggesting a couple of ideas,\nbut they were pretty mediocre. I like to look at things from a different\nperspective, so I suggested some things that were not exactly off-topic,\nbut not entirely serious, either. However, they seemed to fall completely\nflat; not only didn\'t they spark conversation, but I didn\'t even get a\nchuckle. Throughout the meeting, I could tell that Hannah was listening,\nbut maybe she\'s shy, because she didn\'t say much. Pretty quickly we built\non Iain\'s suggestions. </p>\n\n<p> Before the meeting ended, we narrowed it down to three ideas. I\nrecommended that we each look for resources on one topic, report back next\ntime and then select one; everyone else agreed. Iain claimed a topic based\nupon a prior interest, and John spoke up for another. I reluctantly\nvolunteered for the last topic, leaving Hannah without one. She said she\'d\nsearch for additional materials on Iain\'s topic. </p>\n\n<p> I didn\'t find much on my topic, so I got creative in my interpretation\nit &mdash; hopefully it will at least be good for a laugh. I was\nuncomfortable with what I have, but I know I\'ve tried. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(128,10,2,'<p> Hannah was upset because she had found very few materials &mdash;\ncomplaining that there was nothing to find. Iain pointed out that he had\nmore than enough to start with, and even volunteered to explain how he\nsearched to Hannah after the meeting, so she would have a better idea for\nthe future. </p>\n\n<p> After reviewing the topics and the materials everyone found, there was\na lot of discussion around which topic showed the greatest promise. I\ndecided to organize what everyone was saying into lists of pros and cons to\nmake it easier to understand. The topic I\'d looked at was quickly removed,\nbut both John\'s and Iain\'s looked good. Iain pushed really hard for his\ntopic, but I just couldn\'t seem to get as excited about it. Eventually, we\nheld a vote and decided on the topic John had researched. I was pretty\nhappy with the decision, but Iain seemed grumpy afterward. </p>\n\n<p> The materials John had found were just the beginning, so we divided up\nthe major subtopics among us. Hannah and Iain planned to meet separately so\nshe could learn some of his research strategies. We planned to return next\nweek with summaries of what we\'ve found to make it easier for the group to\nget moving quickly. </p>\n\n<p> With John and Iain\'s work as a model, I spent about three and a half\nhours over this week working on my task for the group &mdash; I don\'t want\nto feel stupid again at the next meeting. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(129,10,3,'<p> We began sorting through the materials at this week\'s meeting. Iain and\nHannah were able to collect some quality materials, and the summaries\nthey\'ve written help me understand their value quickly. They\'ve clearly put\na lot of effort into the task. John\'s materials, on the other hand, were\ndifficult to understand and required his help in interpreting what he\nmeant. He seemed embarrassed and told us he\'d rewrite the summaries to make\nthem clearer. My summaries got some laughs, but the group seemed to be\nconfused by them. Their questions make it clear that they didn\'t see the\nsame value in them that I did &mdash; and their questions also made me see\nwhy. They were being polite, but I could still tell. Finally, Iain asked a\nfew direct questions that helped me to understand everything a bit\ndifferently &mdash; he\'s really got good control on this whole project.\nEveryone agreed that there is plenty of time, and that we can wait until\nnext week\'s meeting to review the new and updated materials from John and\nme. </p>\n\n<p> I spent another two hours getting new materials and rewriting my\nsummaries. Hopefully this was time well spent. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(130,10,4,'<p> Iain was late to the meeting by about ten minutes, but Hannah was not\nin class at all, and didn\'t show up for the meeting, either. No one had\nheard anything from her, and no one could reach her. </p>\n\n<p> We began the meeting by working through our updated materials, and Iain\nand John were still concerned. After a few more questions that were\nreminiscent of last week, Iain pushed to move on. I\'d only got through\nabout half of my materials, but they didn\'t seem all that pleased. I felt\nstupid because I guess I still don\'t get it, so I was happy to move on.\nJohn\'s materials, on the other hand, were really solid, and he volunteered\nto put together what we\'ve already got so we can turn it in next week. Iain\npointed out that we really needed to get a draft going. John echoed this\nand I agreed, so it was settled. We split up the tasks of synthesizing the\nsections before we ended the meeting to keep us moving forward.  </p>\n\n<p> I spent an entire evening drafting my portion of the paper, and then I\nspent most of another day reworking it. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(131,10,5,'<p> John turned in our assignment during class, and our instructor gave us\nsome of time in class to meet. We discussed our progress, but none of us\nexpected to have this time, so no one brought their materials to review. I\nhad already finished with my part, and I thought it was OK. Either everyone\nelse was in the same position or they hadn\'t looked at it. We all left\nearly. </p>\n\n<p> Hannah was back this week and wearing a cast. She slipped on some ice\nthe weekend before and it landed her in the hospital for a week. She did\nbring a first draft of the section that was assigned to her in her absence\n&mdash; John emailed meeting notes to the whole group. </p>\n\n<p> Iain seemed like he didn\'t care this week, and he was a bit\ncondescending to me, too. He brought a draft of his portion, but it doesn\'t\nlook like he put much thought into it. There are a number of spots that\nread \"to be determined,\" and I didn\'t see any citations or references. I\nwas nervous when the group reviewed my work, but this time they actually\nseem satisfied with it &mdash; more than that, they seem impressed. I could\nread it on both John and Hannah\'s faces, and that was a relief. Iain seemed\nnot to have paid much attention at all, so I got little reaction there. It\nwasn\'t perfect, but mostly now it was grammar or spelling, so it wasn\'t a\nbig deal to me &mdash; it didn\'t leave me feeling stupid and confused.\nHannah explained that her work was incomplete, and it clearly was, but\n(given the circumstances) even this much was great to have. John\'s writing\nwas excellent. His piece was easy to read and made sense and he covered all\nthe points he was supposed to &mdash; he must be putting a lot of time into\nthis class. Throughout the meeting, Iain was really quiet. </p>\n\n<p> When we were done, I suggested that everyone trade their portion to\nanother group member for a review. John volunteered to take Iain\'s and Iain\nclaimed John\'s &mdash; probably because it was already in such good shape.\nHowever, Hannah said she wanted to take more time to finish her section. I\ndidn\'t feel it was fair for Iain to take the easy task, so I reminded the\ngroup of Iain\'s early, insightful comments and asked that he look at my\nwork; I took John\'s, instead. </p>\n\n<p> John\'s portion was in great shape, and it didn\'t take me more than an\nhour to read through it and fix the few mistakes that were there. Then I\ngot an idea for presenting the information in a different way that could\nshed additional light on the topic. I spent an hour putting it together,\nbut when I looked at the clock and saw how late it was, I switched to my\nother classwork, because I still have time to finish this later. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(132,10,6,'<p> Iain was in class this week, but he emailed the group about an hour and\na half before the meeting to say that there was a family emergency and that\nhe would not be able to make the meeting. He included his work on my\nsection &mdash; and it didn\'t look he\'d gone any deeper than the few\nchanges we discussed in class last week. </p>\n\n<p> The meeting was pretty good, and I can see that the paper is definitely\nstarting to take shape. Unfortunately, I noticed when I got to the meeting\nthat I accidentally forgot to get back to my revisions of John\'s work.\nThat\'s probably a good thing, because John and Hannah don\'t seem to\nunderstand what I was doing, anyway. Maybe it was too much of a stretch. I\nhope they don\'t think I don\'t understand what\'s going on. The three of\nwound up spending awhile discussing how happy we were for choosing this\ntopic &mdash; it\'s more interesting than any of us expected. Feeling like\nmuch of the paper was in good shape, Hannah took the pieces home to\nassemble them into a full draft to use moving forward. </p>\n\n<p> Before the meeting ended, John asked about switching next week\'s\nmeeting time so he could meet with another study group. With mid-terms\ncoming, everyone agreed that we need extra time to prepare. However, we\ncouldn\'t agree on a new time, so we decided instead to meet only for 30\nminutes. I sent an email to let Iain know of the change. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(133,10,7,'<p> This week turned out to be very busy, so I was thankful the group cut\nthe meeting time down for this week. Hannah gave everyone a copy of the\ndocument she assembled. After about 15 minutes of what was scheduled to be\na 30-minute meeting, Iain had not arrived. We went ahead without him and\nwalked through what Hannah had put together. </p>\n\n<p> Hannah clearly spent a lot of time putting everything together. The\nformatting was consistent, and I didn\'t see anything missing. There was one\nempty section that she added, because she felt it was necessary after\nhaving read the whole piece. John joked that Iain should write it, and I\ntold him that would mean he\'d end up writing it anyway. We both laughed,\nbut Hannah got upset and said we were being unfair. She pointed out that\nIain had helped her in the beginning. I don\'t really believe he had an\nemergency last week, but we both stopped talking about it, and turned back\nto reviewing the document. </p>\n\n<p> Once we finished going through the document, we agreed to make\nnotes/corrections/suggestions for next week. As we were getting ready to\nleave, Iain walked in. Hannah quickly asked him if he was OK and what was\ngoing on. He said his brother needed him. We made sure he had a copy and\ntold him what we\'d all be doing for next week. </p>\n\n<p> I spent about two hours reviewing the document, because I wanted to\nmake sure I was doing my part &mdash; I didn\'t want to be seen as another\nIain. However, I had a lot of studying to do for mid-terms and there are\nstill many weeks left in the project, so I figured that was enough. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(134,10,8,'<p> Surprisingly, Iain was already there when I arrived. Everyone was\nimpressed by my attention to detail &mdash; it seems I found more errors\nthan anyone else. Hannah volunteered to take everyone else\'s copies and\nmake all the changes for the draft that we are supposed to turn in next\nweek in class. John pointed out the section that was still missing or\nincomplete. Iain said that it was too late to get it into the draft. He\nfigured it should be fine to include a note that it will be in the final\nversion. Clearly he wasn\'t going to fix it. I was uncomfortable with that,\nso I said I\'d draft the section and get it to Hannah by the middle of the\nweek. Hannah said that she\'d incorporate the new content if she got it in\ntime. Iain did offer some good suggestions on how to approach the new\ncontent, but that was all. </p>\n\n<p> The next evening, I asked John for help getting the section done in\ntime. I had less time than I\'d thought because of a surprise assignment in\none class and I already had to do major rework in another. Also, the\nsections were more complicated than they looked. He came over, and we were\nable to write a decent draft for me to give Hannah the next day &mdash;\nplenty of time. Working with John helped to ground me, I think. If it was\njust me doing this whole project, it would be much less conventional, I\nthink, but, working in a group, I don\'t get to do that. John kept reminding\nme of this with his \"let\'s just get it done\" approach. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(135,10,9,'<p> Hannah turned in our draft, and now we get to wait for feedback. </p>\n\n<p> We do, however, already know of some work that needs done. Last week,\nJohn and I noticed some problems in the draft that will need correcting.\nAlso, it seems Iain barely touched my work when I asked that he review it\n&mdash; and John pointed out a number of other areas that could be\nimproved. Iain had to leave early for another meeting, but when I suggested\nusing some diagrams to illustrate our points, he sat there for another five\nminutes of giving us nothing. We spent some time sketching ideas and then\neveryone was happy to let me clean them up &mdash; I\'d just taken an\nillustration class. John offered to reread the entire document.  </p>\n\n<p> I spent an hour putting together the diagrams. I\'m pretty proud of them\n&mdash; I got to use some of the skills I just learned, and I got to be\ncreative and experiment for the first time on this project. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(136,10,10,'<p> John and I started looking at the images I put together over the past\nweek while we waited for Hannah and Iain to arrive. He seemed to be\nindifferent toward them, but when Hannah arrived, she said that Iain let\nher know he won tickets to the game tonight and that he wouldn\'t be coming\nto our meeting &mdash; why should he start showing up now?  </p>\n\n<p> On a positive note, she said she really liked the images I\'d put\ntogether. John said they reflect my \"quirky personality,\" and Hannah\npointed out that they also included the right details to get the point\nacross. She called them \"functional, eye-catching, and memorable.\" After\nthat, although I could tell John was still uncomfortable with them, he\'d\naccepted it. He still said he wanted Iain\'s opinion, but just asked me to\nmake a few small changes. That takes some of the fun out of the images, but\nI\'m OK with that, as long as John and Hannah are. </p>\n\n<p> John made a lot of changes to the document, and some of them were\npretty extensive. However, he walked through them at a high level and\neveryone agreed, so we moved on to prepare for the presentation. For the\nnext meeting, we each took a part and decided that we should put together\nnotes or a script for what we would say so we could practice it next week.\nHannah said she\'d pass this on to Iain. </p>\n\n<p> I\'ve never minded public speaking, and I drafted a version of my script\nin about 30 minutes one evening. I also put together a PowerPoint, based on\nan outline of what everyone would cover. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(137,10,11,'<p> In class, the instructor returned our draft and we met briefly to\nreview it. Unfortunately, while we already knew there were lots of problems\nwith that version, the instructor left only five comments in our paper. I\nguess they expected much of it to change since it was only a draft, after\nall. One said \"this shows promise,\" two corrected grammar issues in\nsentences that were already gone, and one requested that page numbers be\nadded. The only thing valuable for me was a request to clarify one of the\nsections I wrote. The instructor said it was a \"novel approach\" and that it\nshould therefore be explained more clearly and thoroughly. It was nice to\nknow I\'d made an impression and that someone who counts got it! </p>\n\n<p> During the weekly group meeting, we were all on time. The discussion\nbegan with how little feedback we got and whether this means the paper was\nin great shape or that instructor simply didn\'t really read the whole\nthing. I\'m pretty sure it\'s the latter. Either way, I had the feedback we\'d\nbeen waiting for and it was time to move forward. </p>\n\n<p> I asked Iain to please review my section again and he responded that he\nalready did that once. I told him it\'d be nice if he would actually read it\nthis time; maybe that wasn\'t the best approach, because it turned into a\nshouting match, but I\'m upset that he didn\'t do his job in the first place,\nand I said that, too. I was trying to tell him that I really wanted his\nfeedback, but he got upset and snapped back that it was difficult to read\nmy work because it was so bad. I was too embarrassed to respond, but\nthankfully John jumped in and defended me (sort of), pointing out that at\nleast I showed up and tried hard. Hannah raised her voice and everyone\nquieted down. She focused us back on the presentation coming in two weeks\nand the fact that we hadn\'t practiced for it yet. Iain reluctantly agreed\nto take a look at my section again for next week but made sure to tell us\nhe was too busy to go through the whole thing. </p>\n\n<p> The rest of the meeting was spent working through the presentation. The\ngroup used the PowerPoint I put together in a practice run. We made a few\nchanges as we went, but I\'d made a pretty good start. Iain really seems to\nhave put a lot of time into his part and he sounded very polished. He also\nhad lots of suggestions for the rest of us, but they were a bit hard to\nhear after the argument we just had. The presentation was running too long\n&mdash; particularly John\'s part. He doesn\'t seem very experienced at this\nsort of thing and said way too much, way too fast.  </p>\n\n<p> I spent about an hour revising my portion of the presentation and\nrevising the slides during the week. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(138,10,12,'<p> Everyone arrived on time for the meeting this week. Iain provided\nfeedback on my section and, in reading through it, it was clear that making\nthese changes would require larger changes throughout the paper. We could\neasily just ignore them because what we had was not wrong, but making the\nchanges was the better way to go. It\'s just frustrating because he could\nhave caught this much earlier if he\'d bothered to read the paper, but now\nit\'s so close to the end of class.  </p>\n\n<p> Hannah said she thought she could make the changes this week and\nvolunteered to try if someone else would promise to read through it next\nweek. After a pause, John volunteered. I can\'t believe that Iain didn\'t\nmake the changes when he saw that they were needed and then that he\nwouldn\'t bother to even read it. It\'s his fault we\'re in this mess. </p>\n\n<p> This week the presentation was much better. After three practice runs,\nit sounded smooth. It\'s still running too long, but we agreed that everyone\nwill probably speak faster in class and the instructor probably wouldn\'t be\na stickler on time. </p>\n\n<p> This week I focused on my other classes and end-of-semester activities.\n</p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(139,10,13,'<p> The presentation went very smoothly. Hannah got nervous, spoke too\nquickly and faced the PowerPoint instead of the class, but she knew what\nshe was talking about and it showed. The audience asked some good\nquestions, which showed that they understood the presentation. Iain kept\nstepping forward to answer most of the questions without giving anyone else\na chance &mdash; like he was trying to make it look like he\'d done much\nmore than he actually did. I think he even talked over John once. We should\nhave discussed attire beforehand, because everyone but John dressed up. He\nlooked out of place in his usual jeans and a sweater. I felt badly for him.\n</p>\n\n<p> At our meeting, Iain commented on John\'s casual clothes. John\napologized for it, but it felt cruel because he knew his part and was well\nprepared. He already seemed embarrassed about his choice of clothes. Aside\nfrom that, we felt good about the work we\'d done and we expect positive\nfeedback and good grades. Hannah shared her updated version of the paper\nand, after a quick review of the changes, we ended early with John taking\nthe paper to review it as we discussed last week.  </p>\n\n<p> As we were leaving, I asked John to send me a copy as soon as he\'s\nfinished so I could take one last crack at it before we turned it in. When\nhe did, I spent about an hour and a half reading through the new version,\nbut I didn\'t make any more changes. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(140,10,14,'<p> At the final meeting, we reviewed the paper to make sure it was ready\nfor submission at the end of the week. Iain volunteered to do a final read,\nprint it and send it to the instructor. When I asked why he should bother\nnow since he\'d barely contributed anything to it during the semester, both\nJohn and Hannah stopped me- I guess they just wanted the project to be\nover. John suggested that I send it to him and submit the latest version at\nthe deadline &mdash; if Iain could get his updates to me by that time,\nthey\'ll go in, but otherwise we should go with what I\'ve got. Iain was\nclearly annoyed, but he agreed. </p>\n\n<p> Iain got the document to me in plenty of time to send it in and there\nwere very few changes. After I submitted it, I sent a copy of the finished\nproduct to the entire team. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(141,11,1,'<p> In group time the first week, we began by setting up weekly team\nmeetings. The project is fairly open-ended, so we brainstormed topic ideas\nfor the rest of the time. </p>\n\n<p> Iain had some really good ideas &mdash; it seems he\'s done this sort of\nthing before. John tried hard to be involved, but only suggested a couple\nof ideas and they were pretty mediocre. When Marie spoke, I sometimes\nwasn\'t sure if she was serious or not. Her suggestions were often funny,\nbut I was too nervous to laugh &mdash; especially since no one else did.\nShe definitely has a unique approach. Mostly, I just took it all in. Soon,\nwe were building on each other\'s suggestions (mostly Iain\'s). </p>\n\n<p> Before the meeting ended, we narrowed it down to three ideas. Marie\nrecommended we each look for resources on one topic, report back next time\nand then select a topic. This seemed like a good plan; Iain spoke first to\nclaim a topic based upon a prior interest and John spoke up for another.\nAfter a moment, Marie took the last topic, but she didn\'t sound thrilled\nabout it &mdash; I think it sounds like a tough one. I was left without a\ntopic, so I volunteered to search for additional materials on Iain\'s topic\nbecause it sounded the most promising. </p>\n\n<p> After spending half an hour searching, I wasn\'t able to find much of\nanything. It was frustrating because Iain seemed so excited about it\n&mdash; I guess he\'s going to be disappointed. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(142,11,2,'<p> When I arrived, I felt uncomfortable because everyone had long lists of\nwhat they found and I had so little to offer. I asked how everyone found so\nmuch &mdash; especially Iain. He found so much more than I did on the same\ntopic! He said that he\'d got more than enough to start with and even\noffered to work with me after the meeting to help me. </p>\n\n<p> After reviewing the topics and the materials everyone found, there was\nsome debate regarding which topic to focus on. Marie decided to start\norganizing things into lists of pros and cons to make it easier to\nunderstand; when she\'d got some lists going, John\'s topic looked like the\nclear winner. We held a vote and decided on John\'s topic. This seemed like\na good choice, but I could tell Iain was hoping that his would be selected.\n</p>\n\n<p> The materials John found were just the tip of the iceberg, so we\ndivided up the major subtopics to research with summaries for next week.\nThis way we\'ll be ready for the first assignment and be able to start\nmoving quickly on getting this paper finished. </p>\n\n<p> I met with Iain two days later and he was still bummed about the topic\nthe group selected, but he\'s nice and we got along well. He also seems to\nhave much more experience than the rest of us do because, although he\nstarted with the same searches I did, he dug into the materials further to\nfind related content. It took about two and a half hours, but we found some\nsolid references. I went through them and wrote summaries, and then Iain\nverified them. I learned a lot and we both have a lot to bring to the next\nmeeting. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(143,11,3,'<p> This week, we began sorting through the materials we\'d all found.\nTogether, Iain and I had easily the best materials and summaries to offer.\nVery little time needed to be spent covering our work because there weren\'t\nany questions. John\'s summaries, though, were difficult to understand and\nwe needed his help in interpreting what he meant. It\'s not that the\nmaterials themselves were bad or anything, but he doesn\'t seem to have\nconnected all the dots when writing them up. He was embarrassed and told us\nhe\'d rewrite them to make them clearer. Marie\'s summaries were interesting\nand some were funny, but I wasn\'t sure how exactly they fit in &mdash; and\nI don\'t think anyone else could see it, either. Honestly, she seems to need\nhelp understanding what we\'re doing, and everyone is afraid to tell her so.\nAfter some awkward moments, Iain asked a few direct but fair questions. As\nMarie tried to answer, it seemed that she was finally realizing that what\nshe brought was really weak. He didn\'t push too hard though &mdash;\nprobably didn\'t want to make her feel stupid. We decided to wait for our\nnext meeting to review the new and updated materials from both Marie and\nJohn. </p>\n\n<p> I got to relax during the week without any tasks for this project. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(144,11,4,'<p> I slipped on some ice on my way to class and had to be rushed to the\nhospital to set a broken bone and get some stitches &mdash; it was pretty\nbad. They gave me some painkillers and I didn\'t react well to them. I\ncompletely forgot our team meeting until two days afterward, but by that\npoint, I was working hard to try to make up for lost time in all my\nclasses. John emailed me notes from the meeting and I did my best to try to\nput together my part of the paper, but I know it\'s not going to be close to\nperfect. I did spend a few hours on it, but it honestly wasn\'t my top\npriority. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(145,11,5,'<p> I didn\'t get to class, but I understand that John turned in the\nassignment for us. I was able to make it to the meeting this week and,\nnaturally, everyone was surprised to see my cast. They were even more\nshocked that I\'d brought a draft of my portion of the assignment. Of\ncourse, they didn\'t yet know that it wasn\'t very good. </p>\n\n<p> Iain seemed like he didn\'t care much this week and was a little bit\nmean toward Marie. He brought a draft of his portion, but it didn\'t look\nlike he put much thought into it. There were a number of spots that read\n\"to be determined\" and I didn\'t see any citations or references. Marie\nalmost seemed scared when the team reviewed her work, but I was actually\nimpressed with how much she seems to have improved. Maybe that showed on my\nface; after she looked at me, she seemed to relax. John and I pointed out a\nnumber of rough spots, but I was no longer as nervous about her ability,\nand she was visibly relieved. Then it was my turn. I explained that my work\nwas still incomplete, and it clearly was, but Marie said that, given the\ncircumstances, even this much was great to have. We didn\'t spend much time\non mine. John\'s writing was excellent this time. His thoughts were well\narticulated and he covered all the points he was supposed to &mdash; he\nmust be putting a lot of time into this class. Throughout the meeting, Iain\nwas really quiet &mdash; which is unusual for him. </p>\n\n<p> Marie suggested we each hand off our portion to another team member for\na more thorough review. John volunteered to take Iain\'s and Iain, in turn,\nclaimed John\'s. However, I still needed to take more time to finish my\nsection, and Marie, reminding the group of some of Iain\'s early, insightful\ncomments, asked that Iain look at her work. Marie took John\'s work for\nreview. </p>\n\n<p> I was in much better shape this week and felt relatively caught up, so\nI spent about two hours finishing up my section and proofreading it. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(146,11,6,'<p> Iain was in class this week, but he emailed the team about an hour and\na half before the meeting to say that there was a family emergency and that\nhe would not be able to make it to the meeting. He sent over his progress\non Marie\'s part of the paper. </p>\n\n<p> The meeting was fairly productive, as we were beginning to see the\npaper take shape. Marie took an odd approach to revising John\'s section and\nJohn seemed to agree, but Marie didn\'t push it and said she\'d change it\nback for next week. The three of us spent a while just talking about how\nsatisfied we were with the topic. There was a lot of information on it once\nwe understood how to find it, and the consensus was that it\'s more\ninteresting than any of us expected. Feeling like much of the paper was in\ngood shape, I took the pieces home to assemble them into a full draft to\nuse moving forward &mdash; Marie said she still had the earlier version of\nJohn\'s work and she\'d give me that piece in the next day or so. </p>\n\n<p> Before the meeting broke up, John asked about switching next week\'s\nmeeting time so he could meet with another study group. With mid-terms\ncoming, everyone agreed that they needed extra time to prepare. However, we\ncouldn\'t agree on a new time, so we decided to meet only for 30 minutes\ninstead. Marie sent an email to let Iain know of the change. </p>\n\n<p> I spent two hours assembling and proofreading the document. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(147,11,7,'<p> I gave everyone a copy of the document I\'d assembled when we started\nour meeting. After about 15 minutes of what was scheduled to be a 30-minute\nmeeting, Iain had not arrived, so we decided to walk through the document\ntogether. </p>\n\n<p> John and Marie were vocal about how impressed they were. As the only\none who had read everything through, I felt it was necessary to add a\nsection &mdash; now just a placeholder. John suggested that Iain should\nwrite it and Marie joked that that would mean John would wind up writing\nit. They both chuckled, but I wasn\'t comfortable with it. It\'s true that\nIain hasn\'t been doing his best work recently, but I still think they\'re\nbeing unfair. I reminded them that Iain helped me in the beginning (even\nthough it might seem like ages ago) and maybe he was just really shaken up\nby whatever family emergency he went through. They both got quiet and we\nturned back to reviewing the document. </p>\n\n<p> Once we finished going through the document, the three of us agreed to\nreview it and make notes/corrections/suggestions for next week. As we were\nall getting ready to leave, Iain popped in the door of the meeting room.\nAfraid they might say something mean, I quickly asked him if he was doing\nOK and what had happened. He said his brother was going through something.\nWe made sure he had a copy and knew what we\'d all be doing for next week.\n</p>\n\n<p> I did review the document, but I\'d just put it together last week, so I\ndidn\'t have much to add to it. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(148,11,8,'<p> Iain was already there when I arrived at the meeting this week. Marie\nhas got a great eye for detail, as she found a ton of spelling and\nformatting errors that everyone else missed. I volunteered to take\neveryone\'s copies and make all the changes for the draft that we are to\nturn in next week in class. John pointed out the section that was still\nmissing or incomplete. Iain said it was too late to get it into the draft\nbut that it should be fine to include a note that it will be in the final\nversion. He also made it clear that he wasn\'t writing it. Everyone else was\nuncomfortable with that approach. Marie volunteered to draft it and get it\nto me by the middle of the week. I figured I wouldn\'t have had the time to\ndo both the writing and the editing, but this I can handle. I agreed to\nincorporate the new content if she got it to me in time. Iain offered Marie\nsome good suggestions on how to approach the new content. </p>\n\n<p> It took about another hour to apply all the changes, and Marie got the\nnew content to me in plenty of time to incorporate, as well. It probably\ntook me an hour and a half. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(149,11,9,'<p> I forgot to provide copies to everyone before class and they seemed\nupset about it, but I did have one to turn in to the instructor. Now we get\nto wait for feedback. We do, however, already know of some work that needs\ndone. </p>\n\n<p> Last week, Marie and John (who wound up collaborating on the new\nsection) noticed some problems in the draft that needed to be corrected.\nAlso, it seems Iain didn\'t do much at all on Marie\'s work &mdash; and John\npointed out a number of areas that could be improved. As Iain was getting\nready to leave for another meeting, Marie suggested that we add some\ndiagrams to illustrate some of our points. The three of us sketched out\nconcepts and when the group settled, it was clear that Marie was eager to\ntake on this task. No one fought her for it. John offered to reread the\nentire document. The meeting ended early because Iain had another\nappointment to get to. </p>\n\n<p> I didn\'t have much to do this week for this class, so I got to focus on\nmy other classes for a change. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(150,11,10,'<p> As I was on my way to the meeting, I heard from Iain. He told me that\nhe\'d just got free, front-row tickets to the game tonight, so he wouldn\'t\nbe coming to our meeting. I can\'t believe he skipped another meeting, but\nthere wasn\'t much I could do, so I told John and Marie when I got to our\nmeeting.  </p>\n\n<p> John was already looking at the images Marie put together, and he\ndidn\'t seem to like them much. They were a bit more artistic than we\'d\nexpected, but that\'s Marie! He said they were quirky (and they were), but\nthey included all the right details to get the point across. They were\nfunctional but also eye-catching and memorable, and I said so. John seemed\nto still be a little uncomfortable with them and mentioned that he\'d like\nIain\'s opinion, but ultimately just made a few small requests. His changes\nwould make the images less fun, but Marie and I both accepted them because\nthey made John more comfortable. </p>\n\n<p> John made many changes to the document and some of them were pretty\nbig. We walked through them at a high level and everyone agreed, so we\nmoved on to prepare for the presentation. We worked out a basic structure\nfor it and decided that we should each put together notes or a script for\nwhat we would say during our part so we could practice. I passed this on to\nIain. </p>\n\n<p> Writing up this script took me a while, because I dread the thought of\nspeaking in front of people. I managed to get something down, though. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(151,11,11,'<p> In class, our instructor returned the drafts to the groups and we met\nbriefly during class to review it. Unfortunately, while we knew there were\nlots of problems with that version, the instructor only left five comments\nin our paper. I guess they wisely expected much of it to change since it\nwas only a draft. One read \"this shows promise,\" two corrected grammar\nissues, one requested that page numbers be added and one suggested we\nclarify that section Marie wrote initially, saying it was a novel approach\nand that it should therefore be explained more clearly and thoroughly. </p>\n\n<p> Everyone arrived on time for our meeting and the discussion began with\nhow little feedback we got and whether this meant the paper was in great\nshape or that instructor simply didn\'t really read the whole thing. Either\nway, we had the feedback we\'d been waiting for and it was time to move\nforward. </p>\n\n<p> Marie asked Iain to review her section again and he declined, saying\nthat he\'d already reviewed it once at her request. Marie responded with a\nsnarky tone that she\'d like him to \"actually read it this time.\" This\nturned into an argument with Marie accusing Iain of not participating and\nIain responding that her work was of low quality. John jumped in and\ndefended Marie, saying that at least she was showing up and trying. At this\npoint, I raised my voice and everyone quieted down. I reminded everyone of\nthe upcoming presentation, and that yelling at each other wouldn\'t help us\nprepare. Iain argued that he didn\'t have time to go through the entire\npaper, but reluctantly agreed to take a look at Marie\'s section again by\nnext week. </p>\n\n<p> The rest of the meeting was spent working through the presentation. The\ngroup used a PowerPoint Marie thought to put together in a practice run. We\nmade a few adjustments, but it was nice to have it. Iain really seems to\nhave put a lot of time into his part, and he sounded very polished. He also\nhad lots of suggestions for the rest of us. By the end of the meeting, the\npresentation was still running too long &mdash; particularly John\'s part.\nHe doesn\'t seem very experienced at this sort of thing. He included way too\nmuch and said it way too fast. He\'ll have to cut a bunch of it and\npractice, but with two weeks left, I still feel pretty good about it. </p>\n\n<p> I spent about half an hour revising my portion of the presentation\nduring the week. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(152,11,12,'<p> Everyone arrived on time for the meeting this week. </p>\n\n<p> Iain provided feedback on Marie\'s section and, in reading through it,\nit became clear that making his changes would require changes throughout\nthe paper. It was exactly the kind of feedback Marie wanted in the first\nplace. However, so close to the end of class, it would be tough to make\nthem, because no one in our group had the time to carry all the changes\nthrough &mdash; especially with everyone getting ready for final projects\nand exams. I can\'t believe he hasn\'t bothered to even read the paper until\nnow. What we had wasn\'t wrong or anything, but these changes would make it\nstand out. I really don\'t understand why Iain didn\'t make the changes when\nhe saw they were needed </p>\n\n<p> I volunteered to make the changes because I think they will make an\nimpression on the instructor. I said I could find time to make the changes\nthis week if someone else would read through it to make sure I didn\'t miss\nanything. John volunteered to do that.  </p>\n\n<p> The presentation was much better and, after three practice runs, it\nsounded smooth. While it was still running too long, we agreed that\neveryone would probably speak faster in class and the instructor probably\nwouldn\'t care if we ran over by a little. </p>\n\n<p> Making the changes took me about three hours that I really didn\'t have\nto spend, but at least it\'s done. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(153,11,13,'<p> The presentation went very smoothly. I was nervous, but I knew what I\nwas talking about and I think that showed. The audience asked some good\nquestions, which meant that they understood the presentation.  For some\nreason, Iain stepped forward to answer almost every question. It was like\nhe was trying to show the instructor he\'d done more than he actually did.\nOnce, John started to answer and Iain seemed not to notice &mdash; he just\nwent ahead and answered it himself. Also, we should have discussed clothes\nbeforehand because we all dressed up except for John. He looked out of\nplace in his usual jeans and a sweater. </p>\n\n<p> At our meeting, Iain commented on John\'s casual clothes, and John\napologized. I felt it was unfair, because he was obviously already\nembarrassed about it.  He knew his part and was well prepared, and he has\nworked hard throughout the project. Aside from that, we all felt good about\nthe work we\'d done and I expect we\'ll get positive feedback and good\ngrades. I shared my updated version of the paper and a quick review of the\nchanges, but everyone knew what to expect and no one was surprised. John\ntook it to do his review and we ended early because there wasn\'t much else\nto do. </p>\n\n<p> As we wrapped up, Marie asked John to send her a copy as soon as he was\nfinished so she could take one last crack at it before we turn it in. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(154,11,14,'<p> At our final meeting, we reviewed the paper to make sure it was ready\nfor submission at the end of the week. Iain volunteered to do a final read,\nprint the document and send it to the instructor. Marie started to attack\nIain for not helping the group &mdash; I think she felt like he was trying\nto steal credit for all our work at the end &mdash; just like he did in the\npresentation. John seemed tired and tried to calm her down and I joined\nhim. John suggested that Marie submit the latest version she had at the\ndeadline. If Iain could get his updates to her by that time, great, but\notherwise she should use what she had. Iain was annoyed, but agreed. </p>\n\n<p> After the deadline, Marie confirmed that Iain got his changes to her in\ntime for her to submit them, and she sent a copy of the finished product to\nthe entire team. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(155,12,1,'<p> In group time the first week, we began by setting up weekly team\nmeetings. The rest of the group seem to be freshmen. They\'re all so nervous\nabout this \"huge project\" but, as a junior, I know it\'s not that big of a\ndeal. I just hope that I don\'t wind up getting stuck rewriting the project\nat the last minute after they mess everything up. </p>\n\n<p> The project was fairly open-ended, so we brainstormed topic ideas for\nmost of the first meeting. I suggested some of the more obvious topics and\nwas a little shocked when they all loved them. John tried to be involved,\nbut his suggestions were pretty weak. When Marie spoke, I couldn\'t tell if\nshe was serious or not. Her suggestions were funny, but I\'m not sure that\nwas her intent. She definitely has a unique approach. Hannah didn\'t talk\nmuch. She seemed to be paying attention, but I guess she\'s shy. Pretty\nsoon, everyone built on my suggestions. </p>\n\n<p> Before the meeting ended, we narrowed it down to three ideas. Marie\nrecommended we each look for resources on one topic and then report back\nnext time. It seemed like a good idea and everyone else agreed. I spoke up\nquickly for a topic that I\'ve done some work on it in another class &mdash;\nit was also the most interesting. John spoke up for another and, after a\nmoment, Marie took the last topic. She didn\'t sound thrilled about it,\nthough. That left Hannah without a topic, so she said she\'d search for\nadditional materials on my topic. She seems nice, but we\'ll see where that\ngoes. </p>\n\n<p> The research for this week didn\'t take very long because I was able to\nuse some materials from that previous class. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(156,12,2,'<p> Hannah had a breakdown when she arrived because she couldn\'t find much\n&mdash; she\'s clearly out of her depth. I pointed out that I\'d got more\nthan enough to start with and I offered to work with her after the meeting\nto give her some tips and tricks. </p>\n\n<p> After reviewing the topics and the materials everyone found, there was\nfighting over which topic to focus on. Marie decided to start organizing\nthings into lists of pros and cons to make it easier to understand, and\nthen the group held a vote. For some reason, the three of them decided to\ngo with the topic John had researched &mdash; even though my topic would be\nmuch easier and isn\'t boring. This makes no sense at all and this whole\nproject\'s going to be a nightmare. </p>\n\n<p> The obvious next step was to find more materials, so we divided up the\nmajor subtopics. We decided everyone would return next week with summaries\nof what they\'d found to make it easier for the group to get moving quickly.\n</p>\n\n<p> I met with Hannah two days later and she\'s nice and pretty bright. I\nshowed her how to pull more keywords out of materials and to look in the\nbibliographies for more ideas. After about two and a half hours, we had\nsome solid references. She went through them and wrote summaries, and then\nI verified them. She was probably just overwhelmed at first, because she\ndid a pretty good job. Now she\'s on the right track. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(157,12,3,'<p> In this week\'s meeting, we began sorting through the materials.\nTogether, Hannah and I had easily the best materials and summaries, and we\ndidn\'t spend much time reviewing it. John\'s materials, on the other hand,\nwere difficult to understand and his help was required to interpret what he\nmeant. He seemed embarrassed and told us he\'d rewrite the summaries to make\nthem clearer. Marie\'s summaries were interesting and some of them were\nfunny, but I wasn\'t sure how they fit in. I tried not to look too confused,\nbut everyone seemed unsure of how to respond. After some awkward moments, I\nasked her a few direct questions that seemed to help her see what we need.\nThe team decided there was still plenty of time, though, and that she could\ntake another week to try again. After all, John would be doing the same.\n</p>\n\n<p> I got to relax this week without any tasks for this project. Looks like\nthis project isn\'t going to take too much of my time after all. That\'s\ngreat, because I\'ve got a heavy course load this semester. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(158,12,4,'<p> I arrived a little late to the meeting, but Hannah wasn\'t there at all.\nShe wasn\'t even in class and no one had heard anything from her. The\ninstructor would tell us if she dropped the class, right? </p>\n\n<p> When it looked like she wouldn\'t be coming, we began working through\nMarie\'s updated materials. John and I exchanged concerned looks. After a\nfew more discussions that were reminiscent of last week, I began pushing to\nmove on and John was happy to join that effort. Marie went with it, even\nthough she was clearly confused. Much less time was needed for John\'s\nmaterials because they were in much better shape now. John volunteered to\nput together what we had for the assignment due next week, and we both\npushed to get started on an early draft. We split up the tasks of\nsynthesizing the sections. </p>\n\n<p> I caught John outside after the meeting ended, and we discussed Marie\nand Hannah. We discussed the possibility of talking to the instructor, but\ndecided to wait another week or so. I think we can probably use some of\nMarie\'s resources. John volunteered to proofread her summaries and I said\nI\'d look for additional content. </p>\n\n<p> My searching was pretty easy, and I only needed to spend about half an\nhour on both that and summarizing what I\'d found. For the first draft of my\nportion of the paper, I spent about an hour writing &mdash; there will be\nplenty of time to fix it up later, and I have other classwork. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(159,12,5,'<p> John turned in our assignment during class, and our instructor gave us\nsome time in class to meet. We discussed our progress, but none of us\nexpected to have this time, so no one brought their materials to review. No\none seemed to want to be there, so we all left early instead. </p>\n\n<p> Hannah was back this week and wearing a cast. She slipped on some ice\nand landed in the hospital for a week. Impressively, she brought a first\ndraft of the section that was assigned to her when she was out &mdash; John\nemailed meeting notes to the whole group. </p>\n\n<p> Marie\'s constant attempts to be weird are really getting on my nerves.\nAlso, for some reason, everyone seemed to treat this first draft like it\nwas supposed to be the final complete version; everyone was visibly\ndisappointed with what I brought, but that\'s fine. There\'s lots of time\nleft. Marie was clearly nervous when we reviewed her work, but I was\nactually pleasantly surprised by what she\'d done. Maybe that showed on\neveryone\'s faces because when she looked up at us, she seemed to relax.\nJohn and Hannah both pointed out a number of rough spots, but I\'m no longer\nnervous about her ability and she seemed to be visibly relieved. Hannah\nexplained that her own work was incomplete, and it clearly was, but she was\nin the hospital. The fact that she brought anything at all was awesome. I\nhonestly didn\'t pay too much attention to John\'s piece because I figured it\nwas probably pretty good. I started thinking about an upcoming quiz in one\nof my more advanced classes. I tried to focus and participate, but they\ndidn\'t really need me there. </p>\n\n<p> Marie suggested we hand off our portion to another team member for a\nmore thorough review, even though I didn\'t think we were ready for that\nyet. John immediately volunteered to take mine, so I claimed his &mdash; it\nwas in pretty good shape already and that\'d give me some extra time to\nstudy for my other classes. Hannah asked for more time to finish her\nsection and then Marie specifically asked me to review hers; she took\nJohn\'s. I probably should be flattered, but I\'d really rather have the time\ninstead. </p>\n\n<p> Marie took some notes on her work before we traded papers, so that made\nit pretty quick and easy to make those changes. I quickly read through the\nwhole thing and found that it was kind of a mess. I set it aside so I could\nspend more time on it later in the week when my other work was done. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(160,12,6,'<p> The morning of our meeting, I picked up Marie\'s paper again but I just\ncouldn\'t manage to get through it. It seems that she tried hard to be\ndifferent and come up with a unique perspective, but the end result doesn\'t\ncover the main points and really doesn\'t make any sense. Just as I was\nstarting to make some sense of what she wrote, my brother asked me to come\nover. He\'s been having a rough time since his discharge and he told me he\nneeded to get out. I emailed the team to let them know I had to take care\nof a family thing, sent them what I had and then I drove back home to see\nhim. </p>\n\n<p> I had a massive headache the next morning, but I knew it\'d go away and\nmy brother seemed better. Marie had emailed me to let me know they decided\nto cut the next meeting down to only half an hour to give everyone time to\nprepare for mid-terms in other classes. A good idea, but I\'d have to really\nrush to make it for a short meeting because one of my own study groups was\nset to end when this one starts &mdash; across campus. As a bonus, though,\nMarie\'s paper was out of my hands. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(161,12,7,'<p> I arrived late because of the study group and Hannah asked if\neverything was OK. I explained that something came up with my brother but\nthat he was OK and they gave me a copy of the assembled document &mdash; it\nseems they\'re further along than I thought! We\'re all supposed to review\nthe whole document for next week. </p>\n\n<p> The paper looked pretty good, actually. It seems that Hannah put it\ntogether well and even identified a new section that will need to be\nwritten, as well as a few other changes here and there. They were good\nideas, but the new section will certainly have to wait for the final\nversion, because there\'s no way we can get it written and added into the\ndraft due in two weeks. All told, I probably spent about half an hour going\nthrough this version and I didn\'t have many comments. I didn\'t spend too\nmuch time on Marie\'s work, either. I just didn\'t have the energy. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(162,12,8,'<p> I arrived early this week. They\'ve been making decent progress without\nme though, so it\'s not a problem. This time John arrived late because his\nexam had run late. </p>\n\n<p> Marie has a great eye for detail, as she found a ton of spelling and\nformatting errors that everyone else missed. Hannah volunteered to take\neveryone else\'s copies and make all the changes for the draft that we are\nto turn in next week in class. John pointed out the sections that are still\nmissing or incomplete, but I said it\'s too late to get it into the draft\nand that it should be fine to include a note that it will be in the final\nversion. I certainly didn\'t have the time to write it. The rest of the\ngroup disagreed with me, though. They decided to try to get it done, and\nMarie volunteered to draft the two sections and get them to Hannah by the\nmiddle of the week so Hannah could incorporate the changes. I couldn\'t\nimagine how they can find the time, but I offered Marie some suggestions on\nhow to approach the new content, and everyone seemed to value my\nrecommendations. </p>\n\n<p> Fortunately, I managed to get away with no work for this group this\nweek because my other classes are keeping me very busy. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(163,12,9,'<p> Hannah brought our paper to class and turned it in to the instructor.\nNow we get to wait for feedback while we continue to work. </p>\n\n<p> John and Marie met last week and worked together; while working through\nit, they noticed a bunch of problems in the draft that will need\ncorrecting. Many of them were in Marie\'s work, and she got upset that I\ndidn\'t fix them when she asked me to look at it. Why didn\'t she write it\nlike that in the first place? Eventually, we moved on when Marie suggested\nwe add some diagrams to illustrate some of our points. Even though I had to\ngo to another meeting, I stuck around a bit while the group sketched some\nideas. However, I really did have to go and when they seemed to have it\nunder control, I left. </p>\n\n<p> Again, I was lucky not to have much to do in this class this week. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(164,12,10,'<p> My buddy offered me his extra seat to the game, and the seats were\namazing, so I accepted without realizing this was the night of our meeting.\nAs soon as I remembered, I let Hannah know I wouldn\'t be there.  </p>\n\n<p> When I got back, there was an email from Hannah asking me to look at\nthe report with Marie\'s images. She also asked me to prepare notes or a\nscript for my part in the presentation so we can practice together next\nweek.  </p>\n\n<p> The images were odd, but I sort of liked them.  </p>\n\n<p> Preparing for my part took less than half an hour, so I took some extra\ntime and practiced it on a friend. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(165,12,11,'<p> In class, the instructor returned the drafts and our team met briefly\nduring class to review it. Unfortunately, while we knew there were lots of\nproblems with that version, the instructor left only five comments in the\npaper. I guess they expected much of it to change since it was only a\ndraft. One read \"this shows promise,\" two corrected grammar issues, one\nrequested that page numbers be added and one suggested clarifying some of\nMarie\'s work. It read that it was a novel approach and that it should\ntherefore be explained more clearly and thoroughly. </p>\n\n<p> During the meeting, we were all on time and the discussion began with\nhow little feedback the group got &mdash; we figured that the instructor\nprobably didn\'t really read the whole thing. Either way, we had our\nfeedback and it was time to move forward. </p>\n\n<p> Predictably, Marie asked me once again to review her section. This\nannoyed me because I really don\'t want to look at it again. Marie pushed\nwith a snarky tone that she\'d like me to \"actually read it this time.\" Soon\nshe was accusing me of not participating. Maybe I was out of line, but I\nresponded that the low quality of her contribution made it very difficult\nto work with. John jumped in on Marie\'s side and then Hannah raised her\nvoice and quieted everyone down. She reminded us of the presentation coming\nin two weeks and that yelling at each other wouldn\'t help us get prepared.\nI said I\'d look at Marie\'s section again for next week. </p>\n\n<p> We spent the rest of the meeting working through the presentation. We\nused a PowerPoint Marie put together in a practice run. We had to change it\na bit, but it was nice to have something there to work with. I think my\nsection is pretty good and offered a few suggestions for everyone else.\nEven after three rounds of practice and changes, the presentation ran too\nlong &mdash; particularly John\'s part. I suspect he\'s not very experienced\nat this sort of thing, because he tried to include way too much and said it\nway too fast. However, we still have time. </p>\n\n<p> I spent about an hour and a half working on Marie\'s section during the\nweek. Unfortunately, it really would have been better to get to this\nearlier because my recommendations will mean changes throughout the paper,\nand I didn\'t have time to make them all this past week. Why didn\'t anyone\nelse see this? </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(166,12,12,'<p> Everyone arrived on time for the meeting this week. </p>\n\n<p> We began by walking through the changes I proposed, making it clear\nthat these changes would require larger changes throughout the paper. We\ntalked about forgetting them because what we\'ve got is not wrong, but\neveryone agreed that making the changes would give us a stronger paper.\nThere just isn\'t much time &mdash; especially with everyone getting ready\nfor their final projects and exams in other classes. Fortunately, Hannah\nvolunteered to make the changes this week, if someone else would promise to\nread through it next week to make sure she didn\'t miss anything. After a\npause, John volunteered. Good that they stepped up because I don\'t have\ntime for any of this. </p>\n\n<p> This week the presentation was much better and it sounded smooth. While\nit still ran too long, we agreed that everyone will probably speak faster\nin class, and the instructor probably wouldn\'t care if we ran over a bit.\n</p>\n\n<p> I practiced a few more times during the week when I was able to find a\nmoment. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(167,12,13,'<p> The presentation went very smoothly. Hannah was a bit nervous, but she\nknew what she was talking about and it showed. The audience asked some good\nquestions, which showed that they understood our presentation. I answered\nmost of the questions that came our way because no one else seemed up for\nit. We should have discussed clothes beforehand, because I came wearing a\nsuit, and Marie and Hannah were both wearing dress skirts and blouses. John\nlooked out of place in his usual jeans and a sweater. </p>\n\n<p> I think we\'ll get positive feedback and good grades. Hannah shared her\nupdated version of the paper and after a quick review of the changes, which\nweren\'t huge. As promised, John took the paper home to review it more\nclosely. We ended early because I had to leave for another group and really\nthere was not much else to do. </p>\n\n<p> As we wrapped up, Marie asked John to send her a copy as soon as he\'s\nfinished so she could take one last crack at it. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL),
(168,12,14,'<p> At the final meeting, we reviewed the paper to make sure it was ready\nfor submission at the end of the week. I volunteered to do a final read,\nprint the document and send it to the instructor, but Marie said she was\nnot finished with it and that she\'d like to take some more time with it.\nShe eventually agreed to get it to me the evening of the next day. Hannah\nsuggested that I might not have enough time and asked that Marie submit the\nlatest version at the deadline. She said that if I was able to get Marie my\nupdates by that time, they\'d go in, but otherwise we\'d send what we\'d got.\nI feel like they don\'t trust me and that\'s annoying, but I agreed. </p>\n\n<p> I got Marie the content in plenty of time and she got it in in time.\nShe confirmed this and sent a copy of the finished product to the entire\nteam. </p>\n','2019-09-23 11:40:17','2019-09-23 11:40:17',NULL);
/*!40000 ALTER TABLE `weeks` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-02-18 21:56:56
