function partition = nonlinear_partition(patch,SCSBlocks,q)

% Partition the given "n-1" dimensional polytope using the partitioning
% scheme for `nonlinear` dynamics. 
% 
% Syntax:
%   "partition = nonlinear_partition(patch,SCSBlocks,q)"
%
% Description:
%   Partition the given "n-1" dimensional polytope "patch", so that each
%   polytope in the partition satisfies all the tolerances specfied in the
%   parameter file for `nonlinear` vector field for the SCSBs
%   selected by the FSM state vector "q". The SCSBs information are stored
%   in "SCSBlocks".  The input polytope "patch" is a "linearcon" object and
%   the output "partition" is a cell array of "linearcon" object.
%
% Implementation:
%   Get the approximation parameters by calling parameter file with the FSM
%   vector "q". The relevant approximation parameters for this function
%   are: 
%
%   * "W", "nxn" diagonal weighting matrix
%
%   * "dir_tol", tolerance related to the direction of the vector field on a
%     polytope
%
%   * "size_tol", tolerance for the size of a polytope (weighted by "W")
%
%   * "var_tol", tolerance for the variation of the vector field on a polytope
%     relative to the maximum variation of the vector field on the
%     starting polytope "patch"
%
%   This function splits the polytope recursively until all the
%   tolerances are satisfied. Before we discuss the actual procedure, it
%   is useful to introduce the following definitions. In the definitions,
%   "x" denotes a continuous state in the polytope, "f(x)" denotes the
%   vector field at "x", and "c" denotes the normal vector to the "n-1"
%   dimensional polytope.
%
%   * A polytope is called `too big` if there is an orthonormal vector "z"
%     parallel to the polytope "(c'*z = 0)" such that the weighted width of
%     the polytope along "z" is greated than "size_tol", i.e. "max z'*W*x -
%     min z'*W*x > size_tol"
%
%   * A polytope is called `two-sided` if there are trajectories going
%     both in and out of the polytope, i.e. "max c'*f(x) > var_tol" and "min
%     c'*f(x) < -var_tol".
%
%   * A polytope is called `too varied` if the variation in the vector
%     field is greater than "var_tol", i.e. "max c'*f(x) - min c'*f(x) >
%     var_tol".
%
%   The function "split_patch()" splits each polytope recursively. For
%   each polytope, it checks if the tolerances are satisfied in the
%   following order.
%
%   * If the polytope is `too big`, then split it along the orthonormal
%     direction with the greatest weight width and recursively call
%     "split_patch()" to check if newly split polytopes satisfy the
%     tolerances.
%
%   * Else, if the polytope is `two-sided` or `too varied`, estimate "xmax",
%     the point in the polytope that maximizes "c'*f(x)", and "xmin", the
%     point in the polytope that minimizes "c'*f(x)". Use the normalized
%     diferrence "n = (xmax - xmin)/||xmax - xmin||" as the split direction
%     and split the polytope with the hyperplane "n'*x = n'*(xmax+xmin)/2"
%     that passes through the mid-point between "xmax" and "xmin".
%     Recursively call "split_patch()" to check if newly split polytopes
%     satisfy the tolerances.
%
%   * If the polytope satisfies all tolerances, the function simply return
%     it to the caller function to terminate the recursion.
%
% See Also:
%   clock_partition,linear_partition,overall_system_clock,
%   overall_system_matrix,overall_system_ode,linearcon

global GLOBAL_APPROX_PARAM

[CE,dE] = linearcon_data(patch);
if (length(dE) ~= 1)
  fprintf(1,'\007Invalid patch constraint given.\n')
  return
end

dir_tol = GLOBAL_APPROX_PARAM.dir_tol;
var_tol = GLOBAL_APPROX_PARAM.var_tol;
size_tol = GLOBAL_APPROX_PARAM.size_tol;
W = GLOBAL_APPROX_PARAM.W;
% estimate the maximum variation of vector field on the starting potlytope
[fmin,xmin,fmax] = estimate_vfield_variation(patch,SCSBlocks,q);
% compute the absolute tolerance for the  variation of vector field on
% any polytope
abs_var_tol = (fmax-fmin)*var_tol;
partition = split_patch(patch,SCSBlocks,q,dir_tol,abs_var_tol,size_tol,W);
return

% -----------------------------------------------------------------------------

function partition = split_patch(patch,SCSBlocks,q, ...
    dir_tol,var_tol,size_tol,W)

split = 0;
[too_big,con1,con2] = split_if_too_big(patch,size_tol,W);
if too_big
  split = 1;
else
  % If not too big, check if two-sided or too varied
  [fmin,xmin,fmax,xmax] = estimate_vfield_variation(patch,SCSBlocks,q);
  two_sided = (fmax > dir_tol) & (fmin < -dir_tol);
  too_varied = (fmax - fmin > var_tol);
  if two_sided || too_varied
    n = xmax-xmin;
    n = n/sqrt(n'*n);
    b = n'*(xmax+xmin)/2;
    con1 = patch & linearcon([],[],n',b);
    con2 = patch & linearcon([],[],-n',-b);
    split = 1;
  end
end

if split
  partition1 = split_patch(con1,SCSBlocks,q, ...
      dir_tol,var_tol,size_tol,W);
  partition2 = split_patch(con2,SCSBlocks,q, ...
      dir_tol,var_tol,size_tol,W);
  partition = [partition1,partition2];
else
  partition = {patch};
end

return

% -----------------------------------------------------------------------------

function [too_big,con1,con2] = split_if_too_big(patch,size_tol,W)

global GLOBAL_OPTIM_PAR

[CE,dE,CI,dI] = linearcon_data(patch);

Z = null(CE);
dmax = -Inf;
for k = 1:size(Z,2)
  nk = W*Z(:,k);
  xmin = linprog(nk,CI,dI,CE,dE,[],[],[],GLOBAL_OPTIM_PAR);
  xmax = linprog(-nk,CI,dI,CE,dE,[],[],[],GLOBAL_OPTIM_PAR);
  dk = nk'*(xmax-xmin);
  if (dk > dmax)
    dmax = dk;
    n = nk;
    b = nk'*(xmax+xmin)/2;
  end
end

if (dmax > size_tol)
  too_big = 1;
  con1 = patch & linearcon([],[],n',b);
  con2 = patch & linearcon([],[],-n',-b);
else
  too_big = 0;
  con1 = linearcon;
  con2 = linearcon;
end
return

% -----------------------------------------------------------------------------

function [fmin,xmin,fmax,xmax] = estimate_vfield_variation(patch,SCSBlocks,q)

CE = linearcon_data(patch);
sample_points = vertices(patch);
sample_points = sample_points | average(sample_points);
fmin = Inf; fmax = -Inf;
for j = 1:length(sample_points)
  xj = sample_points(j);
  xj_dot = derivative(SCSBlocks,xj,q);
  fj = CE*xj_dot;
  if (fj < fmin)
    fmin = fj;
    xmin = xj;
  end
  if (fj > fmax)
    fmax = fj;
    xmax = xj;
  end
end
return

% -----------------------------------------------------------------------------

function xdot = derivative(SCSBlocks,x,q)

xdot = [];
idx = 0;
for k = 1:length(SCSBlocks)
  nxk = SCSBlocks{k}.nx;
  xk = x(idx+1:idx+nxk);
  uk = q(SCSBlocks{k}.fsmbindices);
  [sys,type] = feval(SCSBlocks{k}.swfunc,xk,uk);
  if strcmp(type,'linear')
    A = sys.A; b = sys.b;
    xk_dot = A*xk + b;
  else
    xk_dot = sys;
  end
  xdot = [xdot; xk_dot];
  idx = idx + nxk;
end
return
