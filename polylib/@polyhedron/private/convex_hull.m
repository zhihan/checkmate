function [CH,CI,dI] = convex_hull(P)

% Converts a vertices object into a polyhedron object.
%
% Syntax:
%   "[CH,CI,dI] = convex_hull(P)"
%
% Description:
%   "convex_hull(P)" returns a polyhedron object CH constructed as the
%   convex hull of the points in the vertices object "P", and the matrices
%   "CI" and "dI" that determine the inequalities of "CH".
%   Matlab's QHULL routine, which is based on a Quickhull search algorithm,
%   is used to compute the convex hull.
%
%   The following rules determine the construction of the polyhedron object:
%   
%   - If the vertex object contains just one point, the polyhedron object
%     is n-dimensional with the length 2*vector_tol in all dimensions.
%
%   - If the vertices determine a full-dimensional hull the polyhedron
%     object is of course full dimensional.
%
%   - If the vertices determine an (n-1)-dimensional hull the polyhedron
%     object is not bloated, i.e., it is (n-1)-dimensional.
%
%   - If the convex hull of the vertices is of a dimension lower than (n-1)
%     but larger than zero, the polyhedron is bloated to full dimension,
%     i.e., this routine does never return an object that is of dimension
%     less than n-1.
%
%   Note: Since this routine accesses fields of polyhedron objects it can
%   only be used if it is located within the method of this class, i.e.,
%   if it is in the "@polyhedron" folder of the Checkmate distribution.
%
% See Also:
%   polyhedron,vertices
%
%
% --OS-- Last change: 06/05/02
%

[verts, roundtol, svdtol, bloattol] = remove_dup_verts(P);
verts = verts' ;

n=size(verts,2);
m=size(verts,1);

%--------------------------------------------------------------------------
% CASE 1: Input contains only one point
%         The convex hull is a hyperrectangular box obtained from bloating.
%--------------------------------------------------------------------------
if (m==1)
 [CH, CI, dI] = convex_hull_case1(verts, bloattol);
 return
end    

% Singular Value Decomposition:
x_org=verts(1,:);
dverts=verts - ones(m,1) * x_org;
[U,S,V]=svd(dverts);
VT=V';

% Determination of the Rank Deficiency depending on 'roundtol'
rs=0;
for i=1:min(size(S))
   if abs(S(i,i))<svdtol
      S(i,i)=0; 
   else    
      rs=rs+1;        % rs: rank of manipulated S   
   end
end
rd=n-rs;              % rd: rank deficiency

%---- CASE 2: Points form an n-dimensional object "normal case" -----------
if (rs==n)
    [CH, CI, dI] = convex_hull_case2(verts);
end

% Transformation Matrices:
T=VT(1:rs,:);
R=VT(rs+1:rs+rd,:);
if rs==1  % CONVHULLN cannot be called
    [CH, CI, dI] = convex_hull_case3(n, T, VT, R, V, x_org, rs, rd, dverts, bloattol);
elseif rd==1
   [CH, CI, dI] = convex_hull_case4(n, T, VT, R, V, x_org, rs, rd, dverts, bloattol);
elseif (rs>1)&&(rd>1)
    [CH, CI, dI] = convex_hull_case5(n, T, R, V, x_org, rs, rd, dverts, bloattol);
end

return  