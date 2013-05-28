function SEG = seg_approx_lin(A,Ainv,b,X0,SP0,T)

% Approximate a single segment of a flow pipe for a `linear` dynamics.
%
% Syntax:
%   "SEG = seg_approx_lin(A,Ainv,b,X0,SP0,T)"
%
% Description:
%   Compute a conservative approximation of a flow pipe segment in the time
%   interval "[0,T]" for the `linear` (affine) dynamics "dx/dt = A*x +
%   b". The inputs to this function are
%
%   * "A": the system matrix
%
%   * "Ainv": the inverse of "A" if it exists, otherwsie it should be
%     "[]"
%
%   * "b": constant input vector for the affine dynamics
%
%   * "X0": a "linearcon" object represeting the initial set
%
%   * "SP0": sample points on "X0" that are simulated to construct the
%     convex hull. Typically, "SP0" contains the vertices of "X0".
%
%   * "T": the time step for the flow pipe approximation
%
%   The output "SEG" is a "linearcon" object (a polytope) representing the
%   flow pipe segment approximation.
%
% Implementation:
%   To approximate the flow pipe segment, we first simulate the sample
%   points from time "t = 0" to "t = T" and compute the convex hull of the
%   sample points at time "t = 0" and "t = T". For the affine dynamics, the
%   sample points at time "t = T" can be found by the affine transformation
%
%
%
%   "x(T) = e^{A*T}*x(0) + e^{A*T} * integral_{s=0}^{s=T} e^{-A*s}*b ds"
%
%
%
%   The second term, the displacement in the affine transformation, in the
%   above expression is computed by the function "step_response()". The
%   affine transformation performed by calling the function "transform" for
%   the corresponding object type. After the convex hull is obtained, we
%   extract the matrix-vector pair "[CI,dI]" that represents the linear
%   inequality "CI*x <= dI" for the convex hull. The normal vectors for the
%   faces of the conex hull, which are the rows of the matrix "CI", are used
%   to solve the optimization problem.
%
%
%   
%   "max (x0 in X0, t in [0,T]) ci'*x(t,x0)"
%
%
%
%   where "ci" is the "i"-th normal vector and "x(t,x0)" denote the solution
%   to the affine differential equation. 

%   The optimization is performed by using the 'medium-scale' algorithm
%   'fmincon'. As the maximum x0 must lie inside the initial set X0, 
%   the constraints are represented by the hyperplanes defining the initial 
%   set and the time constraint is given by the maximum time T. 
% 
%   As for linear systems it is easy to compute the gradient function
%   analytically, 'fmincon' is provided with the analytical gradient value
%   for the optimization problem. This gradient value consists of the
%   gradient w.r.t time and the gradient w.r.t the initial conditions.
%   (K.S. 02/09/2004)
%
%
%   After solving the optimization problem, we adjust the inequality
%   constraints for the convex hull to be "CI*x <= dInew" where "dInew(i)"
%   is the solution obtained for the "i"-th optimization problem. This, in
%   effect, expands the convex hull to cover the flow pipe segment. Put the
%   new linear inequality constraints into a "linearcon" object, call the
%   function "clean_up()" to remove redundant constraints, and return the
%   result.
%   
%
% See Also:
%   stretch_func_lin,step_response, fs_lin_map,linearcon,transform,
%   clean_up

global GLOBAL_APPROX_PARAM 

eAT = expm(A*T);
displacement = step_response(A,Ainv,b,T);
% Transfrom sample points by eAT
SPf = transform(SP0,eAT,displacement);

% Compute convex hull from these sample points
CH = polyhedron(SP0 | SPf);
[CE,dE,CI,dI] = linearcon_data(linearcon(CH));

[CInew,dInew] = shwrap_lin(CI,A,Ainv,b,X0,T,SP0);
for k = 1:length(dI)
  if (dInew(k) > dI(k))
    dI(k) = dInew(k);
 else
   if (dInew(k) < dI(k) - GLOBAL_APPROX_PARAM.poly_epsilon)
      warning('CheckMate:SegApprox:Lin',...
          ['Warning: Optimization result is not reliable, falling' ...
	    ' back to the convex hull approximation\n']);
    end
  end
end
SEG = clean_up(linearcon([],[],CI,dI));
return

% -----------------------------------------------------------------------------

function [C,d] = shwrap_lin(C,A,Ainv,b,X0,T,SP0)

% Shrink wrap the flow pipe segment in a polytope using the normal vectors
% stored in the rows of the given matrix C, i.e. compute the smallest linear
% constraint set given the set of directions C that contains the flow pipe
% segment from 0 to T.
% C             : a set of directions stacked together in a matrix
% X0            : a constraint representing initial set X0
% A             : system matrix
% Ainv          : inverse of A if exists, otherwise should be []
% b             : constant input vector
% T             : time step with respect to X0
%
% Revised by K.S. on 02/09/2004

global GLOBAL_APPROX_PARAM GLOBAL_OPTIM_PAR

% set parameters for the constraint optimization with 
%
%
%       BoundMatrix*x <= Boundvector
%
%
% the first 2n rows of BoundMatrix and BoundVector define the constraints on the state
% vector given by the initial region X0 and the 2 last rows of BoundMatrix and
% BoundVector define the time constraint 0 <= t <= T, whereas t is the
% simulation time. 

% Compute the constraint matrices

n = size(A,1);

% Define the constraints for time and state variables

[Ce de BoundMatrix BoundVector] = linearcon_data(X0);
BoundMatrix(end+1:end+2,end+1) = [1;-1];
BoundVector(end+1:end+2) = [T;0];

% Setting some options for the MATLAB optimization toolbox
tolerance = GLOBAL_APPROX_PARAM.func_tol;
options = optimset('LargeScale','off','GradObj','on','MaxIter',inf, ...
    'MaxFunEvals',1000,'TolFun',tolerance*T,'Display','off');

% These are the initial conditions for the optimization

Xinit = SP0(1); % One of the vertices of X0 is used as a feasible point for the optimization
Tinit = T/2;

% Compute the initial (t==0) and final (t==T) regions

[CE0,dE0,CI0,dI0] = linearcon_data(X0);
displacement = step_response(A,Ainv,b,T);
XT = transform(X0,expm(A*T),displacement);
[CET,dET,CIT,dIT] = linearcon_data(XT);

% Stretch along each given direction of C to cover reachability region 
    
d = zeros(size(C,1),1);

for l = 1:size(C,1)
    n_vector = C(l,:);
  
    [Xopt,dopt] = fmincon('stretch_func_lin',[Xinit;Tinit],...
        BoundMatrix,BoundVector,[],[],[],[],[],options,...
    A,Ainv,b,n_vector,n);

    % Comparison of the optimized value with the optimal values for t==0 and
    % t==T.
    x0 = linprog(-n_vector,CI0,dI0,CE0,dE0,[],[],[],GLOBAL_OPTIM_PAR);
    xt = linprog(-n_vector,CIT,dIT,CET,dET,[],[],[],GLOBAL_OPTIM_PAR);
    d(l) = max([-dopt,n_vector*xt, n_vector*x0]);
end
return
