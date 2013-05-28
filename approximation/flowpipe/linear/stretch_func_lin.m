function [f,grad] = stretch_func_lin(xt,A,Ainv,b,n_vector,n)

% the current evaluation of the optimization problem 

x0 = xt(1:n);
t = xt(n+1);

% computation of the objective function and gradient function. For the
% gradient, the following analytical expressions are used:
%
%
% \partial(f)/\partial(x0) = -n_vector*(expm(A*t))
% \partial(f)/\partial(t)  = -n_vector*(A*expm(A*t)*x0+expm(A*t)*b)
%
% which are derived from the solution 
% 
% x(t) = expm(A*t)*x0 + \int_0^t expm(A*(t-\tau)*b d\tau
%
% of the state equations 
% 
% \dot(x) = A*x + b.


if t == 0
    
    % objective function
    f = -n_vector*x0;
    
    % gradient function
    grad= zeros(n+1,1);
    grad(n+1) = -n_vector*(A*x0 + b); 
    grad(1:n) = -n_vector;
    return
    
else

    % objective function
    x_end = expm(A*t)*x0 + step_response(A,Ainv,b,t);
    f = -n_vector*x_end;

    % gradient function 
    grad = zeros(n+1,1);
    grad(n+1) = -n_vector*(A*x_end + b);
    grad(1:n) = -n_vector*expm(A*t);
    
end

return    

