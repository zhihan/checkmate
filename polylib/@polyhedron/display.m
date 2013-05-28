function display(p)

% Command window display of a polyhedron object
%
% Syntax:
%   "poly"
%
%   "display(poly)"
%
% Description:
%   "display(poly)" is called whenever a polyhedron object needs to be
%   displayed in the Matlab command window.
%
% Examples:
%   The command sequence 
%
%
%
%     "CE = [0 0 1]; dE = 0;"
%
%     "CI = [1 0 0;-1 0 0;0 1 0;0 -1 0]; dI = [4;-2;3;-1];"
%
%     "con = linearcon(CE,dE,CI,dI);"
%
%     "poly = polyhedron(con)"
%
%
%
%   results in
%
%
%
%   "poly ="
%
%   "Inequality Constraints"
%
%   "----------------------"
%
%   "Constraint 1:  [ 1.000000	0.000000	0.000000 ]x <= 4.000000"
%
%   "Vertices:"
%
%   "[ 4.000000	3.000000	2.000000 ] cTv = 4.000000"
%
%   "[ 4.000000	3.000000	0.000000 ] cTv = 4.000000"
%
%   "[ 4.000000	1.000000	2.000000 ] cTv = 4.000000"
%
%   "[ 4.000000	1.000000	0.000000 ] cTv = 4.000000"
%
%   "Constraint 2:  [ -1.000000	0.000000	0.000000 ]x <= -2.000000"
%
%   "Vertices:"
%
%   "[ 2.000000	3.000000	2.000000 ] cTv = -2.000000"
%
%   "[ 2.000000	3.000000	0.000000 ] cTv = -2.000000"
%
%   "[ 2.000000	1.000000	2.000000 ] cTv = -2.000000"
%
%   "[ 2.000000	1.000000	0.000000 ] cTv = -2.000000"
%
%   "Constraint 3:  [ 0.000000	1.000000	0.000000 ]x <= 3.000000"
%
%   "Vertices:"
%
%   "[ 4.000000	3.000000	2.000000 ] cTv = 3.000000"
%
%   "[ 4.000000	3.000000	0.000000 ] cTv = 3.000000"
%
%   "[ 2.000000	3.000000	2.000000 ] cTv = 3.000000"
%
%   "[ 2.000000	3.000000	0.000000 ] cTv = 3.000000"
%
%   "Constraint 4:  [ 0.000000	-1.000000	0.000000 ]x <= -1.000000"
%
%   "Vertices:"
%
%   "[ 4.000000	1.000000	2.000000 ] cTv = -1.000000"
%
%   "[ 4.000000	1.000000	0.000000 ] cTv = -1.000000"
%
%   "[ 2.000000	1.000000	2.000000 ] cTv = -1.000000"
%
%   "[ 2.000000	1.000000	0.000000 ] cTv = -1.000000"
%
%   "Constraint 5:  [ 0.000000	0.000000	1.000000 ]x <= 2.000000"
%
%   "Vertices:"
%
%   "[ 4.000000	3.000000	2.000000 ] cTv = 2.000000"
%
%   "[ 4.000000	1.000000	2.000000 ] cTv = 2.000000"
%
%   "[ 2.000000	3.000000	2.000000 ] cTv = 2.000000"
%
%   "[ 2.000000	1.000000	2.000000 ] cTv = 2.000000"
%
%   "Constraint 6:  [ 0.000000	0.000000	-1.000000 ]x <= 0.000000"
%
%   "Vertices:"
%
%   "[ 4.000000	3.000000	0.000000 ] cTv = 0.000000"
%
%   "[ 4.000000	1.000000	0.000000 ] cTv = 0.000000"
%
%   "[ 2.000000	3.000000	0.000000 ] cTv = 0.000000"
%
%   "[ 2.000000	1.000000	0.000000 ] cTv = 0.000000"
%
%
%
% See Also:
%   linearcon



fprintf(1,['\n' inputname(1) ' ='])

if isempty(p.dE) & isempty(p.dI)
  fprintf(1,' empty\n\n');
  return
end

fprintf(1,'\n');
if ~isempty(p.dE)
  fprintf(1,'Equality Constraints\n')
  fprintf(1,'--------------------\n')
  for k = 1:length(p.dE)
    fprintf(1,'Constraint %d:  ',k)
    n = p.CE(k,:); b = p.dE(k);
    print_vector(n)
    fprintf(1,'x = %f\n',b)
    fprintf(1,'Vertices:\n')
    print_vertices(p.VE{k},n)
  end
end

if ~isempty(p.dI)
  fprintf(1,'Inequality Constraints\n')
  fprintf(1,'----------------------\n')
  for k = 1:length(p.dI)
    fprintf(1,'Constraint %d:  ',k+length(p.dE))
    n = p.CI(k,:); b = p.dI(k);
    print_vector(n)
    fprintf(1,'x <= %f\n',b)
    fprintf(1,'Vertices:\n')
    print_vertices(p.VI{k},n)
  end
end

return

function print_vector(v)

fprintf(1,'[ ')
for k = 1:length(v)-1
  fprintf(1,'%f\t',v(k))
end
fprintf(1,'%f ]',v(length(v)))
return

function print_vertices(V,n)

for k = 1:length(V)
  fprintf(1,'  ')
  print_vector(V(k))
  fprintf(1,' cTv = %f\n',n*V(k))
end
return
