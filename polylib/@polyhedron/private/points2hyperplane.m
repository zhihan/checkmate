function [c,d] = points2hyperplane(P)

% Given a set of n points, calculate the normal vector 'c' and the constant 'd'
% that define the hyperplane which all points in P belong to.

global GLOBAL_APPROX_PARAM

if isempty(P)
  c = []; d = [];
  return
end

n = dim(P);
if (length(P) ~= n)
  error('Points2Hyperplan:WrongInput',...
      'points2hyperplane: improper number of points given.\n')
end


V = P.list;
DIFF = V(:,2:n) - V(:,1)*ones(1,n-1);

tol = GLOBAL_APPROX_PARAM.poly_vector_tol;
if (rank(DIFF,tol) < (n-1))
    error('Points2Hyperplan:WrongInput',...
        'points2hyperplane: improper number of points given.\n')
end

for k1 = 1:n
  additional =  [zeros(1,k1-1) max(max(abs(DIFF))) zeros(1,n-k1)]';
  T = [DIFF additional];
  if (rank(T,tol) == n)
    break;
  end
end
c = T'\[zeros(1,n-1) 1]';
c = c/sqrt(c'*c);
d = c'*average(P);
return