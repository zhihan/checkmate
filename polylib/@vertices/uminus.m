function c = uminus(a)

% Unary negation of a vertices object 
%
% Syntax:
%   "V = uminus(vtcs)"
%
%   "V = -vtcs"
%
% Description:
%   "uminus(vtcs)" returns a vertices object containing the negation of
%   each element in "vtcs".
%
% Examples:
%   Given a vertices object, "vtcs" representing a square in the x3 = 0
%   plane with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and (4,1), 
%
%
%
%   "V = -vtcs"
%
%
%
%   returns "V" a vertices object representing a square in the x3 = 0
%   plane with corners at (-2,-1), (-2,-3), (-4,-3) and (-4,-1). 
%
% See Also:
%   vertices,minus


c = vertices(-a.list);

