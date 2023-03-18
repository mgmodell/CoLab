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
('environment','test','2023-03-17 21:23:55.438678','2023-03-17 21:23:55.438678'),
('schema_sha1','218ab711be873ee528f3b0fabf022ddfc800a42b','2023-03-17 21:23:55.444097','2023-03-17 21:23:55.444097');
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
  `file_sub` tinyint(1) NOT NULL DEFAULT 0,
  `link_sub` tinyint(1) NOT NULL DEFAULT 0,
  `text_sub` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `index_assignments_on_course_id` (`course_id`),
  KEY `index_assignments_on_project_id` (`project_id`),
  KEY `index_assignments_on_rubric_id` (`rubric_id`),
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `behaviors`
--

LOCK TABLES `behaviors` WRITE;
/*!40000 ALTER TABLE `behaviors` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `candidate_feedbacks`
--

LOCK TABLES `candidate_feedbacks` WRITE;
/*!40000 ALTER TABLE `candidate_feedbacks` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cip_codes`
--

LOCK TABLES `cip_codes` WRITE;
/*!40000 ALTER TABLE `cip_codes` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `emails`
--

LOCK TABLES `emails` WRITE;
/*!40000 ALTER TABLE `emails` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `factor_packs`
--

LOCK TABLES `factor_packs` WRITE;
/*!40000 ALTER TABLE `factor_packs` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `factors`
--

LOCK TABLES `factors` WRITE;
/*!40000 ALTER TABLE `factors` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `genders`
--

LOCK TABLES `genders` WRITE;
/*!40000 ALTER TABLE `genders` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `home_countries`
--

LOCK TABLES `home_countries` WRITE;
/*!40000 ALTER TABLE `home_countries` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `home_states`
--

LOCK TABLES `home_states` WRITE;
/*!40000 ALTER TABLE `home_states` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `languages`
--

LOCK TABLES `languages` WRITE;
/*!40000 ALTER TABLE `languages` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `narratives`
--

LOCK TABLES `narratives` WRITE;
/*!40000 ALTER TABLE `narratives` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quotes`
--

LOCK TABLES `quotes` WRITE;
/*!40000 ALTER TABLE `quotes` DISABLE KEYS */;
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
  `active` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_rubrics_on_name_and_version_and_parent_id` (`name`,`version`,`parent_id`),
  KEY `index_rubrics_on_parent_id` (`parent_id`),
  KEY `index_rubrics_on_school_id` (`school_id`),
  KEY `index_rubrics_on_user_id` (`user_id`),
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scenarios`
--

LOCK TABLES `scenarios` WRITE;
/*!40000 ALTER TABLE `scenarios` DISABLE KEYS */;
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
('20230219025034'),
('20230305001118'),
('20230317191346');
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schools`
--

LOCK TABLES `schools` WRITE;
/*!40000 ALTER TABLE `schools` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `styles`
--

LOCK TABLES `styles` WRITE;
/*!40000 ALTER TABLE `styles` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `themes`
--

LOCK TABLES `themes` WRITE;
/*!40000 ALTER TABLE `themes` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `weeks`
--

LOCK TABLES `weeks` WRITE;
/*!40000 ALTER TABLE `weeks` DISABLE KEYS */;
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

-- Dump completed on 2023-03-17 23:16:07
