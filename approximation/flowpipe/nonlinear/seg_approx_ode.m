function [SEG,SPf,intersect_flag] = seg_approx_ode(sys_eq,ode_param,X0,INV,SP0,t0,tf,Pcon)

% Approximate a single segment of a flow pipe for a `nonlinear` dynamics.
%
% Syntax:
%   "[SEG,SPf,intersect_flag] = seg_approx_ode(sys_eq,ode_param,X0,INV,SP0,t0,tf,Pcon)"
%
% Description:
%   Compute a conservative approximation of a flow pipe segment in the time
%   interval "[t0,tf]" for the `nonlinear` dynamics "dx/dt = f(x)". The
%   inputs to this function are
%
%   * "sys_eq": string containing file name of the derivative function
%     for the ODE (i.e., overall_system_ode in the directory \util)
%
%   * "ode_param": optional parameters for the ODE file
%
%   * "X0": a "linearcon" object representing initial set
% 
%   * "INV": a "linearcon" object representing invariant set
%
%   * "SP0": sample points that are simulated to construct the convex hull,
%     given at time t0
%
%   * "t0"/"tf" : start/final time with respect to "X0"
%
%   * Pcon : linearcon object representing the constraint on the parameters.
%
%   The outputs of this function are
%
%   * "SEG": a "linearcon" object (a polytope) representing the flow pipe
%     segment approximation.
%   
%   * "SFf":  sample points the are simulated from "SP0" to the time "tf".
% 
%   * "intersect_flag": flag to indicate intersection with boundary
% 
% Implementation:
%   To approximate the flow pipe segment, we first simulate the sample
%   points from times "t = t0" to "t = tf" and compute the convex hull of
%   the sample points at time "t = t0" and "t = tf". After the convex hull
%   is obtained, we extract the matrix-vector pair "[CI,dI]" that represents
%   the linear inequality "CI*x <= dI" for the convex hull. The normal
%   vectors for the faces of the conex hull, which are the rows of the
%   matrix "CI", are used to solve the optimization problem.
%
%
%   
%   "max (x0 in X0, t in [0,T]) ci'*x(t,x0)"
%
%
%
%   where "ci" is the "i"-th normal vector and "x(t,x0)" denotes the
%   solution to the nonlinear differential equation. The above optimization
%   problem is solved by calling the MATLAB routine for solving constrained
%   nonlinear optimization problem "constr". The computation of the
%   objective function, which includes numerical intregration of the ODE to
%   find the solution "x(t,x0)" from "x0" at time "t" is done in the
%   function "stretch_func_ode()".
%
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

% [SEG,SPf] = seg_approx_ode(sys_eq,ode_param,X0,SP0,t0,tf)
% Compute the outer approximation of the flow pipe segment from t0 to tf

global GLOBAL_APPROX_PARAM

% Simulate sample points from t0 to tf
[SPf, Siminf] = simulate_points(X0,sys_eq,ode_param,tf,Pcon);
SPf=vertices(polyhedron(SPf)); % Removes unnecessary vertices

% Compute convex hull from these extreme points
SEG = wrap_segment(sys_eq,ode_param,X0,t0,tf,Pcon,Siminf,SP0,SPf);

% >>>>>>>>>>>> -------------- end (Changing Algorithms) --------------- <<<<<<<<<<<<

% >>>>>>>>>>>> Bounding Approximation -- DJ -- 06/30/03 <<<<<<<<<<<<
% After computing the hyperrectangle hull approximation, we used the faces
% of the invariant set to bound the approximation if the hyperrectangle
% intersect with the boundary of the invariant.
% Added by Dong Jia to handle the case if the hyper-rectangle hull
% approximation intersect with borders of the INV set.
intersect_flag=~issubset(SEG,INV) && isfeasible(SEG,INV);

if intersect_flag
    if GLOBAL_APPROX_PARAM.optimize_facet
        SEG = wrap_segment_djia(sys_eq,ode_param,X0,t0,tf,Pcon,Siminf,SEG,INV);
    end
    intersect_flag=~issubset(SEG,INV)&&isfeasible(SEG,INV);
end
return
