function [CH, CI, dI] = convex_hull_case3( n, T,VT,  R, V, x_org, rs, rd, dverts, bloattol)
warning('ConvexHull:Dimension:Case3', ...
    [' CONVEX_HULL Case 3: leads to a hull of dimension ',num2str(rs),' - the hull is expanded to full dimension!']);

CH=polyhedron;
CI=[]; dI=[]; VI=cell(1,1);
CE=[]; dE=[]; VE=cell(1,1);
ni=0;

tdverts=(T*dverts')';
tdmin=min(tdverts); tdmax=max(tdverts);
CI=[VT;-VT];
dI=[tdmax+T*x_org'+2*eps; bloattol*ones(rd,1)+R*x_org'; -tdmin-T*x_org'-2*eps; bloattol*ones(rd,1)-R*x_org'];
% Bloating the minimum and maximum point to 2^rd points each:
vbmin=[tdmin-eps]; vbmax=[tdmax+eps];
for (j=1:rd)
    jvbmin1=[vbmin; -bloattol*ones(1,max(size(vbmin,2),1))]; jvbmin2=[vbmin; bloattol*ones(1,max(size(vbmin,2),1))];
    vbmin=[jvbmin1,jvbmin2];
    jvbmax1=[vbmax; -bloattol*ones(1,max(size(vbmax,2),1))]; jvbmax2=[vbmax; bloattol*ones(1,max(size(vbmax,2),1))];
    vbmax=[jvbmax1,jvbmax2];
end
% Backtransformation of the points:
pmin=V*vbmin; pmax=V*vbmax;
for i=1:size(pmin,2)
    pmin(:,i)=pmin(:,i)+x_org'; pmax(:,i)=pmax(:,i)+x_org';
end
p=[pmin,pmax];
% Assignment of vertices to faces:
vi=cell(size(CI,1),1);
for i=1:size(p,2)
    for j=1:size(CI,1)
        if (CI(j,:)*p(:,i)<=dI(j)+10*eps)&&(CI(j,:)*p(:,i)>=dI(j)-10*eps)
            vi{j}=[vi{j},p(:,i)];
        end
    end
end
for j=1:size(CI,1)
    VI{j}=vertices(vi{j});
end
CH.CI=CI; CH.dI=dI; CH.VI=VI;
CH.CE=CE; CH.dE=dE; CH.VE=VE;
CH.vtcs=vertices(p);
CH=clean_polyhedron(CH,n);
return