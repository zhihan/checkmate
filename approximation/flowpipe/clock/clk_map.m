function mapping = clk_map(X0,v,INV)

% Compute the `mapping set` from the given initial polytope under `clock`
% dynamics in the given location invariant.
% 
% Syntax:
%   "mapping = clk_map(X0,v,INV)"
%
% Description:
%   A `mapping set` is the set of states on the boundary faces of the
%   location `invariant` that can be reached under the given continuous
%   dynamics from the initial continuous set. The inputs to this function
%   are
%
%   * "X0": a "linearcon" object representing the initial continuous set
%     for which the mapping is to be computed.
%
%   * "v": a constant `clock` vector for the `clock` dynamics
%
%   * "INV": the location invariant
%
%   The output "mapping" is a one-dimensional cell array with the same
%   number of elements as the number of faces of the location
%   invariant. Each element "MAPPING{i}" is a cell array of polytopes
%   constituting the mapping set on the "i"-th face of the invariant.
%
% Implementation:
%   The mapping set is computed by intersecting the reachable polytope
%   computed by the function "clk_rch" with the faces of "INV". Each
%   intersection is counted as a valid mapping only if the vector field (the
%   clock vector) is pointing strictly out of the invariant.
%
% See Also:
%   clk_rch,linearcon

% Compute the reachable set
R = clk_rch(X0,v);
%INV=clean_up(INV);
N = number_of_faces(INV);
mapping = cell(N,1);
% Compute the intersection on each face of INV
for m = 1:N
  temp = poly_face(INV,m);
  CE = linearcon_data(temp);
  % take the intersection as the mapping only if the vector field is
  % strictly going out of the invariant
  if (CE*v > 0)
    temp = temp & R;
    if ~isempty(temp)
      mapping{m} = {temp};
    end
  end
end
return
