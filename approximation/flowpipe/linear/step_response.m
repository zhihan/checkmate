function xfinal = step_response(A,Ainv,b,tf)

% Compute the `step response` of the affine system.
%
% Syntax:
%   "xfinal = step_response(A,Ainv,b,tf)"
%
% Description:
%   Compute the final value of the state vector "x" at the final time "tf"
%   for the affine dynamics "dx/dt = A*x + b". The inputs are
%
%   * "A": the system matrix
%
%   * "Ainv": the inverse of "A" if it exists, otherwsie it should be
%     "[]"
%
%   * "b": constant input vector for the affine dynamics
%
%   * "tf": final time for the step response
%
%   The final value of "x" is computed by evaluating the expression
%
%
%
%   "x(tf) = e^{A*tf}*x(0) + e^{A*tf} * integral_{s=0}^{s=tf} e^{-A*s}*b ds"
%
%
%
% Implementation:
%   If "A" is invertible, then the above integral reduces to
%
%
%
%   "x(tf) = (e^{A*tf}-I)*Ainv*b".
%   
%   
%  Otherwise augment the system and reduce a step response to initial
%  response.

if ~isempty(Ainv)
    % if A is invertible, then use the closed form solution
    xfinal = (expm(A*tf)-eye(size(A)))*Ainv*b;
else
    % otherwise, use the augmented system method
    n = size(A,1);
    Aaug = [A b; zeros(1, n+1)];
    xaug_0 = [zeros(n,1); 1];
    xaug_final = expm(Aaug*tf) * xaug_0;
    xfinal = xaug_final(1:n);
end
