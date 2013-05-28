function auto2xsys()

% Construct generic transition system from the current `approximating
% automaton`.
%
% Syntax:
%   "auto2xsys"
%
% Description:
%   Create a generic transition system in the global variable
%   "GLOBAL_TRANSITION" from the current `approximating automaton` stored in
%   the global variables "GLOBAL_AUTOMATON". The hierachical information in
%   "GLOBAL_AUTOMATON" is flattened into a cell array of state transitions
%   in "GLOBAL_TRANSITION". The element "GLOBAL_TRANSITION{i}" is a vector
%   of destination states for the "i"-th state in the transition system. The
%   links between states in "GLOBAL_AUTOMATON" and "GLOBAL_TRANSITION" are
%   stored in the global variables "GLOBAL_AUTO2XSYS_MAP" and
%   "GLOBAL_XSYS2AUTO_MAP". The `reverse` transition system (the transition
%   system with the roles of the destination and the source states reversed)
%   is also created in "GLOBAL_REV_TRANSITION".
%
% Implementation:
%
%   "GLOBAL_AUTO2SYS_MAP" is a structure that maps states in
%   "GLOBAL_AUTOMATON" to states in "GLOBAL_TRANSITION". It contains the
%   following fields.
%
%   * ".init_state_map{l}{s}": Gives the index of the state in
%     "GLOBAL_TRANSITION" corresponding to the initial state "s" in the
%     location "l" in "GLOBAL_AUTOMATON".
%
%   * ".init_state_range": Gives the range of states in "GLOBAL_TRANSITION"
%     that correspond to states in the initial state partition in
%     "GLOBAL_AUTOMATON"
%
%   * ".face_state_map{l}{f}{s}": Gives the index of the state in
%     "GLOBAL_TRANSITION" corresponding to state "s" on face "f" of
%     invariant of loction l in "GLOBAL_AUTOMATON".
%
%   * ".face_state_range": Gives the range of states in "GLOBAL_TRANSITION"
%     that correspond to states in the face state partition in
%     "GLOBAL_AUTOMATON"
%
%   * ".ne_start": Gives the starting index for `null_event` states in
%     "GLOBAL_TRANSITION"
%
%   * ".tl_start": Gives the starting index for `time-limit` states in
%     "GLOBAL_TRANSITION"
%
%   * ".oob_start": Gives the starting index for `out-of-bound` states in
%     "GLOBAL_TRANSITION"
%
%   * ".ind_start": Gives the starting index for `indeterminate` states in
%     "GLOBAL_TRANSITION"
%
%   * ".nr_start": Gives the starting index for `non_reachable` states in
%     "GLOBAL_TRANSITION"
%
%   "GLOBAL_XSYS2AUTO_MAP" is a cell array with the same length as
%   "GLOBAL_TRANSITION" that maps states in "GLOBAL_TRANSITION" to states in
%   "GLOBAL_AUTOMATON" as follows.
%
%   * "GLOBAL_XSYS2AUTO_MAP{k} = [l s]" if the "k"-th state in
%     "GLOBAL_TRANSITION" corresponds to initial state "s" in location "l" in
%     "GLOBAL_AUTOMATON"
%
%   * "GLOBAL_XSYS2AUTO_MAP{k} = [l f s]" if the "k"-th state in
%     "GLOBAL_TRANSITION" corresponds to state "s" on face "f" in location "l"
%     in "GLOBAL_AUTOMATON"
%
%   * "GLOBAL_XSYS2AUTO_MAP{k} = {type l}" where "type" is "'equlibrium'",
%     "'time_limit'", "'out_of_bound'", or "'indeterminate'", if the "k"-th
%     state in "GLOBAL_TRANSTITION" corresponds to a special state of the
%     identified type in location "l" in "GLOBAL_AUTOMATON"
%
%   * "GLOBAL_XSYS2AUTO_MAP{k} = {'terminal' q}" if the "k"-th state in
%     "GLOBAL_TRANSTITION" corresponds to a terminal state for the FSM state
%     "q" in "GLOBAL_AUTOMATON"
%
%   The hierachy of states in "GLOBAL_AUTOMATON" is flattened into a cell
%   array of states in "GLOBAL_TRANSITION" in the following order.
%
%   * `initial` states
%
%   * `face` states
%
%   * `null event` states (one for each location)
%
%   * `time-limit` states (one for each location)
%
%   * `out-of-bound` states (one for each location)
%
%   * `indeterminate` states (one for each location)
%
%   * `non_reachable` states (one for each location)
%
%   * `terminal` FSM states (created as needed)
%
%   The function first allocates a space in "GLOBAL_TRANSITION" for each
%   state in "GLOBAL_AUTOMATON" in the above order and creates the data
%   structure that links the states between the "GLOBAL_TRANSITION" and
%   "GLOBAL_AUTOMATON". Then it fills in the transition table in
%   "GLOBAL_TRANSITION" by mapping the children (destination) state indices
%   in "GLOBAL_AUTOMATON" to the corresponding indices in
%   "GLOBAL_TRANSITION". The only transition for all special states (`null
%   event`, `time-limit`, `out-of-bound`, `indeterminate`, 'non_reachable'
%	 and `terminal`) is a self-loop. Finally, the reverse transition system
%   is created by calling the function "revtran".
%
% See Also:
%   verify,global_var,remove_unreachables,revtran,region

% --- input global variables ---
global GLOBAL_AUTOMATON 

% --- output global variables ---
global GLOBAL_TRANSITION GLOBAL_REV_TRANSITION
global GLOBAL_AUTO2XSYS_MAP GLOBAL_XSYS2AUTO_MAP

GLOBAL_TRANSITION = {};
GLOBAL_XSYS2AUTO_MAP = {};
GLOBAL_AUTO2XSYS_MAP = {};

% Allocate space in GLOBAL_TRANSITION for each state in GLOBAL_AUTOMATON
% but the children (destination states) lists are left empty except for
% the special states (null_event, time-limit, out-of-bound, and
% indeterminate) which have only self-loops.

[init_state_map, istate_start, istate_end] = allocate_space_init();

[interior_state_map, fstate_start, fstate_end] = allocate_space_interior(istate_end);

 [ne_start, tl_start, oob_start, ind_start, nr_start] =...
    allocate_space_terminal();

% allocate "terminal" state as needed
tm_start = length(GLOBAL_XSYS2AUTO_MAP)+1;

% Put together the fields for GLOBAL_AUTO2XSYS_MAP
GLOBAL_AUTO2XSYS_MAP.init_state_map = init_state_map;
GLOBAL_AUTO2XSYS_MAP.init_state_range = [istate_start istate_end];
GLOBAL_AUTO2XSYS_MAP.interior_state_map = interior_state_map;
GLOBAL_AUTO2XSYS_MAP.interior_state_range = [fstate_start fstate_end];
GLOBAL_AUTO2XSYS_MAP.ne_start = ne_start;
GLOBAL_AUTO2XSYS_MAP.tl_start = tl_start;
GLOBAL_AUTO2XSYS_MAP.oob_start = oob_start;
GLOBAL_AUTO2XSYS_MAP.ind_start = ind_start;
GLOBAL_AUTO2XSYS_MAP.nr_start = nr_start;
GLOBAL_AUTO2XSYS_MAP.tm_start = tm_start;

% Use GLOBAL_AUTO2XSYS_MAP constructed earlier to map the children set for
% each state in GLOBAL_AUTOMATON to the corresponding children set for
% GLOBAL_TRANSTITION.

% Map children for initial states
for k = istate_start:istate_end
    idx = GLOBAL_XSYS2AUTO_MAP{k};
    children = GLOBAL_AUTOMATON{idx(1)}.initstate{idx(2)}.children;
    for l = 1:size(children,1)
        GLOBAL_TRANSITION{k} = [GLOBAL_TRANSITION{k} ...
            interior_state_map{children(l,1)}{children(l,2)}{children(l,3)}];
    end
    % add transition to null_event state for the same location
    if GLOBAL_AUTOMATON{idx(1)}.initstate{idx(2)}.null_event == 1
        GLOBAL_TRANSITION{k} = [GLOBAL_TRANSITION{k} ne_start+idx(1)-1];
    end
    % add transition to time_limit state for the same location
    if GLOBAL_AUTOMATON{idx(1)}.initstate{idx(2)}.time_limit == 1
        GLOBAL_TRANSITION{k} = [GLOBAL_TRANSITION{k} tl_start+idx(1)-1];
    end
    % add transition to out_of_bound state for the same location
    if GLOBAL_AUTOMATON{idx(1)}.initstate{idx(2)}.out_of_bound == 1
        GLOBAL_TRANSITION{k} = [GLOBAL_TRANSITION{k} oob_start+idx(1)-1];
    end
    % add transition to indeterminate state for the same location
    if GLOBAL_AUTOMATON{idx(1)}.initstate{idx(2)}.indeterminate == 1
        GLOBAL_TRANSITION{k} = [GLOBAL_TRANSITION{k} ind_start+idx(1)-1];
    end
    % add transition to non_reachable state for the same location
    if GLOBAL_AUTOMATON{idx(1)}.initstate{idx(2)}.non_reachable == 1
        GLOBAL_TRANSITION{k} = [GLOBAL_TRANSITION{k} nr_start+idx(1)-1];
    end
    % add transition to terminal FSM state
    terminal = GLOBAL_AUTOMATON{idx(1)}.initstate{idx(2)}.terminal;
    for l = 1:length(terminal)
        m = find_terminal_state(terminal{l},tm_start);
        if isempty(m)
            m = create_terminal_state(terminal{l});
        end
        GLOBAL_TRANSITION{k} = [GLOBAL_TRANSITION{k} m];
    end
end

% Map children for face states
for k = fstate_start:fstate_end
    idx = GLOBAL_XSYS2AUTO_MAP{k};
    children = GLOBAL_AUTOMATON{idx(1)}.interior_region{idx(2)}.state{idx(3)}.children;
    for l = 1:size(children,1)
        GLOBAL_TRANSITION{k} = [GLOBAL_TRANSITION{k} ...
            interior_state_map{children(l,1)}{children(l,2)}{children(l,3)}];
    end
    % add transition to null_event state for the same location
    if GLOBAL_AUTOMATON{idx(1)}.interior_region{idx(2)}.state{idx(3)}.null_event == 1
        GLOBAL_TRANSITION{k} = [GLOBAL_TRANSITION{k} ne_start+idx(1)-1];
    end
    % add transition to time_limit state for the same location
    if GLOBAL_AUTOMATON{idx(1)}.interior_region{idx(2)}.state{idx(3)}.time_limit == 1
        GLOBAL_TRANSITION{k} = [GLOBAL_TRANSITION{k} tl_start+idx(1)-1];
    end
    % add transition to out_of_bound state for the same location
    if GLOBAL_AUTOMATON{idx(1)}.interior_region{idx(2)}.state{idx(3)}.out_of_bound == 1
        GLOBAL_TRANSITION{k} = [GLOBAL_TRANSITION{k} oob_start+idx(1)-1];
    end
    % add transition to indeterminate state for the same location
    if GLOBAL_AUTOMATON{idx(1)}.interior_region{idx(2)}.state{idx(3)}.indeterminate == 1
        GLOBAL_TRANSITION{k} = [GLOBAL_TRANSITION{k} ind_start+idx(1)-1];
    end
    % add transition to non-reachable state for the same location
    if GLOBAL_AUTOMATON{idx(1)}.interior_region{idx(2)}.state{idx(3)}.non_reachable == 1
        GLOBAL_TRANSITION{k} = [GLOBAL_TRANSITION{k} nr_start+idx(1)-1];
    end
    % add transition to terminal FSM state
    terminal = GLOBAL_AUTOMATON{idx(1)}.interior_region{idx(2)}.state{idx(3)}.terminal;
    for l = 1:length(terminal)
        m = find_terminal_state(terminal{l},tm_start);
        if isempty(m)
            m = create_terminal_state(terminal{l});
        end
        GLOBAL_TRANSITION{k} = [GLOBAL_TRANSITION{k} m];
    end
end

% Generate the REVERSE transition system for GLOBAL_TRANSITION (reverse
% all the arrows in GLOBAL_TRANSITION).
GLOBAL_REV_TRANSITION = revtran(GLOBAL_TRANSITION);

