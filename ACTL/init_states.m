function init = init_states()

% Compute "region" object corresponding to the set of `initial states` in
% the global transition system.
%
% Syntax:
%   "init = init_states"
%
% Description:
%   Returns in the "region" object "init" the set of states in the
%   transition system "GLOBAL_TRANSITION" that corresponds to the initial
%   state in "GLOBAL_AUTOMATON". Both "GLOBAL_TRANSITION" and
%   "GLOBAL_AUTOMATON" are global variables. See help on "auto2xsys.m" for
%   the correspondence between states in "GLOBAL_AUTOMATON" and states in
%   "GLOBAL_TRANSITION".
%
% See Also:
%   region,auto2xsys

global_var;
range = GLOBAL_AUTO2XSYS_MAP.init_state_range;
init = region(length(GLOBAL_TRANSITION),range(1):range(2));
return
