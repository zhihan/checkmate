function out = project(in,vars)

% Compute the projection of the input linearcon object (a polyhedron)
% onto the specified set of variables 
%
% Syntax:
%   "C = project(con,v)"
%
% Description:
%   "project(con,v)" returns a linear constraint object representing
%   the projection of "con" onto the variables given in the indices
%   array "v".
%
% Examples:
%   Suppose the input linear constraint object "in" has 5 variables.
%
%
%
%
%   "out = project(in,[1 4 3])"
%
%
%
%   returns "out" a linear constraint object representing a projection of
%   the polyhedron onto the variables [x1 x4 x3]' (in the order specified
%   in the indices array). 
%
% Note:
%   The input linear constraint object must be bounded for this function
%   to work properly.
%
% See Also:
%   linearcon

[CE,dE,CI,dI] = linearcon_data(in);

if length(unique(vars)) ~= length(vars)
  error('Variable indices must be unique')
end

N = size(CI,2);
if any(vars > N) | any(vars < 1)
  error('Invalid variable indices given')
end

if size(CE,1) > 1
  error('Invalid constraints, more than one equality found')
end

% Reorder the variables so that the variables specified in vars appear
% first.
othervars = setdiff([1:N],vars);
if ~isempty(CE)
  CE = [CE(:,vars) CE(:,othervars)];
end
CI = [CI(:,vars) CI(:,othervars)];


% Keep eliminating the last variable until we have only the variables in
% vars in the constraints.
while size(CI,2) > length(vars)
  if isempty(CE)
    [CI,dI] = elim_no_eq(CI,dI);
  else
    [CE,dE,CI,dI] = elim_one_eq(CE,dE,CI,dI);
  end
end
out = linearcon(CE,dE,CI,dI);
return

% -----------------------------------------------------------------------------

function [Celim,delim] = elim_no_eq(C,d)

iplus = [];
iminus = [];
izero = [];
N = size(C,2);

% Sort indicies into zero, positive, or negative coefficient of
% variable to be eliminated
for k = 1:size(C,1)
  if (C(k,N) == 0)
    izero = [izero k];
  else 
    if (C(k,N) > 0) 
      iplus = [iplus k];
    else
      iminus = [iminus k];
    end
  end
end

Celim = []; delim = [];

% If coefficient of last variable to be eliminated is zero,
% then remove the last column and retain the row as is
for k = izero
  Celim = [Celim; C(k,1:N-1)];
  delim = [delim; d(k)];
end

% Do <name/type of> elimination on rows with nonzero coefficients
for k = iplus
  cplus = C(k,1:N-1);
  cNplus = C(k,N); 
  dplus = d(k);
  for l = iminus
    cminus = C(l,1:N-1);
    cNminus = C(l,N); 
    dminus = d(l);
    ckl = cplus/cNplus - cminus/cNminus;
    dkl = dplus/cNplus - dminus/cNminus;
    magnitude = sqrt(ckl*ckl');
    if (magnitude == 0) % What happens if magnitude is zero and dkl is positive???
      if (dkl < 0)
        error('Infeasible constraint found! Something is wrong!')
      end
    else
      ckl = ckl/magnitude;
      dkl = dkl/magnitude;
      Celim = [Celim; ckl];
      delim = [delim; dkl];
    end
  end
end

return

% -----------------------------------------------------------------------------

function [Ceelim,deelim,Cielim,dielim] = elim_one_eq(Ce,de,Ci,di)

N = size(Ce,2);

Ceelim = []; deelim = [];
Cielim = []; dielim = [];
if (Ce(1,N) == 0)
  % If coefficient of variable to be eliminated is zero, then remove last column
  % and retain the equality as is.  Perform elimination as if with no equality.
  Ceelim = Ce(:,1:N-1);
  deelim = de;
  [Cielim,dielim] = elim_no_eq(Ci,di);
  return
else
  % Otherwise, solve equality for variable to be eliminated in terms of the other
  % variables and substitute into the inequalities
  Cehat = Ce(1,1:N-1);
  CeN = Ce(1,N);
  for k = 1:size(Ci,1)
    cik = Ci(k,1:N-1) - Ci(k,N)*Cehat/CeN;
    dik = di(k) - Ci(k,N)*de/CeN;
    magnitude = sqrt(cik*cik');
    if magnitude == 0
      if dik < 0
        error('Infeasible constraint found! Something is wrong!')
      end
    else
      cik = cik/magnitude;
      dik = dik/magnitude;
      Cielim = [Cielim; cik];
      dielim = [dielim; dik];
    end
  end
end

return
