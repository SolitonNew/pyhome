-- phpMyAdmin SQL Dump
-- version 4.0.10deb1
-- http://www.phpmyadmin.net
--
-- Хост: localhost
-- Время создания: Сен 14 2016 г., 18:18
-- Версия сервера: 5.5.50-0ubuntu0.14.04.1
-- Версия PHP: 5.5.9-1ubuntu4.19

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- База данных: `wisehouse`
--

DELIMITER $$
--
-- Процедуры
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `CORE_SET_VARIABLE`(IN `VAR_ID` INT, IN `VAR_VALUE` FLOAT, IN `DEV_ID` INT)
    NO SQL
BEGIN
    insert into core_variable_changes
      (VARIABLE_ID, VALUE, FROM_ID)
    values
      (VAR_ID, VAR_VALUE, DEV_ID);

    update core_variables
       set VALUE = VAR_VALUE
     where ID = VAR_ID;
END$$

--
-- Функции
--
CREATE DEFINER=`root`@`localhost` FUNCTION `CORE_GET_LAST_CHANGE_ID`() RETURNS int(11)
    NO SQL
return (select auto_increment from information_schema.tables 
 		 where table_name = 'core_variable_changes')$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `app_consoles`
--

CREATE TABLE IF NOT EXISTS `app_consoles` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `NAME` varchar(255) COLLATE utf8_bin NOT NULL,
  `COMM` text COLLATE utf8_bin NOT NULL,
  `TYP` int(11) NOT NULL,
  `PINCODE` int(11) DEFAULT NULL,
  `PAGE_COUNT` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `PINCODE` (`PINCODE`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=10 ;

-- --------------------------------------------------------

--
-- Структура таблицы `app_console_pages`
--

CREATE TABLE IF NOT EXISTS `app_console_pages` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `CONSOLE_ID` int(11) NOT NULL,
  `ORDER_NUM` int(11) NOT NULL,
  `NAME` varchar(255) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Структура таблицы `app_console_parts`
--

CREATE TABLE IF NOT EXISTS `app_console_parts` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `CONSOLE_ID` int(11) NOT NULL,
  `PAGE_ID` int(11) DEFAULT NULL,
  `ORIENTATION` int(11) NOT NULL,
  `X` int(11) NOT NULL,
  `Y` int(11) NOT NULL,
  `W` int(11) NOT NULL,
  `H` int(11) NOT NULL,
  `VARIABLE_ID` int(11) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=659 ;

-- --------------------------------------------------------

--
-- Структура таблицы `core_controllers`
--

CREATE TABLE IF NOT EXISTS `core_controllers` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `NAME` varchar(200) COLLATE utf8_bin NOT NULL,
  `COMM` varchar(1000) CHARACTER SET latin1 NOT NULL,
  `STATUS` int(11) NOT NULL,
  `POSITION` varchar(1000) CHARACTER SET latin1 NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=101 ;

-- --------------------------------------------------------

--
-- Структура таблицы `core_execute`
--

CREATE TABLE IF NOT EXISTS `core_execute` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `COMMAND` varchar(255) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=698 ;

-- --------------------------------------------------------

--
-- Структура таблицы `core_ow_devs`
--

CREATE TABLE IF NOT EXISTS `core_ow_devs` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `CONTROLLER_ID` int(11) NOT NULL,
  `NAME` varchar(255) COLLATE utf8_bin NOT NULL,
  `COMM` varchar(1000) COLLATE utf8_bin NOT NULL,
  `ROM_1` int(8) NOT NULL,
  `ROM_2` int(11) NOT NULL,
  `ROM_3` int(11) NOT NULL,
  `ROM_4` int(11) NOT NULL,
  `ROM_5` int(11) NOT NULL,
  `ROM_6` int(11) NOT NULL,
  `ROM_7` int(11) NOT NULL,
  `ROM_8` int(11) NOT NULL,
  `VALUE` varchar(255) COLLATE utf8_bin NOT NULL,
  `POSITION` varchar(255) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `CONTROLLER_ID` (`CONTROLLER_ID`),
  KEY `ROM_1` (`ROM_1`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=43 ;

-- --------------------------------------------------------

--
-- Структура таблицы `core_ow_types`
--

CREATE TABLE IF NOT EXISTS `core_ow_types` (
  `CODE` int(11) NOT NULL,
  `COMM` varchar(255) COLLATE utf8_bin NOT NULL,
  `CHANNELS` varchar(255) COLLATE utf8_bin NOT NULL,
  `CONSUMING` float NOT NULL DEFAULT '0',
  UNIQUE KEY `CODE` (`CODE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Структура таблицы `core_propertys`
--

CREATE TABLE IF NOT EXISTS `core_propertys` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `NAME` varchar(128) COLLATE utf8_bin NOT NULL,
  `COMM` varchar(2000) COLLATE utf8_bin NOT NULL,
  `VALUE` varchar(2000) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=5 ;

-- --------------------------------------------------------

--
-- Структура таблицы `core_scheduler`
--

CREATE TABLE IF NOT EXISTS `core_scheduler` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `COMM` text COLLATE utf8_bin NOT NULL,
  `ACTION` text COLLATE utf8_bin,
  `ACTION_DATETIME` timestamp NULL DEFAULT NULL,
  `INTERVAL_TIME_OF_DAY` varchar(255) COLLATE utf8_bin NOT NULL,
  `INTERVAL_DAY_OF_TYPE` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `INTERVAL_TYPE` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=19 ;

-- --------------------------------------------------------

--
-- Структура таблицы `core_scripts`
--

CREATE TABLE IF NOT EXISTS `core_scripts` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `COMM` varchar(255) COLLATE utf8_bin NOT NULL,
  `DATA` varchar(4000) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=50 ;

-- --------------------------------------------------------

--
-- Структура таблицы `core_variables`
--

CREATE TABLE IF NOT EXISTS `core_variables` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `CONTROLLER_ID` int(11) NOT NULL,
  `ROM` varchar(20) COLLATE utf8_bin NOT NULL,
  `DIRECTION` int(11) NOT NULL DEFAULT '0' COMMENT '0-input; 1-output',
  `NAME` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'Идентификатор переменной. По этому имени выполняется обращение в скрипте.',
  `COMM` varchar(1000) COLLATE utf8_bin NOT NULL,
  `VALUE` float DEFAULT NULL,
  `LAST_UPDATE` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `OW_ID` int(11) DEFAULT NULL COMMENT 'Эсли заполнено - это указатель на устройство OneWire. Если не заполнено, то это пины контроллера.',
  `CHANNEL` varchar(20) COLLATE utf8_bin DEFAULT NULL COMMENT 'Номер канала для многоканальных устройств',
  `GROUP_ID` int(11) NOT NULL DEFAULT '-1',
  `APP_CONTROL` int(11) NOT NULL DEFAULT '0' COMMENT '0-none; 1-лампочка;  2-выключатель; 3-розетка; 4-термометр; 5-термостат; 6-камера;',
  PRIMARY KEY (`ID`),
  KEY `CONTROLLER_ID` (`CONTROLLER_ID`),
  KEY `OW_ID` (`OW_ID`),
  KEY `GROUP_ID` (`GROUP_ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=124 ;

-- --------------------------------------------------------

--
-- Структура таблицы `core_variable_changes`
--

CREATE TABLE IF NOT EXISTS `core_variable_changes` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `VARIABLE_ID` int(11) NOT NULL,
  `CHANGE_DATE` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `VALUE` float NOT NULL,
  `FROM_ID` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `VARIABLE_ID` (`VARIABLE_ID`),
  KEY `FROM_ID` (`FROM_ID`),
  KEY `CHANGE_DATE` (`CHANGE_DATE`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=620515 ;

-- --------------------------------------------------------

--
-- Структура таблицы `core_variable_controls`
--

CREATE TABLE IF NOT EXISTS `core_variable_controls` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `NAME` varchar(255) COLLATE utf8_bin NOT NULL,
  `DEF_PROPERTY` varchar(250) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=10 ;

-- --------------------------------------------------------

--
-- Структура таблицы `core_variable_events`
--

CREATE TABLE IF NOT EXISTS `core_variable_events` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `EVENT_TYPE` int(11) NOT NULL COMMENT '0-change',
  `VARIABLE_ID` int(11) NOT NULL,
  `SCRIPT_ID` int(11) NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `SCRIPT_ID` (`SCRIPT_ID`),
  KEY `VARIABLE_ID` (`VARIABLE_ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=38 ;

-- --------------------------------------------------------

--
-- Структура таблицы `plan_parts`
--

CREATE TABLE IF NOT EXISTS `plan_parts` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `NAME` varchar(200) COLLATE utf8_bin NOT NULL,
  `PARENT_ID` int(11) DEFAULT NULL,
  `ORDER_NUM` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=23 ;

-- --------------------------------------------------------

--
-- Структура таблицы `web_stat_panels`
--

CREATE TABLE IF NOT EXISTS `web_stat_panels` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `NAME` varchar(255) COLLATE utf8_bin NOT NULL,
  `ORDER_NUM` int(11) NOT NULL,
  `TYP` int(11) NOT NULL,
  `HEIGHT` int(11) NOT NULL DEFAULT '200',
  `SERIES_1` int(11) NOT NULL DEFAULT '-1',
  `SERIES_2` int(11) NOT NULL DEFAULT '-1',
  `SERIES_3` int(11) NOT NULL DEFAULT '-1',
  `SERIES_4` int(11) DEFAULT '-1',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=253 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
