function [MAPPING,null_event,time_limit] = fs_lin_map(A,b,X0,INV)

% Compute the `mapping set` from an initial continuous set to the boundary
% of the given `invariant` set under the given `linear` (affine) continuous
% dynamics using flow pipe approximations with a fixed time step.
%
% Syntax:
%   "[MAPPING,null_event,time_limit] = fs_lin_map(A,b,X0,INV)"
%
% Description:
%   The inputs are 
%
%   * "A": the system matrix
%
%   * "b": constant input vector for the affine dynamics
%
%   * "X0": a "linearcon" object represeting the initial set
%
%   * "INV": a "linearcon" object represeting the invariant set
%
%   The outputs are
%
%   * "MAPPING": a one-dimensional cell array with the same number of elements
%     as the number of faces of "INV". Each element "MAPPING{i}" is a cell
%     array of polytopes constituting the mapping set on the "i"-th face of
%     "INV".
%
%   * "null_event": a boolean flag indicating that the flow pipe computation
%     was terminated because it can be concluded that the subsequent flow
%     pipe segments will remain inside "INV" forever.
%
%   * "time_limit": a boolean flag indicating that the flow pipe computation
%     was terminated because the time limit "max_time" was exceeded.
%
% Implementation:
%   The `mapping set` is the subset of the faces of the invariant "INV" that
%   can be reached from the initial continuous state set "X0" under the
%   affine continuous dynamics. The mapping set is computed by intersecting
%   the flow pipe segment computed in each time step with the boundary of
%   "INV". Terminate the computation when one or more of these criteria
%   are met.
%
%   * `The flow pipe segment lies completely outside of "INV"`. In this,
%     case all trajectories of "X0" must have gone past the "INV"
%     boundary.
%
%   * `The matrix "A" is stable and the flow pipe segment lies completely
%     inside of the Lyapunov stability ellipsoid contained inside "INV"`. In
%     this case, all subsequent flow pipe segments will remain inside
%     "INV". Also set the "null_event" flag to 1 when this criterion is
%     met.
%
%   * `The time interval for the current flow pipe segment has exceeded the
%     time limit "GLOBAL_APPROX_PARAM.max_time"`. In this case, we may not
%     have a truly conservative approximation of the mapping set because we
%     do not know whether the subsequent flow pipe segments can reach the
%     invariant boundary or not. Set the "time_limit" flag to 1 to indicate
%     this case.
% 
%   The Lyapunov stability ellipsoid is computed in the function "lyapell()"
%   in this m-file. See the comments in the function for more detail.
%
% See Also:
%   seg_approx_lin,step_response,stretch_func_lin,linearcon,
%   transform

global GLOBAL_APPROX_PARAM

% Get approximation parameters from the global variables.

% Time step for the flow pipe computations.
T = GLOBAL_APPROX_PARAM.T;

% Maximum time limit for the flow pipe computations.
max_time = GLOBAL_APPROX_PARAM.max_time;

% If A is invertible, precompute inverse of A.
if rank(A) == size(A,1)
  Ainv = inv(A);
else
  Ainv = [];
end
eAT = expm(A*T);
displacement = step_response(A,Ainv,b,T);

% Default flag values for the equilibrium and time limit checking.
check_equilibrium = false;
check_time_limit = true;

% Determine the real part of the eigenvalues of A.
real_eig_A = real(eig(A));

% If A is stable and the equilibrium point is enclosed in INV, then turn
% on the equilbrium check.
if all(real_eig_A < 0)

  % If A is stable, we can turn off the time limit checking flag and
  % avoid having non-conservative flow pipe approximation because:
  % (i)  If the equilibrium point is inside INV, then the flowpipe segment
  %      will eventually be contained in the stability ellipsoid enclosed by
  %      INV. When this happens, we can stop the computation and conclude
  %      that the flow pipe will remain in INV forever.
  % (ii) If the equilibrium point is outside INV, then the flowpipe segment
  %      will eventually exit INV completely, in which case the
  %      computation will stop.
  check_time_limit = false;

  % Next we check if the equilibrium point is contained inside INV.
  [CE,dE,CI,dI] = linearcon_data(INV);
  if ~(isempty(CE) && isempty(dE))
    disp(INV);
    error('CheckMate:LowDimensionInvariant', ...
          'Invariant polytope must be full dimensional.') ;
      
  end

  % The equilibrium point is xe = -Ainv*b.
  xe = -Ainv*b;

  % Translate the invariant from the equilibrium point to the origin
  dIhat = dI-CI*xe;

  % Check equilibrium point enclosure.
  if all(dIhat > 0)
    % If equilibrium point is inside INV, find the largest stability
    % ellipsoid x'*Q*x = gamma contained in the translated INV and turn
    % on the equilibrium checking flag.
    [Q,gamma] = lyapell(A,CI,dIhat);
    check_equilibrium = true;
  end
  
elseif any(real_eig_A > 0)
  
  % If A is unstable, we can turn off the time limit checking flag and
  % avoid having non-conservative flow pipe approximation because the
  % flow pipe segment will eventually exit INV completely.
  check_time_limit = false;
  
end

if check_equilibrium
  fprintf(' - equilibrium point found\n')
end
if check_time_limit
  fprintf(' - time limit will be enforced\n')
end

% Initialize the output cell array for the computed mappings.
N = number_of_faces(INV);
MAPPING = cell(N,1);

% Now perform flow pipe computations until one of the stopping criteria
% is met.
fprintf('Computing flow pipe segments:')

% Flag indicating whether equilibrium stopping criteria has been met.
equilibrium = false;

% Flag indicating whether time limit stopping criteria has been met.
time_limit = false;

first = true; 
t_total = 0.0; 
stop = false;

while ~stop
  if first
    % Compute the first flow pipe segment
    V0 = vertices(X0);
    Pk = seg_approx_lin(A,Ainv,b,X0,V0,T);
    Vk = transform(V0,eAT,displacement);
    Xk = transform(X0,eAT,displacement);
    first = false;
  else
    % Transform the previous flow pipe segment to get the current segment
    Pk = transform(Pk,eAT,displacement);
    Vk = transform(Vk,eAT,displacement);
    Xk = transform(Xk,eAT,displacement);
  end

  % Intersect the current flow pipe segment with each face of INV and
  % append the result to the mapping cell array.
  mapk = invariant_boundary_intersect(INV,Pk,A,b);
  for l = 1:length(mapk)
    if ~isempty(mapk{l})
      MAPPING{l}{end+1} = mapk{l};
    end
  end

  partially_inside = isfeasible(Xk,INV);
  
  if check_equilibrium
    % Translate the vertices of the reachable set Xk at time tk from xe
    % to the origin.
    Vk_hat = transform(Vk,eye(size(A)),-xe);
    % Then check if Vk_hat is in the stability ellipsoid centered at the
    % origin.
    equilibrium = is_in_stability_ellipsoid(Vk_hat,Q,gamma);
  end
  
  if check_time_limit
    t_total = t_total + T;
    time_limit = t_total > max_time;
  end
  
  stop = ~partially_inside || equilibrium || time_limit;
end
fprintf(1,'\n')

null_event = equilibrium;

return

% =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

function map = invariant_boundary_intersect(INV,P,A,b)

% Compute the intersection between the boundary of the invariant and the
% polytope P. It is assumed that the invariant is of full dimensions, no
% inequality constraints.

% map is a cell array of the same size as the number of faces of INV.
% map{i} is the intersection of P with the ith face of INV.

N = number_of_faces(INV);
map = cell(N,1);

% Compute the intersection on each face of INV
for m = 1:N
  temp = poly_face(INV,m);
  CE = linearcon_data(temp);
  temp = temp & P;
  if ~isempty(temp)
      con_out = linearcon([],[],-CE*A,CE*b);
      temp = temp & con_out;
      if ~isempty(temp)
          map{m} = temp;
      end
  end
end
return

% =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

function result = is_in_stability_ellipsoid(V,Q,gamma)

% Check if the given polytope P defined by a set of vertices V is contained
% in the ellipsoid x'*Q*x <= gamma. This done by solving the quadratic
% program
%
%    max    x'*Q*x 
%  x in P 
%
% and check if the maximum is <= gamma. Solve the maximization problem by
% searching over the vertices V of P, since the global maximum of a convex
% function over a polytope occurs at some vertex of the polytope.

result = 1;
for k = 1:length(V)
  if (V(k)'*Q*V(k) > gamma)
    result = 0;
    break;
  end
end

% =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

function [P,gamma] = lyapell(A,C,d)

% Given a STABLE matrix A and an invariant polytope Cx <= d which strictly
% encloses the origin, find the largest Lyapunov ellipsoid x'*P*x = gamma
% contained in Cx <= d.

% If A is STABLE then, we must be able to solve the Lyapunov equation
%
% A'*P + P*A = -I

P = lyap(A',eye(size(A)));

% To fit the largest ellipsoid x'*P*x, inside the polytope CI*x <= dI which
% stictly encloses the origin, we do the following.
% The largest ellipsoid that could fit inside the kth face of the polytope
% can be found by solving the optimization problem
% 
% min        fk(x) = x'*P*x 
% subject to ck'*x = dk
%
% By writing the Lagrangian L(x,lambda) = x'*P*x + lambda(ck'*x-dk), and
% differentiate with respect to x and lambda, we have that the optimal
% solution occurs at
%
% x = -(lambda/2)*P^{-1}*ck        .............. (1)
%
% From the constraint ck'*x = dk, we have that
%
% dk = -(lambda/2)*ck'*P^{-1}*ck   .............. (2)
%
% Solving (2) for lambda and substituting (1) into the objective
% function, we have that the optimal value for the objective function is
% 
% fk(x) = (dk^2)/(ck'*P^{-1}*ck)
%
% Thus, the largest ellipsoid that contained in the polytope is given by
% x'*P*x = gamma where
%
% gamma = min { (dk^2)/(ck'*P^{-1}*ck) }
%          k

P_inv = inv(P);
gamma = Inf;
for k = 1:length(d)
  gamma_k = (d(k)*d(k))/(C(k,:)*P_inv*C(k,:)');
  if gamma_k < gamma
    gamma = gamma_k;
  end
end
