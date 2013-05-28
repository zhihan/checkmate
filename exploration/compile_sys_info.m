function sysinfo = compile_sys_info(sys)

% Compile and/or add system information to be used in the validation
% tool.
%
% Syntax:
%   "sysinfo = compile_sys_info(sys)"
%
% Description:
%   "compile_sys_info(sys)" adds necessary `clock` and `to workspace`
%   blocks to the CheckMate model "sys" and returns pertinent system
%   information in a structure with the following fields.
%
%   * ".clk" structure containing the name, handle, and output variable of
%   the clock block.
%
%   * ".scsbList" structure array containing the name, handle, and output
%   variable of each switched continuous system block (SCSB) in the system
%
%   * ".fsmbList" structure array containing the name, handle, and output
%   variable of each finite state machine block (FSMB) in the system
%
%   * ".pthbList" structure array containing the name, handle, and output
%   variable of each polyhedral threshold block (PTHB) in the system
%
%   * ".AR" composite analysis region (AR) composed from ARs of all SCSBs
%   in the system
%
%   * ".ICS" composite initial continuous (ICS) set composed from ICS of
%   each SCSBs in the system
%
% See Also:
%   validate

% Find a 'Clock' block. Add one if not found.
clk = find_system(sys,'SearchDepth',1,'BlockType','Clock');
if isempty(clk)
  clkname = unique_name(sys,'clock');
  add_block('built-in/Clock',[sys '/' clkname]);
end

% Find Simulink handles for switched continuous system blocks (SCSB),
% finite state machine blocks (FSMB), and polyhedral threshold blocks
% (PTHB) in the CheckMate model.
scsbHandle = find_masked_blocks(sys,'SwitchedContinuousSystem');
fsmbHandle = find_masked_blocks(sys,'Stateflow');
pthbHandle = find_masked_blocks(sys,'PolyhedralThreshold');
% Find the clock block handle.
clk = find_system(sys,'SearchDepth',1,'BlockType','Clock');
clkHandle = get_param(clk{1},'Handle');

clk = check_to_ws(sys,clkHandle);
scsbList = check_to_ws(sys,scsbHandle);
fsmbList = check_to_ws(sys,fsmbHandle);
pthbList = check_to_ws(sys,pthbHandle);

% Compile list of states for each finite state machine block.
machine_id = get_machine_id(sys);
if isempty(machine_id)
  fprintf(1,['\007Error: Cannot find machine id for ''' sys '''!!!\n'])
  return
end
for k = 1:length(fsmbHandle)
  block_name = get_param(fsmbHandle(k),'Name');
  chart_id = find_chart_id(machine_id,block_name);
  if isempty(chart_id)
    error('CheckMate:CannotFindChart', ['Cannot find chart id for ''' block_name '''.'])
    return
  end
  state_id = sf('find','all','state.chart',chart_id);
  if isempty(state_id)
    error('CheckMate:CannotFindState',['No state found for FSM block ''' block_name '''.'])
  end
  parent_chart = sf('get',state_id(1),'.chart');
  transitionsAll = sf('get',parent_chart,'.transitions');
  states = {};
  for l = 1:length(state_id)
    state_number = get_state_number(state_id(l));
    states{state_number}.name = sf('get',state_id(l),'.name');
    transitions = sf('find',transitionsAll,'.src.id',state_id(l));
    states{state_number}.terminal = isempty(transitions);
  end
  fsmbList{k}.states = states;
end

sysinfo = {};
sysinfo.clk = clk;
sysinfo.scsbList = scsbList;
sysinfo.fsmbList = fsmbList;
sysinfo.pthbList = pthbList;
sysinfo.AR = get_analysis_region(scsbHandle);
sysinfo.ICS = get_initial_continuous_set(scsbHandle);

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

% ----------------------------------------------------------------------------

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

function state_number = get_state_number(state_id)

% We assume the label strings in the Stateflow diagram have the following 
% format.
%
%      <state_name>
%      entry: <output_variable> = <state_number>;
%

labelString = sf('get',state_id,'.labelString');
% Skip all the white spaces at the end.
k = length(labelString);
while (k >= 1) && (isspace(labelString(k)) || (labelString(k) == ';'))
  k = k - 1;
end
% Search backwards until a non-numeric character is found.
labelString = labelString(1:k);
while (k >= 1) && (labelString(k) >= '0') && (labelString(k) <= '9')
  k = k - 1;
end
labelString = labelString(k+1:length(labelString));
state_number = str2double(labelString);
return

% -----------------------------------------------------------------------------

function list = check_to_ws(sys,blkHandle)

for k = 1:length(blkHandle)
  dstk = find_dst_port(blkHandle(k),'1');
  list{k}.handle = blkHandle(k);
  list{k}.name = get_param(blkHandle(k),'Name');
  found = 0;
  for l = 1:length(dstk)
    blocktype = get_param(dstk{l}.block,'BlockType');
    if strcmp(blocktype,'ToWorkspace')
      list{k}.variable = get_param(dstk{l}.block,'VariableName');
      found = 1;
      break;
    end
  end
  if ~found
    % Add 'To Workspace' to capture the output of each block as needed 
    block_name = get_param(blkHandle(k),'Name');
    block_pos = get_param(blkHandle(k),'Position');
    width = 7*(length(block_name)+4);
    height = 20;
    xoffset = 1.2*(block_pos(3)-block_pos(1)) + 20;
    yoffset = -1.2*height;
    anchor = block_pos(1:2) + [xoffset yoffset];
    block_pos = [anchor anchor+[width height]];
    towsname = unique_name(sys,'To Workspace');
    add_block('built-in/To Workspace',[sys '/' towsname], ...
              'Position',block_pos,'VariableName',[block_name '_out'], ...
              'MaxDataPoints','inf');
    add_line(sys,[block_name '/1'],[towsname '/1'])
    list{k}.variable = [block_name '_out'];
  end
end

return

% -----------------------------------------------------------------------------

function name = unique_name(sys,prefix)

name = prefix;
count = 0;
while ~isempty(find_system(sys,'SearchDepth',1,'Name',name))
  count = count + 1;
  name = [prefix num2str(count)];
end
return
