function CONout = clean_up(CONin)

% Remove all redundant constraints from a linear constraint object
%
% Syntax:
%   "C = clean_up(a)"
%
% Description:
%   "clean_up(a)" returns a linear constraint object representing the
%   constraint set represented by "a" with all redundant constraints removed. 
%
% Examples:
%   Given a linear constraint object, "a" using six inequalities to
%   represent the intersection of two squares in the x3 = 0 plane with
%   corners at (x1,x2) pairs (2,1), (2,3), (4,3), and (4,1) and (2,1),
%   (2,2), (3,1), and (3,2),  
%
%
%
%   "C = clean_up(a)"
%
%
%
%   returns "C", a linear constraint object which uses four inequalities
%   to represent a square in the x3 = 0 plane with corners at (x1,x2)
%pairs(2,1), (2,2), (3,2), and (3,1).
%
% See Also:
%   linearcon,and,isfeasible

% Since we are having at most one equality constraint for now,
% we do nothing for equality constraint

global GLOBAL_APPROX_PARAM
global GLOBAL_OPTIM_PAR

bigM = GLOBAL_APPROX_PARAM.poly_bigM;
epsilon = GLOBAL_APPROX_PARAM.poly_epsilon;

% Check if new feasible inequality constraints are redundant
CE = CONin.CE; dE = CONin.dE; 
CI = CONin.CI; dI = CONin.dI;

k = 1;
while (k <= length(dI))
  cIk = CI(k,:);
  dIk = dI(k);
  dIprime = dI;
  dIprime(k) = dIk + bigM;
  xmax = linprog(-cIk',CI,dIprime,CE,dE,[],[],[],GLOBAL_OPTIM_PAR);
  xmin = linprog( cIk',CI,dIprime,CE,dE,[],[],[],GLOBAL_OPTIM_PAR);
  old_diff = dIk - cIk*xmin;
  new_diff = cIk*xmax - cIk*xmin;
  if old_diff~=0
     required = ((new_diff/old_diff) > (1+epsilon));
  else
     required=0;
  end
  
  % remove if redundant
  if required
    k = k + 1;
  else
    CI = [CI(1:k-1,:); CI(k+1:length(dI),:)];
    dI = [dI(1:k-1); dI(k+1:length(dI))];
  end    
end
if isempty(dI) 
  error('Warning: empty inequality constraints\n');
  CONout = linearcon;  
else
  CONout = linearcon(CE,dE,CI,dI);
end
