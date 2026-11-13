-- T2 (version 2, RANK). The same question, with RANK() ordered by mean_rating
-- only, keeping rows with pos <= 3.
-- Required columns: occupation, pos, movie_id, title, n, mean_rating
--
-- Prediction (commit before running): ___~70___ rows, which is more
-- than version 1, because ___because every occupation ROW_NUMBER keeps RANK keeps it too and it's rank might be smaller or the same. RANK may keep tied movies, so it returns the same or more number of rows as ROW_NUMBER.

-- YOUR QUERY HERE
