function val = get_param(p,param)

% Retrieve parameters of a polyhedron object
%
% Syntax:
%   "A = get_param(poly,p)"
%
% Description:
%   "get_param(poly,p)" returns the parameter "p" from the
%   polyhedron object "poly".
%
%   "p" is one of "'CE'","'dE'","'CI'","'dI'","'VE'","'VI'","'vtcs'"
%
%   where: 
%
%   *"'CE'" and "'dE'" correspond to the matrix equality CEx = dE
%
%   *"'CI'" and "'dI'" correspond to the matrix inequality CIx <= dI
%
%   *"'VE'" and "'VI'" are the vertices on the respective equalities and
%   inequalities 
%
%   *"'vtcs'" are the vertices of the polyhedron
%
% Example:
%   Given a polyhedron object, "poly" representing a square in the
%   x3 = 0 plane with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and
%   (4,1),
%
%
%
%   "A = get_param(poly,'dI')"
%
%
%
%   results in
%
%
%
%   "A ="
%
%
%
%   "4"
%
%   "-2"
%
%   "3"
%
%   "-1"
%
%
%
%
% See Also:
%   polyhedron

val = eval(['p.' param]);
return





