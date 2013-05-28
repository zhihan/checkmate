function add_region(loc,dst_cell)

global GLOBAL_PIHA
global GLOBAL_AUTOMATON

GLOBAL_PIHA.Locations{loc}.interior_cells=[GLOBAL_PIHA.Locations{loc}.interior_cells dst_cell];
if isfield(GLOBAL_AUTOMATON{loc},'interior_region')
    size=length(GLOBAL_AUTOMATON{loc}.interior_region)+1;
else
    size=1;
end
INV=return_invariant(dst_cell);
GLOBAL_AUTOMATON{loc}.interior_region{size}.state{1}.polytope=INV;
GLOBAL_AUTOMATON{loc}.interior_region{size}.state{1}.mapping = {};
GLOBAL_AUTOMATON{loc}.interior_region{size}.state{1}.children = [];
GLOBAL_AUTOMATON{loc}.interior_region{size}.state{1}.null_event = -1;
GLOBAL_AUTOMATON{loc}.interior_region{size}.state{1}.time_limit = -1;
GLOBAL_AUTOMATON{loc}.interior_region{size}.state{1}.out_of_bound = -1;
GLOBAL_AUTOMATON{loc}.interior_region{size}.state{1}.indeterminate = 0;
GLOBAL_AUTOMATON{loc}.interior_region{size}.state{1}.non_reachable = 1;
GLOBAL_AUTOMATON{loc}.interior_region{size}.state{1}.terminal = {};
GLOBAL_AUTOMATON{loc}.interior_region{size}.state{1}.visited  = 0;

fprintf(['\n\n New region added to PIHA considering' ...
    'guard region %d as an interior region for location %d.\n'], ...
    dst_cell,loc);

return
