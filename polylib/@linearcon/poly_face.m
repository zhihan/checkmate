function F = poly_face(CON,k)

% Project constraints onto one face of the polyhedral 
%
% Syntax:
%   "F = poly_face(con,k)"
%
% Description:
%   "poly_face(con,k)" returns a new linear constraint object constructed
%   by removing the "k"th face of "con" from the inequality constraint
%   (CI,dI) and adding it to the equality constraint (CE,dE) of the new
%   object.  This is accomplished by removing the "k"th row of CI and dI,
%   adding this row to CE and dE, and then constructing a new linear
%   constraint object using these modified constraint matrices.
%
% Examples:
%   Given a linear constraint object "con" representing a cube with
%   corners at (x1,x2,x3) triples (2,1,0), (2,1,2), (2,3,0), (2,3,2),
%   (4,3,0), (4,3,2), (4,1,0), and (4,1,2).  If x3 = 0 is face number 5,
%   then,   
%
%
%
%     "F = polyface(con,5)"
%
%
%
%   returns "F", a linear constraint object representing a square in the
%   x3=0 plane with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and
%   (4,1).
%
%
%
% See Also:
%   linearcon,number_of_faces

[CE,dE,CI,dI] = linearcon_data(CON);
N = length(dI);
if (k <= N) & (k >= 1)
  CEnew = [CE; CI(k,:)];
  dEnew = [dE; dI(k,:)];
  CInew = [CI(1:k-1,:); CI(k+1:N,:)];
  dInew = [dI(1:k-1,:); dI(k+1:N,:)];
  F = linearcon(CEnew,dEnew,CInew,dInew);
else
  disp('LINEARCON/FACE: Invalid face index given.')
end