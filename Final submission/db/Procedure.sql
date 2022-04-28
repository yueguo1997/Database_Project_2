-- Procedures

-- Create insert_game
-- Management: insert a new game
-- This procedure update the values which has been pass from the front end.
-- If insert failed because of duplicate key, it will return the error message. 
-- Otherwise, it will return “insert successfully” message

USE vfb;
DROP PROCEDURE IF EXISTS insert_game;
DELIMITER //
CREATE PROCEDURE insert_game(IN gameid BIGINT, IN home VARCHAR(255),IN away VARCHAR(255), IN week TINYINT, IN season INT, IN year VARCHAR(255))
BEGIN

DECLARE EXIT HANDLER FOR 1062 SELECT "Insert Failed because the game id has already exists";

INSERT INTO game(game_id, home,away, week,season,year)
VALUES (gameid, home,away,week,season,year);

SELECT CONCAT("Insert game ",gameid," successfully");

END //
DELIMITER ;


-- Create procedure delete_game
-- Management: delete new game
-- This procedure delete the data record realted with the game id in game table passed form the front end
-- It checks whether the game id exists in game table. If not, it will return a error message. 
-- If does exist, it operates deleting and return a success message.
USE vfb;
DROP PROCEDURE IF EXISTS delete_game;
DELIMITER //
CREATE PROCEDURE delete_game (IN gameid BIGINT)
BEGIN 

IF NOT EXISTS(SELECT * from vfb.game where game_id = gameid) THEN
	SELECT CONCAT("Game ", gameid, " doesn't exist");
ELSE
	DELETE FROM game 
	WHERE game_id = gameid;
	SELECT CONCAT("Delete game ", gameid, " sucessfully");
END IF;
END //
DELIMITER ;

-- Create procedure update_game
-- Management: update game
-- It checks whether the game id put into the procedure exist in Game table. If not, it will return an error message
-- If exists, it will operate updating and return a successful message
USE vfb;
DROP PROCEDURE IF EXISTS update_game;
DELIMITER //
CREATE PROCEDURE update_game(IN a BIGINT, IN b VARCHAR(255),IN c VARCHAR(255), IN d TINYINT, IN e INT, IN f VARCHAR(255))
BEGIN

IF NOT EXISTS (select * from vfb.game where game_id = a) THEN
    SELECT CONCAT("Game ID ",a, " doesn't exist");
ELSE
    UPDATE game SET home=b, away=c, week=d, season=e, year=f WHERE game_id=a;
    SELECT CONCAT("Game ID ",a," updated successfully");
END IF;
END //
DELIMITER ;

-- Create procedure insert_drive
-- Management: insert a new play game
-- It checks whether the game id put into the procedure exist in Game table. If not, it will return an error message 
-- Then it checks whether down value satisfy the football rules. If not, it will return an error message
-- Finally all the conditions has been satisfied, it use transaction to insert all the values into three tables. If insert successfully, there will be a success message
-- Otherewise, it returns an error message telling users transaction has been rolled back
USE vfb;
DROP PROCEDURE IF EXISTS insert_drive;
DELIMITER //
CREATE PROCEDURE insert_drive(IN gameid BIGINT, IN drivenumber TINYINT, IN off VARCHAR(255),IN off_score TINYINT,  IN de VARCHAR(255), IN de_score TINYINT,IN playnumber TINYINT, IN cl VARCHAR(255), IN yardline INT, IN yardgaol INT, IN yardgain INT, IN down INT, IN distance INT,IN period INT, IN playtype VARCHAR(800),IN playtext VARCHAR(800))
BEGIN
DECLARE driveid BIGINT;
DECLARE sql_error INT DEFAULT FALSE;
DECLARE EXIT HANDLER FOR 1452 SELECT "Please check the values you insert is right";
DECLARE EXIT HANDLER FOR 1062 SELECT "Insert Failed because of duplicate key";
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_error = TRUE;
SET driveid = gameid *100 + drivenumber;

IF NOT EXISTS (SELECT * FROM vfb.game WHERE game_id = gameid ) THEN 
	SELECT " This game id doesn't exist";
ELSE
	IF down <= 0 AND playtype != "2pt Conversion" AND playtype != "Extra Point Good" AND playtype != "Extra Point Missed" THEN 
		SELECT "Wrong down value, please chack again";
    ELSE
		START TRANSACTION;
			INSERT INTO drive(drive_id,drive_number,game_id)
			VALUES(driveid,drivenumber, gameid);
			INSERT INTO play(drive_id,play_number,period,offense_score,defense_score,offense_timeouts,defense_timeouts,offense,defense)
			VALUES(driveid, playnumber, period, off_score, de_score,DEFAULT,DEFAULT,off, de);
			INSERT INTO play_drive(I_D,drive_id,play_number,clock,yard_line,yards_to_goal,down,distance,yards_gained,play_type,play_text,ppa)
			VALUES(DEFAULT,driveid, playnumber, cl, yardline, yardgaol, down, distance, yardgain, playtype,playtext,DEFAULT);
            IF sql_error = FALSE THEN 
				COMMIT;
				SELECT "Insert drive successfully!";
			ELSE 
				ROLLBACK;
                SELECT "INSERT HAS BEEN ROLLED BACK";
			END IF;
	END IF;

END IF;


END //
DELIMITER ;


-- Create procedure explosive_play()
-- Dashbaord
-- Use the team value and season value to calculate the explosive play numbers and offense touchdowns of each team in different seasons
-- explosive number is the play number which offense team yards gained larger than 16 team when play type is pass
-- Or offense team yards gained larger than 12 when play type is rush
-- offensive_touchdowns is the number of times when play type is Passing Touchdown or Rushing Touchdown.
DROP PROCEDURE IF EXISTS explosive_play;
DELIMITER //
CREATE PROCEDURE explosive_play(IN team_value VARCHAR(255),IN season_value INT)
BEGIN
SELECT  SUM(CASE WHEN ((play_type LIKE "%Pass%" AND yards_gained > 16) OR
                         (play_type LIKE "%Rush%" AND yards_gained >= 12)) THEN 1
                   ELSE 0 END) AS explosive_play_number,
		COUNT(CASE WHEN (play_type = "Passing Touchdown" OR play_type = 'Rushing Touchdown') THEN 1
                     ELSE NULL END) AS offensive_touchdowns
    FROM play_drive
             JOIN (SELECT * FROM play WHERE offense = team_value) a USING (drive_id, play_number)
             JOIN  drive USING (drive_id)
             JOIN (SELECT * FROM game WHERE season = season_value) b USING (game_id)
	GROUP BY game_id;
END //
DELIMITER ;

-- Create procedure dashboard
-- Dashbaord
-- This procedure use team value and season value to calculate the parameters we want from the original data
-- pass_attempt is the sum of pass_completion1, pass_td, pass_interception and pass_incomplete in each game
-- pass_completion (new) is the sum of pass_completion1, pass_td in each game
DROP PROCEDURE IF EXISTS dashboard;
DELIMITER //
CREATE PROCEDURE dashboard(IN team_value VARCHAR(255),IN season_value INT)
BEGIN
SELECT *,
		(pass_completion1 + pass_td+ pass_interception+pass_incomplete) AS pass_attempt,
		(pass_completion1+ pass_td) AS pass_completion
        
FROM (
select offense AS offense,
      game_id AS game_id,
       sum(CASE WHEN (play_type = 'Pass Completion') THEN 1 ELSE 0 END) AS pass_completion1,
       sum(CASE WHEN (play_type = 'Passing Touchdown') THEN 1 ELSE 0 END)  AS pass_td,
       sum(CASE WHEN (play_type = 'Pass Interception') THEN 1 ELSE 0 END)  AS pass_interception,
       sum(CASE WHEN (play_type = 'Pass Incompletion') THEN 1 ELSE 0 END)    AS pass_incomplete,
       sum(CASE WHEN (play_type = 'Rush' OR play_type = 'Rushing Touchdown') THEN 1 ELSE 0 END)  AS rush_attempt,
       sum(CASE WHEN (play_type = 'Rush Touchdown') THEN 1 ELSE 0 END) AS rush_td,
       sum(CASE WHEN (play_type = 'Fumble') THEN 1 ELSE 0 END) AS fumble,
       sum(CASE WHEN (play_type = 'Fumble Recovery') THEN 1 ELSE 0 END) AS fumble_recovery
       
FROM play_drive
             JOIN (SELECT * FROM play WHERE offense = team_value) a USING (drive_id, play_number)
             JOIN  drive USING (drive_id)
             JOIN (SELECT * FROM game WHERE season = season_value) b USING (game_id)
GROUP BY game_id) t1;
END //

DELIMITER ;
