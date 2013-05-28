function [CH,CI,dI] = rect_hull(P)

% Converts a vertices object into a polyhedron object.
%
% Syntax:
%   "[CH,CI,dI] = rect_hull(P)"
%
% Description:
%   "rect_hull(P)" returns a polyhedron object CH as an oriented
%   hyper-rectangle constructed from the points in the vertices object "P",
%   and the matrices "CI" and "dI" that determine the inequalities of "CH".
%	 The orientation of the hyperrectangle is obtained from principal
%   component analysis.
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
% --OS-- Last change: 06/21/02
%

[verts, roundtol, svdtol, bloattol]= remove_dup_verts(P);

CH=polyhedron;
VI=cell(1,1); ni=0;
CE=[]; dE=[]; VE=cell(1,1);


n=size(verts,1); m=size(verts,2);

% Translate into the mean as new origin:
xm=sum(verts,2)/m;
tverts=[];
for i=1:m
    tverts=[tverts,verts(:,i)-xm];
end

% Singular value decomposition:
R=tverts*tverts';
[U,S,V]=svd(R);  % U=V!

% Introduce auxiliary point for distortion if two singular values are equal
ind=[];
for i=1:n
    for j=1:i-1
        if (S(i,i)>=S(j,j)-svdtol)&&(S(i,i)<=S(j,j)+svdtol)&&(S(i,i)~=0)
            ind=[ind;i;j];
        end
    end
end
ind=unique(ind);
if length(ind)>=1
    xaux=xm;
    for i=1:length(ind)
        xaux(i)=xaux(i)+bloattol*max(verts(i,:)-xm(i));
    end
    verts=[verts,xaux];
    m=m+1; xm=sum(verts,2)/m;
    tverts=[];
    for i=1:m
        tverts=[tverts,verts(:,i)-xm];
    end
    R=tverts*tverts'; [U,S,VD]=svd(R);
end

% Displacement matrix (minimal/maximal values for the new coordinates):
D=[];
for i=1:n
    D=[D,[max(U(:,i)'*tverts);min(U(:,i)'*tverts)]];
    if (D(2,i))>=-roundtol && (D(1,i)<=roundtol)
        D(1,i)=bloattol; D(2,i)=-bloattol;
    end
end

% (In)-Equalities:
CI=[U';-U'];
dI=[D(1,:)'+U'*xm; -D(2,:)'-U'*xm ];

% Vertices:
VGM=[];
for j=1:n
    Vu=[VGM; D(1,j)*ones(1,max(size(VGM,2),1))];
    Vl=[VGM; D(2,j)*ones(1,max(size(VGM,2),1))];
    VGM=[Vu, Vl];
end
Vt=U*VGM;
V=[];
for i=1:size(Vt,2)
    V=[V,Vt(:,i)+xm];
end
for i=1:n
    ni=ni+1;
    Vu=[]; Vl=[];
    for j=1:size(V,2)
        if (VGM(i,j)>=D(1,i)-eps) && (VGM(i,j)<=D(1,i)+eps)
            Vu=[Vu,V(:,j)];
        else % VGM(i,j)=D(2,i)
            Vl=[Vl,V(:,j)];
        end
    end
    VI{ni}=vertices(Vu);
    VI{n+ni}=vertices(Vl);
end

CH.CI=CI; CH.dI=dI; CH.VI=VI;
CH.CE=CE; CH.dE=dE; CH.VE=VE;
CH.vtcs=vertices(V);

return

