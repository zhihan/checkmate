function result = isempty(p)

% Determine if a polyhedron object is empty 
%
% Syntax:
%   "result = isempty(poly)"
%
% Description:
%   "isempty(poly)" returns "1" if "poly" is empty and "0" otherwise. 
%
% Examples:
%   Given a polyhedron object, "poly" representing a square in the x3 = 0
%   plane with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and (4,1) 
%
%
%
%   "result = isempty(poly)"
%
%
%
%   returns 
%
%
%
%   "result = 0"
%
%
%
%   while 
%
%
%
%   "poly = polyhedron"
%
%   "result = isempty(poly)"
%
%
%
%   returns 
%
%
%
%   "result = 1"
%
%
%
% See Also:
%   polyhedron

result = isempty(p.CE) & isempty(p.dE) & isempty(p.VE) & ...
         isempty(p.CI) & isempty(p.dI) & isempty(p.VI) & ...
         isempty(p.vtcs);
