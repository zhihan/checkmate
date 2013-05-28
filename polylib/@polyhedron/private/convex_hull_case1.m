function [CH, CI, dI] = convex_hull_case1(verts, bloattol)
warning('ConvexHull:Dimension:Case1', ...
    [' CONVEX_HULL case 1: - the hull is expanded to full dimension!']);

CH=polyhedron;
VI=cell(1,1);
CE=[]; dE=[]; VE=cell(1,1);
[m, n] = size(verts);

CI=zeros(2*n,n);
dI= zeros(2*n,1);
Ver=[];
for i=1:n
    CI(2*i-1,i)=-1; dI(2*i-1,1)=-verts(i)+bloattol;
    CI(2*i,i)=1; dI(2*i,1)=verts(i)+bloattol;
    jM=[];
    for j=1:n
        if (j~=i)
            jMa=[jM;(verts(j)-bloattol)*ones(1,max(size(jM,2),1))];
            jMb=[jM;(verts(j)+bloattol)*ones(1,max(size(jM,2),1))];
            jM=[jMa,jMb];
        end
    end
    jMm=[jM(1:i-1,:);(verts(i)-bloattol)*ones(1,size(jM,2));jM(i:size(jM,1),:)];
    jMp=[jM(1:i-1,:);(verts(i)+bloattol)*ones(1,size(jM,2));jM(i:size(jM,1),:)];
    Ver=[Ver,jMm,jMp];
    VI{2*i-1}=vertices(jMm); VI{2*i}=vertices(jMp);
end
CH.CI=CI; CH.dI=dI; CH.VI=VI;
CH.CE=CE; CH.dE=dE; CH.VE=VE;
CH.vtcs=vertices(unique(Ver','rows')');
return