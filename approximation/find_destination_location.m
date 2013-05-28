function [dest_loc,dest_reset,terminal] = ...
    find_destination_location(srcloc,transitions,enabled)
                 
% Given the list of enabled transitions for all FSMBs, find the list of
% next possible destination locations and the indices of SCSBs to be
% reset for each destination location.
%
% Inputs:
%   * "srcloc" - Source location index.
%   * "transitions" - A structure representing the list of FSM transitions
%      for the current location.
%   * "enabled" - A cell array of the same length as the number of
%     FSMBs. Each cell "enabled{i}" is a vector containing the indices for
%     the transitions that have been enabled for the i-th FSMB.
%
% Outputs:
%   * "dest_loc" - A vector of location indices representing the list of
%     next possible locations.
%   * "dest_reset" - A cell array of vectors. Each element "dest_reset{i}" 
%     of the cell array contains the indices of the SCSBs to be reset if
%     the transition to the location "dest_loc(i)" is taken.
%   * "terminal" - A matrix of row vectors. Each row contains the FSMB
%     state vector corresponding to a terminal FSM state that can be
%     reached.

global GLOBAL_PIHA 

q = GLOBAL_PIHA.Locations{srcloc}.q;

% From the list of enabled transitions, find the unique combinations of the
% next state and reset flag for each FSMB.
dest = cell(1,length(q));
for k = 1:length(q)
  if isempty(enabled{k})
    % If no transition is enabled for the current FSMB, then the only
    % possible combination is that the next state is the same as the current
    % state and the reset flag is zero.
    dest{k} = [q(k) 0];
  else
    dest{k} = [];
    for i = 1:length(enabled{k})
      % Find the next q and reset flag for the current transition for the
      % current FSMB.
      next_q = transitions{enabled{k}(i)}.destination;
      next_reset = transitions{enabled{k}(i)}.reset_flag;
      next_combo = [next_q next_reset];
      % Verify that the next state and reset flag combo is unique before
      % including it in the destination list for the current FSMB.
      found = 0;
      for j = 1:size(dest{k},1)
        if all(next_combo == dest{k}(j,:))
          found = 1;
          break;
        end
      end
      if ~found
        dest{k} = [dest{k}; next_combo];
      end
    end
  end
end

% Compute all possible combinations (cross products of the next 'q' vectors
% and 'reset' vectors across all FSMBs. When the loop below finishes,
% "dest_q" and "dest_reset_fsm" are matrices of the same size. "dest_q(i,:)"
% and "dest_reset_fsm(i,:)" go together to represent a combination being
% generated below. For the i-th combination, "dest_q(i,j)" is the next state
% and "dest_reset_fsm(i,j)" is the reset flag for the j-th FSMB.
dest_q = dest{1}(:,1);
dest_reset_fsm = dest{1}(:,2);
for k = 2:length(q)
  dest_q_new = [];
  dest_reset_fsm_new = [];
  m = size(dest_q,1);
  for i = 1:size(dest{k},1)
    dest_q_new = [dest_q_new; [dest_q dest{k}(i,1)*ones(m,1)]];
    dest_reset_fsm_new = [dest_reset_fsm_new;
                    [dest_reset_fsm dest{k}(i,2)*ones(m,1)]];
  end
  dest_q = dest_q_new;
  dest_reset_fsm = dest_reset_fsm_new;
end
clear dest_q_new
clear dest_reset_fsm_new

% Get the list of SCSBs to be reset by each FSMB. This list is identical for
% all transitions under the same FSM, so we can just grab the list from the
% first transition found under each FSM.

for k = 1:length(q)
  if isempty(enabled{k})
    reset_scs_idx{k} = [];
  else
    reset_scs_idx{k} = transitions{enabled{k}(1)}.reset_scs_index;
  end
end

% Convert the reset flag vector for each FSMB in each row of
% "dest_reset_fsm" into an index vector for SCSB to be reset.
dest_reset_scs_idx = cell(size(dest_reset_fsm,1),1);
for i = 1:size(dest_reset_fsm,1)
  for j = 1:size(dest_reset_fsm,2)
    if dest_reset_fsm(i,j)
      dest_reset_scs_idx{i} = ...
          union(dest_reset_scs_idx{i},reset_scs_idx{j});
    end
  end
end

% Find the destination location in GLOBAL_PIHA that corresponds to each
% row of "dest_q".
dest_loc = [];
dest_reset = {};
terminal = [];
for i = 1:size(dest_q,1)
  found = 0;
  for j = 1:length(GLOBAL_PIHA.Locations)
    if all(GLOBAL_PIHA.Locations{j}.q == dest_q(i,:))
      found = 1;
      break;
    end
  end
  if found
    % If a matching location is found, add the location index and the
    % corresponding list of SCSB to be reset to output list.
    dest_loc = [dest_loc; j];
    dest_reset = [dest_reset; {dest_reset_scs_idx{i}}];
  else
    % If a matching location is not found, add the 'q' vector to the
    % terminal state list.
    terminal = [terminal; dest_q(i,:)];
  end
end

return
