function new = create_terminal_state(q)

global GLOBAL_TRANSITION GLOBAL_XSYS2AUTO_MAP

new = length(GLOBAL_TRANSITION)+1;
% self-loop so that transition relation is total
GLOBAL_TRANSITION{new} = new;
GLOBAL_XSYS2AUTO_MAP{new} = {'terminal' q};
return