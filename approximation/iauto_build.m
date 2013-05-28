function iauto_build(continu)

% Build the initial `approximating automaton` given the initial partition
% of the initial continuous set and the invariant faces.
%
% Syntax:
%   "iauto_build(continu)"
%
% Description:
%   Compute the transitions for the states in the initial approximation
%   automaton using `flow pipe approximations` iteratively. The inputs to
%   this function are
%
%   * "continu": a flag indicating whether the CheckMate verification
%     step implemented in this function should be started from scratch or
%     continud from the last break point.
%
% Implementation:
%   The progress of this function is saved in the global variable
%   "GLOBAL_PROGRESS". For this function, "GLOBAL_PROGRESS" has a single
%   field ".step", which is always set to "'iauto_build'" for the CheckMate
%   verification step implemented in this function.
%
%   The transitions in the initial automaton (stored in the global variable
%   "GLOBAL_AUTOMATON") are computed iteratively as follows. In each
%   iteration, the set of reachable states are computed (the computation of
%   the reachable set in the function "reach" is performed on the generic
%   transition system "GLOBAL_TRANSITION" obtained from "GLOBAL_AUTOMATON"
%   using the function "auto2xsys"). The `mapping set` is computed using the
%   function "compute_mapping" for each newly reachable state. The mapping
%   set is then used to define the transitions (the destination states) for
%   each state in the function "find_children". After the transitions for
%   all reachable states are defined, recompute the set of reachable states
%   and repeat the process until no new reachable state is found. Finally,
%   set the "indeterminate" flag for all unreachable states. This iterative
%   process is used so that the mapping set computations, which are
%   extremely expensive, will not wasted on the states that are not
%   reachable.
%
% See Also:
%   iauto_part,compute_mapping,find_children,auto2xsys,region,reach

global GLOBAL_PROGRESS GLOBAL_AUTOMATON GLOBAL_PIHA

if continu
    if ~ismember(GLOBAL_PROGRESS.step,{'iauto_build'})
        error('CheckMate:IAutoBuild:WrongStep' , ['Inconsistent continuous step ''' GLOBAL_PROGRESS.step ...
            ''' (expected ''iauto_build'').'])
    end
else
    temp.step = 'iauto_build';
    GLOBAL_PROGRESS = temp;
end
   
for number_of_locations = 1:length(GLOBAL_PIHA.InitialConditions)
    location_value =GLOBAL_PIHA.InitialConditions{number_of_locations}.initialLocation;
    for state_number = 1:length(GLOBAL_AUTOMATON{location_value}.initstate)
        cell=GLOBAL_AUTOMATON{location_value}.initstate{state_number}.cell;
        
        assign_children(GLOBAL_AUTOMATON{location_value}.initstate{state_number}.polytope,...
            state_number,location_value,cell);

     
    end%for
end%for


auto2xsys;

return


