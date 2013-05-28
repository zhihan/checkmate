function explore(varargin)

% Explore Tests one or more trajectories from the CheckMate model
%
% Syntax:
%   "explore"
%
%   "explore -vertices"
%
%   "explore -points <matrix-of-points>"
%
% Description:
%   "validate" is used to verify a single trajectory of a CheckMate
%   model.  The trajectory originates from the point specified in the
%   `initial condition` property of the switched continuous system blocks
%   (SCSBs) in the model.
%
%   If the "-vertices" switch is used, several
%   trajectories are verified each one begining from one of the vertices
%   of the composite `initial continuous set (ICS)` specified in the
%   CheckMate model.
%
%   If the option "-points" switch is used, the
%   trajectories starting in the points given in <matrix-of-points> (the points are the columns of the matrix) are  tested.
%
% Implementation:
%   The validation routine is carried out using numerical simulation of
%   the CheckMate model.  The initial point(s) are simulated according to
%   the Simulink simulation properties.  The simulation data is captured
%   in the workspace using a `clock` block and several `to workspace`
%   blocks from Simulink.  A discrete trace is then extracted from the
%   simulation data, and used to verify the ACTL specifiation given in
%   the variable "GLOBAL_SPEC".  Finally, the result of the verification
%   is returned to the user, and the routine terminates.
%
% See Also:
%   verify


% Declare global variables (see the file global_var.m for details)
global GLOBAL_APPROX_PARAM
global GLOBAL_SYSTEM
global GLOBAL_SPEC GLOBAL_SPEC_TOTAL GLOBAL_SPEC_ELEMENT GLOBAL_SPEC_TEMP

GLOBAL_APPROX_PARAM=parameters(1);

if ~ischar(GLOBAL_SYSTEM) || isempty(GLOBAL_SYSTEM)
    error('CheckMate:Explore:WrongSystem', ...
        'The variable GLOBAL_SYSTEM has not been set up properly.')
end

% Default flags
vertices_flag = 0;
%Points flag test added by Jim Kapinski 2/2002
points_flag = 0;


k = 1;
while (k <= length(varargin))
    switch varargin{k}
        case '-vertices'
            vertices_flag = 1;
        case '-points'
            points_flag = 1;
            points=evalin('base',varargin{k+1});
            break
        otherwise
            error('CheckMate:Explore:WrongType', ...
                ['Unknown option ''' varargin{k} '''.'])
    end
    k = k + 1;
end

%If 'explore_temp' is not a directory, then create it.
if ~isdir('explore_temp')
    mkdir('explore_temp');
end

clipboard = unique_sys_name('CheckMate_clipboard');
%clipboard = 'CheckMate_clipboard';
if ~isempty(find_system('SearchDepth',0,'Name',clipboard))
    close_system(clipboard,0)
end

if strcmp(get_param(GLOBAL_SYSTEM,'Dirty'),'on')
    fprintf(1,'Please save the system ''%s'' before running explore.\n', ...
        GLOBAL_SYSTEM)
    return
end
save_system(GLOBAL_SYSTEM,['explore_temp' filesep clipboard]);
close_system(clipboard,1);
%

% copy simulation parameters to command-line sim options
load_system(GLOBAL_SYSTEM);
timespan = [eval(get_param(GLOBAL_SYSTEM,'StartTime')) ...
    eval(get_param(GLOBAL_SYSTEM,'StopTime'))];
simoptions = simget(GLOBAL_SYSTEM);
%Call function that lists states in the FSMBlocks
[state_names,fsm_names] = get_fsm_state_names(GLOBAL_SYSTEM);

close_system(GLOBAL_SYSTEM, 0);

% Save current path and directory
current_path = path;
current_dir = pwd;
addpath(current_dir)

% Change to the explore_temp directory, the Stateflow compilation of the
% clipboard model will be saved here.
temp = what('explore_temp');
cd(temp.path);
load_system(clipboard);
sysinfo = compile_sys_info(clipboard);

% dummy simulation call to update the Stateflow block if necessary
sim(clipboard,[0 1],simoptions);

% Restore path and directory
cd(current_dir)
path(current_path)



spec_count=0;
for i=1:length(state_names)
    if findstr('avoid',state_names{i})
        new=length(GLOBAL_SPEC)+1;
        GLOBAL_SPEC{new}=['(AG ~out_of_bound)&(AG ~' fsm_names{i} ' == ' state_names{i} ')'];
        spec_count=spec_count+1;
    elseif findstr('reach',state_names{i})
        new=length(GLOBAL_SPEC)+1;
        GLOBAL_SPEC{new}=['(AG ~out_of_bound)&(AF ' fsm_names{i} ' == ' state_names{i} ')'];
        spec_count=spec_count+1;
    end

end

GLOBAL_SPEC_TOTAL=GLOBAL_SPEC;
% ------ parse the specification ------
% (i) match parentheses
for count_GS=1:length(GLOBAL_SPEC_TOTAL)

    %Is this an automatically generated CTL expression?
    if count_GS>length(GLOBAL_SPEC_TOTAL)-spec_count
        special_CTL_flag=1;
    else
        special_CTL_flag=0;
    end

    fprintf(1,'\nComputing specification %d of %d in the list ', ...
        count_GS,length(GLOBAL_SPEC_TOTAL));
    GLOBAL_SPEC_ELEMENT=GLOBAL_SPEC_TOTAL{count_GS};
    match_paren(GLOBAL_SPEC_ELEMENT,0);
    % (ii) identify terminal symbols in the ACTL specification string and
    %      parse the symbols to obtain parse tree for the specification
    spec_tree = parse(identerm(GLOBAL_SPEC_ELEMENT));
    % (iii) compile the list of all atomic propositions in the parse tree and
    %       replace all the atomic proposition subtree by a single leaf
    [spec_tree,ap_build_list] = compile_ap(spec_tree);

    fprintf(1,'\nblock orders: ')
    fprintf(1,'x = [');
    for l = 1:length(sysinfo.scsbList)
        fprintf(1,'%s',sysinfo.scsbList{l}.name)
        if (l < length(sysinfo.scsbList))
            fprintf(1,' ')
        end
    end
    fprintf(1,'], ')
    fprintf(1,'q = [');
    for l = 1:length(sysinfo.fsmbList)
        fprintf(1,'%s',sysinfo.fsmbList{l}.name)
        if (l < length(sysinfo.fsmbList))
            fprintf(1,' ')
        end
    end
    fprintf(1,'], ')
    fprintf(1,'pth = [');
    for l = 1:length(sysinfo.pthbList)
        fprintf(1,'%s',sysinfo.pthbList{l}.name)
        if (l < length(sysinfo.pthbList))
            fprintf(1,' ')
        end
    end
    fprintf(1,']\n')

    if vertices_flag
        %Compute the vertices of all polytopes in the initial continuous set
        %and the parameter sets

        validate_vertex(clipboard,sysinfo,spec_tree,ap_build_list, ...
            timespan,simoptions,1,special_CTL_flag);

    elseif points_flag==1
        %User defined set of simulation points added by Jim K 2/2002
        for i=1:size(points,2)
            fprintf(1,'Running simulation with initial condition %d',i)
            init_cond = points(:,i);
            start_idx = 0;
            for j = 1:length(sysinfo.scsbList)
                blkH = sysinfo.scsbList{j}.handle;
                nx = eval(get_param(blkH,'nx'));
                x0 = init_cond(1:nx +start_idx);
                set_param(blkH,'x0',mat2str(x0));
                start_idx = start_idx+nx;
            end
            validate_trajectory(clipboard,sysinfo,spec_tree,ap_build_list, ...
                timespan,simoptions,special_CTL_flag);
        end
    else
        fprintf(1,'init: ')
        validate_trajectory(clipboard,sysinfo,spec_tree,ap_build_list, ...
            timespan,simoptions,special_CTL_flag);
    end
end
close_system(clipboard,0);

GLOBAL_SPEC_TEMP={};
for j=1:length(GLOBAL_SPEC)-spec_count
    GLOBAL_SPEC_TEMP{j}=GLOBAL_SPEC{j};
end
GLOBAL_SPEC=GLOBAL_SPEC_TEMP;
return

% -----------------------------------------------------------------------------
function sysinfo=validate_vertex(clipboard,sysinfo,spec_tree,ap_build_list, ...
    timespan,simoptions,scsb_no,special_CTL_flag)
% Recursive function that either selects new vertices or,
% if the vertices are completely determined, validates the trajectory

if scsb_no<=length(sysinfo.scsbList)
    blokH = sysinfo.scsbList{scsb_no}.handle;
    %get the vertices of the initial set
    ICS=evalin('base',get_param(blokH,'ICS'));
    V0=vertices(ICS{1});

    %get the vertices of the parameter set
    P0=vertices(evalin('base',get_param(blokH,'PaCs')));
    for i=1:length(V0)
        set_param(blokH,'x0',mat2str(V0(i)));
        % if there is no parameter move to the next blok
        if isempty(P0)
            set_param(blokH,'p0','[]');
            sysinfo=validate_vertex(clipboard,sysinfo,spec_tree,ap_build_list, ...
                timespan,simoptions,scsb_no+1,special_CTL_flag);
        else
            for j=1:length(P0)
                set_param(blokH,'p0',mat2str(P0(j)));
                sysinfo=validate_vertex(clipboard,sysinfo,spec_tree,ap_build_list, ...
                    timespan,simoptions,scsb_no+1,special_CTL_flag);
            end
        end
    end
else
    % if for all blocks we determined a vertex validate the trajectory

    fprintf('\nSelect parameters\n')
    for k = 1:length(sysinfo.scsbList)
        blokH = sysinfo.scsbList{k}.handle;
        if ~isempty(eval(get_param(blokH,'p0')))
            fprintf('block %s: \t %s \n',get_param(blokH,'Name'),get_param(blokH,'p0'));
        end
    end
    fprintf('\nSelect vertices\n')
    for k = 1:length(sysinfo.scsbList)
        blokH = sysinfo.scsbList{k}.handle;
        if ~isempty(eval(get_param(blokH,'x0')))
            fprintf('block %s: \t %s \n',get_param(blokH,'Name'),get_param(blokH,'x0'));
        end
    end
    fprintf('\n')
    validate_trajectory(clipboard,sysinfo,spec_tree,ap_build_list, ...
        timespan,simoptions,special_CTL_flag);
end

% -----------------------------------------------------------------------------
function result = validate_trajectory(sys,sysinfo,...
    spec_tree,ap_build_list,timespan,simoptions,special_CTL_flag)

global GLOBAL_AP

% Save current path and directory
current_path = path;
current_dir = pwd;
addpath(current_dir)

% Change to the explore_temp directory, the Stateflow compilation of the
% clipboard model will be saved here.
temp = what('explore_temp');
cd(temp.path);

% Simulate the system and put data in the main workspace
sim(sys,timespan,simoptions,[]);

% Restore path and directory
cd(current_dir)
path(current_path)

% Extract the discrete-trace from  the simulated trajectory, store the chain of
% transitions in GLOBAL_TRANSITION
trace = extract_trace(sysinfo);

% build regions in the transition system GLOBAL_TRANSITION
% for atomic propositions in the build list
GLOBAL_AP = build_trace_ap(ap_build_list,sysinfo,trace);

% compute region in GLOBAL_TRANSITION corresponding to ACTL specification
spec = evaluate(spec_tree);

% Check if the initial state (state 1) satisfies the specification
result = isinregion(spec,1);
if result
    start_idx = 1 + (length(trace) > 1);
    fprintf(1,'t = %s, x = %s, q = %s, pth = %s\n', ...
        mat2str(trace{start_idx}.t),mat2str(trace{start_idx}.x), ...
        mat2str(trace{start_idx}.q),mat2str(trace{start_idx}.pth))
    fprintf(1,'  ---> ... --> %s',trace{length(trace)}.special)
    if special_CTL_flag
        temp=ap_build_list{2}.build_info{3};
        if ~isempty(findstr('avoid',temp))
            avoid_state_name = temp;
            fprintf(1,'\n\nFor initial condition x = %s: The system never enters the state "%s"\n',mat2str(trace{start_idx}.x),avoid_state_name);
        elseif ~isempty(findstr('reach',temp))
            reach_state_name = temp;
            fprintf(1,'\n\nFor initial condition x = %s: The system enters the state "%s".\n',mat2str(trace{start_idx}.x),reach_state_name);
        end
    end

    fprintf(1,' / specification satisfied\n')
else
    if (length(trace) > 1)
        for k = 2:length(trace)
            if k > 2
                fprintf(1,'  --> ');
            end
            fprintf(1,'t = %s, x = %s, q = %s, pth = %s\n', ...
                mat2str(trace{k}.t),mat2str(trace{k}.x), ...
                mat2str(trace{k}.q),mat2str(trace{k}.pth))
        end
        fprintf(1,'  --> %s',trace{length(trace)}.special)
    else
        fprintf(1,'t = %s, x = %s, q = %s, pth = %s\n', ...
            mat2str(trace{1}.t),mat2str(trace{1}.x), ...
            mat2str(trace{1}.q),mat2str(trace{1}.pth))
        fprintf(1,'  warning: init condition outside analysis region')
    end

    if special_CTL_flag
        temp=ap_build_list{2}.build_info{3};
        if ~isempty(findstr('avoid',temp))
            avoid_state_name = temp;
            fprintf(1,'\n\nFor initial condition x = %s: The system enters the state "%s"\nor the system leaves the analysis region.\n',mat2str(trace{1}.x),avoid_state_name);
        elseif ~isempty(findstr('reach',temp))
            reach_state_name = temp;
            fprintf(1,'\n\nFor initial condition x = %s: The system does not enter the state "%s"\nor the system leaves the analysis region.\n',mat2str(trace{1}.x),reach_state_name);
        end
    end

    fprintf(1,' / *** specification failed ***\n');
end

% -----------------------------------------------------------------------------

function sys = unique_sys_name(prefix)

count = 0;
sys = prefix;
while ~isempty(find_system('SearchDepth',0,'Name',sys))
    count = count + 1;
    sys = [prefix num2str(count)];
end
return

%------------------------------------------------------------------------------
function [names,fsm_names] = get_fsm_state_names(sys)

fsmbHandle = find_masked_blocks(sys,'Stateflow');
machine_id = get_machine_id(sys);
names={};
fsm_names={};
for k=1:length(fsmbHandle)
    block_name = get_param(fsmbHandle(k),'Name');
    chart_id = find_chart_id(machine_id,block_name);
    states = sf('find','all','state.chart',chart_id);
    names_temp = sf('get',states,'.name');
    for j=1:size(names_temp,1)
        new=length(names)+1;
        names{new}=deblank(names_temp(j,:));
        fsm_names{new}=block_name;
    end
end

return
% -------------------------------------------------------------------------
% ---

function chart_id = find_chart_id(machine_id,block_name)

possible_id = sf('find','all','chart.machine',machine_id, ...
    'chart.name',block_name);
chart_id = [];
for l = 1:length(possible_id)
    name = sf('get',possible_id(l),'.name');
    if strcmp(name,block_name)
        chart_id = possible_id(l);
        break;
    end
end
return

% ----------------------------------------------------------------------------

function machine_id = get_machine_id(sys)

% the Stateflow function returns all block names whose begining substring
% matches with the name given in sys. thus, we have to make sure that we get
% an exact match.

possible_id = sf('find','all','machine.name',sys);
machine_id = [];
for k = 1:length(possible_id)
    name = sf('get',possible_id(k),'.name');
    if strcmp(name,sys)
        machine_id = possible_id(k);
        break;
    end
end
return