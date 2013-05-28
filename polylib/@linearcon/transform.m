function CON = transform(CON,T,v)

% Apply affine transformation Tx + v to a linear constraint object, where
% T is an n by n matrix and v is a constant vector
%
% Syntax:
%   "C = transform(con,T,v)"
%
% Description:
%   "transform(con,T,v)" returns a linear constraint object representing
%   the constraint set "con" with respect to the transformed variable
%   "y = Tx + v". 
%
% Examples:
%   Given the linear constraint object "con" representing a cube with
%   corners at (x1,x2,x3) triples (2,1,0), (2,1,2), (2,3,0), (2,3,2),
%   (4,3,0), (4,3,2), (4,1,0), and (4,1,2),
%
%
%
%     "T = [0.5 0 0;0 0.25 0;0 0 1]; v = [0 0 2]';"
%
%     "C = transform(con,T,v)"
%
%
%
%   returns "C", a linear constraint object representing the cube with
%   corners at (x1,x2,x3) triples (1,0.25,2), (1,0.25,4), (1,0.75,2),
%   (1,0.75,4), (2,0.75,2), (2,0.75,4), (2,0.25,2), and (2,0.25,4).
%
% See Also:
%   linearcon,vertices,transform

% Test whether T has full rang. In this case we transform the 
% hyperplanes, otherwise the vertices.
if rank(T)==size(T,2)
    CE = CON.CE; dE = CON.dE;
    CI = CON.CI; dI = CON.dI;
    [CE,dE] = transform_hyperplanes(CE,dE,T,v);
    [CI,dI] = transform_hyperplanes(CI,dI,T,v);
    CON = linearcon(CE,dE,CI,dI);
else
    vert=vertices(CON);
    for i=1:length(vert)
        Tvert(:,i)=T*vert(i)+v;
    end;
    CON =linearcon(polyhedron(Tvert));
end;
return

function [C,d] = transform_hyperplanes(C,d,T,v)

for k = 1:size(C,1)
  % update the normal vector and the constant for the
  % hyperplane representing each face
  ck = C(k,:)/T;
  dk = d(k) + ck*v;
  norm_ck = sqrt(ck*ck');
  C(k,:) = ck/norm_ck;
  d(k) = dk/norm_ck;
end % for k
return

