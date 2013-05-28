function map = invariant_boundary_intersect(INV,P)
% -----------------------------------------------------------------------------

% Compute the intersection between the boundary of the invariant and the
% polytope P.  It is assumed that the invariant is of full dimensions, no
% inequality constraints.

% map is a cell array of the same size as the number of faces of INV
% map{i} is the intersection of P with the ith face of INV
N = number_of_faces(INV);
map = cell(N,1);

% Compute the intersection on each face of INV
for m = 1:N
    temp = poly_face(INV,m);
    temp = temp & P;
    if ~isempty(temp)
        map{m} = temp;
    end
end
return