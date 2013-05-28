function cP = clean_polyhedron(P,n)

% This function tests whether the polyhedron objects contains inequality
% constraints that are redundant (within a tolerance vector_tol);
%
% (Equality constraints are changed. The fields 'VE' and 'vtcs' are also not updated
%  - this is impossible since it is not known which points are superfluous.)
%
% Remark: The fact that redundant inequality constraints and superfluous points
% can be contained in P is a result from the qhull-routine which uses perturbation
% of points combined with triangulation.
%

global GLOBAL_APPROX_PARAM

cP=polyhedron;

%tol=1e-8;
tol=0.9*GLOBAL_APPROX_PARAM.poly_vector_tol;

p=0; ind=[];
for i=1:size(P.CI,1)
    Cdi=[P.CI(i,:),P.dI(i,:)];
    b1=0;
    if (i>1)
       for j=1:size(cP.CI,1)
          Cdj=[cP.CI(j,:),cP.dI(j,:)];
          k=1; b2=0;
          while (k<=(size(P.CI,2)+1))
            if (abs(Cdj(k)-Cdi(k))>tol)
               b2=1;   % at least one entry different
               break
            end
            k=k+1;
          end
          if b2==0     % all components are the same
             b1=j;
             break    
          end
       end
    end
    if b1>0  % remove component -> do not copy to cP
       va=[];
       for q=1:length(cP.VI{b1})
          va=[va,cP.VI{b1}(q)];
       end    
       for q=1:length(P.VI{i})
          va=[va,P.VI{i}(q)];
       end
       va=unique(va','rows')';
       cP.VI{b1}=vertices(va);
       ind=[ind,b1];   
    else     % copy components from P tp cP
       p=p+1;
       cP.CI(p,:)=P.CI(i,:); cP.dI(p,:)=P.dI(i,:); cP.VI{p}=P.VI{i};
    end
end    

% Check the validity of vertices of eliminated faces
if (isempty(P.CE))
   dc=n;
else
   dc=n-1;
end   
for i=1:length(ind)
   Va=[];
   for j=1:length(cP.VI{ind(i)})
      dV=cP.CI*cP.VI{ind(i)}(j)-cP.dI;
      ffc=0;
      for k=1:length(dV)
         if abs(dV(k))<=10*eps
            ffc=ffc+1;
         end
      end
      if ffc>=dc
         Va=[Va,cP.VI{ind(i)}(j)];   
      end   
   end
   cP.VI{ind(i)}=vertices(Va);
end
Ver=[];
for i=1:size(cP.CI,1)
   for j=1:length(cP.VI{i})
      Ver=[Ver,cP.VI{i}(j)];           
   end   
end
cP.vtcs=vertices(unique(Ver','rows')');
cP.VE{1}=cP.vtcs;

% No change for:
cP.CE=P.CE; cP.dE=P.dE;

return

