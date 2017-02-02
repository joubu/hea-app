DROP TABLE IF EXISTS installation;
CREATE TABLE `installation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `koha_id` varchar(32) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `country` varchar(255) NOT NULL DEFAULT '',
  `geolocation` varchar(255) NOT NULL DEFAULT '',
  `library_type` varchar(255) NOT NULL DEFAULT '',
  `creation_time` timestamp NULL DEFAULT NULL,
  `modification_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`koha_id`),
  UNIQUE KEY id (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS library;
CREATE TABLE `library` (
  `library_id` int(11) NOT NULL AUTO_INCREMENT,
  `koha_id` varchar(32) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `country` varchar(255) NOT NULL DEFAULT '',
  `geolocation` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`library_id`),
  KEY `library_installation` (`koha_id`),
  CONSTRAINT `library_installation` FOREIGN KEY (`koha_id`) REFERENCES `installation` (`koha_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS volumetry;
CREATE TABLE `volumetry` (
  `koha_id` varchar(32) NOT NULL,
  `name` varchar(255) NOT NULL,
  `value` int(11) NOT NULL DEFAULT '0',
  `inserted` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `vol_install` (`koha_id`),
  CONSTRAINT `vol_install` FOREIGN KEY (`koha_id`) REFERENCES `installation` (`koha_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS systempreference;
CREATE TABLE `systempreference` (
  `koha_id` varchar(32) NOT NULL,
  `name` varchar(255) NOT NULL,
  `value` text,
  KEY `syspref_install` (`koha_id`),
  CONSTRAINT `syspref_install` FOREIGN KEY (`koha_id`) REFERENCES `installation` (`koha_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
