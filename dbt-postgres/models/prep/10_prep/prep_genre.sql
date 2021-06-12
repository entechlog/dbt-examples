{{ config(materialized='view') }}

SELECT "genre", count(1)
FROM {{ref('movies')}} im
inner join {{ref('movies_genres')}} img on im.id = img.movie_id 
group by "genre"
order by 2 desc 