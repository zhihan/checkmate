function [state_name,state_number] = get_fsm_state(block_name,q)

% Get the FSM state for the specified FSMB given the composite FSM state
% vector.
%
% Syntax:
%   "[state_name,state_number] = get_fsm_state(block_name,q)"
%
% Description:
%   Given the composite FSM state vector "q", find the active state name and
%   the state number for the FSMB specified by "block_name". The state
%   name is returned in the string "state_name" and the state number is
%   returned in the integer "state_number".
% 
% See Also:
%   piha

global GLOBAL_PIHA

FSMBlocks = GLOBAL_PIHA.FSMBlocks;

found = 0;
for k = 1:length(FSMBlocks)
  if strcmp(FSMBlocks{k}.name,block_name)
    found = 1;
    state_number = q(k);
    state_name = FSMBlocks{k}.states{q(k)};
    break;
  end
end

if ~found
  error(['Invalid FSM block name ''' block_name '''.'])
end
return
