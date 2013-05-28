function result = isempty(con)

% Determine whether or not a linear constraint object is empty 
%
% Syntax:
%   "result = isempty(con)"
%
% Description:
%   "isempty(con)" returns a "1" if "con" is empty and "0" otherwise. 
%
% Examples:
%   Given a linear constraint object, "con" representing a square in the
%   x3 = 0 plane with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and
%   (4,1)  
%
%
%
%   "result = isempty(con)"
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
%   "con = linearcon"
%
%   "result = isempty(con)"
%
%
%
%   returns 
%
%
%
%   "result = 1"
%
% See Also:
%   linearcon

result = isempty(con.CE) & isempty(con.dE) & ...
         isempty(con.CI) & isempty(con.dI);

  