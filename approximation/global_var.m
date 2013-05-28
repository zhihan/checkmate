% An m-file script that declares global variables used in the verification
% procedure in CheckMate.
%
% Syntax:
%   "global_var"
%
% Description:
%   CheckMate uses global variables to store the verification progress so
%   that the process can be stopped (by pressing ctrl+c) and resumed
%   afterwards. 
%
% User Specified Global Variables:
%
%   * "GLOBAL_SYSTEM": name of the Simulink Model to be verified
%
%   * "GLOBAL_APARAM": name of the function file that returns the
%     user specified approximation parameters as a function of the
%     composite FSM states.
%
%   * "GLOBAL_SPEC": string containing the ACTL specification
%
% Verification Global Variables:
%
%   * "GLOBAL_ITERATION": verification iteration counter
%
%   * "GLOBAL_PROGRESS": record of verification progress
%
%   * "GLOBAL_PIHA": `polyhedral-invariant hybrid automaton (PIHA)`
%     converted from the Simulink model
%
%   * "GLOBAL_AUTOMATON": data struture for the current `approximating
%     automaton` (or `quotient transition system`) 
%
%   * "GLOBAL_TRANSITION": generic `transition system` obtained by
%     flattening "GLOBAL_AUTOMATON"
%
%   * "GLOBAL_REV_TRANSITION": `reverse` transition system of
%     "GLOBAL_TRANSITION"
%
%   * "GLOBAL_AUTO2XSYS_MAP": data structure containing state mapping from
%     "GLOBAL_AUTOMATON" to "GLOBAL_TRANSITION"
%
%   * "GLOBAL_XSYS2AUTO_MAP": data structure containing state mapping from
%     "GLOBAL_TRANSITION" to "GLOBAL_AUTOMATON"
%
%   * "GLOBAL_SPEC_TREE": `parse tree` for the ACTL specification
%
%   * "GLOBAL_AP_BUILD_LIST": list of `atomic propositions` to be built
%
%   * "GLOBAL_AP": a structure with fields containing the sets of states
%     ("region" objects) in "GLOBAL_TRANSITION" that satisfy the atomic
%     propositions
%
%   * "GLOBAL_TBR": the set of states "to-be-refined" in "GLOBAL_TRANSITION"
%
%   * "GLOBAL_NEW_AUTOMATON": new approximating automaton obtained by refining
%     the current approximating automaton "GLOBAL_AUTOMATON"
%
%   * "GLOBAL_RAUTO_REMAP_LIST": lists of the refined states in
%     "GLOBAL_NEW_AUTOMATON" for which the `mapping set` needs to be computed
%
%   * "GLOBAL_RAUTO_FACE_MAP": data structure containing the state mappping
%     from `face` state indices in "GLOBAL_AUTOMATON" to the `face` state
%     indices in "GLOBAL_NEW_AUTOMATON"
%
%   * GLOBAL_TIME_ELAPSED: Data structure containing the time elapsed for
%     each one of the processes in the verification procedure
%
%   * GLOBAL_EXPLORATION: Data structure containing the results from the
%     CheckMate trajectory exploration routine.
%
% See Also:
%   verify,auto2xsys,iauto_build,remove_unreachables,compute_mapping,
%   iauto_part,set_auto_state,find_children,rauto_ischild,flow_reach,
%   rauto_mapping,get_auto_state,rauto_tran,refine_auto,region

global GLOBAL_ITERATION
global GLOBAL_SYSTEM
global GLOBAL_APARAM
global GLOBAL_SPEC
global GLOBAL_PROGRESS
global GLOBAL_PIHA
global GLOBAL_AUTOMATON
global GLOBAL_TRANSITION
global GLOBAL_REV_TRANSITION
global GLOBAL_AUTO2XSYS_MAP
global GLOBAL_XSYS2AUTO_MAP
global GLOBAL_SPEC_TREE
global GLOBAL_AP_BUILD_LIST
global GLOBAL_AP
global GLOBAL_TBR
global GLOBAL_NEW_AUTOMATON
global GLOBAL_RAUTO_REMAP_LIST
global GLOBAL_RAUTO_FACE_MAP
global GLOBAL_TIME_ELAPSED
global GLOBAL_EXPLORATION
global GLOBAL_APPROX_PARAM

% Approximation Parameters (as of 3/15/99): The function file specified by
% GLOBAL_APARAM should return a structure with the following fields as a
% function of the composite FSM state q.  
%     .dir_tol    : tolerance for patch single-sided-ness
%     .var_tol    : tolerance for patch vector field variation relative
%                   to the vector field variation on the parent invariant
%                   face.
%     .size_tol   : tolerance for patch size
%     .W          : (diagonal) weighting matrix
%     .T          : time step for flow pipe computation 
%     .max_time   : time limit (sec) for mapping computation 
%     .eq_tol     : equilibrium termination tolerance for mapping computation