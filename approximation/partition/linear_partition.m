function partition = linear_partition(patch,A,b)

% Partition the given "n-1" dimensional polytope using the partitioning
% scheme for `linear` (affine) dynamics. 
% 
% Syntax:
%   "partition = linear_partition(patch,A,b,q)"
%
% Description:
%   Partition the given "n-1" dimensional polytope "patch", so that each
%   polytope in the partition satisfies all the tolerances specfied in the
%   parameter file for `linear` vector field "f(x) = A*x + b"
%   for the SCSBs selected by the FSM state vector "q". The SCSBs
%   information are stored in "SCSBlocks".  The input polytope "patch" is a
%   "linearcon" object and the output "partition" is a cell array of
%   "linearcon" object.
%
% Implementation:
%   Get the approximation parameters by calling parameter file with the FSM
%   vector "q". The relevant approximation parameters for this function
%   are: 
%
%   * "W", "nxn" diagonal weighting matrix
%
%   * "size_tol", tolerance for the size of a polytope (weighted by "W")
%
%   * "var_tol", tolerance for the variation of the vector field on a polytope
%     relative to the maximum variation of the vector field on the
%     starting polytope "patch"
%
%   Before we discuss the actual partitioning procedure, it is useful to
%   introduce the following definitions. In the definitions, "x" denotes a
%   continuous state in the polytope, "f(x)" denotes the vector field at
%   "x", and "c" denotes the normal vector to the "n-1" dimensional
%   polytope.  
%
%   * A polytope is called `too big` if there is an orthonormal vector "z"
%     parallel to the polytope "(c'*z = 0)" such that the weighted width of
%     the polytope along "z" is greated than "size_tol", i.e. "max z'*W*x -
%     min z'*W*x > size_tol"
%
%   * A polytope is called `too varied` if the variation in the vector field
%     is greater than "var_tol", i.e. "max c'*f(x) - min c'*f(x) >
%     var_tol". Substituting "f(x) = A*x + b", we have that this condition
%     reduces to "max c'*A*x - min c'*A*x > var_tol". It is clear the the
%     vector field variation can be computed taking the difference between
%     the solutions to two linear programs.
%
%   The function "split_patch()" first splits the starting polytope "patch",
%   if possible, into parts with the vector field going in and out of the
%   polytope, respectively. This is done by spliting "patch" with the
%   hyperplane "(c'*A)*x = -c'*b", i.e. the hyperplane where "c'*f(x) =
%   0". Then it splits each polytope recursively as follows. For each
%   polytope, it checks if the tolerances are satisfied in the following
%   order.
%
%   * If the polytope is `too big`, then split it along the orthonormal
%     direction with the greatest weight width and recursively call
%     "split_patch()" to check if newly split polytopes satisfy the
%     tolerances.
%
%   * Else, if the polytope is `too varied`, compute "fmax", the maximum
%     value of "c'*A*x", and "xmin", the minimum value of "c'*A*x".  split the
%     polytope with the hyperplane "(c'*A)*x = (fmax+fmin)/2".  Recursively
%     call "split_patch()" to check if newly split polytopes satisfy the
%     tolerances.
%
%   * If the polytope satisfies all tolerances, the function simply return
%     it to the caller function to terminate the recursion.
%
% See Also:
%   clock_partition,nonlinear_partition,overall_system_clock,
%   overall_system_matrix,overall_system_ode,linearcon

global GLOBAL_APPROX_PARAM

[CE,dE] = linearcon_data(patch);
if (length(dE) ~= 1)
  fprintf(1,'\007Invalid patch constraint given.\n')
  return
end

var_tol = GLOBAL_APPROX_PARAM.var_tol;
size_tol = GLOBAL_APPROX_PARAM.size_tol;
W = GLOBAL_APPROX_PARAM.W;
[fmin,fmax] = compute_vfield_variation(patch,A);
abs_var_tol = (fmax-fmin)*var_tol;

% subset of patch with trajectories going inside invariant polytope
con1 = patch & linearcon([],[],CE*A,-CE*b);
if ~isempty(con1)
  partition1 = split_patch_lin(con1,A,abs_var_tol,size_tol,W);
else
  partition1 = {};
end

% subset of patch with trajectories going outside invariant polytope
con2 = patch & linearcon([],[],-CE*A,CE*b);
if ~isempty(con2)
  partition2 = split_patch_lin(con2,A,abs_var_tol,size_tol,W);
else
  partition2 = {};
end

partition = [partition1,partition2];
return

