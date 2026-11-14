-- T1a. Every rating next to its user's mean and its movie's mean.
-- Required columns: user_id, movie_id, rating, user_mean, movie_mean
-- One query, no join, no GROUP BY.
--
-- Prediction (commit before running): this query returns _100k_ rows, because  there's no GROUPBY OR JOIN.

-- YOUR QUERY HERE
SELECT user_id, movie_id, rating, timestamp, AVG(rating) OVER (PARTITION BY user_id) AS user_mean, AVG(rating) OVER (PARTITION BY movie_id) AS movie_mean FROM ratings;
