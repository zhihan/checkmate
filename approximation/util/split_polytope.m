function [CON1,CON2] = split_polytope(CON,W)

% Split the given polytope in half along the orthonormal direction of the
% greatest (weighted) width.
%
% Syntax:
%   "[CON1,CON2] = split_polytope(CON,W)"
%
% Description:
%   Given the input polytope "CON" which is a "linearcon" object. Measure
%   the width of the polytope by solving `linear programs` along the
%   positive and negative directions for each othonormal basis vector and
%   take the difference as the width of the polytope. Scale the basis vector
%   by the diagonal weighting matrix "W" when calculating the width. Then
%   compute the hyperplane that passes through the middle of "CON" in the
%   direction of the greatest width. Split "CON" by into "CON1" and "CON2"
%   by intersecting it with the negative and the positive half spaces of the
%   splitting hyperplane, respectively.
%
% Note:
%   The input polytope must be bounded and of dimension `n` or `n-1` where
%   `n` is the full dimension for the linear constaints of the polytope.
%
% See Also:
%   linearcon

global GLOBAL_OPTIM_PAR

[CE,dE,CI,dI] = linearcon_data(CON);
NE = length(dE);
if (NE ~= 0) && (NE ~= 1)
  fprintf(1,['\007split_polytope: Only n or n-1 dimension polytopes' ...
        ' allowed.\n'])
  return
end

if NE == 1
  % n-1 dimensional
  Z = null(CE);
else
  % n dimensional
  Z = eye(size(CI,2));
end

dmax = -Inf;
for k = 1:size(Z,2)
  nk = Z(:,k);
  xmin = linprog(nk,CI,dI,CE,dE,[],[],[],GLOBAL_OPTIM_PAR);
  xmax = linprog(-nk,CI,dI,CE,dE,[],[],[],GLOBAL_OPTIM_PAR);
  dk = nk'*W*(xmax-xmin);
  if (dk > dmax)
    dmax = dk;
    n = nk;
    b = nk'*(xmax+xmin)/2;
  end
end

CON1 = CON & linearcon([],[],n',b);
CON2 = CON & linearcon([],[],-n',-b);
