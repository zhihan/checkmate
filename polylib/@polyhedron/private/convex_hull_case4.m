function [CH, CI, dI] = convex_hull_case4( n, T,VT,  R, V, x_org, rs, rd, dverts, bloattol)

CH=polyhedron;
CI=[]; dI=[]; VI=cell(1,1);
CE=[]; dE=[]; VE=cell(1,1);
ni=0;

% Transformation into the rs-dimensional space
tdverts=(T*dverts')';
% Compute the convexhull in the transformed space
chi=convhulln(tdverts);

Ver=[];
for i=1:size(chi,1) % Loop over all facets
    facetverts=[];
    for j=1:rs
        facetverts=[facetverts,tdverts(chi(i,j),:)'];
    end
    [c,d]=points2hyperplane(vertices(facetverts));

    % Determine where outside of the facet is, and reverse 'c' if necessary:
    if ~isempty(c)
        k=1;
        while (k<=size(tdverts,1))
            if ~ismember(k,chi(i,:))
                if (c'*tdverts(k,:)'-d > 10*eps)
                    c=-c; d=-d;
                    break
                end
            end
            k=k+1;
        end
        % Backtransformation of the relevant facet vertices:
        bfverts=V*[facetverts;zeros(1,size(facetverts,2))];
        bverts=[];
        for j=1:size(bfverts,2)
            bverts=[bverts,bfverts(:,j)+x_org'];
        end
        % Create the polyhedron object:
        CI=[CI; c'*T]; dI=[dI; d+c'*T*x_org'+2*eps];
        Ver=[Ver,bverts];
        ni=ni+1; VI{ni}=vertices(bverts);
    end
end

CH.CI=CI; CH.dI=dI; CH.VI=VI;
CH.CE=VT(rs+1,:); CH.dE=VT(rs+1,:)*x_org'; CH.VE{1}=vertices(unique(Ver','rows')');
CH.vtcs=vertices(unique(Ver','rows')');
CH=clean_polyhedron(CH,n);
return