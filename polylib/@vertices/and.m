function I = and(v1,v2)

% Find the intersection of two vertices objects 
%
% Syntax:
%   "V = and(a,b)"
%

%   "V = a & b"
%
% Description:
%   "and(a,b)" returns a vertices object constructed from all points
%   contained in both "a" and "b".  "b" can be given as a list of points
%   which is then converted to a vertices object before finding the
%   intersection.
%
% Examples:
%   Given two vertices objects, "a" representing a square in the x3 = 0
%   plane with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and (4,1)
%   and "b", another square in the same plane with corners at (2,1),
%   (2,2), (3,1), and (3,2),
%
%
%
%   "V = and(a,b)"
%
%
%
%   returns "V", a vertices object containing the (x1,x2) pair (2,1). 
%
% See Also:
%   vertices



I = vertices; % assume

if ~isa(v2,'vertices')
  v2 = vertices(v2);
end

if isempty(v1) && isempty(v2) && (dim(v1) ~= dim(v2))
  disp('VERTICES/OR: different dimensions given')
  return
end
  
% point_tol = parameters.poly_point_tol;
global GLOBAL_APPROX_PARAM
point_tol = GLOBAL_APPROX_PARAM.poly_point_tol;

if isempty(v1) || isempty(v2)
  return
end

N1 = length(v1);
N2 = length(v2);

list = v1.list;
isInV2 = false(N1, 1);

for k = 1:N1
  v1k = v1.list(:,k);
  for l = 1:N2
    v2l = v2.list(:,l);
    diff = (v1k-v2l);
    if (diff'*diff < point_tol)
      isInV2(k) = true;
      break;
    end
  end
end
list = list(:,isInV2);
I = vertices(list);

