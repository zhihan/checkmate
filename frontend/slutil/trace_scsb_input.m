function fsmbH = trace_scsb_input(scsbH,port)

% Find handles and order of finite state machine blocks (FSMBs)
% connected to a switched continuous system block (SCSB)
%
% Syntax:
%   "fsmbH = trace_scsb_input(scsbH,portID)"
%
% Description:
%   "trace_scsb_input(scsbH,portID)" returns an ordered list of the FSMBs
%   connected to the input port "port" of the SCSB with handle "scsbH".
%   portID can have two values: 'input' for the discrete input port and
%   'reset' for the reset port.
%
% Output: A vector of handles for FSMBs in the order that they connect to the
%         input of scsbH
%
% See Also:
%   trace_mux_network,trace_pthb_input
 
% Last changed by Ansgar 09/16/2002

% Check to make sure that the specified block is an SCSB.
if ~(strcmp(get_param(scsbH,'BlockType'),'S-Function') & ...
     strcmp(get_param(scsbH,'MaskType'),'SwitchedContinuousSystem'))
  error('Input block must be a switched continuous system block.')
end

% Determine the port ID for the specified SCSB input port.
switch port
 case 'input'
  portID = '1';
 case 'reset'
  portID = '2';
 otherwise
  error(['Unknown SCSB port ''' port '''.'])
end

% Trace back, possibly through a mux network, to find all FSMBs connected
% to the specified SCSB input port.
fsmbH = trace_mux_network(scsbH,portID);

% Check to make sure that each block in the search result is an FSMB.
for k = 1:length(fsmbH)
  if ~(strcmp(get(fsmbH(k),'BlockType'),'SubSystem'))
    msg = ['Invalid block "' get(fsmbH(k),'Name') ...
           '" connected to switched continuous system block "' ...
           get_param(scsbH,'Name') '".'];
    error(msg)
  end
end

% For the reset port, make sure that exactly one FSMB is connected to the
% reset port of the SCSB. Note that the case where some block is connected
% but none is an FSMB would have been caught by the above error
% checking. Also, the case where no block is connected to the reset port at
% all would have been caught by trace_mux_network(). Thus, the only possible
% error, if any, is that more than one FSMB is connected to the reset port
% of the SCSB.
if strcmp(port,'reset') & (length(fsmbH) ~= 1)
  msg = ['Found more than one FSMB connected to reset port of SCSB "' ...
         get_param(scsbH,'Name') '".'];
  error(msg)
  return
end

return
