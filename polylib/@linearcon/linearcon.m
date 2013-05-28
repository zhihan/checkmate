function con = linearcon(CE,dE,CI,dI)

% Linear constraint object class constructor 
%
% Syntax:
%   "con = linearcon(CE,dE,CI,dI)"
%
%   "con = linearcon(C)"
%
%   "con = linearcon"
%
% Description:
%   "linearcon(CE,dE,CI,dI)" returns a linear constraint object satisfying
%   the linear equations CEx = dE and CIx <= dI.  If "C" is a linear
%   constraint object, then "linearcon(C)" returns another linear
%   constraint object using the constraints from "C".  A call to "linearcon"
%   with no arguments returns an empty linear constraint object.
%
% Examples:
%   The command sequence 
%
%
%
%     "CE = [0 0 1]; dE = 0;"
%
%     "CI = [1 0 0;-1 0 0;0 1 0;0 -1 0]; dI = [4;-2;3;-1];"
%
%     "con = linearcon(CE,dE,CI,dI);"
%
%
%
%   constructs the linear constraint object "con" representing a square in
%   the plane x3 = 0 with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and
%   (4,1).
%
% See Also:
%   linearcon_data

if (nargin == 1) && isa(CE,'linearcon')
  con = CE;
elseif (nargin == 4)
    if size(dE,1) > 1
        aug = [CE, dE];
        [R, jb] = rref(aug);
        CE = CE(jb, :);
        dE = dE(jb, :);
    end
    
  con.CE = CE;
  con.dE = dE;
  con.CI = CI;
  con.dI = dI;
  con = class(con,'linearcon');
else
  con.CE = [];
  con.dE = [];
  con.CI = [];
  con.dI = [];
  con = class(con,'linearcon');
end
