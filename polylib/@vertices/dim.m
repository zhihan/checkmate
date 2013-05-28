function n = dim(v)

% Dimension of the space containing a vertices object 
%
% Syntax:
%   "n = dim(vtcs)"
%
% Description:
%   "dim(vtcs)" returns the dimension of the space in which "vtcs" resides. 
%
% Examples:
%   Given a vertices object, "vtcs" representing a square in the x3 = 0
%   plane with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and (4,1) 
%
%
%
%   "n = dim(vtcs)"
%
%
%
%   returns 
%
%
%
%   "n = 3"
%
% See Also:
%   vertices

n = size(v.list,1);
