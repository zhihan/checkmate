function [destination,terminal] = ...
    find_guard_destination(cell_face_hp_idx,transitions,srcloc,srccell,mapping)

% Find destination cells in cases where a location transition has been
% taken.

global GLOBAL_PIHA

% Find the list of transitions being enabled by the mapping polytopes for
% the current cell face. Keep a separate list for each FSMB. Also, find the
% list of (possibly overlapping) guard cells in the cell partition for each
% transition that have been reached by the mapping polytopes.
q = GLOBAL_PIHA.Locations{srcloc}.q;
enabled = cell(1,length(q));
guard_cells_reached = [];
enabled_transition_found = 0;
for j = 1:length(transitions)
  % Get all guard cells associated with the current transition.
  guard_cells = transitions{j}.guard;
  guard_cell_event_flags = transitions{j}.guard_cell_event_flags;
  for i = 1:length(guard_cells)
    % Check if the current cell face is also a boundary face of the current
    % guard cell.
    [dum1,boundary_idx] = ...
        intersect(GLOBAL_PIHA.Cells{guard_cells(i)}.boundary, ...
                  cell_face_hp_idx);
    if ~isempty(boundary_idx)
      % If so, check further if any mapping polytope actually lands on the
      % guard cell face.
      dst_cell_inv = return_invariant(guard_cells(i));
      for k = 1:length(mapping)
        if isfeasible(mapping{k}, dst_cell_inv) 
          % If the event flag set to 1 for the current guard cell face being
          % hit, then we know that the parent transition for this guard cell
          % must be enabled. Add the enabled transition to the list for
          % its parent FSMB.
          if guard_cell_event_flags{i}(boundary_idx)
            fsm_idx = transitions{j}.idx;
            enabled{fsm_idx} = [enabled{fsm_idx} j];
            enabled_transition_found = 1;
          end
          % Keep the list of guard cells reached by the mapping.
          guard_cells_reached = union(guard_cells_reached,guard_cells(i));
          break;
        end
      end
    end
  end
end

destination = [];
terminal=[];

if enabled_transition_found
  
  % If there are enabled transitions, find all next possible
  % locations. 
  [dest_loc,dest_scs_reset,terminal] = ...
      find_destination_location(srcloc,transitions,enabled);

  % For each non-terminal destination location, find the destination
  % interior cells and a new entry into the destination list for each
  % destination cell found.
  for i = 1:length(dest_loc)
    % Apply the reset transformation for the destination location to
    % the mapping polytopes.
    q = GLOBAL_PIHA.Locations{dest_loc(i)}.q;
    scs_reset_indices = dest_scs_reset{i};
    [T,v] = overall_system_reset(GLOBAL_PIHA.SCSBlocks,q,scs_reset_indices);
    reset_mapping = cell(length(mapping),1);
    for k = 1:length(mapping)
      % The new transform routine should give full dimensional polytope even
      % if T is singular.
      reset_mapping{k} = transform(mapping{k},T,v);
    end
    
    % Intersect each interior cell with the reset mapping polytopes. Add
    % each non-empty result to the destination list.
    found = 0;
    interior_cells = GLOBAL_PIHA.Locations{dest_loc(i)}.interior_cells;
    for j = 1:length(interior_cells)
      dst_cell_inv = return_invariant(interior_cells(j));
      intersection = {};
      for k = 1:length(reset_mapping)
        if isfeasible(reset_mapping{k}, dst_cell_inv)
          intersection{end+1} = reset_mapping{k};
        end
      end
      if ~isempty(intersection)
        % Over approximate the intersection between the reset mapping
        % polytopes and the destination cell by a single polytope and
        % intersect it with the destination cell again before adding
        % the mapping to the destination list.
        temp.cell = interior_cells(j);
        temp.location = dest_loc(i); 
        temp.mapping = bounding_box(intersection) & dst_cell_inv;
        temp.Tstamp = [];
        destination = [destination temp];
        % Turn on the flag indicating that we have found at least one
        % destination cell in the interior region.
        found = 1;
      end
    end
      
    % If no destination interior cell is found, issue an error message to
    % the user about this.
    if ~found
      src_name = location_name(srcloc);
      dst_name = location_name(dest_loc(i));
      msg = [sprintf('\n\n') 'Transition from location ' src_name ...
             ' to location ' dst_name ' lands the system completely ' ...
             'outside of ' sprintf('\n') 'the interior region of the ' ...
             'destination location. Reachability not reliable!'];
      error('CheckMate:ComputeMapping:TransitionNotFound', msg);
    end
  end %for i

else

  % If no transition is enabled but some guard cells have been reached,
  % warn the user about this.
  if ~isempty(guard_cells_reached)
    msg = ['Warning: Reachability analysis indicates that the system may ' ...
           'exit the interior region' sprintf('\n') 'without taking any ' ...
           'transition from cell ' num2str(srccell) ' of location ' ...
           location_name(srcloc) '.'];
    fprintf(1,'%s\n',msg);
    return
  end
  
end
  
return
