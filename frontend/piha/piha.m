function piha(sys)

% Polyhedral invariant hybrid automaton compiler
%
% This compiler uses a modified method to create a PIHA from the switched
% continuous system.  Instead of dividing the entire state space region with
% every hyperplane associated with all of the PTHB's, this method creates a
% partition of the analysis region for each discrete location.  The analysis
% region for each location is then partitioned only with the pthb's that
% are relevant for that location (i.e. only the pthb's which define the guards).
%Also, clock information and reset information are collected and attached
%to the
%transition information.
%
%A location is created for each finite state in the
%Stateflow machine(s).  An interior region is defined for each location.  This interior
%region is a collection of pointers to the structure 'cells' which is a collection
%of convex regions (i.e. so the interior regions are made up of a collection of smaller
%convex regions).
%
%Each location also contains information about each of its 'exiting'
%transitions.  Information about transitions are contained within each 'transition'.
%This information includes:
%
%-'id'	     					the number of the transition (assigned by Stateflow)
%-'expression'					the expression attached to the transition
%-'clock'							the clock number (if there is one)
%-'source'						the source state (identified by the value of 'q')
%-'destination'					the source state (identified by the value of 'q')
%-'destination_name'			the label given to the destination
%-'reset_flag'					set if there is a reset associated with this transition
%-'guard'							pointers to elements in 'cells' that define the guard regions
%-'guard_cell_event_flags'	a matrix where the i'th row is a vector of flags identifying
%									which boundary hyperplane of the i'th guard cell is an event
%									hyperplane
%-'guard_compl'					cells which define the complement of the cells in 'guard'
%
%
%
% Example:
%   "HA = piha(sys)"
%
%    piha help prints the description of a PIHA structure
%
% Description:
%   "piha(sys)" returns a PIHA object.  The returned PIHA object is
%   equivalent to the Simulink CheckMate model "sys" within the analysis
%   region.
%

% "only_condition_inputs_flag" added by JimK (11/2002).  The purpose of the flag
% is to notify "create_guard" if there are only condition inputs into the stateflow
% block.  If this is the case, all edges should be flagged as event edges.

%
% Last change: 11/18/2002 JPK


global GLOBAL_PIHA CELLS 

CELLS={};

if ~ischar(sys)
    error('CheckMate:PIHA','Input argument must be a string.')
end

%=============================================================
%
%=============================================================
if strcmp(sys,'help')
    fid = fopen('@piha/piha_structure.txt');
    while true
        line = fgetl(fid);
        if ~ischar(line), break, end
        fprintf(1,'%s\n',line)
    end
    fclose(fid);
    return
end

% Check the model syntax before performing conversion
if ~check_model_syntax(sys)
    error('CheckMate:PIHA:SyntaxError', ...
        '\007Syntax error, model conversion aborted.\n')
end

% Find Simulink handles for switched continuous system blocks (SCSB),
% finite state machine blocks (FSMB), and polyhedral threshold blocks
% (PTHB) in the CheckMate model.
scsbHandle = find_masked_blocks(sys,'SwitchedContinuousSystem');
fsmbHandle = find_masked_blocks(sys,'Stateflow');
pthbHandle = find_masked_blocks(sys,'PolyhedralThreshold');


% **********************************
% (1) Construct list of hyperplanes.
% **********************************

% Get threshold hyperplanes from the PTHBs in the simulink model.
disp('Compiling threshold hyperplanes.')
NBDHP = {};
for k = 1:length(pthbHandle)
    [Ck,dk] = augment_poly_constraints(scsbHandle,pthbHandle(k));
    pthb{k}.c=Ck;
    pthb{k}.d=dk;
    pthb{k}.hps=[];
    for Idx = 1:length(dk)
        NBDHP{end+1} = struct('pthb', k, 'index', Idx, ...
            'c', Ck(Idx,:), 'd', dk(Idx,:));
    end
end

%Create hyperplane list
AR = get_analysis_region(scsbHandle);
[pthb,NAR]=create_hyperplanes(NBDHP,AR,pthb);


% **************************************************************************
% (3) Build data base for Stateflow blocks that will be used for conversion.
% **************************************************************************



% process sf data
sfdata = process_sf_data(sys, fsmbHandle);
% **************************************************************
% (4) Find initial discrete states for all the Stateflow blocks.
% **************************************************************

% Get initial state id for each Stateflow block, assuming that there is
% only one default transition per machine.
q0 = [];
for k = 1:length(sfdata)
    chart_id = sfdata{k}.StateflowChartID;
    DTid = sf('DefaultTransitionsOf',chart_id);
    q0id = sf('get',DTid,'.dst.id');
    q0(k) = q0id;
end

%**************************************************************
%Create list of locations and all guards for each location
%**************************************************************
locations = create_locations(sfdata, pthb, NAR, fsmbHandle, scsbHandle, pthbHandle);

% **********************************************************************
% (4.1) Reposition the locations to make the initial locations the first ones.
% **********************************************************************

locations = move_initial_location(locations, q0);

% **********************************************************************
% (5) Create lists of blocks for each block type in the CheckMate model.
% **********************************************************************

% (i) Switched continuous system blocks (SCSB)
scsbList = cell(length(scsbHandle),1);
use_sd=0;
for k = 1:length(scsbHandle)
    scsbList{k}.name = get_param(scsbHandle(k),'Name');
    scsbList{k}.nx = eval(get_param(scsbHandle(k),'nx'));
    scsbList{k}.nz = eval(get_param(scsbHandle(k),'nz'));
    scsbList{k}.nup = eval(get_param(scsbHandle(k),'nup'));
    if strcmp(get_param(scsbHandle(k),'use_sd'),'on')
        use_sd=1;
    end
    scsbList{k}.nu = eval(get_param(scsbHandle(k),'nu'));
    scsbList{k}.swfunc = get_param(scsbHandle(k),'swfunc');
    % parametric information
    scsbList{k}.pacs = evalin('base',get_param(scsbHandle(k),'PaCs'));
    scsbList{k}.paradim = length(evalin('base',get_param(scsbHandle(k),'p0')));
    inputfsmb_Handle = trace_scsb_input(scsbHandle(k),'input');

    fsmbindices = [];
    for l = 1:length(inputfsmb_Handle)
        fsmbindices(l) = find(inputfsmb_Handle(l) == fsmbHandle);
    end
    scsbList{k}.fsmbindices = fsmbindices;
end

% (ii) Finite state machine blocks (FSMB)
fsmbList = cell(length(sfdata),1);
for k = 1:length(sfdata)
    chart_id = sfdata{k}.StateflowChartID;
    state_id = sf('find','all','state.chart',chart_id);
    states = {};
    for l = 1:length(state_id)
        state_number = get_state_number(state_id(l));
        states{state_number} = sf('get',state_id(l),'.name');
    end
    fsmbList{k}.name = get_param(sfdata{k}.SimulinkHandle,'Name');
    fsmbList{k}.states = states;
end

% (iii) Polyhedral threshold blocks (PTHB)
pthbList = cell(length(pthbHandle),1);
for k = 1:length(pthbHandle)
    pthbList{k}.name = get_param(pthbHandle(k),'Name');
end

% Finally, replace all Stateflow state id by the enumeration
% given in the label (the entry action) of each state.
for k = 1:length(locations)
    locations{k}.q = get_labeled_state(locations{k}.q);
    for l = 1:length(locations{k}.transitions)
        locations{k}.transitions{l}.destination = ...
            get_labeled_state(locations{k}.transitions{l}.destination);
        locations{k}.transitions{l}.source=...
            get_labeled_state(locations{k}.transitions{l}.source);

    end
end

%*************************************************************************************
%Find inital regions and initial states
%*************************************************************************************

% Get initial continuous set from the parameter block
X0 = get_initial_continuous_set(scsbHandle);

% Identify initial cells from intersection with initial continuous set X0.
% P0 contains all indices (to SSTREE) for the leaf nodes corresponding
% to initial cells.
P0 = [];
for k = 1:length(X0)
    test=find_initial_cells(X0{k},locations{1},AR);
    if ~isempty(test)
        P0 = union(P0,test);
    end
end

L0=[ones(length(P0),1) P0'];
for location_counter=1:length(locations)
    locations{location_counter}.orig_interior_cells=locations{location_counter}.interior_cells;
end

[initial_conditions , locations] = find_initial_conditions(X0,locations);

% Conversion completed, return the PIHA object.
% GLOBAL_PIHA.Hyperplanes should already be assigned.  Assign
% everything else here.
GLOBAL_PIHA.NAR                  = NAR;
GLOBAL_PIHA.InitialContinuousSet = X0;
GLOBAL_PIHA.InitialDiscreteSet   = {get_labeled_state(q0)};
GLOBAL_PIHA.Cells                = CELLS;
GLOBAL_PIHA.InitialCells         = P0;
GLOBAL_PIHA.Locations            = locations;
GLOBAL_PIHA.InitialConditions    = initial_conditions;
GLOBAL_PIHA.InitialLocation_Cells= L0;
GLOBAL_PIHA.CLOCKBlocks				= {}; % removed clocklist
GLOBAL_PIHA.SCSBlocks            = scsbList;
GLOBAL_PIHA.PTHBlocks            = pthbList;
GLOBAL_PIHA.FSMBlocks            = fsmbList;
GLOBAL_PIHA.use_sd               = use_sd;

disp('PIHA conversion successful.')
return


