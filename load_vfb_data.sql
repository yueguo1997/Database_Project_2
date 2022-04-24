-- create vfb database
DROP DATABASE IF EXISTS vfb;
CREATE DATABASE IF NOT EXISTS vfb;
USE vfb;

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
DROP TABLE IF EXISTS team_offense;
CREATE TABLE team_offense(
offense                  VARCHAR(255), 
year                     VARCHAR(255),
offense_conference       VARCHAR(255), 
PRIMARY KEY(offense,year)
);


DROP TABLE IF EXISTS team_defense;
CREATE TABLE team_defense(
defense                   VARCHAR(255),
year                      VARCHAR(255),
defense_conference        VARCHAR(255),
PRIMARY KEY(defense,year)
);

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

DROP TABLE IF EXISTS playtype;
CREATE TABLE playtype(
play_type         VARCHAR(255), 
scoring           VARCHAR(255),
PRIMARY KEY (play_type )
);


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
    ON UPDATE CASCADE
);



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

DROP TABLE IF EXISTS drive_dairy;
CREATE TABLE drive_dairy(
action_id        INT               AUTO_INCREMENT,
drive_id         BIGINT,
play_number      INT,
action_time      DATETIME,
action           VARCHAR(255)      CHECK(action IN ("insert", "update","delete")),
PRIMARY KEY(action_id)
);

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



-- INSERT DATA
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


-- Check the final count

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

-- Features
USE vfb;

-- Triggers

DROP TRIGGER IF EXISTS insert_game_check
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

DROP TRIGGER IF EXISTS update_game_check
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


DROP TRIGGER IF EXISTS delete_game_check
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
-- insert_game
USE vfb;
DROP PROCEDURE IF EXISTS insert_game;
DELIMITER //
CREATE PROCEDURE insert_game(IN gameid BIGINT, IN home VARCHAR(255),IN away VARCHAR(255), IN week TINYINT, IN season INT, IN year VARCHAR(255))
BEGIN

DECLARE EXIT HANDLER FOR 1062 SELECT "Insert Failed because of duplicate key";

INSERT INTO game(game_id, home,away, week,season,year)
VALUES (gameid, home,away,week,season,year);

SELECT CONCAT("Insert game ",gameid," successfully");

END //
DELIMITER ;










-- delete_game
USE vfb;
DROP PROCEDURE IF EXISTS delete_game;
DELIMITER //
CREATE PROCEDURE delete_game (IN gameid BIGINT)
BEGIN 

IF NOT EXISTS(SELECT * from vfb.game where game_id = gameid) THEN
	SELECT CONCAT("Game ", gameid, " Doesn't exist");
ELSE
	DELETE FROM game 
	WHERE game_id = gameid;
	SELECT CONCAT("Delete game ", gameid, " sucessfully");
END IF;
END //
DELIMITER ;

-- update_game
USE vfb;
DROP PROCEDURE IF EXISTS update_game;
DELIMITER //
CREATE PROCEDURE update_game(IN a BIGINT, IN b VARCHAR(255),IN c VARCHAR(255), IN d TINYINT, IN e INT, IN f VARCHAR(255))
BEGIN

IF NOT EXISTS (select * from vfb.game where game_id = a) THEN
    SELECT CONCAT("GAME ID ",a, " doesn't exist");
ELSE
    UPDATE game SET home=b, away=c, week=d, season=e, year=f WHERE game_id=a;
    SELECT CONCAT("GAME ID ",a," updated sucessfully");
END IF;
END //
DELIMITER ;

-- insert_drive
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


DROP PROCEDURE IF EXISTS exposive_play;
DELIMITER //
CREATE PROCEDURE exposive_play()
BEGIN
SELECT SUM(CASE WHEN (play_type LIKE "%Pass%" AND yards_gained > 16) THEN 1 ELSE 0 END) AS explosive_play_number,
       SUM(offense_score) AS off_tds
FROM play_drive
	JOIN play USING(drive_id,play_number)
    JOIN drive USING(drive_id)
GROUP BY game_id;
END //
DELIMITER ;





-- Views
USE vfb;

-- create a view of the game_id, season, home, away, home_score, away_score
-- from the play drive and game tables
-- home_score should be the max offense_score for the home team in the game when offense is home
-- away_score should be the max offense_score for the away team in the game when offense is away
DROP VIEW IF EXISTS game_score;
CREATE VIEW game_score AS
SELECT game.game_id, game.season, game.home, game.away,
       MAX(CASE WHEN offense = home THEN offense_score ELSE NULL END) AS home_score,
       MAX(CASE WHEN offense = away THEN offense_score ELSE NULL END) AS away_score
FROM play
JOIN drive ON play.drive_id = drive.drive_id
JOIN game ON drive.game_id = game.game_id
GROUP BY game.game_id, game.season, game.home, game.away;


-- create team score view
USE vfb;

DROP VIEW IF EXISTS team_score;
CREATE VIEW team_score AS
SELECT season,(CASE WHEN home_score > away_score THEN home ELSE away END) AS winner,count(*) as wins
FROM game_score
GROUP BY winner,season 
HAVING season IS NOT NULL;





