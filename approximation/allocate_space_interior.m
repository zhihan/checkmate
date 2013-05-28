function [interior_state_map, fstate_start, fstate_end] = allocate_space_interior(istate_end)
global GLOBAL_AUTOMATON GLOBAL_XSYS2AUTO_MAP GLOBAL_TRANSITION
% allocate space for each member in invariant face partitions
interior_state_map = {};
for loc_idx = 1:length(GLOBAL_AUTOMATON)
    interior_state_map{loc_idx} = {};
    if ~isempty(GLOBAL_AUTOMATON{loc_idx})
        for interior_idx = 1:length(GLOBAL_AUTOMATON{loc_idx}.interior_region)
            interior_state_map{loc_idx}{interior_idx} = {};
            for state_idx = 1:length(GLOBAL_AUTOMATON{loc_idx}.interior_region{interior_idx}.state)
                new = length(GLOBAL_XSYS2AUTO_MAP)+1;
                interior_state_map{loc_idx}{interior_idx}{state_idx} = new;
                GLOBAL_XSYS2AUTO_MAP{new} = [loc_idx interior_idx state_idx];
                GLOBAL_TRANSITION{new} = [];
            end
        end
    end
end
fstate_start = istate_end+1;
fstate_end = length(GLOBAL_XSYS2AUTO_MAP);
