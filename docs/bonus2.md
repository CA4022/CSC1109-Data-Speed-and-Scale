---
title: "Bonus Lab 2: Honey Roast Ham 󰾡&nbsp;󱀆&nbsp;"
---

{{ "# " ~ page.meta.title ~ " #" }}

![XKCD 1563](https://imgs.xkcd.com/comics/synonym_movies.png#center)

## Hive and Pig on Movielens data ##

For this Lab, we will use the MovieLens Small Dataset to examine the functions of Hive and Pig.
Both of these applications can either run on top of a working HDFS/MapReduce cluster, or they can
run in local mode. We suggest you use the local mode for debugging first, and then move onto
executing them on your Hadoop cluster.

## Tasks ##

1. Obtain the MovieLens Latest Small dataset from [here](http://grouplens.org/datasets/movielens/)
   * `$ wget http://files.grouplens.org/datasets/movielens/ml-latest-small.zip`

2. Load and clean the MovieLens Dataset files with Pig. Before saving the results into a .csv file
for further processing, you would need to clean and organize the data, including, among others:

    - split multiple genres
    - fix delimiters
    - separate year from title
    - decide which files to merge or not into single tables
    - etc... based on what queries/exploration/analysis you need to run

3. With Pig, do some simple analysis on the data you have loaded and cleaned, specifically:
    - What is the title of the movie with the highest number of ratings (top-rated movie)?
    - What is the title of the most liked movie (e.g. only 5 stars ratings OR only 4 and 5 star
    ratings OR majority of 5 star ratings)
    - What is the User with the highest average rating?

4. With Hive, explore the data you have structured by running the simple queries below (in order
of difficulty):
    - What is the title of the movie with the highest number of ratings (top-rated movie)?
    - What is the title of the most liked movie (e.g. only 5 stars ratings OR only 4 and 5 star
    ratings OR majority of 5 star ratings)
    - What is the User with the highest average rating?

5. With Hive, explore the data you have structured by running the queries below (in order of
difficulty):
    - Count the number of ratings for each star level (How many 1 star ratings? ... How many 5*
    ratings?)
    - What is the most popular rating?
    - How are ratings distributed by genre? (this can tell you what genre is most seen and rated,
    independently of the rating)

## Notes ##

- Read the [README](http://files.grouplens.org/datasets/movielens/ml-latest-small-README.html) for
details of how the files are organised.
- Note that when you execute Pig and Hive onto your Hadoop cluster, you need to:
  - run dfs and yarn
  - check your JAVA_HOME, HADOOP_HOME, HIVE_HOME and PIG_HOME are set correctly, if not use `export`
  to set them.
  - make sure the MovieLens dataset you downloaded is present onto the hadoop HDFS (if not, use
  `-put` or `-copyFromLocal` to move it)

## Further Reading & Examples &nbsp; ##

Useful Links on Pig, Hive and MovieLens (note that not all the data necessary to run the queries
below is contained in the small dataset):

- [Hive for film user behaviour](https://liamgavinmurray.com/2014/04/13/evaluating-film-user-behaviour-with-hive/)
- [Hive for gender bias](https://ragrawal.wordpress.com/2013/09/14/detecting-gender-bias-per-movie-genre-using-hive/)
- [Pig for loading/cleaning MovieLens files](https://ashokharnal.wordpress.com/2014/03/25/analysing-movielens-movie-data-using-pig-a-step-by-step-tutorial/)
