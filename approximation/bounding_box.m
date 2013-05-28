function box = bounding_box(mapping)

% New version of this routine: uses the chosen option for hull computation to
% determine the bounding box.
%
% --OS--06/21/02

global GLOBAL_APPROX_PARAM

V = vertices;
if length(mapping) > 1
  for j = 1:length(mapping)
    vj = vertices(mapping{j});
    V = V | vj;
  end   
  box = linearcon(polyhedron(V));
else
%   Changed from
%  box = mapping{1};
%   to the following codes by Dong Jia, Mar. 27.
     [CE,dE,CI,dI]=linearcon_data(mapping{1});
%     if length(CE)==0
%         box=mapping{1};
%     else
         CI=[CI;CE;-CE];
         dI=[dI;[dE;-dE]+ones(2*length(dE),1)*GLOBAL_APPROX_PARAM.poly_bloat_tol];
         box=linearcon([],[],CI,dI);
         box=clean_up(box);
%     end
end
return
