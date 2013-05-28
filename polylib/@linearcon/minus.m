function diff = minus(con1,con2)

% Subtract two linear constraint objects
%
% Syntax:
%   "C = a - b"
%
%   "C = minus(a,b)
%
% Description:
%   "minus(a,b)" returns "C" a cell array of linearcon objects whose
%   union represents "a-b".
%
% Examples:
%   Given two linear constraint objects, "a" representing a square in the
%   x3 = 0 plane with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and
%   (4,1) and "b", another square in the same plane with corners at (2,1),
%   (2,2), (3,1), and (3,2),
%
%
%
%     "C = a - b"
%
%
%
%   returns "C", a cell array with elements,
%
%
%
%     "C{1} ="
%
%     "[ 1.000000 0.000000 ]x <= 4.000000"
%
%     "[ 0.000000 1.000000 ]x <= 3.000000"
%
%     "[ 0.000000 -1.000000 ]x <= -1.000000"
%
%     "[ -1.000000 0.000000 ]x <= -3.000000"
%
%
%
%     "C{2} ="
%
%     "[ -1.000000 0.000000 ]x <= -2.000000"
%
%     "[ 0.000000 1.000000 ]x <= 3.000000"
%
%     "[ 1.000000 0.000000 ]x <= 3.000000"
%
%     "[ 0.000000 -1.000000 ]x <= -2.000000"
%
%
%
% Note:
%   It is assumed that "a" and "b" have the same equality constraint (if
%   any), i.e they lie in the same subspace.
%
% See Also:
%   linearcon

global GLOBAL_APPROX_PARAM

[CE1,dE1,CI1,dI1] = linearcon_data(con1);
[CE2,dE2,CI2,dI2] = linearcon_data(con2);

% Handle some trivial cases
if isempty(con1)
  diff = {};
  return
end

if isempty(con2)
  diff = {con1};
  return
end

% Check for illegal constraints
if (length(dE1) > 1) | (length(dE2) > 1)
  error(['LINEARCON/MINUS: More than one equality constraint found in' ...
	' one of the objects.'])
  return
end

if (length(dE1) ~= length(dE2))
  error(['LINEARCON/MINUS: Both objects must have the same number' ...
	' of equality contstraints.'])
  return
end

if length(dE1) == 1
  hp_tol = GLOBAL_APPROX_PARAM.poly_hyperplane_tol;
  if rank([CE1 dE1; CE2 dE2],hp_tol) > 1
    error(['LINEARCON/MINUS: Both (n-1) dimensional objects must have ' ...
	  ' the same equality contstraint.'])
    return
  end
end


% For i = 1,...,N where N is the number of inequality hyperplanes in con2,
% Add hyperplanes 1,..,.N-1 and the Nth hyperplane with the sign for the
% normal and b reversed to con1 and recompute the new region with these
% hyperplane constraints.

diff = {};
for k = 1:size(CI2,1)
  CIk = [CI2(1:k-1,:)
         -CI2(k,:)];
  dIk = [dI2(1:k-1,:)
         -dI2(k,:)];
  conk = con1 & linearcon([],[],CIk,dIk);
  if ~isempty(conk)
    diff{length(diff)+1} = conk;
  end
end

return
