-- T2 (version 1, ROW_NUMBER). The three highest-rated movies for each
-- occupation, among movies rated at least 20 times by users with that occupation.
-- Required columns: occupation, pos, movie_id, title, n, mean_rating
-- Order the window so that the result is the same on every run (state your
-- tie-breaker in WRITEUP.md).
--
-- Prediction (commit before running): _60_ rows.

-- YOUR QUERY HERE
WITH top3_row_num AS(
    SELECT u.occupation, r.movie_id, COUNT(*) AS n, AVG(r.rating) AS mean_rating FROM ratings r
    JOIN users u ON u.user_id = r.user_id
    GROUP BY u.occupation, r.movie_id
    HAVING COUNT(*)>=20),
    
ranking AS(
    SELECT *, ROW_NUMBER() OVER(PARTITION BY OCCUPATION ORDER BY mean_rating DESC, movie_id) 
    AS pos FROM top3_row_num)

SELECT rk.occupation, rk.pos, rk.movie_id, m.title, rk.n, rk.mean_rating FROM ranking rk
JOIN movies m on m.movie_id = rk.movie_id 
WHERE rk.pos<=3;


    