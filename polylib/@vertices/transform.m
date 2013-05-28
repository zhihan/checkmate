function u = transform(v,A,b)

% Apply affine transformation Tx + v to a vertices object, where T is an
% n by n invertible matrix and v is a constant vector 
%
% Syntax:
%   "V = transform(vtcs,T,v)"
%
% Description:
%   "transform(vtcs,T,v)" returns a vertices object representing the set
%   of vertices "vtcs" with respect to the transformed variable
%   "y = Tx + v".
%
% Examples:
%   Given the vertices object "vtcs" representing a cube with corners at
%   (x1,x2,x3) triples (2,1,0), (2,1,2), (2,3,0), (2,3,2), (4,3,0),
%   (4,3,2), (4,1,0), and (4,1,2),
%
%
%
%   "T = [0.5 0 0;0 0.25 0;0 0 1]; v = [0 0 2]';"
%
%   "V = transform(vtcs,T,v)"
%
%
%
%   returns "V", a vertices object representing the cube with corners at
%   (x1,x2,x3) triples (1,0.25,2), (1,0.25,4), (1,0.75,2), (1,0.75,4),
%   (2,0.75,2), (2,0.75,4), (2,0.25,2), and (2,0.25,4).
%
% See Also:
%   vertices,transform

vk = v.list;
u = vertices(A * vk + repmat(b, 1, length(v)));



