# Predictions

- T1(a): 100k rows. Ratings of all the users including the avg rating of user and avg rating of the movie, because there's no GROUPBY or JOIN. 
- T1(b): About 50?. I think it's rare for one rating to be above both averages. 
- T1(c): The genre_means AS() and JOIN genre_means USING genre_id queries are disappeared and replaced by the window function. The reason that the original CTE has two extra steps because it grouped by genre to find the mean of each genre which returned a one row per genre and no movies. To compare the movie to it's genre mean, it joined the genre table to the movie rows. 


- T2: ROW_NUMBER will return about 60 rows or less because there are 21 occupations and we have to return the top 3 per occupation which is 21*3 = 63, some occupations might not have 3 movies with 20+ ratings, so around 60. RANK will return more rows than ROW_NUMBER because every occupation ROW_NUMBER keeps RANK keeps it too and it's rank might be smaller or the same. RANK may keep tied movies, so it returns the same or more number of rows as ROW_NUMBER. 
- The movie_id can be a tiebreaker and if there is a tie, the lower movie_id will get the earlier position. The value of movie_id is distinct and never the same so it can be a tie-breaker. movie_id order has no meaning, lower movie_id doesn't mean that it's a better movie, it just helps in keeping the result consistent.

- T3:

- T4, T5: I pick the 