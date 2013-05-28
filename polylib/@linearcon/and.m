function c = and(a,b)

% Find the intersection of two linear constraint objects.  Remove all
% redundant constraints
%
% Syntax:
%   "C = and(a,b)"
%
%   "C = a & b"
%
% Description:
%   "and(a,b)" returns a linear constraint object representing the
%   intersection of the constraint sets represented by "a" and "b", and
%   removes any redundant constraints. 
%
% Examples:
%   Given two linear constraint objects, "a", representing a square in the
%   x3 = 0 plane with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and
%   (4,1) and "b", another square in the same plane with corners at (2,1),
%   (2,2), (3,1), and (3,2),
%
%
%
%     "C = and(a,b)"
%
%
%
%   returns "C", a linear constraint object which uses four inequalities
%   to represent a square in the x3 = 0 plane with corners at (x1,x2)
%   pairs (2,1), (2,2), (3,2), and (3,1).
%
% See Also:
%   linearcon,isfeasible 

if isa(b,'polyhedron')
  b = linearcon(b);
end

if isa(b,'linearcon')
    if isfeasible(a,b)
        c = intersect(a,b,1);
    else
        c = linearcon;
    end
else
  c = linearcon;
end

