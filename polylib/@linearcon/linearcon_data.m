function [CE,dE,CI,dI] = linearcon_data(con)

% Retrieve constraint matrices and vectors from linear constraint object 
%
% Syntax:
%   "[CE,dE,CI,dI] = linearcon_data(con)"
%
% Description:
%   "linearcon_data(con)" returns matrices "CE" and "CI" and vectors "dE"
%   and "dI" describing the constraints represented by linear constraint
%   object "con".  The constraints are expressed as CEx = dE and CIx <= dI. 
%
% Examples:
%   Given the linear constraint object "con" representing a square in the
%   plane x3 = 0 with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and (4,1), 
%
%
%
%   "[CE,dE,CI,dI] = linearcon_data(con"
%
%
%
%   will return 
%
%
%
%   "CE = [0 0 1]"
%
%   "dE = 0"
%
%   "CI = [1 0 0;-1 0 0;0 1 0;0 -1 0]"
%
%   "dI = [4;-2;3;-1]"
%
% See Also:
%   linearcon

CE = con.CE;
dE = con.dE;
CI = con.CI;
dI = con.dI;
