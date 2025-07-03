a = LOAD ‘<path_to_iris1.csv>’ using PigStorage(‘,’);
b = LOAD ‘<path_to_iris2.csv>’ using PigStorage(‘,’);
c = UNION a,b;
SPLIT c INTO d IF $0==0, e IF $0==1;
dump d;
dump e;
f = FILTER c BY $1>3;
dump f;

A = LOAD ‘<path_to_iris1.csv>’ using PigStorage(‘,’) as (a1:int, a2:int, a3:int);
B = LOAD ‘<path_to_iris2.csv>’ using PigStorage(‘,’) as (b1:int, b2:int, b3:int);
C = UNION A,B;
G = FOREACH C GENERATE a2, a2*a3;
dump G;
