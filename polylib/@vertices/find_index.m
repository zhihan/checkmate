function idx = find_index(v,p)

% Find the index of a point in a vertices object 
%
% Syntax:
%   "i = find_index(vtcs,p)"
%
% Description:
%   "find_index(vtcs,p)" returns the index of "vtcs" where the point "p"
%   is stored.  If "p" is not contained in "vtcs", then
%   "find_index(vtcs,p)" returns "0".
%
% Examples:
%
%
%
%   "a = ["
%
%   "2 2 4 4"
%
%   "1 3 3 1"
%
%   "0 0 0 0];"
%
%   "vtcs = vertices(a);"
%
%   "i = find_index(vtcs,[4 3 0]')"
%
%
%
%   returns 
%
%
%
%   "i = 4"
%
%
%
% See Also:
%   vertices,subsref


% point_tol = parameters.poly_point_tol;
global GLOBAL_APPROX_PARAM
point_tol = GLOBAL_APPROX_PARAM.poly_point_tol;


idx = 0;
for k = 1:length(v)
  diff = v.list(:,k)-p;
  if (diff'*diff < point_tol)
    idx = k;
    break;
  end
end
