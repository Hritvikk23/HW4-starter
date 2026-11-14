# Predictions

- T1(a): 100k rows. Ratings of all the users including the avg rating of user and avg rating of the movie, because there's no GROUPBY or JOIN. 
- T1(b): About 50?. I think it's rare for one rating to be above both averages. 
- T1(c): The genre_means AS() and JOIN genre_means USING genre_id queries are disappeared and replaced by the window function. The reason that the original CTE has two extra steps because it grouped by genre to find the mean of each genre which returned a one row per genre and no movies. To compare the movie to it's genre mean, it joined the genre table to the movie rows. 


- T2: ROW_NUMBER will return about 60 rows or less because there are 21 occupations and we have to return the top 3 per occupation which is 21*3 = 63, some occupations might not have 3 movies with 20+ ratings, so around 60. RANK will return more rows than ROW_NUMBER because every occupation ROW_NUMBER keeps RANK keeps it too and it's rank might be smaller or the same. RANK may keep tied movies, so it returns the same or more number of rows as ROW_NUMBER. 
    - The movie_id can be a tiebreaker and if there is a tie, the lower movie_id will get the earlier position. The value of movie_id is distinct and never the same so it can be a tie-breaker. movie_id order has no meaning, lower movie_id doesn't mean that it's a better movie, it just helps in keeping the result consistent.

- T3:  
    - The median ratings per session is 11.0, it's smaller than I expected it to be 
    - No, the results did not change after ROWS frame is removed.
    - Tied timestamps do not affect session numbers because when a user gives rating for two movies at the same time, the second one's gap is 0 and it can never start a session. It doesn't matter if the window is ordered by (timestamp, movie_id ) or timestamp alone because both the rows get the same session number. In T3b, the tied rows carry real ratings and changes the average. 
    - The rows that differ are the rows where the user has two or more ratings with time same timestamp. Run_default is ordered by timestamp only so the rows with the same timestamps are included in each row's average at once. Run_rows is ordered by timestamp and movie_id, so it goes one row at a time in timestamp,movie_id order. 
    - A user can rate a movie only once because the primary key is user_id and movie_id and the query is ordered by timestamp and movie_id, so no two rows of the same user can have both the same timestamp and movie_id. So with no ties, run_default behaves like ROWS fra e. This is why session flags didn't change. 
    - Both frames cover the same rows at a user's last rows, so every user's last value agrees.
- T4: 
    - I pick movie_id, rating cause every time anyone opens a movie page, the database has to search all the 100k ratings to find one. With movie_id as an index, it jumps straight to movie ratings. The output supports it, before the index it takes 2.5162, after the index it takes 0.0365.
    - timestamp is the other index because it helps for both t4c and t4d_rewrite. Output for t4c before is 2.2832 and after is 0.0477 and for t4d before is 2.9708, after is 0.2811. user_id, timestamp do not not help with td4 because it sorts out user_id first, similar to the phonebook problem.
    - A_profile uses an index before adding any because user_id, movie_id are primary keys and automatically gets an index. A_profile can use it because it filters on user_id which is the leftmost column. 
    - For A_profile, the user_id finds the user's rows but in movie_id order. The query is ordered by timestamp so the B-TREE sorts them by timestamp in a temp structure and takes the top 20. 
    - Before indexes the bytes were 3629056 and after were 6168576. 6168576 - 2629056 = 2539520 bytes which approx is 2.5MB
    - D_month cannot become a SEARCH because index stores raw timestamps but the query is asking in the format of year and month. These values are not stored in the index, so it has to go through every row and compare them which is basically a SCAN. The rewrite changes to timestamp>= AND timestamp < ?, which compares the raw column directly without any function and the index is sorted, so the database jumps to the first second of the month and stops at the end of month and reads only entries of that month. SCAN has become SEARCH.
    - No, it did not change my choice. Choosing timestamp as index not only made t4c into SEARCH but made T4D quicker as well even though it's a SCAN. One index served two queries. C_recent Before: 2.283 and After: 0.048, D_rewrite Before: 2.971 After: 0.281.
- T5:
    I would recommed the add indexes on (movie_id, rating) and (timestamp). An index is like an index in a phone book which is sorted by the last name to find the contacts faster, without an index, the database has to read every row to answer a question. With an index, it can jump straight to it. The outputs from t4 are the evidences for this, after adding the index, the times were quicker. For B_movie page before the index it takes 2.5162, after the index it takes 0.0365, similarly for C_recent Before: 2.283 After: 0.048 and D_rewrite Before: 2.971 After: 0.281. Leave out (user_id, timestamp) because the database already created an index automatically that starts with user_id which makes A_profile fast, adding another would cost more storage and save a small sorting step. One of the risks with an index is storage, the index adds storage, before indexes the bytes were 3629056 and after were 6168576. 6168576 - 3629056 = 2539520 bytes which approx is 2.5MB.


# Output

```
--- t1
 n_ratings  n_above_both  share_above_both  share_above_both_20plus
    100000         45232           0.45232                 0.460408
wrote output\t1.json
--- t2
wrote output\t2.json
--- t3
wrote output\t3.json
--- t4
wrote output\t4.json
A_profile         0.115 ms ->     0.115 ms   ['SEARCH ratings USING INDEX sqlite_autoindex_ratings_1 (user_id=?)', 'USE TEMP B-TREE FOR ORDER BY']
B_movie_page      2.516 ms ->     0.036 ms   ['SEARCH ratings USING COVERING INDEX idx_ratings_movie_rating (movie_id=?)']
C_recent          2.283 ms ->     0.048 ms   ['SEARCH ratings USING COVERING INDEX idx_ratings_timestamp (timestamp>?)']
D_month          20.785 ms ->    19.626 ms   ['SCAN ratings USING COVERING INDEX idx_ratings_timestamp']
D_rewrite         2.971 ms ->     0.281 ms   ['SEARCH ratings USING COVERING INDEX idx_ratings_timestamp (timestamp>? AND timestamp<?)']

```