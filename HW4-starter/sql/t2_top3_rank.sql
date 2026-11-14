-- T2 (version 2, RANK). The same question, with RANK() ordered by mean_rating
-- only, keeping rows with pos <= 3.
-- Required columns: occupation, pos, movie_id, title, n, mean_rating
--
-- Prediction (commit before running): ___~70___ rows, which is more
-- than version 1, because ___because every occupation ROW_NUMBER keeps RANK keeps it too and it's rank might be smaller or the same. RANK may keep tied movies, so it returns the same or more number of rows as ROW_NUMBER.

-- YOUR QUERY HERE
WITH top3_row_num AS(
    SELECT u.occupation, r.movie_id, COUNT(*) AS n, AVG(r.rating) AS mean_rating FROM ratings r
    JOIN users u ON u.user_id = r.user_id
    GROUP BY u.occupation, r.movie_id
    HAVING COUNT(*)>=20),
    
ranking AS(
    SELECT *, RANK() OVER(PARTITION BY OCCUPATION ORDER BY mean_rating DESC) 
    AS pos FROM top3_row_num)

SELECT rk.occupation, rk.pos, rk.movie_id, m.title, rk.n, rk.mean_rating FROM ranking rk
JOIN movies m on m.movie_id = rk.movie_id 
WHERE rk.pos<=3;
