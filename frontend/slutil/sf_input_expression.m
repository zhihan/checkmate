function [expression,clock] = sf_input_expression(sfblk,iptype,ipidx)

% Compute the logical expression for the specified input to a Stateflow block
%
% Syntax:
%   "expression = sf_input_expression(sfblk,iptype,ipidx,sf_list,pth_list)"
%
% Description:
%   "sf_input_expression(sfblk,iptype,ipidx,sf_list,pth_list)" returns a
%   logical expression for input number "ipidx" of type "iptype" to
%   Stateflow block "sfblk".  "sf_list" and "pth_list" are respective
%   lists of finite state machine (FSMBs) and polyhedral threshold
%   (PTHBs) blocks in the system.
%
% See Also:
%   block_logic

% Inputs:
%   sfblk    - Stateflow block
%   iptype   - type of input 'event' or 'data'
%   ipidx    - index of the input
%   sf_list  - global list of Stateflow blocks in the system
%   pth_list - global list of PolyhedralThreshold blocks in the system
% Output:
%   expression - logical expression for the specified input containing 
%                containing the names of FSMBs and PTHBs as atomic variables.

clock=[];
expression=[];
switch iptype
case 'data',
  dstport = num2str(ipidx);
  dstblk = get_param(sfblk,'Handle');
  src = find_src_port(dstblk,dstport);
  input_block = src.block;
case 'event',
  % We assume that the output of each block non-mux block found  
  % when we trace backward from the 'trigger' port of the stateflow block 
  % has only one output and the output must be a logical signal.
  event_input_blks = trace_mux_network(sfblk,'trigger');
  input_block = event_input_blks(ipidx);
  type=get_param(input_block,'BlockType');
  otherwise
  error('unknown input type.')
end

type=get_param(input_block,'BlockType');
if strcmp(type,'SubSystem')&strcmp(get_param(input_block,'MaskType'),'VariableZeroOrderHold')
   clock=input_block;
else
   expression = block_logic(input_block,iptype);
end

   
return

