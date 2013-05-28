function [CH, CI, dI] = convex_hull_case5( n, T, R, V, x_org, rs, rd, dverts, bloattol)
warning('ConvexHull:Dimension:Case5', ...
    [' CONVEX_HULL Case 5: leads to a hull of dimension ',num2str(rs),' - the hull is expanded to full dimension!']);

CH=polyhedron;
CI=[]; dI=[]; VI=cell(1,1);
CE=[]; dE=[]; VE=cell(1,1);
ni=0;

% Transformation into the rs-dimensional space
tdverts=(T*dverts')';
% Compute the convexhull in the transformed space
chi=convhulln(tdverts);

Ver=[];
ifcaib=0;   % identifier that is set to one once the constraints resulting from bloating are added
ind=[];     % index vector that stores the indices of those rows of CI which correspond to bloated directions
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
        bfiverts=facetverts;
        for j=1:rd
            sbfi=size(bfiverts,2);
            bfiverts=[[bfiverts;bloattol*ones(1,sbfi)],[bfiverts;-bloattol*ones(1,sbfi)]];
        end
        bfverts=V*bfiverts;

        bverts=[];
        for j=1:size(bfverts,2)
            bverts=[bverts,bfverts(:,j)+x_org'];
        end
        % Create the polyhedron object:
        CI=[CI; c'*T]; dI=[dI; d + c'*T*x_org' + 2*eps];
        ni=ni+1; VI{ni}=vertices(bverts);
        Ver=[Ver,bverts];
        if (ifcaib==0)
            for j=1:rd
                CI=[CI; R(j,:); -R(j,:)]; dI=[dI; bloattol + R(j,:)*x_org'; bloattol - R(j,:)*x_org'];
                ni=ni+2; ind=[ind,ni-1,ni]; VI{ni-1}=[]; VI{ni}=[];
                % The vertices are already stored in 'Ver'.
            end
            ifcaib=1;
        end
    end
end

% Assign vertices:
Ver=unique(Ver','rows')';
for i=1:size(Ver,2)
    for j=1:length(ind)
        if (CI(ind(j),:)*Ver(:,i)<=dI(ind(j))+10*eps) && (CI(ind(j),:)*Ver(:,i)>=dI(ind(j))-10*eps)
            vij=VI{ind(j)};
            vijk=[];
            for k=1:length(vij)
                vijk=[vijk,vij(k)];
            end
            VI{ind(j)}=vertices([vijk,Ver(:,i)]);
        end
    end
end

CH.CI=CI; CH.dI=dI; CH.VI=VI;
CH.CE=CE; CH.dE=dE; CH.VE=VE;
CH.vtcs=vertices(Ver);
CH=clean_polyhedron(CH,n);
return