function [destination,null_event,time_limit,out_of_bound,terminal] = ...
    compute_mapping_no_SD(X0,srcloc,srccell)

% Perform reachability analysis to compute the destination locations and
% cells from the given polytope in the specified location and cell.
%
% Example
%   [destination,null_event,time_limit,out_of_bound,terminal] =
%    compute_mapping_no_SD(X0,srcloc,srccell)
%
% Description
%   The inputs to this function are
%
%   * "X0": a "linearcon" object representing the initial continuous set
%     from which the reachability is to be computed. It is assumed that "X0"
%     is full-dimensional and resides in the given source cell which in
%     turns is part of the interior region for the source location.
%   * "srcloc": current location.
%   * "srccell": current polyhedral cell where "X0" resides
%
%   The outputs of this function are
%
%   * "destination": a cell array of structures containing the
%     information about next destination locations and cells that are
%     reachable from the given initial condition (see note below for more
%     detail on the structure).
%   * "null_event": a boolean flag indicating that the flow pipe computation
%     was terminated because it can be concluded that the subsequent flow
%     pipe segments will remain inside "INV" forever.
%   * "time_limit": a boolean flag indicating that the flow pipe computation
%     was terminated because the time limit "max_time" was exceeded.
%   * "out_of_bound": a boolean flag indicating that the flow pipe computation
%     resulted in some mapppings polytopes that went out of the analysis
%     region.
%   * "terminal": a cell array of FSMB state (rows) vectors indicating
%     the terminal FSM states that can be reached from the given initial
%     condition.
%
% Note:
%   The output argument "destination" is a cell array of structures.  Each
%   element in the cell array correspond to a destination with the following
%   fields.
%
%   * ".location" - destination location index
%   * ".cell" - destination cell index
%   * ".mapping" - a single polytope representing the reachable set from
%                  the given initial condition in the destination location
%                  and cell.
%   * ".Tstamp" - not used here since no sampled data is involved.
%
% Implementation:
%   Call the mapping computation routine corresponding to the type of the
%   composite continuous dynamics of all SCSBs for the given location
%   ("fs_lin_map" for `linear` (affine) dynamics, "fs_nonlin_map" for
%   `nonlinear` dynamics, and "clk_map" for `clock` dynamics) to map the
%   continuous trajectory from "X0" to the boundaries of the current
%   cell. For each cell boundary that has been reached determine the
%   following.
%
%   1. If the mapping is entering another interior cell, then add a
%   destination corresponding to that interior cell. The destination
%   location and mapping remain unchanged.
%
%   2. If the mapping is entering a guard cell and at least one transition
%   in one FSM is enabled, compute all possible destination locations. For
%   each possible destination location, apply the reset transformation to
%   the mapping as needed and find the interior cells in the destination
%   location that can be reached by the transformed mapping. Add all
%   combinations of destination interior cells and locations as well as the
%   correponding mapping to the destination cell array.
%
%   3. If the mapping does not enable any transition, find all guard cells
%   that can be reached from the cell partitions of all transitions. Then
%   eliminate all the guard cells that are already covered by some other
%   guard cells. Add the remaining cells to the destination list. As with
%   case 1, the destination location and the mapping remain unchanged.
%
%   To speed up the subsequent computation, the mapping polytopes are over
%   approximate by a single polytope before the result is stored in the
%   ".mapping" field above.
%
% See Also:
%   fs_nonlin_map,fs_lin_map,clk_map

global GLOBAL_PIHA
global GLOBAL_APPROX_PARAM


% Default return values.
null_event = 0;
time_limit = 0;
out_of_bound = 0;
destination = {};
terminal = {};

% Do nothing if the initial condition is empty.
if isempty(X0)
  error('CheckMate:ComputeMapping:InitSetEmpty',...
      'The given initial continuous set is empty.');
end

% Get the polytope for the current cell.
INV = return_invariant(srccell);

% Get the constraints on the parameters for the given location.
Pcon = return_parameter_cons();

% Compute the type of the composite dynamics of all SCSBs for the FSM
% state in the source location.
overall_dynamics = check_overall_dynamics(GLOBAL_PIHA.SCSBlocks, ...
                                          GLOBAL_PIHA.Locations{srcloc}.q);

% Apply different methods for computing the mapping polytopes for each
% type of dynamics.
switch overall_dynamics,
 
 case 'linear',
  [A,b] = overall_system_matrix(GLOBAL_PIHA.SCSBlocks, ...
                                GLOBAL_PIHA.Locations{srcloc}.q);
  [mapping,null_event,time_limit] = fs_lin_map(A,b,X0,INV);
 
 case 'clock',
  v = overall_system_clock(GLOBAL_PIHA.SCSBlocks, ...
                           GLOBAL_PIHA.Locations{srcloc}.q);
  % Check to make sure that the clock vector is not zero before we
  % proceed to compute the mapping by quantifier elimination.
  if all(v == 0)
    error('CheckMate:ComputeMapping:ZeroClock', ...
        ['Found zero clock vector for location ' num2str(srcloc) '.']);
    return
  end
  % Compute the mapping by projecting X0 along the clock direction and
  % intersect it with the current cell polytope.
  mapping = clk_map(X0,v,INV);
  % As long as the clock vector is not zero, the system cannot remain in
  % the same location forever, hence the null event flag is always 0 in
  % this case.
  null_event = 0;
  % Since the above mapping computation by quantifier elimination always
  % terminates without having to check for the time-limit, the time-limit
  % flag is always 0 in this case.
  time_limit = 0;
 
 case 'nonlinear',
  % Why is q an ode_param here? Need to confirm this with Ansgar.
  ode_param = GLOBAL_PIHA.Locations{srcloc}.q;
  [mapping,null_event,time_limit] = ...
      fs_nonlin_map('overall_system_ode',ode_param,X0,INV,Pcon, ...
                    GLOBAL_APPROX_PARAM.T,GLOBAL_APPROX_PARAM.max_time);
 
 otherwise,
  error('CheckMate:ComputeMapping:WrongDynamics', ...
      ['Unknown dynamics type ''' overall_dynamics '''.'])

end

% For each cell face with non-empty mapping, find where the mapping leads
% (i.e. what location and cell) as described in the comments at the start of
% the file.
destination = [];
terminal = [];
NAR = GLOBAL_PIHA.NAR;
transitions = GLOBAL_PIHA.Locations{srcloc}.transitions;
interior_cells = GLOBAL_PIHA.Locations{srcloc}.interior_cells;
for k = 1:length(mapping)
  % Do nothing and skip to the next cell face if the mapping for the current
  % cell face is empty.
  if isempty(mapping{k})
    continue;
  end
  
  % Get the global hyperplane index for the current cell face.
  cell_face_hp_idx = GLOBAL_PIHA.Cells{srccell}.boundary(k);
  
  % If the current cell face is a boundary of the analysis region, set the
  % out-of-bound flag to 1.
  if cell_face_hp_idx <= NAR
    out_of_bound = 1;
    % Since there can't possibly be another neighboring cell when the
    % current face is a boundary of the analysis region, there is no
    % destination cell. Therefore, we can skip the rest of the loop and
    % proceed to the next cell face.
    continue;
  end
  
  % Find destinations within the interior cells for the current location for
  % the mapping on the current face of the current cell.
  interior_dst = find_interior_destination( ...
      cell_face_hp_idx,interior_cells,srcloc,srccell,mapping{k});
  destination = [destination interior_dst];

  % Find destinations outside the interior cells.
  [guard_dst,terminal_k] = find_guard_destination( ...
      cell_face_hp_idx,transitions,srcloc,srccell,mapping{k});
  destination = [destination guard_dst];
  terminal = [terminal; terminal_k];
end

% Convert the return variable "terminal" to a cell array of row vectors as
% required by the caller function.
temp = cell(size(terminal,1), 1);
for k = 1:size(terminal,1)
  temp{k} = terminal(k,:);
end
terminal = temp;

% Convert the return variable "destination" to a cell array of structures,
% which is inefficient, but required by the caller function. Need to remove
% all cell arrays of structures from the code and replace them with
% structure array.
temp = cell(size(destination,1), 1);
for k = 1:length(destination)
  temp{k} = destination(k);
end
destination = temp;

return
