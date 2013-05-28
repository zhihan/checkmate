function result = issubset(a,b)

% Determine whether or not the intersection of two linear constraint objects
% exists.
%
% Syntax:
%   "C = issubset(a,b)"
%
% Description:
%   "issubset(a,b)" returns a "1" if  "a" a subset of "b" and
%   "0" otherwise.
%
% Examples:
%   Given two linear constraint objects, "a" representing a square in the
%   x3 = 0 plane with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and
%   (4,1) and "b", another square in the same plane with corners at (2,1),
%   (2,2), (3,1), and (3,2), 
%
%
%
%   "C = issubset(a,b)"
%
%
%
%   returns "1".
%
% See Also:
%   linearcon,and, isfeasible

if isa(b,'polyhedron')
  b = linearcon(b);
end

if isa(b,'linearcon')
  c = subseteq(a,b);
else
  c = 0;
end

result = c;

