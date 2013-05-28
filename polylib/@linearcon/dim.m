function n = dim(con)

% Dimension of the space containing a linear constraint object
%
% Syntax:
%   "n = dim(con)"
%
% Description:
%   "dim(con)" returns the dimension of the space in which "con" resides. 
%
% Examples:
%   Given a linear constraint object, "con" representing a square in the
%   x3 = 0 plane with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and
%   (4,1)
%
%
%
%   "n = dim(con)"
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
%   linearcon 

if ~isempty(con.CE)
  n = size(con.CE,2);
elseif ~isempty(con.CI)
  n = size(con.CI,2);
else
  n = 0;
end
