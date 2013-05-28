function rauto_tran(iscontinue)

% Update the transitions for the states in the new `approximating
% automaton` ( the automaton obtained after the refinement).  Progress is
% saved in the global variable so that the verification may be stopped and
% continued at a later time.
%
% Syntax:
%   "rauto_tran(iscontinue)"
%
% Description:
%   The input "continue" is a flag indicating whether the CheckMate
%   verification step implemented in this function should be started from
%   scratch or continued from the last break point.
%
% Implementation:
%   The progress of this function is saved in the global variable
%   "GLOBAL_PROGRESS". For this function, "GLOBAL_PROGRESS" has the
%   following fields.
%
%   * ".step". This field is always set to "'rauto_transition'" for the
%     CheckMate verification step implemented in this function.
%
%   * ".idx". Index of the current state in "GLOBAL_NEW_AUTOMATON" for which
%     the transitions are being computed. A state index for
%     "GLOBAL_NEW_AUTOMATON" is a row vector of length 2 or 3. An `initial
%     state` has an index of the form "[l s]" where "l" is the `location`
%     number and "s" is the `state` number. A `face state` has an idex of the
%     form "[l f s]" where "l" is the `location` number, "f" is the `face`
%     number, and "s" is the `state` number.
%
%   The transitions are updated by removing the destination `face` states
%   that are no longer reachable from the ".children" field of each state in
%   "GLOBAL_NEW_AUTOMATON". The list of `terminal` FSM states and the
%   out-of-bound flag are also updated for each state. The state index is
%   incremented using the function "inc_new_auto_idx" until all states in
%   "GLOBAL_NEW_AUTOMATON" are processed.
%
% See Also:
%   verify,iauto_part,refine_auto,rauto_mapping,compute_mapping,set_auto_state,
%   get_auto_state,rauto_ischild,total_new_auto_states,inc_new_auto_idx

% rauto_face_tran(continue):

% Reference global variable
% -----------------------
global GLOBAL_PIHA

% Output global variables
% -----------------------
global GLOBAL_PROGRESS      % records the progress

% Updating transition (children states) for face partition states
if iscontinue
  if ~ismember(GLOBAL_PROGRESS.step,{'rauto_transition'})
    error('CheckMate:RAuto:WrongStep',['Inconsistent continue step ''' GLOBAL_PROGRESS.step ...
          ''' (expected ''rauto_transition'').'])
  end
  idx = GLOBAL_PROGRESS.idx; 
else
  idx = [1 1];
  temp.step = 'rauto_transition';
  temp.idx = idx;
  GLOBAL_PROGRESS = temp;
end

total = total_new_auto_states(idx);
computed = 0;
t_start = clock;
% if not a valid index, find the next valid index
if ~is_valid_new_auto_idx(idx)
  idx = inc_new_auto_idx(idx);
end
while ~isempty(idx)
  GLOBAL_PROGRESS.idx = idx;
      
  % display some info
  if (length(idx) == 2) % if initial state
    str = sprintf('loc %d : initstate %d (%d/%d)', ...
        idx(1),idx(2),computed+1,total);
  else % if face state
    str = sprintf('loc %d : face %d : state %d (%d/%d)', ...
        idx(1),idx(2),idx(3),computed+1,total);
  end
  if (computed > 0) 
    time_to_go = etime(clock,t_start)/computed*(total-computed)/3600;
    if time_to_go > 1
      str = [str sprintf(' -- %f hr to go',time_to_go)];
    else
      time_to_go = time_to_go*60;
      str = [str sprintf(' -- %f min to go',time_to_go)];
    end
  end
  % clc; 
  fprintf(1,'Updating transitions.\n'); fprintf(1,'%s',str); drawnow
  
  indeterminate = get_auto_state('new',idx,'indeterminate');
  children = get_auto_state('new',idx,'children');
  mapping = get_auto_state('new',idx,'mapping');
  if (indeterminate == 0)
    % remove the children states that are no longer possible to reach
    children_new = [];
    for k = 1:size(children,1)
      if rauto_ischild(children(k,:),idx(1),mapping)
        children_new = [children_new; children(k,:)];
      end
    end
    % refresh the out-of-bound flag and terminal
    out_of_bound = 0;
    terminal = {};
    for k = 1:length(mapping)
      if ~isempty(mapping{k})
        % find destination location(s) for the kth invariant face
	transitions_k = GLOBAL_PIHA.Locations{idx(1)}.transitions{k};
	for m = 1:length(transitions_k)
	  switch transitions_k(m).type
	    case 'out_of_bound'
	      out_of_bound = 1;
	    case 'terminal'
	      terminal{length(terminal)+1} = transitions_k(m).destination;
	  end
	end
      end
    end
    set_auto_state('new',idx,'children',children_new);
    set_auto_state('new',idx,'out_of_bound',out_of_bound);
    set_auto_state('new',idx,'terminal',terminal);
  end

  idx = inc_new_auto_idx(idx);
  computed = computed + 1;
end
fprintf(1,'\n')
