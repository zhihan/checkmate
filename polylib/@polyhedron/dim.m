function n = dim(POLY)

% Dimension of the space containing a polyhedron object 
%
% Syntax:
%   "n = dim(poly)"
%
% Description:
%   "dim(poly)" returns the dimension of the space in which "poly" resides. 
%
% Examples:
%   Given a polyhedron object, "poly" representing a square in the x3 = 0
%   plane with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and (4,1) 
%
%
%
%   "n = dim(poly)"
%
%
%
%   returns 
%
%
%
%   "n = 3"
%
%
%
% See Also:
%   polyhedron

if ~isempty(POLY.CE)
  n = size(POLY.CE,2);
elseif ~isempty(POLY.CI)
  n = size(POLY.CI,2);
else
  n = 0;
end
