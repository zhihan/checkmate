function c = minus(a,b)

% Subtract two vertices objects 
%
% Syntax:
%   "vtcs = minus(v1,v2)"
%
%   "vtcs = v1 - v2"
%
% Description:
%   "minus(v1,v2)" returns a vertices object containing the difference
%   between  the point "v2" and each point in "v1".  "v2" may be passed
%   as a vector of coordinates which is then converted to a single point
%   vertices object and subtracted from each point in "v1".  If "v2" is
%   larger than a single point or of a different dimension than "v1", then
%   an empty vertices object is returned. 
%
% Examples:
%   Given a vertices object, "v1" representing a square in the x3 = 0
%   plane with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and (4,1), 
%
%
%
%   "v2 = [0 0 -1]';"
%
%   "vtcs = v1 - v2"
%
%
%
%   returns "vtcs", a vertices object representing the same square in the
%   x3 = 1 plane.
%
% See Also:
%   vertices,uminus,plus

if ~isa(b,'vertices')
  b = vertices(b);
end

c = a + (-b);
