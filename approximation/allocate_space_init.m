function [init_state_map, istate_start, istate_end] = allocate_space_init()
global GLOBAL_PIHA GLOBAL_AUTOMATON GLOBAL_XSYS2AUTO_MAP GLOBAL_TRANSITION
% allocate space for each member in initial state partition
init_state_map = {};
for k=1:length(GLOBAL_PIHA.InitialConditions)
    L0=GLOBAL_PIHA.InitialConditions{k}.initialLocation;
end
for loc_idx = L0
    init_state_map{loc_idx} = {};
    for state_idx = 1:length(GLOBAL_AUTOMATON{loc_idx}.initstate)
        new = length(GLOBAL_XSYS2AUTO_MAP)+1;
        init_state_map{loc_idx}{state_idx} = new;
        GLOBAL_XSYS2AUTO_MAP{new} = [loc_idx state_idx];
        GLOBAL_TRANSITION{new} = [];
    end
end
istate_start = 1;
istate_end = length(GLOBAL_XSYS2AUTO_MAP);