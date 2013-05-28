function destination = find_interior_destination( ...
    cell_face_hp_idx,interior_cells,srcloc,srccell,mapping)

% Find destinations within the interior region for the current location for
% the mapping on the current face of the current cell.

global GLOBAL_PIHA

% Over-approximate the mapping by a single polytope.
box = bounding_box(mapping);

destination = [];
% Find the neigboring cells (other than the current cell) in the interior
% region for the current location that have been hit by the mapping
% polytopes.
for i = 1:length(interior_cells)
  if interior_cells(i) ~= srccell
    % Check if the current cell face for the source cell is also a boundary
    % face of the current interior cell.
    [dum1,boundary_idx] = ...
        intersect(GLOBAL_PIHA.Cells{interior_cells(i)}.boundary, ...
                  cell_face_hp_idx);
    if ~isempty(boundary_idx)
      % If so, check further if any mapping polytope actually lands on the
      % neighboring cell face.
      dst_cell_inv = return_invariant(interior_cells(i));
      for j = 1:length(mapping)
        % If a mapping polytope overlaps with the invariant, then we can
        % conclude that the current interior cell can be reached. Add the
        % current interior cell to the destination list. 
        if isfeasible(box, dst_cell_inv)
          % Since reaching another interior cell cannot trigger a transition
          % the location must remain the same. To reduce the computational
          % complexity later on, we also over approximate the mapping
          % polytopes by a single polytope the covers all the mapping
          % polytopes. Since we are interested in finding the mapping
          % polytopes that reach each destination cell, the resulting
          % approximation of the mapping is also intersected with the
          % destination cell.
          temp.cell = interior_cells(i);
          temp.location = srcloc; 
          temp.mapping = box & dst_cell_inv;
          temp.Tstamp = [];
          destination = [destination temp];
          break;
        end % if ~isempty(intersection)
      end % for j
    end % if ~isempty(boundary_idx)
  end % if interior(i) ~= srccell
end % for i

return