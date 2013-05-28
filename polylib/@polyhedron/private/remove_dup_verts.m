function [verts, roundtol, svdtol, bloattol] = remove_dup_verts(P)
global GLOBAL_APPROX_PARAM

roundtol = GLOBAL_APPROX_PARAM.poly_vector_tol;
if (roundtol==0)
   roundtol=1e3*eps;
end

svdtol = GLOBAL_APPROX_PARAM.poly_svd_tol;
if (svdtol==0)
   svdtol=1e4*eps;
end

% Absolute value for bloating
bloattol = GLOBAL_APPROX_PARAM.poly_bloat_tol;
% must be larger than 'roundtol'!
if bloattol<=roundtol+10*eps;
   bloattol=roundtol+10*eps;
end

% Rounding and Removal of points with multiple occurrence:
verts=[];
for i=1:length(P)
   verts=[verts; roundtol*round(P(i)'/roundtol)];
end

verts=unique(verts,'rows')'; % each point contained as a column vector

end