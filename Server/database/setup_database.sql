-- ==============================================================================
-- OPEN//77 Life-Sim RP — Esquema Completo de Banco de Dados (MariaDB / MySQL InnoDB)
-- Servidor: 127.0.0.1:3306 (XAMPP / MariaDB 10.4.32+)
-- Banco de Dados: open77_lifesim
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS `open77_lifesim` 
    DEFAULT CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

USE `open77_lifesim`;

-- ------------------------------------------------------------------------------
-- 1. TABELAS OFICIAIS DO CORE OPEN//77 (Aparência, Roupas e Guarda-Roupa)
-- ------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `open77_characters` (
  `user_id` char(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `character_key` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'default',
  `character_id` char(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `body_family` varchar(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `status` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`, `character_key`),
  UNIQUE KEY `uq_open77_character_id` (`character_id`),
  CONSTRAINT `chk_open77_character_family` CHECK (`body_family` IN ('female', 'male'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `open77_player_appearances` (
  `user_id` char(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `character_key` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'default',
  `schema_version` int(10) unsigned NOT NULL,
  `game_build` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `catalog_digest` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `revision` bigint(20) unsigned NOT NULL DEFAULT 1,
  `logical_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`, `character_key`),
  CONSTRAINT `chk_open77_appearance_schema` CHECK (`schema_version` = 1),
  CONSTRAINT `chk_open77_appearance_revision` CHECK (`revision` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `open77_character_presentation` (
  `user_id` char(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `character_key` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `equipment_json` longtext NOT NULL,
  `wardrobe_json` longtext NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`, `character_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------------------------
-- 2. TABELAS DO GAMEMODE LIFE-SIM RP (VICCS CyberLife)
-- ------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `players` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `license` varchar(64) NOT NULL,
  `user_id` char(36) DEFAULT NULL,
  `name` varchar(64) NOT NULL,
  `eurodollars` bigint(20) NOT NULL DEFAULT 1000,
  `bank_balance` bigint(20) NOT NULL DEFAULT 5000,
  `job` varchar(32) NOT NULL DEFAULT 'unemployed',
  `job_grade` int(11) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `license` (`license`),
  INDEX `idx_players_user_id` (`user_id`),
  CONSTRAINT `chk_eurodollars_positive` CHECK (`eurodollars` >= 0),
  CONSTRAINT `chk_bank_balance_positive` CHECK (`bank_balance` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `characters_vitals` (
  `license` varchar(64) NOT NULL,
  `nutrition` decimal(5,2) NOT NULL DEFAULT 100.00,
  `hydration` decimal(5,2) NOT NULL DEFAULT 100.00,
  `energy` decimal(5,2) NOT NULL DEFAULT 100.00,
  `hygiene` decimal(5,2) NOT NULL DEFAULT 100.00,
  `neural_stability` decimal(5,2) NOT NULL DEFAULT 100.00,
  `stress_factor` decimal(5,2) NOT NULL DEFAULT 0.00,
  `implants_count` int(11) NOT NULL DEFAULT 0,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`license`),
  CONSTRAINT `fk_vitals_player` FOREIGN KEY (`license`) REFERENCES `players` (`license`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `inventories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `owner` varchar(64) NOT NULL,
  `type` varchar(24) NOT NULL DEFAULT 'player',
  `items` longtext NOT NULL,
  `max_weight` decimal(6,2) NOT NULL DEFAULT 35.00,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_inventories_owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `properties` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `megabuilding_id` varchar(16) NOT NULL,
  `interior_coords` longtext NOT NULL,
  `owner_license` varchar(64) DEFAULT NULL,
  `bucket_id` int(11) NOT NULL,
  `daily_rent` int(11) NOT NULL DEFAULT 150,
  `rent_due_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `furniture_data` longtext NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `bucket_id` (`bucket_id`),
  INDEX `idx_properties_owner` (`owner_license`),
  CONSTRAINT `fk_properties_player` FOREIGN KEY (`owner_license`) REFERENCES `players` (`license`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `bank_transactions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `sender_license` varchar(64) DEFAULT NULL,
  `receiver_license` varchar(64) DEFAULT NULL,
  `amount` bigint(20) NOT NULL,
  `type` varchar(32) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_transactions_sender` (`sender_license`),
  INDEX `idx_transactions_receiver` (`receiver_license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
