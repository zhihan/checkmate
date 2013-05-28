function R = clk_rch(X0,v)

% Compute the reachable set from the initial polytope under `clock`
% dynamics.
% 
% Syntax:
%   "R = clk_rch(X0,v)"
%
% Description:
%   Given the initial polytope "X0", compute the polytope "R" representing
%   the set of reachable states from "X0" in the clock direction given by the
%   clock vector "v". "X0" and "R" are "linearcon" objects.
%
% Implementation:
%   The reachable set is computed using the technique called `quantifier
%   eliminations`. See the in-file comments for more detail.
%
% See Also:
%   clk_map,linearcon

% The reachable set can be written as the set
%    { x | there exists t >= 0 and x0 in X0 such that x = x0+vt }
% X0 is given by the linear equalities and inequalities
%    CEx0 = dE and CIx0 <= dI 
% Substituting x = x0+vt, we have
%    CE(x-vt) = dE and CI(x-vt) <= dI
% Thus, the reachable set can be rewritten as
%    { x | there exists t >= 0 such that CE(x-vt) = dE and CI(x-vt) <= dI }
% 
% Eliminating the quantified variable t
% -------------------------------------
%
% (1) If there is no equality constraint, we eliminate t from the
% inequalities as follows.Let CIi and dIi be the ith row and ith
% component of CI and dI, respectively.
%   (1.1) If CIi*v = 0, then the inequality CIi(x-vt) <= dIi implies
%           CIi*x <= dIi
%   (1.2) If CIi*v ~= 0, then we solve for t and obtain
%           CIi*v*t >= CIi*x - dIi
%         if CIi*v < 0, we have
%           t <= (CIi*x - dIi)/CIi*v
%         if CIi*v > 0, we have
%           (CIi*x - dIi)/CIi*v <= t
%         We also have 0 <= t by default.
%         In summary, we have the set T- of inequalities 
%                             0 <= t 
%           (CI1*x - dI1)/CIk*v <= t
%                   .
%                   .
%                   .
%           (CIk*x - dIk)/CIk*v <= t
%         and the set T+ of inequalities 
%                                  t <= (CI(k+1)*x - dI(k+1))/CI(k+1)*v
%                                            .
%                                            .
%                                            .
%                                  t <= (CIm*x - dIm)/CIm*v
%         where m is the number of inequalities with CIi*v ~= 0.
%         We take all possible combinations of the inqualities from the
%         T- and T+, i.e
%           (CIi*x - dIi)/CIi*v <= t <= (CIj*x - dIj)/CIj*v
%         where i is from T- and j is from T+. Clean each combination up 
%         and we obtain
%             CIi     CIj         dIi     dIj
%           (----- - -----)*x <= ----- - -----
%            CIi*v   CIj*v       CIi*v   CIj*v
%
% Finally, we take the conjunction of all the equalities and inequalities 
% obtained from (1.1) and (1.2).
%
%
% (2) If there is an equality constraint (We assume there is no more than
% one equality contraint in X0). We eliminate t as follows.
% (2.1) Equality constraints. Let CEi and dEi be the ith row and ith
% component of CE and dE, respectively.
%   (2.1.1) If CE*v = 0, then the equality CE(x-vt) = dE implies
%             CE*x = dE
%   (2.1.2) If CE*v ~= 0, then we solve for t and obtain
%             t = (CE*x - dE)/CE*v.
%           Conjunct this with t >= 0, we have
%             (CE*x - dE)/CE*v >= 0
%           or
%             -CE*x <= -dE, if CE*v > 0
%              CE*x <=  dE, if CE*v < 0
% (2.2) Inequality constraints. Let CIi and dIi be the ith row and ith
% component of CI and dI, respectively. If CE*v ~= 0, we substitute 
% t = (CE*x - dE)/CE*v into the inequality to obtain
%             CIi(x-v*t) <= dIi
% to obtain
%             CIi(x-v*(CE*x - dE)/CE*v) <= dIi
% or
%                    CIi*v                CIi*v
%             (CIi - -----*CE)*x <= dIi - -----*dE
%                     CE*v                 CE*v
% If CE*v = 0, we do the same as in (1.1) and (1.2).


[CE,dE,CI,dI] = linearcon_data(X0);
if length(dE) > 1
  error('CheckMate:Flowpipe:Clock', ...
      'CheckMate can only handle initial set with at most one equality constraint.')
end

if isempty(dE)
  R = reach_no_eq(CI,dI,v);
else
  R = reach_one_eq(CE,dE,CI,dI,v);
end
return

% -----------------------------------------------------------------------------

function R = reach_no_eq(CI,dI,v)

% [CEreach,dEreach,CIreach,dIreach] are the constraints for the reachable 
% set.
CEreach = []; dEreach = [];

[CIreach, dIreach] = fourier_elim(CI, dI, v);

% create a linearcon object and return the reachable set
R = linearcon(CEreach,dEreach,CIreach,dIreach);
return

  
% -----------------------------------------------------------------------------

function R = reach_one_eq(CE,dE,CI,dI,v)

% [CEreach,dEreach,CIreach,dIreach] are the constraints for the reachable 
% set.
CEreach = []; dEreach = [];
CIreach = []; dIreach = [];

% Check the equality constraint
if (CE*v == 0)  % case (2.1.1)
  CEreach = [CEreach; CE];
  dEreach = [dEreach; dE];
  % Go through the inequality contraints
   [CIreach, dIreach] = fourier_elim(CI, dI, v);
else
  if (CE*v > 0) % case (2.1.2)
    CIreach = [CIreach; -CE];
    dIreach = [dIreach; -dE];
  else
    CIreach = [CIreach; CE];
    dIreach = [dIreach; dE];
  end
  % Go through inequality constraints
  for i = 1:length(dI)
    CIi = CI(i,:); dIi = dI(i);
    c = CIi - (CIi*v)*CE/(CE*v);
    d = dIi - (CIi*v)*dE/(CE*v);
    % normalize the normal vector
    magnitude = sqrt(c*c');
    if (magnitude == 0) 
          if (d < 0)
              error('CheckMate:Flowpipe:Clock', ...
                  'Infeasible constraint found! Something is wrong!')
          end
    else
      c = c/magnitude;
      d = d/magnitude;
      CIreach = [CIreach; c];
      dIreach = [dIreach; d];
    end
  end
end


% create a linearcon object and return the reachable set
R = linearcon(CEreach,dEreach,CIreach,dIreach);
return
%---------------------------------------------
function [CIreach, dIreach] = fourier_elim(CI, dI, v)
CIreach = []; 
dIreach = [];
  Tplus = [];
  Tminus = 0;
  for i = 1:length(dI)
    if (CI(i,:)*v == 0)  % case (1.1)
      CIreach = [CIreach; CI(i,:)];
      dIreach = [dIreach; dI(i)];
    else
      if (CI(i,:)*v > 0) % case (1.2)
        Tminus = [Tminus i];
      else
        Tplus = [Tplus i];
      end
    end
  end
  % Case (1.2) (continue): compute all possible conjunctions of two
  % inequalities in T+ and T-
  for i = 1:length(Tminus)
    for j = 1:length(Tplus)
      if (Tminus(i) == 0)
        CIj = CI(Tplus(j),:);  dIj = dI(Tplus(j));
        c = -CIj/(CIj*v);
        d = -dIj/(CIj*v);
      else
        CIi = CI(Tminus(i),:); dIi = dI(Tminus(i));
        CIj = CI(Tplus(j),:);  dIj = dI(Tplus(j));
        c = CIi/(CIi*v) - CIj/(CIj*v);
        d = dIi/(CIi*v) - dIj/(CIj*v);
      end
      % normalize the normal vector
      magnitude = sqrt(c*c');
      if (magnitude == 0) 
          if (d < 0)
              error('CheckMate:Flowpipe:Clock', ...
                  'Infeasible constraint found! Something is wrong!')
          end
      else
        c = c/magnitude;
        d = d/magnitude;
        CIreach = [CIreach; c];
        dIreach = [dIreach; d];
      end
    end
  end
%-------------------------------------
