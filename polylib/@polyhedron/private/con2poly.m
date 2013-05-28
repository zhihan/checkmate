function POLY = con2poly(CON)

% Convert a linear constraint object to a polyhedron object
%
% Syntax:
%   "poly = con2poly(con)"
%
% Description:
%   "con2poly(con)" returns a polyhedron object representing the region
%   defined by the constraints from the linear constraint object "con".
%
% See Also:
%   polyhedron,linearcon

% Compute the intersection points and add to the list of points for each
% hyperplane in the combination, if the point computed satisfies all the 
% constraints. It is assumed that the constraint is feasible.

if isempty(CON)
  POLY = polyhedron;
  return;
end


[CE,dE,CI,dI] = linearcon_data(CON);
VE = {}; VI = {};
for i = 1:length(dE)
  VE{i} = vertices;
end
for i = 1:length(dI)
  VI{i} = vertices;
end
vtcs = vertices;

n_total = dim(CON);
n_free = n_total-length(dE);

if (n_free < 1)
  % if there are at least n equality constraints the we can ignore the
  % inequality constraints 
  v = CE(1:n_total,:)\dE(1:n_total,:);
  for i = 1:length(dE)
    VE{i} = VE{i} | v;
  end
else
  COMBO = nchoosek([1:length(dI)],n_free);
  for i = 1:size(COMBO,1)
    C = CE; d = dE;
    for j = 1:length(COMBO(i,:))
      C = [C; CI(COMBO(i,j),:)];
      d = [d; dI(COMBO(i,j),:)];
    end
    if rank(C) == n_total
      vi = C\d;
      if feasible_point(linearcon([],[],CI,dI),vi)
        vtcs = vtcs | vi;
        for j = 1:length(dE)
          VE{j} = VE{j} | vi;
        end
        for j = 1:length(COMBO(i,:));
          VI{COMBO(i,j)} = VI{COMBO(i,j)} | vi;
        end
      end
    end
  end
end

POLY = polyhedron;
POLY.CE = CE; POLY.dE = dE; POLY.VE = VE;
POLY.CI = CI; POLY.dI = dI; POLY.VI = VI;
POLY.vtcs = vtcs;



