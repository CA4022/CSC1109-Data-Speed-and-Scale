a = LOAD '<path_to_iris1.csv>' USING PigStorage(',');
b = LOAD '<path_to_iris2.csv>' USING PigStorage(',');

c = UNION a,b;
SPLIT c INTO d IF $0 < 5.5, e IF $0 >= 5.5;
DUMP d;
DUMP e;
f = FILTER c BY $4 == 'Setosa';
DUMP f;


A = LOAD '<path_to_iris1.csv>'
      USING PigStorage(',')
      AS (
        sepal_length:float,
        sepal_width:float,
        petal_length:float,
        petal_width:float,
        species:chararray
      );

B = LOAD '<path_to_iris2.csv>'
      USING PigStorage(',')
      AS (
        sepal_length:float,
        sepal_width:float,
        petal_length:float,
        petal_width:float,
        species:chararray
      );

C = UNION A,B;
G = FOREACH C GENERATE sepal_length, sepal_length * sepal_width;
DUMP G;
