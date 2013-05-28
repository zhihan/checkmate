function isfeasible = subseteq(CONfeas,CONsup)

% Compute whether one linear constraint defines a subset of another set
% of linear constraints
%
% Syntax:
%   "C = subseteq(a,b)"
%
% Description:
%   "subseteq(a,b)" returns a boolean that is 1 if "a" is a subset of
%   "b", and a 0 otherwise.
%
% Note:
%   At most one equality constraint is allowed in "a", and if "b" has an
%   equality constraint, it must be the same as the one present in "a".
%
% See Also:
%   linearcon,isfeasible,and, intersect

global GLOBAL_APPROX_PARAM
global GLOBAL_OPTIM_PAR

epsilon = GLOBAL_APPROX_PARAM.poly_epsilon;
hyperplane_tol = GLOBAL_APPROX_PARAM.poly_hyperplane_tol;


if isempty(CONfeas) 
    isfeasible=1;
  return
end

if isempty(CONsup) 
    isfeasible=0;
  return
end


if (length(CONfeas.dE) > 1) || (length(CONsup.dE) > 1)
  fprintf('\007intersect: Invalid constraints given, more than 1 equality found\n')
  return
end

if (isempty(CONfeas.dE)) && (length(CONsup.dE) == 1)
  %fprintf('\007intersect: Invalid constraints given, additional equality constraints\n')
  return
end

% If an equality constraint is found in both sets of constraints,
% check if they're the same constraint, if not return an empty
% cell array

if (length(CONfeas.dE) == 1) && (length(CONsup.dE) == 1)
  MATRIX = [CONfeas.CE CONfeas.dE
            CONsup.CE  CONsup.dE];
  if rank(MATRIX,hyperplane_tol) > 1
%    fprintf('intersect: Patches w/ different eq constraints found\n')
    return
  else
    CONsup.CE = []; CONsup.dE = [];
  end
end  

% Start with the feasible constraints
CE = CONfeas.CE; dE = CONfeas.dE;
CI = CONfeas.CI; dI = CONfeas.dI;

% Find out if each new inequality constraint is feasible
CIsup = CONsup.CI; dIsup = CONsup.dI;
for k = 1:size(CIsup,1)
  cIk = CIsup(k,:);
  dIk = dIsup(k);
  xmax = linprog(-cIk',CI,dI,CE,dE,[],[],[],GLOBAL_OPTIM_PAR);
  fmax = cIk*xmax;
  isfeasible = (fmax < dIk+epsilon);
  if ~ isfeasible
      break;
  end
end

return

