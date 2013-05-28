function [CH, CI, dI] = convex_hull_case2(verts)
% Compute the convexhull in the original space
CH=polyhedron;
CI=[]; dI=[]; VI=cell(1,1);
CE=[]; dE=[]; VE=cell(1,1);
ni=0; 
[m, n] = size(verts);

chi=convhulln(verts);

Ver=[];
for i=1:size(chi,1) % Loop over all facets
    facetverts=[];
    for j=1:n
        facetverts=[facetverts,verts(chi(i,j),:)'];
    end
    [c,d]=points2hyperplane(vertices(facetverts));

    % Check if 'c' points to outside, and correct it if not:
    if ~isempty(c)
        for k=1:m
            if ~ismember(k,chi(i,:))
                if (c'*verts(k,:)'-d > 10*eps)
                    c=-c; d=-d;
                    break
                end
            end
        end
        Ver=[Ver,facetverts];
        CI=[CI;c']; dI=[dI;d];
        ni=ni+1; VI{ni}=vertices(facetverts);
    end
end
CH.CI=CI; CH.dI=dI; CH.VI=VI;
CH.CE=CE; CH.dE=dE; CH.VE=VE;
CH.vtcs=vertices(unique(Ver','rows')');
CH=clean_polyhedron(CH,n);
return
