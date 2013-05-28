function iauto_part()

% Compute initial partition for the initial `approximating automaton`
% according to the user specified parameters.
%
% Syntax:
%   "iauto_part()"
%
% Description:
%   Compute the initial partition for the initial approximating automaton
%   and create the skeleton for the approximating automaton in the global
%   variable "GLOBAL_AUTOMATON".
%
% Implementation:
%
%   The approximating automaton "GLOBAL_AUTOMATON" is a discretization of
%   "GLOBAL_PIHA" with a few special states added to each
%   location. "GLOBAL_AUTOMATON" is a cell array in which each element
%   corresponds to a location in "GLOBAL_PIHA". Each element
%   "GLOBAL_AUTOMATON{l}" is a structure containing the following fields
%   for the location "l".
%
%   * ".initstate": a cell array of states representing to the
%     discretization of `initial continuous set` for each location
%
%   * ".face": a cell array of the same length as the number of the
%     invariant faces for the location "l"
%
%   The field ".face" is also a structure with a single field ".state" where
%
%   * ".face{f}.state": is a cell array of states representing the
%     discretization of face "f" of the the invariant polytope for location "l"
%
%   States under the ".initstate" field are referred to as `initial states`
%   and states under the ".face" field are referred to as `face
%   states`. Each state is a structure with the following fields.
%
%   * ".polytope": Continuous set for this state.
%
%   * ".mapping": The `mapping set` from the polytope.
%
%   * ".children": Indices to destination `face` states.
%
%   * ".null_event": A boolean flag indicating whether there exists a
%     trajectory from the polytope for this state that never leaves the
%     invariant
%
%   * ".time_limit": A boolean flag indicating wheter the mapping computation
%     is terminated by the user specified time limit in which case the
%     computed mapping set may not contain all possible reachable states.
%
%   * ".out_of_bound": A boolean flag indicating whether part of the mapping
%     computed goes out of analysis region.
%
%   * ".indeterminate": A boolean flag. If set, it indicates that further
%     evolutions of the system from this state cannot be determined. Reasons
%     maybe that polytope for this state contains singularities so that
%     mapping cannot be computed. This flag is typically be set manually by
%     user. CheckMate also set this flag to 1 for those states that are
%     not reachable from the initial states to save computation time.
%
%   * ".terminal": A cell array containing the list of FSM terminal state
%     vectors, i.e. the FSM state for which there is no outgoing transition
%     from any of the component states, that a reachable from the polytope
%     for this state.
%
% Implementation:
%   The polytopes in the initial continuous set are intersected with the
%   invariant polytope and discretized to form the `initial states` for each
%   location. The polytopes of dimension "n-1" are partitioned further in
%   the exact same way as the invariant faces (see below). Currently,
%   polytopes of all other dimensions are not partitioned
%   further. Partitioning procedure for these polytopes are to left for
%   future work. After the partitioning is done, each polytope in the
%   partition is entered as a state under the field ".initstate" in the
%   parent location.
%
%
%
%   Faces of the invariant polytope are partitioned to form `face states` for
%   each location. Each face of the invariant is used as the starting point
%   for the partition. The partitioning scheme depends on the type of the
%   continuous dynamics in each location (see the source code). After the
%   partitioning is done, each polytope in the partition is entered as a
%   state under the parent face and location in "GLOBAL_AUTOMATON".
%
%
%
%   Finally, the reachability analysis is performed for the polytopes
%   associated with all `initial states` using the function "flow_reach",
%   which computes the set of reachable polytopes from the initial
%   poltyope. We use each reachable polytope to refine the partition of the
%   invariant face which that reachable polytope is on further by spliting
%   each poltope in the partition into the part that overlaps with the
%   reachable polytope (the intersection) and the part does not overlap with
%   the reachable polytope (the set difference).
%
% See Also:
%   verify,flow_reach

% input global variable
global GLOBAL_PIHA

% output global variable
global GLOBAL_AUTOMATON

GLOBAL_AUTOMATON = cell(length(GLOBAL_PIHA.Locations),1);
% GLOBAL_AUTOMATON is a discretization of GLOBAL_PIHA with a few special
% states added to each location

% There are two types of states for each location
%   .initstate     : discretization of initial continuous set for each
%                    location
%   .face{i}.state : discretization of ith invariant face for each location
%
% Each state has the following components
%   .polytope      : Continuous set for this state.
%   .mapping       : Continuous mapping computed from polytope.
%   .children      : Destination states.
%   .null_event    : There exists trajectories that never triggers any
%                    further event from the polytope for this state.
%   .time_limit    : Mapping computation terminated by time limit so the
%                    the mapping may not contain all states in mapping set.
%   .out_of_bound  : Part of the mapping computed goes out of analysis
%                    region.
%   .indeterminate : Cannot determine further evolution of the system from
%                    this state. Reasons maybe that polytope for this state
%                    contains singularities so that mapping cannot be
%                    computed. This flag must be set manually by user.
%   .non_reachable : This state wasn't reached during initial partition
%							computation. If some state leads to this state it won't
%							be considered in the reachability analysis, since
%							it could have happened due to numerical imprecision.
%
%   null_event,time_limit,out_of_bound,indeterminate are boolean flags.
%
%   .terminal      : If there exists a trajectory from the polytope for this
%                    state that causes the FSM to switch to a terminal
%                    FSM state q', i.e the FSM state for which there is no
%                    outgoing transition from any of the component states,
%                    then the cell array .terminal contains q', otherwise it
%                    is empty.

% Initialize initial states for each initial location
%X0 = GLOBAL_PIHA.InitialContinuousSet;
%GLOBAL_AUTOMATON{1}.initstate={};

%Get flag which decides if initial reachability is to be performed or not.

global GLOBAL_APPROX_PARAM
approx_param = GLOBAL_APPROX_PARAM;

init_reach = approx_param.perform_init_reachability;

IC = GLOBAL_PIHA.InitialConditions;
for i=1: length(IC)
    GLOBAL_AUTOMATON{IC{i}.initialLocation}.initstate={};
    X0 =GLOBAL_PIHA.InitialContinuousSet{i};
    init_loc = IC{i}.initialLocation;
    init_cell = IC{i}.initialCells;
    INV = return_init_region(init_cell);

    overall_dynamics = check_overall_dynamics(GLOBAL_PIHA.SCSBlocks, ...
        GLOBAL_PIHA.Locations{init_loc}.q);
    if strcmp(overall_dynamics,'linear')
        [A,b] = overall_system_matrix(GLOBAL_PIHA.SCSBlocks, ...
            GLOBAL_PIHA.Locations{init_loc}.q);
    end
    initstate = {};
    if issubset(X0,INV)
        polytope = X0;
    else
        polytope = X0&INV;
    end;
    if ~isempty(polytope)
        [CE,dE] = linearcon_data(polytope);
        if (length(dE) == 1)
            % if n-1 dimensional patch
            patch = polytope;
            switch overall_dynamics

                case 'linear',
                    % First partition the patch into 2 subpatches according to
                    % the direction of the vector field (in/out of invariant). Then
                    % partition further using tolerances.
                    partition = linear_partition(patch,A,b, ...
                        GLOBAL_PIHA.Locations{init_loc}.q);

                case 'nonlinear',
                    partition = nonlinear_partition(patch,GLOBAL_PIHA.SCSBlocks, ...
                        GLOBAL_PIHA.Locations{init_loc}.q);

                case 'clock',
                    % Since there is no variation in vector field, only the size
                    % tolerance is used.
                    partition = clock_partition(patch);

                otherwise,
                    error('CheckMate:IAutoPart:UnknownType',['Unknown overall system dynamics ''' ...
                        overall_dynamics '''.'])

            end%case

        else
            % partition to be coded later for full dimensional X0, do nothing
            % for now
            partition = {polytope};

        end%if


        for m = 1:length(partition)
            initstate.polytope = partition{m};
            initstate.mapping = {};
            initstate.children = [];
            initstate.null_event = -1;
            initstate.time_limit = -1;
            initstate.out_of_bound = -1;
            initstate.indeterminate = 0;
            initstate.non_reachable = 0;
            initstate.terminal = {};
            initstate.visited  = 0;
            initstate.cell=init_cell;
            initstate.destination = {};
            GLOBAL_AUTOMATON{init_loc}.initstate{end+1} = initstate;
        end%for m
    end%if length
end %if ~isempty

%There will be an 'initstate' in  GLOBAL_AUTOMATON for every location and Cell location
%in GLOBAL_AUTOMATON.InitialConditions.
% Initialize partition for invariant faces in each location
for k = 1:length(GLOBAL_PIHA.Locations)
    entry_region =cell(length(partition),1);
    for m = 1:length(GLOBAL_PIHA.Locations{k}.interior_cells)
        partition=return_region(GLOBAL_PIHA.Locations{k}.interior_cells(m));
        % >>>>>>>>>>>> Initial Partition -- DJ -- 06/30/03 <<<<<<<<<<<<
        % There are a set of states. One corresponds
        % to interior region and others are boundary states.
        % The for-loop is added by Dong Jia to initialize information for all states.
        for l=1:length(partition)
            entry_region{m}.state{l}.polytope = partition{l};
            entry_region{m}.state{l}.mapping = {};
            entry_region{m}.state{l}.children = [];
            entry_region{m}.state{l}.null_event = -1;
            entry_region{m}.state{l}.time_limit = -1;
            entry_region{m}.state{l}.out_of_bound = -1;
            entry_region{m}.state{l}.indeterminate = 0;
            entry_region{m}.state{l}.non_reachable = 1;
            entry_region{m}.state{l}.terminal = {};
            entry_region{m}.state{l}.visited  = 0;
            entry_region{m}.state{l}.split = 0;
            % >>>>>>>>>>>> Adding Field destination (states) -- DJ -- 06/30/03 <<<<<<<<<<<<
            % The field destination is add to record the reachability results.
            % Added by Dong Jia
            entry_region{m}.state{l}.destination = {};
            % >>>>>>>>>>>> -------------- end (Adding Field destination (states)) --------------- <<<<<<<<<<<<
        end
        % >>>>>>>>>>>> -------------- end (Initial Partition) --------------- <<<<<<<<<<<<
    end
    if isempty(entry_region)
        GLOBAL_AUTOMATON{k} = [];
    else
        GLOBAL_AUTOMATON{k}.interior_region = entry_region;
    end
end
fprintf(1,'\n')
if init_reach
    % Refine partition for invariant faces in each location further using
    % reachability analysis.
    for m = 01:length(GLOBAL_PIHA.InitialConditions)
        % Compute sequence of reachable polytopes for each initial state
        init_loc = GLOBAL_PIHA.InitialConditions{m}.initialLocation;
        init_cell=GLOBAL_PIHA.InitialConditions{m}.initialCells;
        for n=1:length(GLOBAL_AUTOMATON{init_loc}.initstate)
            fprintf(1,'Reachability analysis for loc %d , Cell region %d initial state %d:\n',init_loc,init_cell,n)
            [reachable,time_limit] = ...
                flow_reach(GLOBAL_AUTOMATON{init_loc}.initstate{n}.polytope,init_loc,init_cell);
            % Intersect (subtract) each reachable polytope with (from) all states
            % on the same face.
            % Skip the first state in the reachable set which is always an
            % initial state.
            GLOBAL_AUTOMATON{init_loc}.initstate{n}.time_limit = time_limit;
            GLOBAL_AUTOMATON{init_loc}.initstate{n}.mapping = reachable(1).mapping;
            % >>>>>>>>>>>> Recording Reachability Results (initial state) -- DJ -- 06/30/03 <<<<<<<<<<<<
            % Recording the reachability results for the initial state.
            % Added by Dong Jia to record complet information from
            % reachability analysis
            GLOBAL_AUTOMATON{init_loc}.initstate{n}.destination=reachable(1).destination;
            GLOBAL_AUTOMATON{init_loc}.initstate{n}.null_event=reachable(1).null_event;
            GLOBAL_AUTOMATON{init_loc}.initstate{n}.time_limit=reachable(1).time_limit;
            GLOBAL_AUTOMATON{init_loc}.initstate{n}.out_of_bound=reachable(1).out_of_bound;
            GLOBAL_AUTOMATON{init_loc}.initstate{n}.terminal=reachable(1).terminal;
            % >>>>>>>>>>>> -------------- end (Recording Reachability Results (initial state)) --------------- <<<<<<<<<<<<

            fprintf(1,'\n Finished preliminary reachability analysis. \n');
            % save reachable_data reachable;
            prel_refine(reachable);
        end %for n
    end % for m
end %if init_reach

return

