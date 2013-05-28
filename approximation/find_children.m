function [mapping_region, destination] = find_children(loc, state_idx, cell, first)
% FIND_CHILDREN find the destination mapping and added the mapping state to
% the global structure
%
% Example
%
%   [mapping_region, destination] = find_children(loc, state_idx, cell, ...
%   first)
%
%
global GLOBAL_AUTOMATON GLOBAL_PIHA
if first
    fprintf('initial state in location %d cell region %d.\n',loc,cell);
    mapping_region = GLOBAL_AUTOMATON{loc}.initstate{state_idx}.mapping;

    destination = GLOBAL_AUTOMATON{loc}.initstate{state_idx}.destination;
    null_event = GLOBAL_AUTOMATON{loc}.initstate{state_idx}.null_event;
    time_limit = GLOBAL_AUTOMATON{loc}.initstate{state_idx}.time_limit;
    out_of_bound = GLOBAL_AUTOMATON{loc}.initstate{state_idx}.out_of_bound;
    terminal = GLOBAL_AUTOMATON{loc}.initstate{state_idx}.terminal;
else
    [dum1,dum2,cell_idx]=intersect(cell,GLOBAL_PIHA.Locations{loc}.interior_cells);
    mapping_region = GLOBAL_AUTOMATON{loc}.interior_region{cell_idx}.state{state_idx}.mapping;

    destination = GLOBAL_AUTOMATON{loc}.interior_region{cell_idx}.state{state_idx}.destination;
    null_event = GLOBAL_AUTOMATON{loc}.interior_region{cell_idx}.state{state_idx}.null_event;
    time_limit = GLOBAL_AUTOMATON{loc}.interior_region{cell_idx}.state{state_idx}.time_limit;
    out_of_bound = GLOBAL_AUTOMATON{loc}.interior_region{cell_idx}.state{state_idx}.out_of_bound;
    terminal = GLOBAL_AUTOMATON{loc}.interior_region{cell_idx}.state{state_idx}.terminal;
    fprintf(1,'in location %d cell region %d.\n',loc,cell);
end

if isempty(mapping_region) && null_event<=0 && time_limit<=0 ...
        && out_of_bound<=0 && isempty(terminal)
    [destination,null_event,time_limit,out_of_bounds,terminal] = ...
        compute_mapping(X0, loc,cell);
    [dum1,dum2,cell_idx]=intersect(cell,GLOBAL_PIHA.Locations{loc}.interior_cells);
    if (~first)  %if not dealing with initstate
        if null_event
            GLOBAL_AUTOMATON{loc}.interior_region{cell_idx}.state{state_idx}.null_event=1;
        end
        if time_limit
            GLOBAL_AUTOMATON{loc}.interior_region{cell_idx}.state{state_idx}.time_limit=1;
        end
        if out_of_bounds
            GLOBAL_AUTOMATON{loc}.interior_region{cell_idx}.state{state_idx}.out_of_bound=1;
        end
        if ~isempty(terminal)
            GLOBAL_AUTOMATON{loc}.interior_region{cell_idx}.state{state_idx}.terminal=terminal;
        end
    else
        if null_event
            GLOBAL_AUTOMATON{loc}.initstate{state_idx}.null_event=1;
        end
        if time_limit
            GLOBAL_AUTOMATON{loc}.initstate{state_idx}.time_limit=1;
        end
        if out_of_bounds
            GLOBAL_AUTOMATON{loc}.initstate{state_idx}.out_of_bound=1;
        end
        if ~isempty(terminal)
            GLOBAL_AUTOMATON{loc}.initstate{state_idx}.terminal=terminal;
        end
    end
end