-- Filter to only include irises of the "virginica" species
SELECT * FROM iris WHERE species == "virginica";
-- Find the 10 samples with the longest petals
SELECT * FROM iris ORDER BY "petal_length" LIMIT 10;
-- Get the averages on a per-species basis
SELECT
    species,
    AVG(petal_width),
    AVG(petal_length),
    AVG(sepal_width),
    AVG(sepal_length)
FROM iris GROUP BY species;
