function V = volume(POLY)

% Compute volume of the polytope represented by a polyhedron object
%
% Syntax:
%   "V = volume(poly)"
%
% Description:
%   "volume(poly)" returns the volume of the region represented by "poly".  
%
% Notes:
%   It is assumed that the polytope is full dimensional (n), so there are
%   no equality constraints.
%
%
%
%   The polyhedron object is first converted to a linear constraint
%   object, and the volume is then calculated using the linear constraint
%   volume function.
%
% Examples:
%   Given,
%
%
%
%     "con ="
%
%     "[ 1.000000 0.000000 0.000000 ]x <= 4.000000"
%
%     "[ -1.000000 0.000000 0.000000 ]x <= -2.000000"
%
%     "[ 0.000000 1.000000 0.000000 ]x <= 3.000000"
%
%     "[ 0.000000 -1.000000 0.000000 ]x <= -1.000000"
%
%     "[ 0.000000 0.000000 1.000000 ]x <= 2.000000"
%
%     "[ 0.000000 0.000000 -1.000000 ]x <= 0.000000"
%
%     "poly = polyhedron(con);"
%
%
%
%   then,
%
%
%
%     "V = volume(poly)"
%
%
%
%   results in
%
%
%
%     "V = 8"
%
%
%
% See Also:
%   volume,polyhedron,linearcon


V = volume(linearcon(POLY));
return


