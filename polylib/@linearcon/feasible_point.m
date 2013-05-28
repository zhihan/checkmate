function result = feasible_point(con,p)

% Check the feasibility of the point "p" with respect to "con"
%
% Syntax:
%   "result = feasible_point(con,p)"
%
% Description:
%   "feasible_point(con,p)" returns "1" if the point "p" satisfies the linear
%   constraints represented by "con", and "0" if "p" does not. 
%
% Examples:
%   Given the linear constraint object "con" representing a square in the
%   plane x3=0 with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and
%   (4,1) and point "p = [3 2 0]'".
%
%
%
%     "result = feasible_point(con,p)"
%
%     "result = 1"
%
%
%
%   Now use "p = [5 4 2]'". 
%
%
%
%     "result = feasible_point(con,p)"
%
%     "result = 0"
%
%
%
% See Also:
%   linearcon

global GLOBAL_APPROX_PARAM

epsilon = GLOBAL_APPROX_PARAM.poly_epsilon;

% Equality constraints first
CE = con.CE; dE = con.dE;
result = 1;
for k = 1:length(dE)
  if abs(CE(k,:)*p - dE(k)) > epsilon
    result = 0;
    return
  end
end

% Inequality constraints next
CI = con.CI; dI = con.dI;
result = 1;
for k = 1:length(dI)
  if CI(k,:)*p > (dI(k) + epsilon)
    result = 0;
    return
  end
end