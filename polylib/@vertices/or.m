function U = or(v1,v2)

% Union of two vertices objects 
%
% Syntax:
%   "vtcs = or(v1,v2)"
%
%   "vtcs = v1 | v2"
%
% Description:
%   "or(v1,v2)" returns a vertices object containing all unique points
%   from "v1" and "v2". 
%
% Examples:
%   Given a vertices object, "v1" representing a square in the x3 = 0
%   plane with corners at (x1,x2) pairs (2,1), (2,3), (4,3), and (4,1), 
%
%
%
%   "v2 = ["
%
%   "2 2 4 4"
%
%   "1 3 3 1"
%
%   "2 2 2 2];"
%
%   "vtcs = v1 | v2"
%
%
%
%   returns "vtcs" a vertices object representing a cube with corners at
%   (x1,x2,x3) triples (2,1,0), (2,3,0), (4,3,0), (4,1,0), (2,1,2),
%   (2,3,2), (4,3,2), and (4,1,2).
%
% See Also:
%   vertices,and 


U = vertices; %assume

if ~isa(v2,'vertices')
  v2 = vertices(v2);
end

if ~isempty(v1) && ~isempty(v2) && (dim(v1) ~= dim(v2))
  disp('VERTICES/OR: different dimensions given')
  return
end
  
% point_tol = parameters.poly_point_tol;
global GLOBAL_APPROX_PARAM
point_tol = GLOBAL_APPROX_PARAM.poly_point_tol;


N1 = length(v1);
N2 = length(v2);

if (N1 == 0)
  U = v2;
  return
end

if (N2 == 0)
  U = v1;
  return
end

U = [v1 v2];
noDuplicate = true(length(U),1);

for k = 1:N2
  found = false;
  v2k = v2.list(:,k);
  for l = 1:N1
    v1l = v1.list(:,l);
    diff = (v1l-v2k);
    if (diff'*diff < point_tol)
      found = true;
      break;
    end
  end
  if found
    noDuplicate(N1+k) = false;
  end
end
U = vertices(U.list(:,noDuplicate));

