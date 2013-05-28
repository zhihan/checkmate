function box = grow_polytope_for_iautobuild(CE,dE,CI,dI,tmp)

%This function will 'grow' a polytope that has a dimension less than n. 
%The 'sizetol' parameter that is specified by the user in the parameter m-file
%is used as the size to grow the polytope.  If this parameter is not specified,
%then the default of 1e-4 is used.

global GLOBAL_AUTOMATON
global GLOBAL_APPROX_PARAM

delta = GLOBAL_APPROX_PARAM.grow_size;

CI = [CE; -CE; CI];
dI = [dE+delta; -dE + delta; dI];
    
state_region=GLOBAL_AUTOMATON{tmp(1)}.interior_region{tmp(2)}.state{tmp(3)}.polytope;

[d,c,CI_state,dI_state]=linearcon_data(state_region);

box=linearcon(d,c,[CI ; CI_state],[dI ; dI_state]);
box=clean_up(box);

return