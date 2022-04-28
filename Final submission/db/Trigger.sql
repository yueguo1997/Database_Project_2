-- Features
-- Following codes include all the functions we accomplished in the front end and data base(after decomposition
-- We have 5 triggers, 7 procedures(include 1 transaction) and 2 views.
USE vfb;

-- Triggers

-- Create insert_game_check trigger
-- Management
-- This trigger will record the data after any inserting on the game table
-- It records what values have been inserted in game table, the operation time and set action as "insert"
DROP TRIGGER IF EXISTS insert_game_check;
DELIMITER //
CREATE TRIGGER insert_game_check
AFTER INSERT
ON game
FOR EACH ROW
BEGIN

INSERT INTO game_dairy
VALUES (DEFAULT, NEW.game_id, NEW.home,NEW.away,NEW.week, NEW.season,NEW.year, SYSDATE(), "insert");

END//
DELIMITER ;

-- Create trigger update_game_check
-- Management
-- This trigger will record the data after any updating on the game table
-- It records the old data before update, the operation time and set action as "update"
DROP TRIGGER IF EXISTS update_game_check;
DELIMITER //
CREATE TRIGGER update_game_check
AFTER UPDATE
ON game
FOR EACH ROW
BEGIN

INSERT INTO game_dairy
VALUES (DEFAULT, OLD.game_id, OLD.home,OLD.away,OLD.week, OLD.season,OLD.year, SYSDATE(), "update");

END//
DELIMITER ;

-- Create trigger delete_game_check
-- Management
-- This trigger will record the data after any deleting on the game table
-- It records the old data before deleting, the operation time and set action as "delete"
DROP TRIGGER IF EXISTS delete_game_check;
DELIMITER //
CREATE TRIGGER delete_game_check
AFTER DELETE
ON game
FOR EACH ROW
BEGIN

INSERT INTO game_dairy
VALUES (DEFAULT, OLD.game_id, OLD.home,OLD.away,OLD.week, OLD.season,OLD.year, SYSDATE(), "delete");

END//
DELIMITER ;


-- Create trigger insert_drive_check1
-- Management
-- If distance > yards_gained (inserted), then down should plus 1. Otherewise down should be 1
-- If down is larger than 4, the we need rto swao the defense and offense. In the meanwhile set down as
-- Generate drive id based on play number and game id
DROP TRIGGER IF EXISTS insert_drive_check1;
DELIMITER //
CREATE TRIGGER insert_drive_check1
BEFORE INSERT 
ON play_drive
FOR EACH ROW
BEGIN

DECLARE new_offense_value VARCHAR(255);
DECLARE new_defense_value VARCHAR(255);

IF new.distance > new.yards_gained THEN 
	SET NEW.down = NEW.down + 1;
ELSE
	SET NEW.down = 1;
END IF;

IF NEW.down > 4 THEN
	SET new_offense_value = (SELECT defense FROM play WHERE drive_id = NEW.drive_id AND play_number = NEW.play_number);
	SET new_defense_value = (SELECT offense FROM play WHERE drive_id = NEW.drive_id AND play_number = NEW.play_number);
	SET NEW.down = 1;
	UPDATE play
	SET defense = new_defense_value, offense = new_offense_value
	WHERE drive_id = NEW.drive_id AND play_number = NEW.play_number;



END IF;
END //
DELIMITER ;

-- Create trigger insert_drive_check2
-- Management
-- This trigger will record the data after any inserting tables with drive id
-- It records the new data after inserting, the operation time and set action as "delete"
DROP TRIGGER IF EXISTS insert_drive_check2;
DELIMITER //
CREATE TRIGGER insert_drive_check2
AFTER INSERT 
ON play_drive
FOR EACH ROW
BEGIN

INSERT INTO drive_dairy
VALUES(DEFAULT,NEW.drive_id, NEW.play_number, SYSDATE(),"insert");


END //
DELIMITER ;
