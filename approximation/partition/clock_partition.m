function partition = clock_partition(patch)

% Partition the given "n-1" dimensional polytope using the partitioning
% scheme for `clock` (constant derivative) dynamics. 
% 
% Syntax:
%   "partition = clock_partition(patch,q)"
%
% Description:
%   Partition the given "n-1" dimensional polytope "patch", so that each
%   polytope in the partition satisfies all the tolerances specfied in the
%   parameter file for `clock` vector field "f(x) = v" for the
%   SCSBs selected by the FSM state vector "q". The SCSBs information are
%   stored in "SCSBlocks". The input polytope "patch" is a "linearcon"
%   object and the output "partition" is a cell array of "linearcon" object.
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
%   Before we discuss the actual partitioning procedure, it is useful to
%   introduce the following definition. In the definition, "x" denotes a
%   continuous state in the polytope and "c" denotes the normal vector to
%   the "n-1" dimensional polytope.
%
%   * A polytope is called `too big` if there is an orthonormal vector "z"
%     parallel to the polytope "(c'*z = 0)" such that the weighted width of
%     the polytope along "z" is greated than "size_tol", i.e. "max z'*W*x -
%     min z'*W*x > size_tol"
%
%   The function "split_patch()" splits each polytope, starting from
%   "patch", recursively as follows.
%
%   * If the polytope is `too big`, then split it along the orthonormal
%     direction with the greatest weight width and recursively call
%     "split_patch()" to check if newly split polytopes satisfy the
%     tolerances.
%
%   * Otherwise, the function simply return it to the caller function to
%     terminate the recursion.
%
% See Also:
%   linear_partition,nonlinear_partition,overall_system_clock,
%   overall_system_matrix,overall_system_ode,linearcon

global GLOBAL_APPROX_PARAM

CE,dE = linearcon_data(patch);
if length(dE) ~= 1
  error('CheckMate:ClockPartition','\007Invalid patch constraint given.\n')
end

size_tol = GLOBAL_APPROX_PARAM.size_tol;
W = GLOBAL_APPROX_PARAM.W;
partition = split_patch(patch,size_tol,W);
return

% -----------------------------------------------------------------------------


