function vtcs = vertices(p)

% Convert a polyhedron object to a vertices object 
%
% Syntax:
%   "vtcs = vertices(poly)"
%
% Description:
%   "vertices(poly)" returns a new vertices object containing the
%   vertices of the polyhedron represented by "poly". 
%
% Examples:
%   Given the polyhedron object "poly" representing a cube with corners
%   at (x1,x2,x3) triples (2,1,0), (2,1,2), (2,3,0), (2,3,2), (4,3,0),
%   (4,3,2), (4,1,0), and (4,1,2),
%
%
%
%   "vtcs = vertices(poly)"
%
%
%
%   returns "vtcs", a vertices object containing the list of triples
%   given above.
%
% See Also:
%   polyhedron,linearcon,vertices

vtcs = p.vtcs;
