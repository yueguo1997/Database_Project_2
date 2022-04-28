-- Create vfb database
DROP DATABASE IF EXISTS vfb;
CREATE DATABASE IF NOT EXISTS vfb;
USE vfb;

-- Create vfb mega table: all_plays. There are 30 variables in total
-- This is the table with all the variables of the dataset we originally have
DROP TABLE IF EXISTS all_plays;
CREATE TABLE IF NOT EXISTS all_plays (
    I_D BIGINT,
    drive_id BIGINT,
    game_id BIGINT,
    drive_number INT,
    play_number INT,
    offense VARCHAR(255),
    offense_conference VARCHAR(255),
    offense_score INT,
    defense VARCHAR(255),
    home VARCHAR(255),
    away VARCHAR(255),
    defense_conference VARCHAR(255),
    defense_score INT,
    period INT,
    clock VARCHAR(255),
    offense_timeouts INT,
    defense_timeouts INT,
    yard_line INT,
    yards_to_goal INT,
    down VARCHAR(255),
    distance VARCHAR(255),
    yards_gained VARCHAR(255),
    scoring VARCHAR(255),
    play_type VARCHAR(255),
    play_text VARCHAR(800),
    ppa VARCHAR(255),
    wallclock VARCHAR(255),
    week INT,
    season INT,
    year VARCHAR(255)
);

-- Load data
-- Some values in the dataset is '' value and its datatype in the magetable is INt, which will casue problem when we load data.
-- Therefore, we will change these '' value into NULL value. 
-- Also ignore the first line of variable names
-- Data source: https://drive.google.com/file/d/1k4XSZeyNO7ZEdn90TZo9WADNjZqxb6H2/view?usp=sharing

LOAD DATA LOW_PRIORITY
INFILE "/Users/pangli/Desktop/all_plays2 (1) copy.csv"
INTO TABLE vfb.all_plays
	FIELDS TERMINATED BY '$'
    LINES TERMINATED BY '\n'
    ignore 1 lines
    (I_D,drive_id,game_id,drive_number,play_number,offense,offense_conference,
    offense_score,defense,home,away,defense_conference,defense_score,period,clock,
    @offense_timeouts,@defense_timeouts,yard_line,yards_to_goal ,down,distance,
    yards_gained,scoring,play_type,play_text,ppa,wallclock,@week,@season,year)
    SET offense_timeouts = (CASE WHEN @offense_timeouts = '' THEN NULL ELSE @offense_timeouts END),
        defense_timeouts = (CASE WHEN @defense_timeouts = '' THEN NULL ELSE @defense_timeouts END),
        week = (CASE WHEN @week = '' THEN NULL ELSE @week END),
        season = (CASE WHEN @season = '' THEN NULL ELSE @season END);
        
        
        
-- Decompose tables
-- There are 8 tables after the decompasation 
-- There are also created two additional log tables to record additions, deletions, and changes


-- Create Team offense table
-- This table record which teams have been offense and the corresponding conference and year. 
-- The datatypes in this table are all VARCHAR(255)
DROP TABLE IF EXISTS team_offense;
CREATE TABLE team_offense(
offense                  VARCHAR(255), 
year                     VARCHAR(255),
offense_conference       VARCHAR(255), 
PRIMARY KEY(offense,year)
);


-- Create Team defense table
-- This table record which teams have been defense and the corresponding conference and year. 
-- The datatypes in this table are all VARCHAR(255)
DROP TABLE IF EXISTS team_defense;
CREATE TABLE team_defense(
defense                   VARCHAR(255),
year                      VARCHAR(255),
defense_conference        VARCHAR(255),
PRIMARY KEY(defense,year)
);


-- Create Game table
-- This table record all the game information such as home, away, season and year
-- In this  table, week, season should be positive number. 
DROP TABLE IF EXISTS game;
CREATE TABLE game(
 game_id BIGINT,
 home    VARCHAR(255),
 away    VARCHAR(255), 
 week    TINYINT          UNSIGNED,
 season  INT              UNSIGNED,
 year    VARCHAR(255),
 PRIMARY KEY (game_id)
);

-- Create Drive table
-- This table record the drive information include which game id this drive belongs to.
-- The game_id in this table is a foreign key referring to Game table, including sync updating and deleting

DROP TABLE IF EXISTS drive;
CREATE TABLE drive(
drive_id       BIGINT,
drive_number   TINYINT, 
game_id        BIGINT, 
PRIMARY KEY(drive_id ),
CONSTRAINT fk_game_id FOREIGN KEY (game_id)
    REFERENCES game(game_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- Create Playtype table
-- This table records all diiferent playtypes in football game and whether the playtype can cause scoring.

DROP TABLE IF EXISTS playtype;
CREATE TABLE playtype(
play_type         VARCHAR(255), 
scoring           VARCHAR(255),
PRIMARY KEY (play_type )
);

-- Create Play table
-- On drive can have different plays. This table includes part of the information like which team is deffense and which team is offense in one play.alter
-- defense and offense are foreign keys in this table referring to team defense table and team offense table.
DROP TABLE IF EXISTS play;
CREATE TABLE play(
 drive_id               BIGINT,
 play_number            TINYINT        UNSIGNED,
 period                 TINYINT ,
 offense_score          TINYINT, 
 defense_score          TINYINT, 
 offense_timeouts       INT             DEFAULT 3,
 defense_timeouts       INT             DEFAULT 3,
 wallclock              VARCHAR(255),
 offense                VARCHAR(255), 
 defense                VARCHAR(255),
 
PRIMARY KEY(drive_id, play_number),
CONSTRAINT fk_offense FOREIGN KEY (offense)
    REFERENCES team_offense(offense)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
CONSTRAINT fk_defense FOREIGN KEY (defense)
    REFERENCES team_defense(defense)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
CONSTRAINT fk_newdrive FOREIGN KEY (drive_id)
    REFERENCES drive(drive_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);


-- Create play_drive table
-- This part records the smaller-grained dimension information in the play.
-- Play type, drive id and play number are the forein keys in this table. 
DROP TABLE IF EXISTS play_drive;
CREATE TABLE play_drive(
 I_D          BIGINT               AUTO_INCREMENT,
 drive_id     BIGINT,
 play_number  TINYINT              UNSIGNED,
 clock        VARCHAR(255),
 yard_line              INT,
 yards_to_goal          INT,
 down                   TINYINT,
 distance               INT,
 yards_gained           INT,
 play_type              VARCHAR(255),
 play_text              VARCHAR(800), 
 ppa                    VARCHAR(255)       DEFAULT "0", 
 PRIMARY KEY(I_D),
 CONSTRAINT fk_play_type FOREIGN KEY (play_type)
    REFERENCES playtype(play_type)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
 CONSTRAINT fk_drive_play FOREIGN KEY (drive_id,play_number)
    REFERENCES play(drive_id,play_number)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- Create drive dairy table. 
-- This table records the operations happen on the tables which have drive information.
DROP TABLE IF EXISTS drive_dairy;
CREATE TABLE drive_dairy(
action_id        INT               AUTO_INCREMENT,
drive_id         BIGINT,
play_number      INT,
action_time      DATETIME,
action           VARCHAR(255)      CHECK(action IN ("insert", "update","delete")),
PRIMARY KEY(action_id)
);

-- Create game dairy table
-- This table records the operation happen on the Game table.
DROP TABLE IF EXISTS game_dairy;
CREATE TABLE game_dairy(
action_id        INT               AUTO_INCREMENT,
game_id          BIGINT,
home             VARCHAR(255),
away             VARCHAR(255),
week             TINYINT,
season           INT,
year             VARCHAR(255),
action_time      DATETIME,
action           VARCHAR(255)      CHECK(action IN ("insert", "update","delete")),
PRIMARY KEY(action_id)
);

-- Verify whether the decomposition meets 3CNF
-- In this part we will use group by key to check. If the table meets 3CNF, then there will be nothing returned.
SELECT  COUNT(DISTINCT offense_conference)
FROM all_plays
GROUP BY offense,year
HAVING  COUNT(DISTINCT offense_conference)>1;

SELECT  COUNT(DISTINCT defense_conference)
FROM all_plays
GROUP BY defense,year
HAVING  COUNT(DISTINCT defense_conference)>1;


SELECT game_id
FROM all_plays
GROUP BY game_id
HAVING  COUNT(DISTINCT home)>1 
		or COUNT(DISTINCT away)>1 
        or COUNT(DISTINCT week)>1 
        or COUNT(DISTINCT season)>1 
        or COUNT(DISTINCT year)>1;

SELECT drive_id
FROM all_plays
GROUP BY drive_id
HAVING  COUNT(DISTINCT drive_number)>1 
		or COUNT(DISTINCT game_id)>1;


SELECT play_type
FROM all_plays
GROUP BY play_type
HAVING  COUNT(DISTINCT scoring)>1;

SELECT drive_id, play_number
FROM all_plays
GROUP BY drive_id,play_number
HAVING  COUNT(DISTINCT period)>1 
		or COUNT(DISTINCT offense_score)>1 
        or COUNT(DISTINCT defense_score)>1 
        or COUNT(DISTINCT offense_timeouts)>1 
        or COUNT(DISTINCT defense_timeouts)>1
        or COUNT(DISTINCT wallclock)>1 
        or COUNT(DISTINCT offense)>1 
        or COUNT(DISTINCT defense)>1;

SELECT I_D
FROM all_plays
GROUP BY I_D
HAVING  COUNT(DISTINCT drive_id)>1 
		or COUNT(DISTINCT play_number)>1 
        or COUNT(DISTINCT clock)>1 
        or COUNT(DISTINCT yard_line)>1 
        or COUNT(DISTINCT yards_to_goal)>1
        or COUNT(DISTINCT down)>1 
        or COUNT(DISTINCT distance)>1 
        or COUNT(DISTINCT yards_gained)>1
        or COUNT(DISTINCT play_type)>1 
        or COUNT(DISTINCT play_text)>1
        or COUNT(DISTINCT ppa)>1;

-- Insert data from maga table into each decompsition table
INSERT INTO game(game_id, home,away, week,season,year)
SELECT DISTINCT game_id, home,away, week,season,year
FROM all_plays;

INSERT INTO team_offense(offense, year,offense_conference)
SELECT DISTINCT offense, year,offense_conference
FROM all_plays;

INSERT INTO team_defense(defense, year,defense_conference)
SELECT DISTINCT defense,year, defense_conference
FROM all_plays;

INSERT INTO drive(drive_id,drive_number, game_id)
SELECT DISTINCT drive_id,drive_number, game_id
FROM all_plays;

INSERT INTO playtype(play_type, scoring)
SELECT DISTINCT play_type, scoring
FROM all_plays;

INSERT INTO play(drive_id ,play_number,period,offense_score, defense_score, offense_timeouts,defense_timeouts,
wallclock, offense, defense)
SELECT DISTINCT drive_id ,play_number,period,offense_score, defense_score, offense_timeouts,defense_timeouts,
 wallclock, offense, defense
FROM all_plays;

INSERT INTO play_drive(I_D,drive_id,play_number,clock,yard_line,yards_to_goal,down,distance,yards_gained,play_type,play_text,ppa)
SELECT DISTINCT I_D,drive_id,play_number,clock,yard_line,yards_to_goal,down,distance,yards_gained,play_type,play_text,ppa
FROM all_plays;


-- Check whether the data number in the decomposition table is the same with the data number in the maga table
SELECT COUNT(*)
FROM play_drive
	JOIN play USING(drive_id ,play_number)
    JOIN playtype USING(play_type)
    JOIN drive USING(drive_id)
    JOIN game USING(game_id)
    JOIN team_defense USING(defense,year)
    JOIN team_offense USING(offense,year);
    
SELECT COUNT(*)
FROM all_plays;
-- From the result we can see that the numbers are the same. 


-- Features
-- Following codes include all the functions we accomplished in the front end and data base(after decomposition
-- We have 5 triggers, 7 procedures(include 1 transaction) and 2 views.
USE vfb;

-- Triggers

-- Create insert_game_check trigger
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


-- Procedures

-- Create insert_game
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

-- Views
USE vfb;

-- Create a view of the game_id, season, home, away, home_score, away_score
-- From the play drive and game tables
-- Home_score should be the max offense_score for the home team in the game when offense is home
-- Away_score should be the max offense_score for the away team in the game when offense is away
DROP VIEW IF EXISTS game_score;
CREATE VIEW game_score AS
SELECT game.game_id, game.season, game.home, game.away,
       MAX(CASE WHEN offense = home THEN offense_score ELSE NULL END) AS home_score,
       MAX(CASE WHEN offense = away THEN offense_score ELSE NULL END) AS away_score
FROM play
JOIN drive ON play.drive_id = drive.drive_id
JOIN game ON drive.game_id = game.game_id
GROUP BY game.game_id, game.season, game.home, game.away;


-- Create team score view
-- This view shows how many games a team wins in different season
-- Find the winner of each game and calculate the number group by winner
DROP VIEW IF EXISTS team_score;
CREATE VIEW team_score AS
SELECT season,(CASE WHEN home_score > away_score THEN home ELSE away END) AS winner,count(*) as wins
FROM game_score
GROUP BY winner,season 
HAVING season IS NOT NULL;

