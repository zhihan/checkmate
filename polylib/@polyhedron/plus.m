function sum = plus(con1,con2)
% Compute the Vector sum of two linearcon object
%
% test code, derived from 'Invariant Set Toolbox' by Kerrigan
% it seems not work in some cases, 
% so I switch to point method.

v1 = vertices(con1);
v2 = vertices(con2);

v3 = v1 + v2;
sum =polyhedron(v3);
return
