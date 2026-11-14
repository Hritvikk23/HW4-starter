-- T3. Rating sessions. A user's ratings form one session until there is a gap
-- of more than 1800 seconds (30 minutes) since that user's previous rating.
-- Required columns, one row per session:
--   user_id, session_no, n_ratings, start_ts, duration_s
-- session_no counts 1, 2, 3, ... within each user, in time order.
-- Suggested steps (one CTE each): gap with LAG; a 0/1 new_session flag;
-- a running SUM of the flag with an explicit ROWS frame; GROUP BY.
--
-- Prediction (commit before running): median ratings per session = ~40_.


-- YOUR QUERY HERE
WITH gaps AS(
    SELECT user_id, movie_id, timestamp AS ts, 
    timestamp - LAG(timestamp) OVER ( PARTITION BY user_id ORDER BY timestamp, movie_id) AS gap FROM ratings
    ),

flag AS(
    SELECT user_id, movie_id, ts, 
    CASE WHEN gap IS NULL OR gap>1800 THEN 1 ELSE 0 END AS new_session FROM gaps),  
session_number AS(
    SELECT user_id,movie_id,ts,
        SUM(new_session) OVER (PARTITION BY user_id ORDER BY ts, movie_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT row) AS session_no FROM flag)
SELECT user_id, session_no, COUNT(*) AS n_ratings, MIN(ts) AS start_ts, MAX(ts)-MIN(ts) AS duraion_s FROM session_number
GROUP BY user_id, session_no;