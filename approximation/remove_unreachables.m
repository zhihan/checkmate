function remove_unreachables()

% Remove states that are unreachable from the initial states in the
% current approximating automaton.
%
% Syntax:
%   "remove_unreachables"
%
% Description:
%   Remove states that are unreachable from the initial states in
%   "GLOBAL_AUTOMATON". Store the intermediate result in
%   "GLOBAL_NEW_AUTOMATON" and put the final result back in
%   "GLOBAL_AUTOMATON" when the removal process is complete.
%
% Implementation:
%   The computation of the reachable states is performed on the generic
%   transition system "GLOBAL_TRANSITION" obtained from "GLOBAL_AUTOMATON"
%   by calling the function "auto2xsys". The links between states in
%   "GLOBAL_AUTOMATON" and "GLOBAL_TRANSITION" are maintained in the global
%   variable "GLOBAL_AUTO2XSYS_MAP". Copy all reachable states in
%   "GLOBAL_AUTOMATON" to "GLOBAL_NEW_AUTOMATON", skipping all unreachable
%   states. The `initial` states in "GLOBAL_AUTOMATON" are always copied
%   because they are reachable by default. The `interior_region` state index in
%   "GLOBAL_NEW_AUTOMATON" may be different the state index for the same
%   state in "GLOBAL_AUTOMATON" as some states may have been removed. The
%   link between states in "GLOBAL_AUTOMATON" and "GLOBAL_AUTOMATON" are
%   maintained in "GLOBAL_RAUTO_FACE_MAP" where
%
%   * "GLOBAL_RAUTO_FACE_MAP{loc}{interior_region}{old_state} = [new_state]", if the
%     state "old_state" on interior_region "interior_region" in location "loc" in "GLOBAL_AUTOMATON"
%     has become the state "new_state" on the same interior_region in the same location
%     in "GLOBAL_NEW_AUTOMATON".
%
%   * "GLOBAL_RAUTO_FACE_MAP{loc}{interior_region}{old_state} = []", if the state
%     "old_state" on interior_region "interior_region" in location "loc" in "GLOBAL_AUTOMATON" has
%     been removed.
%
%   Update the children (destination) state indices for each state in
%   "GLOBAL_NEW_AUTOMATON" after the removals by calling the function
%   "update_children". Copy "GLOBAL_NEW_AUTOMATON" back into
%   "GLOBAL_AUTOMATON" and call "auto2xsys" to update "GLOBAL_TRANSITION" to
%   reflect the automaton obtained after the state removals.
%
% See Also:
%   verify,auto2xsys,global_var,get_auto_state,set_auto_state,region

% input global variables
global GLOBAL_PIHA
global GLOBAL_AUTOMATON
global GLOBAL_AUTO2XSYS_MAP

% output global variables
global GLOBAL_NEW_AUTOMATON    % Approximating automaton with unreachable
% states removed from GLOBAL_AUTOMATON.
global GLOBAL_RAUTO_FACE_MAP   % state map from interior_region states in
% GLOBAL_AUTOMATON to interior_region states in
% GLOBAL_NEW_AUTOMATON

% Compute the set of reachable states from the set of initial states.
reachables = reach(init_states);

GLOBAL_NEW_AUTOMATON = {};
GLOBAL_RAUTO_FACE_MAP = {};

% Copy initial states over.
for loc = GLOBAL_PIHA.InitialLocation_Cells(:,1)
    GLOBAL_NEW_AUTOMATON{loc}.initstate = GLOBAL_AUTOMATON{loc}.initstate;
end

% Copy only the reachable states from GLOBAL_AUTOMATON to
% GLOBAL_NEW_AUTOMATON.
for loc = 1:length(GLOBAL_AUTOMATON)
    GLOBAL_NEW_AUTOMATON{loc}.interior_region = {};
    GLOBAL_RAUTO_FACE_MAP{loc} = {};
    for interior_region = 1:length(GLOBAL_AUTOMATON{loc}.interior_region)
        GLOBAL_NEW_AUTOMATON{loc}.interior_region{interior_region}.state = {};
        GLOBAL_RAUTO_FACE_MAP{loc}{interior_region} = {};
        for state = 1:length(GLOBAL_AUTOMATON{loc}.interior_region{interior_region}.state)
            % find the corresponding index in GLOBAL_TRANSITION for the interior_region
            % state "state" on interior_region "interior_region" in location "loc"
            XSYSidx = GLOBAL_AUTO2XSYS_MAP.interior_state_map{loc}{interior_region}{state};
            % remove this state if it is not reachable
            if isinregion(reachables,XSYSidx)
                temp = GLOBAL_AUTOMATON{loc}.interior_region{interior_region}.state{state};
                new = length(GLOBAL_NEW_AUTOMATON{loc}.interior_region{interior_region}.state)+1;
                GLOBAL_NEW_AUTOMATON{loc}.interior_region{interior_region}.state{new} = temp;
                GLOBAL_RAUTO_FACE_MAP{loc}{interior_region}{state} = new;
            else
                % clc
                fprintf(1,'removing location %d : interior region %d : state %d\n', ...
                    loc,interior_region,state)
                drawnow
                GLOBAL_RAUTO_FACE_MAP{loc}{interior_region}{state} = [];
            end
        end
    end
end

% Update children for each state where each child state (which must be a
% interior_region state) is mapped from the old index in GLOBAL_AUTOMATON to the new
% index for GLOBAL_NEW_AUTOMATON.

for l = GLOBAL_PIHA.InitialLocation_Cells(:,1)
    for s = 1:length(GLOBAL_NEW_AUTOMATON{l}.initstate)
        GLOBAL_NEW_AUTOMATON{l}.initstate{s}.children = update_children(...
            GLOBAL_NEW_AUTOMATON{l}.initstate{s}.children);
    end
end

for l = 1:length(GLOBAL_NEW_AUTOMATON)
    for f = 1:length(GLOBAL_NEW_AUTOMATON{l}.interior_region)
        for s = 1:length(GLOBAL_NEW_AUTOMATON{l}.interior_region{f}.state)
            GLOBAL_NEW_AUTOMATON{l}.interior_region{f}.state{s}.children = update_children(...
                GLOBAL_NEW_AUTOMATON{l}.interior_region{f}.state{s}.children);
        end
    end
end

GLOBAL_AUTOMATON = GLOBAL_NEW_AUTOMATON;
GLOBAL_NEW_AUTOMATON = {};
auto2xsys;
return

% -----------------------------------------------------------------------------

function children_new = update_children(children)

global GLOBAL_RAUTO_FACE_MAP

children_new = [];
for k = 1:size(children,1)
    loc = children(k,1);
    interior_region = children(k,2);
    state = children(k,3);
    map = GLOBAL_RAUTO_FACE_MAP{loc}{interior_region}{state};
    for l = 1:length(map)
        children_new = [children_new; loc interior_region map(l)];
    end
end
