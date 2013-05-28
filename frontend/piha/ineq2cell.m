function [boundary,hpflags] = ineq2cell(C,d)

global GLOBAL_PIHA GLOBAL_APPROX_PARAM

hyperplanes = GLOBAL_PIHA.Hyperplanes;

% This function is the dual of cell_ineq(), which has been changed to
% reflect the fact that 'hpflags' is no longer the same length as
% HYPERPLANES, rather it is the length of 'boundary' and each element
% relates to the side of the hp which makes up the boundary.

hyperplane_tol = GLOBAL_APPROX_PARAM.poly_hyperplane_tol;

n = length(d);
boundary = -ones(1,n);
hpflags = boundary;
for k = 1:n
  ck = C(k,:);
  dk = d(k);
  for m = 1:length(hyperplanes)
    cm = hyperplanes{m}.c;
    dm = hyperplanes{m}.d;
    if rank([ck dk; cm dm],hyperplane_tol) == 1
      boundary(k) = m;
      hpflags(k) = (ck*cm' > 0);
      break;
    end
  end
end

return