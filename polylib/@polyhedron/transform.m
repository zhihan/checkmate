function POLY = transform(POLY,T,v)

% Apply affine transformation Tx + v to a polyhedron object, where T is
% an invertible n by n matrix and v is a constant vector
%
% Syntax:
%   "P = transform(poly,T,v)"
%
% Description:
%   "transform(poly,T,v)" returns a polyhedron object representing the
%   constraint set "poly" with respect to the transformed variable
%   "y = Tx + v".
%
% Note:
%   "transform" decomposes the object into a linear constraint object and
%   a vertices object, performs the transformation on each of these
%   objects and then reconstructs the polyhedron object using the transformed
%   linear constraint and vertices object.
%
% Examples:
%   Given the polyhedron object "poly" representing a cube with corners
%   at (x1,x2,x3) triples (2,1,0), (2,1,2), (2,3,0), (2,3,2), (4,3,0),
%   (4,3,2), (4,1,0), and (4,1,2),  
%
%
%
%   "T = [0.5 0 0;0 0.25 0;0 0 1]; v = [0 0 2]';"
%
%   "P = transform(poly,T,v)"
%
%
%
%   returns "P", a polyhedron object representing the cube with corners
%   at (x1,x2,x3) triples (1,0.25,2), (1,0.25,4), (1,0.75,2), (1,0.75,4),
%   (2,0.75,2), (2,0.75,4), (2,0.25,2), and (2,0.25,4).  
%
% See Also:
%   polyhedron,linearcon,vertices

if rank(T)==max(size(T))
    [CE,dE,CI,dI] = linearcon_data(transform(linearcon(POLY),T,v));
    POLY.CE = CE; POLY.dE = dE;
    POLY.CI = CI; POLY.dI = dI;
    POLY.vtcs = transform(POLY.vtcs,T,v);
    for k = 1:length(POLY.VE)
        POLY.VE{k} = transform(POLY.VE{k},T,v);
    end
    for k = 1:length(POLY.VI)
        POLY.VI{k} = transform(POLY.VI{k},T,v);
    end
else
    vtcs = transform(POLY.vtcs,T,v);
    POLY = polyhedron(vtcs);
end
    
return
