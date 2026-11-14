-- T1b. How many ratings are above BOTH the user's mean and the movie's mean?
-- Required columns (one row):
--   n_ratings, n_above_both, share_above_both, share_above_both_20plus
-- share_above_both_20plus: the same share, counting only ratings of movies
-- that have at least 20 ratings.
-- Build on T1a in a CTE; filter or count outside it.
--
-- Prediction (commit before running): share_above_both is about _0.4_.

-- YOUR QUERY HERE
WITH rating_in_context AS(
    SELECT 
        user_id, movie_id, rating, timestamp, 
        AVG(rating) OVER (PARTITION BY user_id) AS user_mean, 
        AVG(rating) OVER (PARTITION BY movie_id) AS movie_mean,
        COUNT(*) OVER (PARTITION BY movie_id) AS number_of_ratings_movie
        FROM ratings
    )
SELECT
    COUNT(*) AS n_ratings,
    SUM(rating>user_mean AND rating>movie_mean) AS n_above_both,
    AVG(rating>user_mean AND rating>movie_mean) AS share_above_both,
    AVG(rating>user_mean AND rating>movie_mean) FILTER (WHERE number_of_ratings_movie>=20) AS share_above_both_20plus
    FROM rating_in_context;





