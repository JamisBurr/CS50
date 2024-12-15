SELECT AVG(rating) AS "Rating AVG for 2012"
  FROM ratings
       JOIN movies ON ratings.movie_id = movies.id
 WHERE year = 2012;