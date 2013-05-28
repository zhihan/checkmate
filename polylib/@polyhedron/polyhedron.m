function p = polyhedron(a)

% Polyhedron class constructor 
%
% Syntax:
%   "poly = polyhedron(a)"
%
%   "poly = polyhedron(con)"
%
%   "poly = polyhedron(vert)"
%
%   "poly = polyhedron"
%
% Description:
%   "polyhedron(a)" where "a" is a list of the vertices of the desired
%   polyhedron returns a polyhedron object with the desired vertices.  If
%   "con" is a linear constraint object, then "polyhedron(con)" constructs a
%   polyhedron object using the constraints from "con".  Similarly, if "vert"
%   is a vertices object, then "polyhedron(vert)" returns a polyhedron
%   with vertices at the points contained in "vert".  A call to
%   "polyhedron" with no arguments returns an empty polyhedron object. 
%
% Examples:
%   The command sequence 
%
%
%
%   "CE = [0 0 1]; dE = 0;"
%
%   "CI = [1 0 0;-1 0 0;0 1 0;0 -1 0]; dI = [4;-2;3;-1];"
%
%   "con = linearcon(CE,dE,CI,dI);"
%
%   "poly = polyhedron(con);"
%
%
%
%   constructs the linear constraint object "con" and the polyhedron
%   object "poly" both  representing a square in the plane x3=0 with
%   corners at (x1,x2) pairs (2,1), (2,3), (4,3), and (4,1).
%
% See Also:
%   get_param,linearcon,vertices

global GLOBAL_APPROX_PARAM

error = 1;
if nargin == 1
   if isa(a,'vertices')
      if strcmp(GLOBAL_APPROX_PARAM.hull_flag,'convexhull')
         p = convex_hull(a);
      else
         p = rect_hull(a);
      end
      error = 0;
  end
  if isa(a,'double')
      if strcmp(GLOBAL_APPROX_PARAM.hull_flag,'convexhull')
         p = convex_hull(vertices(a));
      else
         p = rect_hull(vertices(a));
      end
      error = 0;
  end
  if isa(a,'linearcon')
    p = con2poly(a);
    error = 0;
  end
end

if error
  % ---- POLYHEDRON data structure ----
  % CE(k,:) and dE(k) define the k-th equality constraint
  % VE{k} contains the vertices on the k-th equality contstraints
  % CI(k,:) and dI(k) define the k-th inequality constraint
  % VI{k} contains the vertices on the k-th inequality contstraints

  p.CE = []; p.dE = []; p.VE = {};
  p.CI = []; p.dI = []; p.VI = {};
  p.vtcs = vertices;
  p = class(p,'polyhedron');
end
