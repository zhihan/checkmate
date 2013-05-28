function [ne_start, tl_start, oob_start, ind_start, nr_start] =...
    allocate_space_terminal()
global GLOBAL_XSYS2AUTO_MAP GLOBAL_AUTOMATON GLOBAL_TRANSITION

% allocate "null_event" state for each location
ne_start = length(GLOBAL_XSYS2AUTO_MAP)+1;
for k = 1:length(GLOBAL_AUTOMATON)
    new = length(GLOBAL_XSYS2AUTO_MAP)+1;
    GLOBAL_XSYS2AUTO_MAP{new} = {'null_event' k};
    % self-loop so that transition relation is total
    GLOBAL_TRANSITION{new} = new;
end

% allocate "time_limit" state for each location
tl_start = length(GLOBAL_XSYS2AUTO_MAP)+1;
for k = 1:length(GLOBAL_AUTOMATON)
    new = length(GLOBAL_XSYS2AUTO_MAP)+1;
    GLOBAL_XSYS2AUTO_MAP{new} = {'time_limit' k};
    % self-loop so that transition relation is total
    GLOBAL_TRANSITION{new} = new;
end

% allocate "out_of_bound" state for each location
oob_start = length(GLOBAL_XSYS2AUTO_MAP)+1;
for k = 1:length(GLOBAL_AUTOMATON)
    new = length(GLOBAL_XSYS2AUTO_MAP)+1;
    GLOBAL_XSYS2AUTO_MAP{new} = {'out_of_bound' k};
    % self-loop so that transition relation is total
    GLOBAL_TRANSITION{new} = new;
end

% allocate "indeterminate" state for each location
ind_start = length(GLOBAL_XSYS2AUTO_MAP)+1;
for k = 1:length(GLOBAL_AUTOMATON)
    new = length(GLOBAL_XSYS2AUTO_MAP)+1;
    GLOBAL_XSYS2AUTO_MAP{new} = {'indeterminate' k};
    % self-loop so that transition relation is total
    GLOBAL_TRANSITION{new} = new;
end

% allocate "non_reachable" state for each location
nr_start = length(GLOBAL_XSYS2AUTO_MAP)+1;
for k = 1:length(GLOBAL_AUTOMATON)
    new = length(GLOBAL_XSYS2AUTO_MAP)+1;
    GLOBAL_XSYS2AUTO_MAP{new} = {'non_reachable' k};
    % self-loop so that transition relation is total
    GLOBAL_TRANSITION{new} = new;
end

