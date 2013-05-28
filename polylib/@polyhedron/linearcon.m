function con = linearcon(p)

% Converts a polyhedron object to a linear constraint object 
%
% Syntax:
%   "con = linearcon(poly)"
%
% Description:
%   "linearcon(poly)" returns a linear constraint object constructed from
%   the equality and inequality constraints specified in "poly". 
%
% Examples:
%   Given a polyhedron object "poly" representing a square in the x3 = 0
%   plane with corners at (x1,x2) pairs (1,1), (2,1), (2,2) and (1,2), 
%
%
%
%   "con = linearcon(poly)"
%
%
%
%   returns a linear constraint object "con" representing the constraints
%   CEx = dE and CIx <= dI where, CE = [0 0 1], dE = 0, CI = [1 0 0;
%   -1 0 0;0 1 0;0 -1 0] and dI = [2;-1;2;-1].   
%
% See Also:
%   polyhedron,linearcon

CE = p.CE;
dE = p.dE;
CI = p.CI;
dI = p.dI;
con = linearcon(CE,dE,CI,dI);
