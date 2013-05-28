function c = plus(a,b)

% Add two vertices objects 
%
% Syntax:
%   "vtcs = plus(v1,v2)"
%
%   "vtcs = v1 + v2"
%
% Description:
%   "plus(v1,v2)" returns a vertices object containing the sum of "v2"
%   and each point in "v1".  "v2" may be passed as a vector of
%   coordinates which is then converted to a single point vertices object
%   and added to each point in "v1".  If "v2" is larger than a single
%   point or of a different dimension than "v1", an empty vertices
%   object is returned. 
%
% Examples:
%   Given a vertices object, "v1" representing a square in the x3 = 0
%   plane with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and (4,1), 
%
%
%
%   "v2 = [0 0 1]';"
%
%   "vtcs = v1 + v2"
%
%
%
%   returns "vtcs", a vertices object representing the same square in the
%   x3 = 1 plane.
%
% See Also:
%   vertices,minus

if ~isa(b,'vertices')
  b = vertices(b);
end

if (dim(a) == dim(b)) && (length(b) == 1)
    b1 = b.list(:,1);
    c = vertices(a + repmat(b1, 1, length(a)));
elseif (dim(a) == dim(b))  
    lenb = length(b);
    lena = length(a);
    c = vertices(repmat(a.list, 1, lenb) + ...
                 repmat(b.list, 1, lena));
end
