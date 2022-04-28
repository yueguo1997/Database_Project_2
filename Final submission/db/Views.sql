-- Views
USE vfb;

-- Create a view of the game_id, season, home, away, home_score, away_score
-- Display: Game Score
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
-- Display: Team results
-- This view shows how many games a team wins in different season
-- Find the winner of each game and calculate the number group by winner
DROP VIEW IF EXISTS team_score;
CREATE VIEW team_score AS
SELECT season,(CASE WHEN home_score > away_score THEN home ELSE away END) AS winner,count(*) as wins
FROM game_score
GROUP BY winner,season 
HAVING season IS NOT NULL;
