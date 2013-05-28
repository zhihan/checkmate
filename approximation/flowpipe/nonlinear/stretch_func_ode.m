function f = stretch_func_ode(X,sys_eq,ode_param,n_vector,t0,tf,dimension)

% Compute objective function for the optimization problem in the flow pipe
% segment approximation procedure for `nonlinear` dynamics.
% 
% Syntax:
%   "[f,g] = stretch_func_ode(X,sys_eq,ode_param,n_vector,C_matrix,d_vector,t0,tf)"
%  
% Description:
%   Compute the following objective function value for the given "x0" and "t"
% 
%
%
%   "max (x0 in X0, t in [0,T]) n_vector'*x(t,x0)"
%
%
%
%   where "n_vector" is the normal vector and "x(t,x0)" denotes the solution
%   to the nonlinear differential equation.
%
% Implementation:
%   The ODE solution "x(t,x0)" is computed for the given "t" and "x0" using
%   the ODE solver "ode15s" in MATLAB.  The optimization variables for the
%   objective function are passed in as a single variable "X" whose first
%   "n" element is the vector "x0" and last element is the time "t".  The
%   objective function for the optimization is a function of "X"
%   only. "sys_eq", "ode_param", "n_vector","C_matrix", "d_vector", "t0",
%   and "tf" are optional parameters (See MATLAB help on "constr.m" for more
%   detail). "g" represents the constraints for the optimization problem,
%   which are that "x0" must be in the set "X0" (specified by the
%   "C_matrix"-"d_vector" pair) and that "t" must lie in
%   "[t0,tf]". "ode_param" contains optional parameters for the ODE file
%   (see MATLAB help on "odefile" for more detail).
%
% See Also:
%   seg_approx_ode

%fprintf('\nstrech_func_ode> X: %3.0f %3.0f',size(X));   


x0 = X(1:dimension,1);

if tf~=t0
  t = X(dimension+1,1);
  p = X(dimension+2:end,1);
else
  t=tf;
  p= X(dimension+1:end,1);
end;

if (t ~= 0)
  [T,xtraj] = ode45(sys_eq,[0 t],x0,[],ode_param,p);
  xt = xtraj(end,:)';
else
  xt = x0;
end

% objective function value
f = -n_vector'*xt;


