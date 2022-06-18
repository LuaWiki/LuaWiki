SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for archive
-- ----------------------------
DROP TABLE IF EXISTS `archive`;
CREATE TABLE `archive`  (
  `ar_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `ar_namespace` int(11) NOT NULL DEFAULT 0,
  `ar_title` varbinary(255) NOT NULL DEFAULT '',
  `ar_comment_id` bigint(20) UNSIGNED NOT NULL,
  `ar_actor` bigint(20) UNSIGNED NOT NULL,
  `ar_timestamp` binary(14) NOT NULL,
  `ar_minor_edit` tinyint(4) NOT NULL DEFAULT 0,
  `ar_rev_id` int(10) UNSIGNED NOT NULL,
  `ar_deleted` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `ar_len` int(10) UNSIGNED NULL DEFAULT NULL,
  `ar_page_id` int(10) UNSIGNED NULL DEFAULT NULL,
  `ar_parent_id` int(10) UNSIGNED NULL DEFAULT NULL,
  `ar_sha1` varbinary(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`ar_id`) USING BTREE,
  UNIQUE INDEX `ar_revid_uniq`(`ar_rev_id`) USING BTREE,
  INDEX `ar_name_title_timestamp`(`ar_namespace`, `ar_title`, `ar_timestamp`) USING BTREE,
  INDEX `ar_actor_timestamp`(`ar_actor`, `ar_timestamp`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for bot_passwords
-- ----------------------------
DROP TABLE IF EXISTS `bot_passwords`;
CREATE TABLE `bot_passwords`  (
  `bp_user` int(10) UNSIGNED NOT NULL,
  `bp_app_id` varbinary(32) NOT NULL,
  `bp_password` tinyblob NOT NULL,
  `bp_token` binary(32) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
  `bp_restrictions` blob NOT NULL,
  `bp_grants` blob NOT NULL,
  PRIMARY KEY (`bp_user`, `bp_app_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for category
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category`  (
  `cat_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `cat_title` varbinary(255) NOT NULL,
  `cat_pages` int(11) NOT NULL DEFAULT 0,
  `cat_subcats` int(11) NOT NULL DEFAULT 0,
  `cat_files` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`cat_id`) USING BTREE,
  UNIQUE INDEX `cat_title`(`cat_title`) USING BTREE,
  INDEX `cat_pages`(`cat_pages`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for categorylinks
-- ----------------------------
DROP TABLE IF EXISTS `categorylinks`;
CREATE TABLE `categorylinks`  (
  `cl_from` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `cl_to` varbinary(255) NOT NULL DEFAULT '',
  `cl_sortkey` varbinary(230) NOT NULL DEFAULT '',
  `cl_sortkey_prefix` varbinary(255) NOT NULL DEFAULT '',
  `cl_timestamp` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0),
  `cl_collation` varbinary(32) NOT NULL DEFAULT '',
  `cl_type` enum('page','subcat','file') CHARACTER SET `binary` COLLATE `binary` NOT NULL DEFAULT 'page',
  PRIMARY KEY (`cl_from`, `cl_to`) USING BTREE,
  INDEX `cl_sortkey`(`cl_to`, `cl_type`, `cl_sortkey`, `cl_from`) USING BTREE,
  INDEX `cl_timestamp`(`cl_to`, `cl_timestamp`) USING BTREE,
  INDEX `cl_collation_ext`(`cl_collation`, `cl_to`, `cl_type`, `cl_from`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for change_tag
-- ----------------------------
DROP TABLE IF EXISTS `change_tag`;
CREATE TABLE `change_tag`  (
  `ct_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `ct_rc_id` int(10) UNSIGNED NULL DEFAULT NULL,
  `ct_log_id` int(10) UNSIGNED NULL DEFAULT NULL,
  `ct_rev_id` int(10) UNSIGNED NULL DEFAULT NULL,
  `ct_params` blob NULL,
  `ct_tag_id` int(10) UNSIGNED NOT NULL,
  PRIMARY KEY (`ct_id`) USING BTREE,
  UNIQUE INDEX `change_tag_rc_tag_id`(`ct_rc_id`, `ct_tag_id`) USING BTREE,
  UNIQUE INDEX `change_tag_log_tag_id`(`ct_log_id`, `ct_tag_id`) USING BTREE,
  UNIQUE INDEX `change_tag_rev_tag_id`(`ct_rev_id`, `ct_tag_id`) USING BTREE,
  INDEX `change_tag_tag_id_id`(`ct_tag_id`, `ct_rc_id`, `ct_rev_id`, `ct_log_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for change_tag_def
-- ----------------------------
DROP TABLE IF EXISTS `change_tag_def`;
CREATE TABLE `change_tag_def`  (
  `ctd_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `ctd_name` varbinary(255) NOT NULL,
  `ctd_user_defined` tinyint(1) NOT NULL,
  `ctd_count` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`ctd_id`) USING BTREE,
  UNIQUE INDEX `ctd_name`(`ctd_name`) USING BTREE,
  INDEX `ctd_count`(`ctd_count`) USING BTREE,
  INDEX `ctd_user_defined`(`ctd_user_defined`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for comment
-- ----------------------------
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment`  (
  `comment_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `comment_hash` int(11) NOT NULL,
  `comment_text` blob NOT NULL,
  `comment_data` blob NULL,
  PRIMARY KEY (`comment_id`) USING BTREE,
  INDEX `comment_hash`(`comment_hash`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cu_changes
-- ----------------------------
DROP TABLE IF EXISTS `cu_changes`;
CREATE TABLE `cu_changes`  (
  `cuc_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `cuc_namespace` int(11) NOT NULL DEFAULT 0,
  `cuc_title` varbinary(255) NOT NULL DEFAULT '',
  `cuc_user` int(11) NOT NULL DEFAULT 0,
  `cuc_user_text` varbinary(255) NOT NULL DEFAULT '',
  `cuc_actiontext` varbinary(255) NOT NULL DEFAULT '',
  `cuc_comment` varbinary(255) NOT NULL DEFAULT '',
  `cuc_minor` tinyint(1) NOT NULL DEFAULT 0,
  `cuc_page_id` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `cuc_this_oldid` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `cuc_last_oldid` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `cuc_type` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `cuc_timestamp` binary(14) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
  `cuc_ip` varbinary(255) NULL DEFAULT '',
  `cuc_ip_hex` varbinary(255) NULL DEFAULT NULL,
  `cuc_xff` varbinary(255) NULL DEFAULT '',
  `cuc_xff_hex` varbinary(255) NULL DEFAULT NULL,
  `cuc_agent` varbinary(255) NULL DEFAULT NULL,
  `cuc_private` mediumblob NULL,
  PRIMARY KEY (`cuc_id`) USING BTREE,
  INDEX `cuc_ip_hex_time`(`cuc_ip_hex`, `cuc_timestamp`) USING BTREE,
  INDEX `cuc_user_ip_time`(`cuc_user`, `cuc_ip`, `cuc_timestamp`) USING BTREE,
  INDEX `cuc_xff_hex_time`(`cuc_xff_hex`, `cuc_timestamp`) USING BTREE,
  INDEX `cuc_timestamp`(`cuc_timestamp`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cu_log
-- ----------------------------
DROP TABLE IF EXISTS `cu_log`;
CREATE TABLE `cu_log`  (
  `cul_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `cul_timestamp` binary(14) NOT NULL,
  `cul_user` int(10) UNSIGNED NOT NULL,
  `cul_user_text` varbinary(255) NOT NULL,
  `cul_reason` varbinary(255) NOT NULL,
  `cul_type` varbinary(30) NOT NULL,
  `cul_target_id` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `cul_target_text` blob NOT NULL,
  `cul_target_hex` varbinary(255) NOT NULL DEFAULT '',
  `cul_range_start` varbinary(255) NOT NULL DEFAULT '',
  `cul_range_end` varbinary(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`cul_id`) USING BTREE,
  INDEX `cul_user`(`cul_user`, `cul_timestamp`) USING BTREE,
  INDEX `cul_type_target`(`cul_type`, `cul_target_id`, `cul_timestamp`) USING BTREE,
  INDEX `cul_target_hex`(`cul_target_hex`, `cul_timestamp`) USING BTREE,
  INDEX `cul_range_start`(`cul_range_start`, `cul_timestamp`) USING BTREE,
  INDEX `cul_timestamp`(`cul_timestamp`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for externallinks
-- ----------------------------
DROP TABLE IF EXISTS `externallinks`;
CREATE TABLE `externallinks`  (
  `el_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `el_from` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `el_to` blob NOT NULL,
  `el_index` blob NOT NULL,
  `el_index_60` varbinary(60) NOT NULL,
  PRIMARY KEY (`el_id`) USING BTREE,
  INDEX `el_from`(`el_from`, `el_to`(40)) USING BTREE,
  INDEX `el_to`(`el_to`(60), `el_from`) USING BTREE,
  INDEX `el_index`(`el_index`(60)) USING BTREE,
  INDEX `el_index_60`(`el_index_60`, `el_id`) USING BTREE,
  INDEX `el_from_index_60`(`el_from`, `el_index_60`, `el_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for filearchive
-- ----------------------------
DROP TABLE IF EXISTS `filearchive`;
CREATE TABLE `filearchive`  (
  `fa_id` int(11) NOT NULL AUTO_INCREMENT,
  `fa_name` varbinary(255) NOT NULL DEFAULT '',
  `fa_archive_name` varbinary(255) NULL DEFAULT '',
  `fa_storage_group` varbinary(16) NULL DEFAULT NULL,
  `fa_storage_key` varbinary(64) NULL DEFAULT '',
  `fa_deleted_user` int(11) NULL DEFAULT NULL,
  `fa_deleted_timestamp` binary(14) NULL DEFAULT NULL,
  `fa_deleted_reason_id` bigint(20) UNSIGNED NOT NULL,
  `fa_size` int(10) UNSIGNED NULL DEFAULT 0,
  `fa_width` int(11) NULL DEFAULT 0,
  `fa_height` int(11) NULL DEFAULT 0,
  `fa_metadata` mediumblob NULL,
  `fa_bits` int(11) NULL DEFAULT 0,
  `fa_media_type` enum('UNKNOWN','BITMAP','DRAWING','AUDIO','VIDEO','MULTIMEDIA','OFFICE','TEXT','EXECUTABLE','ARCHIVE','3D') CHARACTER SET `binary` COLLATE `binary` NULL DEFAULT NULL,
  `fa_major_mime` enum('unknown','application','audio','image','text','video','message','model','multipart','chemical') CHARACTER SET `binary` COLLATE `binary` NULL DEFAULT 'unknown',
  `fa_minor_mime` varbinary(100) NULL DEFAULT 'unknown',
  `fa_description_id` bigint(20) UNSIGNED NOT NULL,
  `fa_actor` bigint(20) UNSIGNED NOT NULL,
  `fa_timestamp` binary(14) NULL DEFAULT NULL,
  `fa_deleted` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `fa_sha1` varbinary(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`fa_id`) USING BTREE,
  INDEX `fa_name`(`fa_name`, `fa_timestamp`) USING BTREE,
  INDEX `fa_storage_group`(`fa_storage_group`, `fa_storage_key`) USING BTREE,
  INDEX `fa_deleted_timestamp`(`fa_deleted_timestamp`) USING BTREE,
  INDEX `fa_actor_timestamp`(`fa_actor`, `fa_timestamp`) USING BTREE,
  INDEX `fa_sha1`(`fa_sha1`(10)) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for image
-- ----------------------------
DROP TABLE IF EXISTS `image`;
CREATE TABLE `image`  (
  `img_name` varbinary(255) NOT NULL DEFAULT '',
  `img_size` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `img_width` int(11) NOT NULL DEFAULT 0,
  `img_height` int(11) NOT NULL DEFAULT 0,
  `img_metadata` mediumblob NOT NULL,
  `img_bits` int(11) NOT NULL DEFAULT 0,
  `img_media_type` enum('UNKNOWN','BITMAP','DRAWING','AUDIO','VIDEO','MULTIMEDIA','OFFICE','TEXT','EXECUTABLE','ARCHIVE','3D') CHARACTER SET `binary` COLLATE `binary` NULL DEFAULT NULL,
  `img_major_mime` enum('unknown','application','audio','image','text','video','message','model','multipart','chemical') CHARACTER SET `binary` COLLATE `binary` NOT NULL DEFAULT 'unknown',
  `img_minor_mime` varbinary(100) NOT NULL DEFAULT 'unknown',
  `img_description_id` bigint(20) UNSIGNED NOT NULL,
  `img_actor` bigint(20) UNSIGNED NOT NULL,
  `img_timestamp` binary(14) NOT NULL,
  `img_sha1` varbinary(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`img_name`) USING BTREE,
  INDEX `img_actor_timestamp`(`img_actor`, `img_timestamp`) USING BTREE,
  INDEX `img_size`(`img_size`) USING BTREE,
  INDEX `img_timestamp`(`img_timestamp`) USING BTREE,
  INDEX `img_sha1`(`img_sha1`(10)) USING BTREE,
  INDEX `img_media_mime`(`img_media_type`, `img_major_mime`, `img_minor_mime`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for imagelinks
-- ----------------------------
DROP TABLE IF EXISTS `imagelinks`;
CREATE TABLE `imagelinks`  (
  `il_from` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `il_to` varbinary(255) NOT NULL DEFAULT '',
  `il_from_namespace` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`il_from`, `il_to`) USING BTREE,
  INDEX `il_to`(`il_to`, `il_from`) USING BTREE,
  INDEX `il_backlinks_namespace`(`il_from_namespace`, `il_to`, `il_from`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for interwiki
-- ----------------------------
DROP TABLE IF EXISTS `interwiki`;
CREATE TABLE `interwiki`  (
  `iw_prefix` varbinary(32) NOT NULL,
  `iw_url` blob NOT NULL,
  `iw_api` blob NOT NULL,
  `iw_wikiid` varbinary(64) NOT NULL,
  `iw_local` tinyint(1) NOT NULL,
  `iw_trans` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`iw_prefix`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ip_changes
-- ----------------------------
DROP TABLE IF EXISTS `ip_changes`;
CREATE TABLE `ip_changes`  (
  `ipc_rev_id` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `ipc_rev_timestamp` binary(14) NOT NULL,
  `ipc_hex` varbinary(35) NOT NULL DEFAULT '',
  PRIMARY KEY (`ipc_rev_id`) USING BTREE,
  INDEX `ipc_rev_timestamp`(`ipc_rev_timestamp`) USING BTREE,
  INDEX `ipc_hex_time`(`ipc_hex`, `ipc_rev_timestamp`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ipblocks
-- ----------------------------
DROP TABLE IF EXISTS `ipblocks`;
CREATE TABLE `ipblocks`  (
  `ipb_id` int(11) NOT NULL AUTO_INCREMENT,
  `ipb_address` tinyblob NOT NULL,
  `ipb_user` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `ipb_by_actor` bigint(20) UNSIGNED NOT NULL,
  `ipb_reason_id` bigint(20) UNSIGNED NOT NULL,
  `ipb_timestamp` binary(14) NOT NULL,
  `ipb_auto` tinyint(1) NOT NULL DEFAULT 0,
  `ipb_anon_only` tinyint(1) NOT NULL DEFAULT 0,
  `ipb_create_account` tinyint(1) NOT NULL DEFAULT 1,
  `ipb_enable_autoblock` tinyint(1) NOT NULL DEFAULT 1,
  `ipb_expiry` varbinary(14) NOT NULL,
  `ipb_range_start` tinyblob NOT NULL,
  `ipb_range_end` tinyblob NOT NULL,
  `ipb_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `ipb_block_email` tinyint(1) NOT NULL DEFAULT 0,
  `ipb_allow_usertalk` tinyint(1) NOT NULL DEFAULT 0,
  `ipb_parent_block_id` int(11) NULL DEFAULT NULL,
  `ipb_sitewide` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`ipb_id`) USING BTREE,
  UNIQUE INDEX `ipb_address_unique`(`ipb_address`(255), `ipb_user`, `ipb_auto`) USING BTREE,
  INDEX `ipb_user`(`ipb_user`) USING BTREE,
  INDEX `ipb_range`(`ipb_range_start`(8), `ipb_range_end`(8)) USING BTREE,
  INDEX `ipb_timestamp`(`ipb_timestamp`) USING BTREE,
  INDEX `ipb_expiry`(`ipb_expiry`) USING BTREE,
  INDEX `ipb_parent_block_id`(`ipb_parent_block_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ipblocks_restrictions
-- ----------------------------
DROP TABLE IF EXISTS `ipblocks_restrictions`;
CREATE TABLE `ipblocks_restrictions`  (
  `ir_ipb_id` int(11) NOT NULL,
  `ir_type` tinyint(4) NOT NULL,
  `ir_value` int(11) NOT NULL,
  PRIMARY KEY (`ir_ipb_id`, `ir_type`, `ir_value`) USING BTREE,
  INDEX `ir_type_value`(`ir_type`, `ir_value`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for iwlinks
-- ----------------------------
DROP TABLE IF EXISTS `iwlinks`;
CREATE TABLE `iwlinks`  (
  `iwl_from` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `iwl_prefix` varbinary(32) NOT NULL DEFAULT '',
  `iwl_title` varbinary(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`iwl_from`, `iwl_prefix`, `iwl_title`) USING BTREE,
  INDEX `iwl_prefix_title_from`(`iwl_prefix`, `iwl_title`, `iwl_from`) USING BTREE,
  INDEX `iwl_prefix_from_title`(`iwl_prefix`, `iwl_from`, `iwl_title`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for job
-- ----------------------------
DROP TABLE IF EXISTS `job`;
CREATE TABLE `job`  (
  `job_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `job_cmd` varbinary(60) NOT NULL DEFAULT '',
  `job_namespace` int(11) NOT NULL,
  `job_title` varbinary(255) NOT NULL,
  `job_timestamp` binary(14) NULL DEFAULT NULL,
  `job_params` mediumblob NOT NULL,
  `job_random` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `job_attempts` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `job_token` varbinary(32) NOT NULL DEFAULT '',
  `job_token_timestamp` binary(14) NULL DEFAULT NULL,
  `job_sha1` varbinary(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`job_id`) USING BTREE,
  INDEX `job_sha1`(`job_sha1`) USING BTREE,
  INDEX `job_cmd_token`(`job_cmd`, `job_token`, `job_random`) USING BTREE,
  INDEX `job_cmd_token_id`(`job_cmd`, `job_token`, `job_id`) USING BTREE,
  INDEX `job_cmd`(`job_cmd`, `job_namespace`, `job_title`, `job_params`(128)) USING BTREE,
  INDEX `job_timestamp`(`job_timestamp`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for l10n_cache
-- ----------------------------
DROP TABLE IF EXISTS `l10n_cache`;
CREATE TABLE `l10n_cache`  (
  `lc_lang` varbinary(35) NOT NULL,
  `lc_key` varbinary(255) NOT NULL,
  `lc_value` mediumblob NOT NULL,
  PRIMARY KEY (`lc_lang`, `lc_key`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for langlinks
-- ----------------------------
DROP TABLE IF EXISTS `langlinks`;
CREATE TABLE `langlinks`  (
  `ll_from` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `ll_lang` varbinary(35) NOT NULL DEFAULT '',
  `ll_title` varbinary(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`ll_from`, `ll_lang`) USING BTREE,
  INDEX `ll_lang`(`ll_lang`, `ll_title`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for log_search
-- ----------------------------
DROP TABLE IF EXISTS `log_search`;
CREATE TABLE `log_search`  (
  `ls_field` varbinary(32) NOT NULL,
  `ls_value` varbinary(255) NOT NULL,
  `ls_log_id` int(10) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`ls_field`, `ls_value`, `ls_log_id`) USING BTREE,
  INDEX `ls_log_id`(`ls_log_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for logging
-- ----------------------------
DROP TABLE IF EXISTS `logging`;
CREATE TABLE `logging`  (
  `log_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `log_type` varbinary(32) NOT NULL DEFAULT '',
  `log_action` varbinary(32) NOT NULL DEFAULT '',
  `log_timestamp` binary(14) NOT NULL DEFAULT 19700101000000,
  `log_actor` bigint(20) UNSIGNED NOT NULL,
  `log_namespace` int(11) NOT NULL DEFAULT 0,
  `log_title` varbinary(255) NOT NULL DEFAULT '',
  `log_page` int(10) UNSIGNED NULL DEFAULT NULL,
  `log_comment_id` bigint(20) UNSIGNED NOT NULL,
  `log_params` blob NOT NULL,
  `log_deleted` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `log_type_time`(`log_type`, `log_timestamp`) USING BTREE,
  INDEX `log_actor_time`(`log_actor`, `log_timestamp`) USING BTREE,
  INDEX `log_page_time`(`log_namespace`, `log_title`, `log_timestamp`) USING BTREE,
  INDEX `log_times`(`log_timestamp`) USING BTREE,
  INDEX `log_actor_type_time`(`log_actor`, `log_type`, `log_timestamp`) USING BTREE,
  INDEX `log_page_id_time`(`log_page`, `log_timestamp`) USING BTREE,
  INDEX `log_type_action`(`log_type`, `log_action`, `log_timestamp`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for moderation
-- ----------------------------
DROP TABLE IF EXISTS `moderation`;
CREATE TABLE `moderation`  (
  `mod_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `mod_timestamp` varbinary(14) NOT NULL DEFAULT '',
  `mod_user` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `mod_user_text` varbinary(255) NOT NULL,
  `mod_cur_id` int(10) UNSIGNED NOT NULL,
  `mod_namespace` int(11) NOT NULL DEFAULT 0,
  `mod_title` varbinary(255) NOT NULL DEFAULT '',
  `mod_comment` varbinary(255) NOT NULL DEFAULT '',
  `mod_minor` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `mod_bot` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `mod_new` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `mod_last_oldid` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `mod_ip` varbinary(40) NOT NULL DEFAULT '',
  `mod_old_len` int(11) NULL DEFAULT NULL,
  `mod_new_len` int(11) NULL DEFAULT NULL,
  `mod_header_xff` varbinary(255) NULL DEFAULT '',
  `mod_header_ua` varbinary(255) NULL DEFAULT '',
  `mod_tags` blob NULL,
  `mod_preload_id` varbinary(256) NOT NULL,
  `mod_rejected` tinyint(4) NOT NULL DEFAULT 0,
  `mod_rejected_by_user` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `mod_rejected_by_user_text` varbinary(255) NULL DEFAULT NULL,
  `mod_rejected_batch` tinyint(4) NOT NULL DEFAULT 0,
  `mod_rejected_auto` tinyint(4) NOT NULL DEFAULT 0,
  `mod_preloadable` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `mod_conflict` tinyint(4) NOT NULL DEFAULT 0,
  `mod_merged_revid` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `mod_text` mediumblob NULL,
  `mod_stash_key` varbinary(255) NULL DEFAULT NULL,
  `mod_type` varbinary(16) NOT NULL DEFAULT 'edit',
  `mod_page2_namespace` int(11) NOT NULL DEFAULT 0,
  `mod_page2_title` varbinary(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`mod_id`) USING BTREE,
  UNIQUE INDEX `moderation_load`(`mod_preloadable`, `mod_type`, `mod_namespace`, `mod_title`, `mod_preload_id`) USING BTREE,
  INDEX `moderation_approveall`(`mod_user_text`, `mod_rejected`, `mod_conflict`) USING BTREE,
  INDEX `moderation_rejectall`(`mod_user_text`, `mod_rejected`, `mod_merged_revid`) USING BTREE,
  INDEX `moderation_folder_pending`(`mod_rejected`, `mod_merged_revid`, `mod_timestamp`) USING BTREE,
  INDEX `moderation_folder_rejected`(`mod_rejected`, `mod_rejected_auto`, `mod_merged_revid`, `mod_timestamp`) USING BTREE,
  INDEX `moderation_folder_merged`(`mod_merged_revid`, `mod_timestamp`) USING BTREE,
  INDEX `moderation_folder_spam`(`mod_rejected_auto`, `mod_timestamp`) USING BTREE,
  INDEX `moderation_signup`(`mod_preload_id`, `mod_preloadable`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for moderation_block
-- ----------------------------
DROP TABLE IF EXISTS `moderation_block`;
CREATE TABLE `moderation_block`  (
  `mb_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `mb_address` tinyblob NOT NULL,
  `mb_user` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `mb_by` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `mb_by_text` varbinary(255) NOT NULL DEFAULT '',
  `mb_timestamp` binary(14) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
  PRIMARY KEY (`mb_id`) USING BTREE,
  UNIQUE INDEX `moderation_block_address`(`mb_address`(255)) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for module_deps
-- ----------------------------
DROP TABLE IF EXISTS `module_deps`;
CREATE TABLE `module_deps`  (
  `md_module` varbinary(255) NOT NULL,
  `md_skin` varbinary(32) NOT NULL,
  `md_deps` mediumblob NOT NULL,
  PRIMARY KEY (`md_module`, `md_skin`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oathauth_users
-- ----------------------------
DROP TABLE IF EXISTS `oathauth_users`;
CREATE TABLE `oathauth_users`  (
  `id` int(11) NOT NULL,
  `module` varbinary(255) NOT NULL,
  `data` blob NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for objectcache
-- ----------------------------
DROP TABLE IF EXISTS `objectcache`;
CREATE TABLE `objectcache`  (
  `keyname` varbinary(255) NOT NULL DEFAULT '',
  `value` mediumblob NULL,
  `exptime` binary(14) NOT NULL,
  PRIMARY KEY (`keyname`) USING BTREE,
  INDEX `exptime`(`exptime`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for oldimage
-- ----------------------------
DROP TABLE IF EXISTS `oldimage`;
CREATE TABLE `oldimage`  (
  `oi_name` varbinary(255) NOT NULL DEFAULT '',
  `oi_archive_name` varbinary(255) NOT NULL DEFAULT '',
  `oi_size` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `oi_width` int(11) NOT NULL DEFAULT 0,
  `oi_height` int(11) NOT NULL DEFAULT 0,
  `oi_bits` int(11) NOT NULL DEFAULT 0,
  `oi_description_id` bigint(20) UNSIGNED NOT NULL,
  `oi_actor` bigint(20) UNSIGNED NOT NULL,
  `oi_timestamp` binary(14) NOT NULL,
  `oi_metadata` mediumblob NOT NULL,
  `oi_media_type` enum('UNKNOWN','BITMAP','DRAWING','AUDIO','VIDEO','MULTIMEDIA','OFFICE','TEXT','EXECUTABLE','ARCHIVE','3D') CHARACTER SET `binary` COLLATE `binary` NULL DEFAULT NULL,
  `oi_major_mime` enum('unknown','application','audio','image','text','video','message','model','multipart','chemical') CHARACTER SET `binary` COLLATE `binary` NOT NULL DEFAULT 'unknown',
  `oi_minor_mime` varbinary(100) NOT NULL DEFAULT 'unknown',
  `oi_deleted` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `oi_sha1` varbinary(32) NOT NULL DEFAULT '',
  INDEX `oi_actor_timestamp`(`oi_actor`, `oi_timestamp`) USING BTREE,
  INDEX `oi_name_timestamp`(`oi_name`, `oi_timestamp`) USING BTREE,
  INDEX `oi_name_archive_name`(`oi_name`, `oi_archive_name`(14)) USING BTREE,
  INDEX `oi_sha1`(`oi_sha1`(10)) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for page
-- ----------------------------
DROP TABLE IF EXISTS `page`;
CREATE TABLE `page`  (
  `page_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `page_namespace` int(11) NOT NULL,
  `page_title` varbinary(255) NOT NULL,
  `page_restrictions` tinyblob NULL,
  `page_is_redirect` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `page_is_new` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `page_random` double UNSIGNED NOT NULL,
  `page_touched` binary(14) NOT NULL,
  `page_links_updated` varbinary(14) NULL DEFAULT NULL,
  `page_latest` int(10) UNSIGNED NOT NULL,
  `page_len` int(10) UNSIGNED NOT NULL,
  `page_content_model` varbinary(32) NULL DEFAULT NULL,
  `page_lang` varbinary(35) NULL DEFAULT NULL,
  PRIMARY KEY (`page_id`) USING BTREE,
  UNIQUE INDEX `name_title`(`page_namespace`, `page_title`) USING BTREE,
  INDEX `page_random`(`page_random`) USING BTREE,
  INDEX `page_len`(`page_len`) USING BTREE,
  INDEX `page_redirect_namespace_len`(`page_is_redirect`, `page_namespace`, `page_len`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for page_props
-- ----------------------------
DROP TABLE IF EXISTS `page_props`;
CREATE TABLE `page_props`  (
  `pp_page` int(11) NOT NULL,
  `pp_propname` varbinary(60) NOT NULL,
  `pp_value` blob NOT NULL,
  `pp_sortkey` float NULL DEFAULT NULL,
  PRIMARY KEY (`pp_page`, `pp_propname`) USING BTREE,
  UNIQUE INDEX `pp_propname_page`(`pp_propname`, `pp_page`) USING BTREE,
  UNIQUE INDEX `pp_propname_sortkey_page`(`pp_propname`, `pp_sortkey`, `pp_page`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for page_restrictions
-- ----------------------------
DROP TABLE IF EXISTS `page_restrictions`;
CREATE TABLE `page_restrictions`  (
  `pr_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `pr_page` int(11) NOT NULL,
  `pr_type` varbinary(60) NOT NULL,
  `pr_level` varbinary(60) NOT NULL,
  `pr_cascade` tinyint(4) NOT NULL,
  `pr_user` int(10) UNSIGNED NULL DEFAULT NULL,
  `pr_expiry` varbinary(14) NULL DEFAULT NULL,
  PRIMARY KEY (`pr_id`) USING BTREE,
  UNIQUE INDEX `pr_pagetype`(`pr_page`, `pr_type`) USING BTREE,
  INDEX `pr_typelevel`(`pr_type`, `pr_level`) USING BTREE,
  INDEX `pr_level`(`pr_level`) USING BTREE,
  INDEX `pr_cascade`(`pr_cascade`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pagelinks
-- ----------------------------
DROP TABLE IF EXISTS `pagelinks`;
CREATE TABLE `pagelinks`  (
  `pl_from` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `pl_namespace` int(11) NOT NULL DEFAULT 0,
  `pl_title` varbinary(255) NOT NULL DEFAULT '',
  `pl_from_namespace` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`pl_from`, `pl_namespace`, `pl_title`) USING BTREE,
  INDEX `pl_namespace`(`pl_namespace`, `pl_title`, `pl_from`) USING BTREE,
  INDEX `pl_backlinks_namespace`(`pl_from_namespace`, `pl_namespace`, `pl_title`, `pl_from`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for protected_titles
-- ----------------------------
DROP TABLE IF EXISTS `protected_titles`;
CREATE TABLE `protected_titles`  (
  `pt_namespace` int(11) NOT NULL,
  `pt_title` varbinary(255) NOT NULL,
  `pt_user` int(10) UNSIGNED NOT NULL,
  `pt_reason_id` bigint(20) UNSIGNED NOT NULL,
  `pt_timestamp` binary(14) NOT NULL,
  `pt_expiry` varbinary(14) NOT NULL,
  `pt_create_perm` varbinary(60) NOT NULL,
  PRIMARY KEY (`pt_namespace`, `pt_title`) USING BTREE,
  INDEX `pt_timestamp`(`pt_timestamp`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for querycache
-- ----------------------------
DROP TABLE IF EXISTS `querycache`;
CREATE TABLE `querycache`  (
  `qc_type` varbinary(32) NOT NULL,
  `qc_value` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `qc_namespace` int(11) NOT NULL DEFAULT 0,
  `qc_title` varbinary(255) NOT NULL DEFAULT '',
  INDEX `qc_type`(`qc_type`, `qc_value`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for querycache_info
-- ----------------------------
DROP TABLE IF EXISTS `querycache_info`;
CREATE TABLE `querycache_info`  (
  `qci_type` varbinary(32) NOT NULL DEFAULT '',
  `qci_timestamp` binary(14) NOT NULL DEFAULT 19700101000000,
  PRIMARY KEY (`qci_type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for querycachetwo
-- ----------------------------
DROP TABLE IF EXISTS `querycachetwo`;
CREATE TABLE `querycachetwo`  (
  `qcc_type` varbinary(32) NOT NULL,
  `qcc_value` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `qcc_namespace` int(11) NOT NULL DEFAULT 0,
  `qcc_title` varbinary(255) NOT NULL DEFAULT '',
  `qcc_namespacetwo` int(11) NOT NULL DEFAULT 0,
  `qcc_titletwo` varbinary(255) NOT NULL DEFAULT '',
  INDEX `qcc_type`(`qcc_type`, `qcc_value`) USING BTREE,
  INDEX `qcc_title`(`qcc_type`, `qcc_namespace`, `qcc_title`) USING BTREE,
  INDEX `qcc_titletwo`(`qcc_type`, `qcc_namespacetwo`, `qcc_titletwo`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for recentchanges
-- ----------------------------
DROP TABLE IF EXISTS `recentchanges`;
CREATE TABLE `recentchanges`  (
  `rc_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `rc_timestamp` binary(14) NOT NULL,
  `rc_actor` bigint(20) UNSIGNED NOT NULL,
  `rc_namespace` int(11) NOT NULL DEFAULT 0,
  `rc_title` varbinary(255) NOT NULL DEFAULT '',
  `rc_comment_id` bigint(20) UNSIGNED NOT NULL,
  `rc_minor` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `rc_bot` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `rc_new` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `rc_cur_id` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `rc_this_oldid` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `rc_last_oldid` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `rc_type` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `rc_source` varbinary(16) NOT NULL DEFAULT '',
  `rc_patrolled` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `rc_ip` varbinary(40) NOT NULL DEFAULT '',
  `rc_old_len` int(11) NULL DEFAULT NULL,
  `rc_new_len` int(11) NULL DEFAULT NULL,
  `rc_deleted` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `rc_logid` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `rc_log_type` varbinary(255) NULL DEFAULT NULL,
  `rc_log_action` varbinary(255) NULL DEFAULT NULL,
  `rc_params` blob NULL,
  PRIMARY KEY (`rc_id`) USING BTREE,
  INDEX `rc_timestamp`(`rc_timestamp`) USING BTREE,
  INDEX `rc_namespace_title_timestamp`(`rc_namespace`, `rc_title`, `rc_timestamp`) USING BTREE,
  INDEX `rc_cur_id`(`rc_cur_id`) USING BTREE,
  INDEX `rc_new_name_timestamp`(`rc_new`, `rc_namespace`, `rc_timestamp`) USING BTREE,
  INDEX `rc_ip`(`rc_ip`) USING BTREE,
  INDEX `rc_ns_actor`(`rc_namespace`, `rc_actor`) USING BTREE,
  INDEX `rc_actor`(`rc_actor`, `rc_timestamp`) USING BTREE,
  INDEX `rc_name_type_patrolled_timestamp`(`rc_namespace`, `rc_type`, `rc_patrolled`, `rc_timestamp`) USING BTREE,
  INDEX `rc_this_oldid`(`rc_this_oldid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for redirect
-- ----------------------------
DROP TABLE IF EXISTS `redirect`;
CREATE TABLE `redirect`  (
  `rd_from` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `rd_namespace` int(11) NOT NULL DEFAULT 0,
  `rd_title` varbinary(255) NOT NULL DEFAULT '',
  `rd_interwiki` varbinary(32) NULL DEFAULT NULL,
  `rd_fragment` varbinary(255) NULL DEFAULT NULL,
  PRIMARY KEY (`rd_from`) USING BTREE,
  INDEX `rd_ns_title`(`rd_namespace`, `rd_title`, `rd_from`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for revision
-- ----------------------------
DROP TABLE IF EXISTS `revision`;
CREATE TABLE `revision`  (
  `rev_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `rev_page` int(10) UNSIGNED NOT NULL,
  `rev_text_id` int(10) UNSIGNED NOT NULL,
  `rev_comment_id` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `rev_user` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `rev_timestamp` binary(14) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
  `rev_deleted` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `rev_len` int(10) UNSIGNED NULL DEFAULT NULL,
  `rev_parent_id` int(10) UNSIGNED NULL DEFAULT NULL,
  `rev_sha1` varbinary(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`rev_id`) USING BTREE,
  INDEX `rev_page_id`(`rev_page`, `rev_id`) USING BTREE,
  INDEX `rev_timestamp`(`rev_timestamp`) USING BTREE,
  INDEX `page_timestamp`(`rev_page`, `rev_timestamp`) USING BTREE,
  INDEX `rev_actor_timestamp`(`rev_user`, `rev_timestamp`, `rev_id`) USING BTREE,
  INDEX `rev_page_actor_timestamp`(`rev_page`, `rev_user`, `rev_timestamp`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 AVG_ROW_LENGTH = 1024 CHARACTER SET = `binary` MAX_ROWS = 10000000 ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for searchindex
-- ----------------------------
DROP TABLE IF EXISTS `searchindex`;
CREATE TABLE `searchindex`  (
  `si_page` int(10) UNSIGNED NOT NULL,
  `si_title` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `si_text` mediumtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  UNIQUE INDEX `si_page`(`si_page`) USING BTREE,
  FULLTEXT INDEX `si_title`(`si_title`),
  FULLTEXT INDEX `si_text`(`si_text`)
) ENGINE = MyISAM CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for site_identifiers
-- ----------------------------
DROP TABLE IF EXISTS `site_identifiers`;
CREATE TABLE `site_identifiers`  (
  `si_type` varbinary(32) NOT NULL,
  `si_key` varbinary(32) NOT NULL,
  `si_site` int(10) UNSIGNED NOT NULL,
  PRIMARY KEY (`si_type`, `si_key`) USING BTREE,
  INDEX `si_site`(`si_site`) USING BTREE,
  INDEX `si_key`(`si_key`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for site_stats
-- ----------------------------
DROP TABLE IF EXISTS `site_stats`;
CREATE TABLE `site_stats`  (
  `ss_row_id` int(10) UNSIGNED NOT NULL,
  `ss_total_edits` bigint(20) UNSIGNED NULL DEFAULT NULL,
  `ss_good_articles` bigint(20) UNSIGNED NULL DEFAULT NULL,
  `ss_total_pages` bigint(20) UNSIGNED NULL DEFAULT NULL,
  `ss_users` bigint(20) UNSIGNED NULL DEFAULT NULL,
  `ss_active_users` bigint(20) UNSIGNED NULL DEFAULT NULL,
  `ss_images` bigint(20) UNSIGNED NULL DEFAULT NULL,
  PRIMARY KEY (`ss_row_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sites
-- ----------------------------
DROP TABLE IF EXISTS `sites`;
CREATE TABLE `sites`  (
  `site_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `site_global_key` varbinary(64) NOT NULL,
  `site_type` varbinary(32) NOT NULL,
  `site_group` varbinary(32) NOT NULL,
  `site_source` varbinary(32) NOT NULL,
  `site_language` varbinary(35) NOT NULL,
  `site_protocol` varbinary(32) NOT NULL,
  `site_domain` varbinary(255) NOT NULL,
  `site_data` blob NOT NULL,
  `site_forward` tinyint(1) NOT NULL,
  `site_config` blob NOT NULL,
  PRIMARY KEY (`site_id`) USING BTREE,
  UNIQUE INDEX `site_global_key`(`site_global_key`) USING BTREE,
  INDEX `site_type`(`site_type`) USING BTREE,
  INDEX `site_group`(`site_group`) USING BTREE,
  INDEX `site_source`(`site_source`) USING BTREE,
  INDEX `site_language`(`site_language`) USING BTREE,
  INDEX `site_protocol`(`site_protocol`) USING BTREE,
  INDEX `site_domain`(`site_domain`) USING BTREE,
  INDEX `site_forward`(`site_forward`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for templatelinks
-- ----------------------------
DROP TABLE IF EXISTS `templatelinks`;
CREATE TABLE `templatelinks`  (
  `tl_from` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `tl_namespace` int(11) NOT NULL DEFAULT 0,
  `tl_title` varbinary(255) NOT NULL DEFAULT '',
  `tl_from_namespace` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`tl_from`, `tl_namespace`, `tl_title`) USING BTREE,
  INDEX `tl_namespace`(`tl_namespace`, `tl_title`, `tl_from`) USING BTREE,
  INDEX `tl_backlinks_namespace`(`tl_from_namespace`, `tl_namespace`, `tl_title`, `tl_from`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for text
-- ----------------------------
DROP TABLE IF EXISTS `text`;
CREATE TABLE `text`  (
  `old_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `old_text` mediumblob NOT NULL,
  `old_flags` tinyblob NOT NULL,
  PRIMARY KEY (`old_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for updatelog
-- ----------------------------
DROP TABLE IF EXISTS `updatelog`;
CREATE TABLE `updatelog`  (
  `ul_key` varbinary(255) NOT NULL,
  `ul_value` blob NULL,
  PRIMARY KEY (`ul_key`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for uploadstash
-- ----------------------------
DROP TABLE IF EXISTS `uploadstash`;
CREATE TABLE `uploadstash`  (
  `us_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `us_user` int(10) UNSIGNED NOT NULL,
  `us_key` varbinary(255) NOT NULL,
  `us_orig_path` varbinary(255) NOT NULL,
  `us_path` varbinary(255) NOT NULL,
  `us_source_type` varbinary(50) NULL DEFAULT NULL,
  `us_timestamp` binary(14) NOT NULL,
  `us_status` varbinary(50) NOT NULL,
  `us_chunk_inx` int(10) UNSIGNED NULL DEFAULT NULL,
  `us_props` blob NULL,
  `us_size` int(10) UNSIGNED NOT NULL,
  `us_sha1` varbinary(31) NOT NULL,
  `us_mime` varbinary(255) NULL DEFAULT NULL,
  `us_media_type` enum('UNKNOWN','BITMAP','DRAWING','AUDIO','VIDEO','MULTIMEDIA','OFFICE','TEXT','EXECUTABLE','ARCHIVE','3D') CHARACTER SET `binary` COLLATE `binary` NULL DEFAULT NULL,
  `us_image_width` int(10) UNSIGNED NULL DEFAULT NULL,
  `us_image_height` int(10) UNSIGNED NULL DEFAULT NULL,
  `us_image_bits` smallint(5) UNSIGNED NULL DEFAULT NULL,
  PRIMARY KEY (`us_id`) USING BTREE,
  UNIQUE INDEX `us_key`(`us_key`) USING BTREE,
  INDEX `us_user`(`us_user`) USING BTREE,
  INDEX `us_timestamp`(`us_timestamp`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `user_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_name` varbinary(255) NOT NULL DEFAULT '',
  `user_real_name` varbinary(255) NOT NULL DEFAULT '',
  `user_password` tinyblob NOT NULL,
  `user_newpassword` tinyblob NOT NULL,
  `user_newpass_time` binary(14) NULL DEFAULT NULL,
  `user_email` tinyblob NOT NULL,
  `user_touched` binary(14) NOT NULL,
  `user_token` binary(32) NULL DEFAULT NULL,
  `user_email_authenticated` binary(14) NULL DEFAULT NULL,
  `user_email_token` binary(32) NULL DEFAULT NULL,
  `user_email_token_expires` binary(14) NULL DEFAULT NULL,
  `user_registration` binary(14) NULL DEFAULT NULL,
  `user_editcount` int(11) NULL DEFAULT NULL,
  `user_password_expires` varbinary(14) NULL DEFAULT NULL,
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `user_name`(`user_name`) USING BTREE,
  INDEX `user_email_token`(`user_email_token`) USING BTREE,
  INDEX `user_email`(`user_email`(50)) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user_former_groups
-- ----------------------------
DROP TABLE IF EXISTS `user_former_groups`;
CREATE TABLE `user_former_groups`  (
  `ufg_user` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `ufg_group` varbinary(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`ufg_user`, `ufg_group`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user_groups
-- ----------------------------
DROP TABLE IF EXISTS `user_groups`;
CREATE TABLE `user_groups`  (
  `ug_user` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `ug_group` varbinary(255) NOT NULL DEFAULT '',
  `ug_expiry` varbinary(14) NULL DEFAULT NULL,
  PRIMARY KEY (`ug_user`, `ug_group`) USING BTREE,
  INDEX `ug_group`(`ug_group`) USING BTREE,
  INDEX `ug_expiry`(`ug_expiry`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user_newtalk
-- ----------------------------
DROP TABLE IF EXISTS `user_newtalk`;
CREATE TABLE `user_newtalk`  (
  `user_id` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `user_ip` varbinary(40) NOT NULL DEFAULT '',
  `user_last_timestamp` binary(14) NULL DEFAULT NULL,
  INDEX `un_user_id`(`user_id`) USING BTREE,
  INDEX `un_user_ip`(`user_ip`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user_properties
-- ----------------------------
DROP TABLE IF EXISTS `user_properties`;
CREATE TABLE `user_properties`  (
  `up_user` int(10) UNSIGNED NOT NULL,
  `up_property` varbinary(255) NOT NULL,
  `up_value` blob NULL,
  PRIMARY KEY (`up_user`, `up_property`) USING BTREE,
  INDEX `up_property`(`up_property`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for watchlist
-- ----------------------------
DROP TABLE IF EXISTS `watchlist`;
CREATE TABLE `watchlist`  (
  `wl_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `wl_user` int(10) UNSIGNED NOT NULL,
  `wl_namespace` int(11) NOT NULL DEFAULT 0,
  `wl_title` varbinary(255) NOT NULL DEFAULT '',
  `wl_notificationtimestamp` binary(14) NULL DEFAULT NULL,
  PRIMARY KEY (`wl_id`) USING BTREE,
  UNIQUE INDEX `wl_user`(`wl_user`, `wl_namespace`, `wl_title`) USING BTREE,
  INDEX `wl_namespace_title`(`wl_namespace`, `wl_title`) USING BTREE,
  INDEX `wl_user_notificationtimestamp`(`wl_user`, `wl_notificationtimestamp`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for watchlist_expiry
-- ----------------------------
DROP TABLE IF EXISTS `watchlist_expiry`;
CREATE TABLE `watchlist_expiry`  (
  `we_item` int(10) UNSIGNED NOT NULL,
  `we_expiry` binary(14) NOT NULL,
  PRIMARY KEY (`we_item`) USING BTREE,
  INDEX `we_expiry`(`we_expiry`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = `binary` ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
